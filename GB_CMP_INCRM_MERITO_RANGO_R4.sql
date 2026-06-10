/******************************************************************************
* FORMULA NAME      : GB_CMP_INCRM_MERITO_RANGO_R4                            *
* FORMULA TYPE      : Compensation Default and Override                       *
* DESCRIPTION       : Obtiene el texto del rango de incremento por merito     *
*                     para R4 (Espana, Portugal, Marruecos) leyendo desde     *
*                     UDT por idioma: GB_CMP_ES_PT_RANGOS_MERITO o            *
*                     GB_CMP_MAR_RANGOS_MERITO. Key por pais derivada del     *
*                     Legal Employer. Deteccion de Promotion por recorrido    *
*                     historico de PER_ASG_JOB_MANAGER_LEVEL en ventana       *
*                     de 5 meses previa al fin del plan.                      *
*-----------------------------------------------------------------------------*
* CREATED BY        : IT-GLOBAL                                               *
* CREATION DATE     : 07-Abril-2026                                           *
* LAST UPDATE DATE  : 28-Mayo-2026                                            *
*-----------------------------------------------------------------------------*
* Change History:                                                             *
* Author          | Date            | Ver | Comments                          *
*-----------------+-----------------+-----+-----------------------------------*
* IT Global       | 15-Abril-2026   |  1  | Version Inicial                   *
* IT Global       | 21-Abril-2026   |  2  | Reestructura dinamica UDT         *
* IT Global       | 14-Mayo-2026    |  3  | Replica logica retrofit promotion *
*                 |                 |     | por recorrido historico de nivel  *
* IT Global       | 27-Mayo-2026    |  4  | Adaptacion R4: key por pais       *
*                 |                 |     | MOR/ESP/PT desde Legal Employer,  *
*                 |                 |     | correccion UDT calificac por      *
*                 |                 |     | idioma, fix tab en WithoutEval    *
* IT Global       | 28-Mayo-2026    |  5  | Correccion UDT rangos por idioma: *
*                 |                 |     | GB_CMP_ES_PT_RANGOS_MERITO y      *
*                 |                 |     | GB_CMP_MAR_RANGOS_MERITO;         *
*                 |                 |     | correccion UDT calificac ES_PT    *
*                 |                 |     | a GB_CMP_ES_PT_CALIFICAC_MERITO   *
******************************************************************************/

INPUTS ARE CMP_IV_PLAN_START_DATE (text),
CMP_IV_PLAN_END_DATE (text),
CMP_IVR_ASSIGNMENT_ID(NUMBER_NUMBER),
CMP_IV_PLAN_EXTRACTION_DATE (text)

/*============================================================================
  DEFAULTS
============================================================================*/
DEFAULT_DATA_VALUE FOR CMP_EXTERNAL_WORKER_DATA_RGE_ASG_VALUE1 IS 'N/A'
DEFAULT_DATA_VALUE FOR CMP_EXTERNAL_WORKER_DATA_RGE_ASG_SEQUENCE_NUMBER IS 0
DEFAULT_DATA_VALUE FOR CMP_EXTERNAL_WORKER_DATA_RGE_ASG_ASSIGNMENT_ID IS 0
DEFAULT_DATA_VALUE FOR CMP_EXTERNAL_WORKER_DATA_RGE_ASG_VALUE2 IS 'N/A'
DEFAULT FOR PER_ASG_ATTRIBUTE1 IS 'PERMANENTE'
DEFAULT FOR PER_ASG_ACTION_CODE IS 'N/A'
DEFAULT FOR PER_ASG_EFFECTIVE_START_DATE IS '1900/01/01' (date)
DEFAULT FOR PER_ASG_EFFECTIVE_END_DATE IS '4712/12/31' (date)
DEFAULT FOR PER_ASG_JOB_MANAGER_LEVEL IS 'NA'
DEFAULT FOR PER_ASG_GRADE_ID IS 123
DEFAULT FOR PER_ASG_PERSON_ID IS 0
DEFAULT FOR CMP_ASSIGNMENT_SALARY_AMOUNT IS 0
DEFAULT FOR PER_ASG_ORG_LEGAL_EMPLOYER_NAME IS 'N/LE'
DEFAULT FOR PER_ASG_DATE_START IS '1900/01/01' (date)

/*============================================================================
  FECHAS BASE
============================================================================*/
HR_EXTRACT_DATE = TO_DATE(CMP_IV_PLAN_EXTRACTION_DATE, 'YYYY/MM/DD')
L_PL_END_DATE   = TO_DATE(CMP_IV_PLAN_END_DATE, 'YYYY/MM/DD')

