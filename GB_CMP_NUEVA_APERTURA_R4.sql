/*****************************************************************************
FORMULA NAME: GB_CMP_NUEVA_APERTURA_R4
CREATED_BY : IT-GLOBAL
CREATION_DATE : 23 de Junio del 2026
LAST_UPDATE_DATE : 14 de Julio del 2026
FORMULA TYPE : Compensation Default and Override
DESCRIPTION : Calcula la Nueva Apertura del colaborador para Region 4 (EMEA)
              considerando el Nuevo Minimo y Nuevo Maximo (Min/Max actuales +
              Incremento Plan Salarial ESP/PT/MOR) y el Nuevo Sueldo asignado
              en la hoja de trabajo.
              Formula: ((Nuevo Sueldo - Nuevo Minimo) / Nuevo Valor del Punto) + 70
              MOR: divisor 30 (sueldo diario). ESP y PT: divisor 365 (sueldo anual).
-----------------------------------------------------------------------------
Change History:
Author          | Date            | Ver | Comments
-----------------+-----------------+-----+-----------------------------------
IT Global       | 23-Junio-2026   |  1  | Version Inicial (Apertura actual,
                 |                 |     | sin Nuevo Minimo/Maximo)
IT Global       | 14-Julio-2026   |  2  | Se agrega calculo de Nueva Apertura
                 |                 |     | con Incremento Plan Salarial via UDT
                 |                 |     | GB_CMP_INC_PLAN_SALARIAL. Uso de
                 |                 |     | L_CTX_ASG via GET_CONTEXT
                 |                 |     | (HR_ASSIGNMENT_ID,-1) en params de
                 |                 |     | Value Set. Pais unificado via
                 |                 |     | PER_ASG_LEGISLATION_CODE.
IT Global       | 14-Julio-2026   |  3  | Correccion: Nuevo Valor del Punto se
                 |                 |     | calcula con Nuevo Maximo (Max actual
                 |                 |     | + Incremento Plan Salarial), no con
                 |                 |     | el Maximo actual sin ajustar.
*****************************************************************************/
INPUTS ARE CMP_IV_PLAN_EXTRACTION_DATE (text),
CMP_IVR_ASSIGNMENT_ID (NUMBER_NUMBER)

DEFAULT FOR CMP_IV_PLAN_EXTRACTION_DATE IS '4012/01/01'
DEFAULT FOR PER_ASG_GRADE_ID IS 123
DEFAULT FOR PER_ASG_PERSON_ID IS 0
DEFAULT FOR CMP_ASSIGNMENT_SALARY_AMOUNT IS 0
DEFAULT FOR PER_ASG_LEGISLATION_CODE IS 'N/A'

HR_EXTRACT_DATE = TO_DATE(CMP_IV_PLAN_EXTRACTION_DATE, 'YYYY/MM/DD')

l_log = SET_LOG('*** INICIO GB_CMP_NUEVA_APERTURA_R4 ***')

L_ASG_ID = CMP_IVR_ASSIGNMENT_ID[1]
l_log = SET_LOG('Assignment ID segun input CMP_IVR: ' || TO_CHAR(L_ASG_ID))

/*============================================================================
  GRADE, PERSON, LEGISLATION, NUEVO SUELDO Y CONTEXTO REAL DE ASSIGNMENT
============================================================================*/
CHANGE_CONTEXTS(EFFECTIVE_DATE = HR_EXTRACT_DATE)
(
    L_GRADE        = PER_ASG_GRADE_ID
    L_PER_ID       = PER_ASG_PERSON_ID
    L_NUEVO_SUELDO = CMP_ASSIGNMENT_SALARY_AMOUNT
    L_LEGISLATION  = PER_ASG_LEGISLATION_CODE
    L_CTX_ASG      = GET_CONTEXT(HR_ASSIGNMENT_ID, -1)
)

l_log = SET_LOG('Legislation Code: ' || L_LEGISLATION)
l_log = SET_LOG('Grade ID: ' || TO_CHAR(L_GRADE))
l_log = SET_LOG('Nuevo Sueldo: ' || TO_CHAR(L_NUEVO_SUELDO))
l_log = SET_LOG('Assignment ID segun contexto interno (HR_ASSIGNMENT_ID): ' || TO_CHAR(L_CTX_ASG))

/*============================================================================
  MAPEO PAIS: LEGISLATION_CODE -> CLAVE UDT GB_CMP_INC_PLAN_SALARIAL
  MISMO VALOR SE USA PARA DIVISOR. PENDIENTE VALIDAR codigos reales del DBI
============================================================================*/
IF L_LEGISLATION = 'MA' THEN
    L_PAIS_UDT = 'MOR'
ELSE IF L_LEGISLATION = 'PT' THEN
    L_PAIS_UDT = 'PT'
ELSE IF L_LEGISLATION = 'ES' THEN
    L_PAIS_UDT = 'ESP'
ELSE
    L_PAIS_UDT = L_LEGISLATION

l_log = SET_LOG('Pais UDT: ' || L_PAIS_UDT)


L_DIVISOR = 30

l_log = SET_LOG('Divisor periodicidad: ' || TO_CHAR(L_DIVISOR))

