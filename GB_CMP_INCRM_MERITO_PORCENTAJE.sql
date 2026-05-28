/******************************************************************************
* FORMULA NAME      : GB_CMP_INCRM_MERITO_PORCENTAJE                     *
* FORMULA TYPE      : Compensation Default and Override                       *
* DESCRIPTION       : Obtiene el porcentaje promedio de incremento por merito *
*                     desde UDT GB_INCREMENTO_MERITO para R4 (Espana,         *
*                     Portugal, Marruecos). Key derivada del Legal Employer.  *
*-----------------------------------------------------------------------------*
* CREATED BY        : IT-GLOBAL                                               *
* CREATION DATE     : 08-Mayo-2026                                            *
* LAST UPDATE DATE  : 27-Mayo-2026                                            *
*-----------------------------------------------------------------------------*
* Change History:                                                             *
* Author          | Date            | Ver | Comments                          *
*-----------------+-----------------+-----+-----------------------------------*
* IT Global       | 08-Mayo-2026    |  1  | Version Inicial                   *
* IT Global       | 27-Mayo-2026    |  2  | Adaptacion R4: key por pais       *
*                 |                 |     | MOR/ESP/PT desde Legal Employer,  *
*                 |                 |     | correccion nombre UDT             *
******************************************************************************/

INPUTS ARE CMP_IV_PLAN_START_DATE (text),
CMP_IV_PLAN_END_DATE (text),
CMP_IVR_ASSIGNMENT_ID(NUMBER_NUMBER),
CMP_IV_PLAN_EXTRACTION_DATE (text)

DEFAULT FOR PER_ASG_ORG_LEGAL_EMPLOYER_NAME IS 'N/LE'

/*============================================================================
  FECHAS BASE
============================================================================*/
HR_EXTRACT_DATE = TO_DATE(CMP_IV_PLAN_EXTRACTION_DATE, 'YYYY/MM/DD')

l_log = SET_LOG('*** INICIO GB_CMP_INCRM_MERITO_PORCENTAJE_R4 ***')

/*============================================================================
  LEGAL EMPLOYER Y KEY UDT POR PAIS
============================================================================*/
CHANGE_CONTEXTS(EFFECTIVE_DATE = HR_EXTRACT_DATE)
(
    L_LEGAL_EMPLOYER = PER_ASG_ORG_LEGAL_EMPLOYER_NAME
)

l_log = SET_LOG('Legal Employer: ' || L_LEGAL_EMPLOYER)

IF L_LEGAL_EMPLOYER = 'Bimbo Morocco, S.A.R.L.A.U.' THEN
    L_KEY_PAIS = 'MOR'
ELSE IF L_LEGAL_EMPLOYER = 'Bimbo Donuts Portugal, LDA' THEN
    L_KEY_PAIS = 'PT'
ELSE
    L_KEY_PAIS = 'ESP'

l_log = SET_LOG('Key pais UDT: ' || L_KEY_PAIS)

/*============================================================================
  PROMEDIO UDT
============================================================================*/
L_UDT_PROM = TO_NUMBER(GET_TABLE_VALUE('GB_INCREMENTO_MERITO', 'Incremento_Promedio', L_KEY_PAIS))

l_log = SET_LOG('Promedio UDT: ' || TO_CHAR(L_UDT_PROM))

/*============================================================================
  RESULTADO
============================================================================*/
l_log = SET_LOG('*** RESULTADO PROMEDIO UDT: ' || TO_CHAR(L_UDT_PROM) || ' ***')
RETURN L_UDT_PROM