l_log = SET_LOG('*** INICIO GB_CMP_INCRM_MERITO_RANGO_R4 ***')
L_ASG_ID = CMP_IVR_ASSIGNMENT_ID[1]
l_log = SET_LOG('Assignment ID: ' || TO_CHAR(L_ASG_ID))

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
  PROMEDIO POR PAIS
============================================================================*/
L_PROM = TO_NUMBER(GET_TABLE_VALUE('GB_INCREMENTO_MERITO', 'Incremento_Promedio', L_KEY_PAIS))
l_log = SET_LOG('Promedio: ' || TO_CHAR(L_PROM))

/*============================================================================
  EVALUACION
============================================================================*/
L_EVAL_TXT    = 'N/A'
L_EVAL_MAPPED = 'N/A'
L_IDX         = 0

CHANGE_CONTEXTS(EFFECTIVE_DATE = HR_EXTRACT_DATE, COMPENSATION_RECORD_TYPE = 'CMP_MERITO')
(
    L_IDX = CMP_EXTERNAL_WORKER_DATA_RGE_ASG_SEQUENCE_NUMBER.LAST(-1)
    WHILE L_IDX >= 1 LOOP
    (
        L_EXT_VAL = CMP_EXTERNAL_WORKER_DATA_RGE_ASG_VALUE1[L_IDX]
        IF L_EXT_VAL != 'N/A' THEN
        (
            IF L_KEY_PAIS = 'MOR' THEN
                L_EVAL_MAPPED = GET_TABLE_VALUE('GB_CMP_MAR_CALIFICAC_MERITO', 'Calificacion_Texto', L_EXT_VAL)
            ELSE
                L_EVAL_MAPPED = GET_TABLE_VALUE('GB_CMP_CALIFICAC_MERITO', 'Calificacion_Texto', L_EXT_VAL)

            IF L_EVAL_MAPPED != 'N/A' THEN
            (
                L_EVAL_TXT = L_EVAL_MAPPED
                L_IDX = 0
            )
            ELSE
                L_IDX = L_IDX - 1
        )
        ELSE
            L_IDX = L_IDX - 1
    )
)
l_log = SET_LOG('Evaluacion: ' || L_EVAL_TXT)

/*============================================================================
  DATOS DEL ASSIGNMENT
============================================================================*/
CHANGE_CONTEXTS(EFFECTIVE_DATE = HR_EXTRACT_DATE)
(
    L_TIPO_CONTRATO    = PER_ASG_ATTRIBUTE1
    L_ACTION           = PER_ASG_ACTION_CODE
    L_HIRE_DATE        = PER_ASG_EFFECTIVE_START_DATE
    L_GRADE            = PER_ASG_GRADE_ID
    L_SUELDO           = CMP_ASSIGNMENT_SALARY_AMOUNT
    L_PER_ID           = PER_ASG_PERSON_ID
    MGR_LVL            = PER_ASG_JOB_MANAGER_LEVEL
    ASSIGN_START_DATE  = PER_ASG_EFFECTIVE_START_DATE
    ASSIGN_END_DATE    = PER_ASG_EFFECTIVE_END_DATE
)

l_log = SET_LOG('Tipo contrato: ' || L_TIPO_CONTRATO)
l_log = SET_LOG('Action code: '   || L_ACTION)
l_log = SET_LOG('Hire Date: '     || TO_CHAR(L_HIRE_DATE, 'YYYY/MM/DD'))
l_log = SET_LOG('Grade ID: '      || TO_CHAR(L_GRADE))
l_log = SET_LOG('Sueldo: '        || TO_CHAR(L_SUELDO))
l_log = SET_LOG('Manager Level actual: ' || MGR_LVL)

/*============================================================================
  CALCULO APERTURA
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

l_log = SET_LOG('Min plan: ' || TO_CHAR(L_MIN))
l_log = SET_LOG('Max plan: ' || TO_CHAR(L_MAX))

IF L_MAX = L_MIN THEN
    L_APERTURA = 0
ELSE
(
    L_VALOR_PUNTO = (L_MAX - L_MIN) / 30
    L_APERTURA    = ((L_SUELDO - L_MIN) / L_VALOR_PUNTO) + 70
)
l_log = SET_LOG('Apertura calculada: ' || TO_CHAR(L_APERTURA))

/*============================================================================
  DETECCION DE PROMOCION POR RETROFIT
============================================================================*/
PROMOTION_START_DATE = ADD_MONTHS(L_PL_END_DATE, -5)
PROMOTION_END_DATE   = HR_EXTRACT_DATE

l_log = SET_LOG('Promotion Start Date: ' || TO_CHAR(PROMOTION_START_DATE, 'YYYY/MM/DD'))
l_log = SET_LOG('Promotion End Date: '   || TO_CHAR(PROMOTION_END_DATE,   'YYYY/MM/DD'))

