/******************************************************************************
* FORMULA NAME      : GB_CMP_APERTURA_R1                                      *
* FORMULA TYPE      : Compensation Default and Override                       *
* DESCRIPTION       : Calcula la apertura del colaborador para Region 4.      *
*                     ESP y PT: sueldo anual dividido entre 365.              *
*                     MOR: sueldo diario dividido entre 30.                   *
* Formula: ((Sueldo - Min) / ((Max - Min) / 30)) + 70                         *
*-----------------------------------------------------------------------------*
* CREATED BY        : IT-GLOBAL                                               *
* CREATION DATE     : 10-Abril-2026                                           *
* LAST UPDATE DATE  : 23-Junio-2026                                           *
*-----------------------------------------------------------------------------*
* Change History:                                                             *
* Author          | Date            | Ver | Comments                          *
*-----------------+-----------------+-----+-----------------------------------*
* IT Global       | 10-Abril-2026   |  1  | Version Inicial                  *
* IT Global       | 23-Junio-2026   |  2  | Divisor por periodicidad: 365    *
*                 |                 |     | para ESP/PT, 30 para MOR         *
******************************************************************************/

INPUTS ARE CMP_IV_PLAN_EXTRACTION_DATE (text)

DEFAULT FOR CMP_IV_PLAN_EXTRACTION_DATE IS '4012/01/01'
DEFAULT FOR PER_ASG_GRADE_ID IS 123
DEFAULT FOR PER_ASG_PERSON_ID IS 0
DEFAULT FOR CMP_ASSIGNMENT_SALARY_AMOUNT IS 0
DEFAULT FOR PER_ASG_ORG_LEGAL_EMPLOYER_NAME IS 'N/LE'

HR_EXTRACT_DATE = TO_DATE(CMP_IV_PLAN_EXTRACTION_DATE, 'YYYY/MM/DD')

l_log = SET_LOG('*** INICIO GB_CMP_APERTURA_R4 ***')

/*============================================================================
  LEGAL EMPLOYER Y PERIODICIDAD
============================================================================*/
CHANGE_CONTEXTS(EFFECTIVE_DATE = HR_EXTRACT_DATE)
(
    L_LEGAL_EMPLOYER = PER_ASG_ORG_LEGAL_EMPLOYER_NAME
    L_GRADE          = PER_ASG_GRADE_ID
    L_SUELDO         = CMP_ASSIGNMENT_SALARY_AMOUNT
    L_PER_ID         = PER_ASG_PERSON_ID
)

l_log = SET_LOG('Legal Employer: ' || L_LEGAL_EMPLOYER)
l_log = SET_LOG('Grade ID: '       || TO_CHAR(L_GRADE))
l_log = SET_LOG('Sueldo: '         || TO_CHAR(L_SUELDO))

IF L_LEGAL_EMPLOYER = 'Bimbo Morocco, S.A.R.L.A.U.' THEN
    L_DIVISOR = 30
ELSE
    L_DIVISOR = 365

l_log = SET_LOG('Divisor periodicidad: ' || TO_CHAR(L_DIVISOR))

/*============================================================================
  OBTENER MIN Y MAX
============================================================================*/
L_PARAM_PER = '|=PERSON_ID=' || TO_CHAR(L_PER_ID)
L_RATE_ID   = TO_NUM(GET_VALUE_SET('GB_CMP_ASG_RATE_ID', L_PARAM_PER))

l_log = SET_LOG('Rate ID: ' || TO_CHAR(L_RATE_ID))

IF L_RATE_ID > 0 THEN
(
    L_PARAM_MIN = '|=P_ASSIGNMENT_RATE=' || TO_CHAR(L_RATE_ID) || '|P_ASSIGNMENT_GRADE=' || TO_CHAR(L_GRADE)
    L_PARAM_MAX = '|=P_ASSIGNMENT_GRADE=' || TO_CHAR(L_GRADE)  || '|P_ASSIGNMENT_RATE='  || TO_CHAR(L_RATE_ID)
    L_MIN = TO_NUM(GET_VALUE_SET('GB_CMP_RATE_ID_VALUE_MIN', L_PARAM_MIN))
    L_MAX = TO_NUM(GET_VALUE_SET('GB_CMP_RATE_ID_VALUE_MAX', L_PARAM_MAX))
)
ELSE
(
    L_PARAM_GRADE = '|=P_ASSIGNMENT_GRADE=' || TO_CHAR(L_GRADE)
    L_MIN = TO_NUM(GET_VALUE_SET('GB_CMP_RATE_VALUE_MIN', L_PARAM_GRADE))
    L_MAX = TO_NUM(GET_VALUE_SET('GB_CMP_RATE_VALUE_MAX', L_PARAM_GRADE))
)

l_log = SET_LOG('Min: ' || TO_CHAR(L_MIN))
l_log = SET_LOG('Max: ' || TO_CHAR(L_MAX))

/*============================================================================
  CALCULO APERTURA
============================================================================*/
IF L_MAX = L_MIN THEN
(
    l_log = SET_LOG('Max igual a Min, retorna 0')
    L_DEFAULT_VALUE = 0
    RETURN L_DEFAULT_VALUE
)

L_VALOR_PUNTO = (L_MAX - L_MIN) / L_DIVISOR
L_APERTURA    = ((L_SUELDO - L_MIN) / L_VALOR_PUNTO) + 70

l_log = SET_LOG('Valor del Punto: ' || TO_CHAR(L_VALOR_PUNTO))
l_log = SET_LOG('*** RESULTADO APERTURA: ' || TO_CHAR(L_APERTURA) || ' ***')

L_DEFAULT_VALUE = L_APERTURA
RETURN L_DEFAULT_VALUE