/*============================================================================
  OBTENER MIN Y MAX ACTUALES (Rate/Grade) - PARAMS CON L_CTX_ASG
============================================================================*/
L_PARAM_PER = '|=PERSON_ID=' || TO_CHAR(L_PER_ID) || '|P_ASSIGNMENT_ID=' || TO_CHAR(L_CTX_ASG) || '|P_EFFECTIVE_DATE=' || TO_CHAR(HR_EXTRACT_DATE, 'YYYY/MM/DD')
L_RATE_ID   = TO_NUM(GET_VALUE_SET('GB_CMP_ASG_RATE_ID', L_PARAM_PER))
l_log = SET_LOG('Rate ID: ' || TO_CHAR(L_RATE_ID))

IF L_RATE_ID > 0 THEN
(
    L_PARAM_MIN = '|=P_ASSIGNMENT_RATE=' || TO_CHAR(L_RATE_ID) || '|P_ASSIGNMENT_GRADE=' || TO_CHAR(L_GRADE) || '|P_ASSIGNMENT_ID=' || TO_CHAR(L_CTX_ASG) || '|P_EFFECTIVE_DATE=' || TO_CHAR(HR_EXTRACT_DATE, 'YYYY/MM/DD')
    L_PARAM_MAX = '|=P_ASSIGNMENT_GRADE=' || TO_CHAR(L_GRADE)  || '|P_ASSIGNMENT_RATE='  || TO_CHAR(L_RATE_ID) || '|P_ASSIGNMENT_ID=' || TO_CHAR(L_CTX_ASG) || '|P_EFFECTIVE_DATE=' || TO_CHAR(HR_EXTRACT_DATE, 'YYYY/MM/DD')
    L_MIN = TO_NUM(GET_VALUE_SET('GB_CMP_RATE_ID_VALUE_MIN', L_PARAM_MIN))
    L_MAX = TO_NUM(GET_VALUE_SET('GB_CMP_RATE_ID_VALUE_MAX', L_PARAM_MAX))
)
ELSE
(
    L_PARAM_GRADE = '|=P_ASSIGNMENT_GRADE=' || TO_CHAR(L_GRADE) || '|P_ASSIGNMENT_ID=' || TO_CHAR(L_CTX_ASG) || '|P_EFFECTIVE_DATE=' || TO_CHAR(HR_EXTRACT_DATE, 'YYYY/MM/DD')
    L_MIN = TO_NUM(GET_VALUE_SET('GB_CMP_RATE_VALUE_MIN', L_PARAM_GRADE))
    L_MAX = TO_NUM(GET_VALUE_SET('GB_CMP_RATE_VALUE_MAX', L_PARAM_GRADE))
)

l_log = SET_LOG('Min actual: ' || TO_CHAR(L_MIN))
l_log = SET_LOG('Max actual: ' || TO_CHAR(L_MAX))

IF L_MAX = L_MIN THEN
(
    l_log = SET_LOG('Max igual a Min, retorna 0')
    L_DEFAULT_VALUE = 0
    RETURN L_DEFAULT_VALUE
)

/*============================================================================
  INCREMENTO PLAN SALARIAL ESP/PT/MOR (UDT) Y NUEVO MINIMO / NUEVO MAXIMO
============================================================================*/
L_INCR_PLAN = TO_NUM(GET_TABLE_VALUE('GB_CMP_INC_PLAN_SALARIAL', 'Valor_Inc_Plan_Salarial', L_PAIS_UDT))

L_INCR_PLAN = L_INCR_PLAN / 100

l_log = SET_LOG('Incremento Plan Salarial (%): ' || TO_CHAR(L_INCR_PLAN))

L_NUEVO_MIN = L_MIN + (L_MIN * L_INCR_PLAN)
L_NUEVO_MAX = L_MAX + (L_MAX * L_INCR_PLAN)

l_log = SET_LOG('Nuevo Minimo: ' || TO_CHAR(L_NUEVO_MIN))
l_log = SET_LOG('Nuevo Maximo: ' || TO_CHAR(L_NUEVO_MAX))

/*============================================================================
  NUEVO VALOR DEL PUNTO Y NUEVA APERTURA
============================================================================*/
L_NUEVO_VALOR_PUNTO = (L_NUEVO_MAX - L_NUEVO_MIN) / L_DIVISOR

IF L_NUEVO_VALOR_PUNTO = 0 THEN
(
    l_log = SET_LOG('Nuevo Valor del Punto es 0, retorna 0')
    L_DEFAULT_VALUE = 0
    RETURN L_DEFAULT_VALUE
)

L_NUEVA_APERTURA = ((L_NUEVO_SUELDO - L_NUEVO_MIN) / L_NUEVO_VALOR_PUNTO) + 70

l_log = SET_LOG('Nuevo Valor del Punto: ' || TO_CHAR(L_NUEVO_VALOR_PUNTO))
l_log = SET_LOG('*** RESULTADO NUEVA APERTURA: ' || TO_CHAR(L_NUEVA_APERTURA) || ' ***')

L_DEFAULT_VALUE = L_NUEVA_APERTURA
RETURN L_DEFAULT_VALUE