LEVEL1       = 'NA'
PRIOR_LEVEL  = 'NA'
LEVEL_CHANGE = 'N'
PRO          = 'N'
L_COUNT      = 0

IF ASSIGN_START_DATE >= PROMOTION_START_DATE AND ASSIGN_START_DATE <= PROMOTION_END_DATE THEN
(
    WHILE L_COUNT <= 10 LOOP
    (
        L_COUNT = L_COUNT + 1
        PRIOR_ASSIGN_START_DATE = ADD_DAYS(ASSIGN_START_DATE, -1)

        IF ASSIGN_END_DATE > PROMOTION_START_DATE THEN
        (
            CHANGE_CONTEXTS(EFFECTIVE_DATE = PRIOR_ASSIGN_START_DATE)
            (
                PRIOR_ASSIGN_START_DATE = PER_ASG_EFFECTIVE_START_DATE
                PRIOR_ASSIGN_END_DATE   = PER_ASG_EFFECTIVE_END_DATE
                PRIOR_LEVEL             = PER_ASG_JOB_MANAGER_LEVEL

                IF PRIOR_LEVEL != 'NA' AND PRIOR_LEVEL = MGR_LVL THEN
                (
                    ASSIGN_START_DATE = PRIOR_ASSIGN_START_DATE
                )
                ELSE
                (
                    IF PRIOR_ASSIGN_END_DATE < PROMOTION_START_DATE THEN
                    (
                        ASSIGN_START_DATE = PRIOR_ASSIGN_START_DATE
                    )
                    ELSE
                    (
                        LEVEL1  = PRIOR_LEVEL
                        L_COUNT = 11
                    )
                )
            )
        )
    )
)

IF LEVEL1 != 'NA' AND MGR_LVL != 'NA' THEN
(
    IF TO_NUMBER(MGR_LVL) > TO_NUMBER(LEVEL1) THEN
        LEVEL_CHANGE = 'Y'
)

IF LEVEL_CHANGE = 'Y' THEN
    PRO = 'PRO'

l_log = SET_LOG('Level previo (LEVEL1): ' || LEVEL1)
l_log = SET_LOG('Level change: '          || LEVEL_CHANGE)
l_log = SET_LOG('PRO flag: '              || PRO)

/*============================================================================
  CONDICION
============================================================================*/
L_CINCO_MESES = ADD_MONTHS(L_PL_END_DATE, -5)

IF PRO = 'PRO' THEN
    L_CONDICION = 'Promotion'
ELSE IF L_HIRE_DATE >= L_CINCO_MESES AND (L_ACTION = 'HIRE' OR L_ACTION = 'ADD_ASSIGN') THEN
    L_CONDICION = 'NewHire'
ELSE IF L_TIPO_CONTRATO = '2' THEN
    L_CONDICION = 'NonPerm'
ELSE
    L_CONDICION = 'None'

l_log = SET_LOG('Condicion: ' || L_CONDICION)

/*============================================================================
  CONSTRUCCION DE CLAVE UDT
============================================================================*/
IF L_CONDICION = 'Promotion' THEN
    L_CLAVE = 'Promotion'
ELSE IF L_CONDICION = 'NonPerm' THEN
    L_CLAVE = 'NonPerm'
ELSE IF L_CONDICION = 'NewHire' THEN
    L_CLAVE = 'NewHire'
ELSE IF L_EVAL_TXT = 'N/A' THEN
    L_CLAVE = 'WithoutEval'
ELSE IF L_EVAL_TXT = 'Exit' THEN
    L_CLAVE = 'Exit'
ELSE IF L_EVAL_TXT = 'Needs Improvement' AND L_KEY_PAIS != 'MOR' THEN
    L_CLAVE = 'Needs Improvement'
ELSE IF L_EVAL_TXT = 'Below Expectations' AND L_KEY_PAIS != 'MOR' THEN
    L_CLAVE = 'Below Expectations'
ELSE IF L_APERTURA <= 100 THEN
    L_CLAVE = L_EVAL_TXT || '_LT100'
ELSE
    L_CLAVE = L_EVAL_TXT || '_GE100'

l_log = SET_LOG('Clave UDT: ' || L_CLAVE)

/*============================================================================
  LECTURA UDT POR IDIOMA
============================================================================*/
IF L_KEY_PAIS = 'MOR' THEN
    L_RANGO_OUTPUT = GET_TABLE_VALUE('GB_CMP_MAR_RANGOS_MERITO_V2', 'Text_Range', L_CLAVE)
ELSE
    L_RANGO_OUTPUT = GET_TABLE_VALUE('GB_CMP_RANGOS_MERITO', 'Texto_Rango', L_CLAVE)

l_log = SET_LOG('*** RESULTADO RANGO: ' || L_RANGO_OUTPUT || ' ***')
RETURN L_RANGO_OUTPUT