/******************************************************************************
* *
* FORMULA NAME      : GB_CMP_INC_PLAN_SALARIAL_PCT_R4
* FORMULA TYPE      : Compensation Default and Override
* DESCRIPTION       : Retorna el porcentaje de incremento del plan salarial
*                     para R4 (Espana, Portugal, Marruecos) desde UDT
*                     GB_CMP_INC_PLAN_SALARIAL usando key por pais derivada
*                     del Legal Employer.
* *
*-----------------------------------------------------------------------------*
* CREATED BY        : IT-GLOBAL                                               *
* CREATION DATE     : 27-Mayo-2026                                            *
* LAST UPDATE DATE  : 27-Mayo-2026                                            *
* *
*******************************************************************************
* Change History:                                                             *
* Name              Date             Version          Comments                *
*-----------------------------------------------------------------------------*
* It Global         27-Mayo-2026     1                Version Inicial R4      *
* *
******************************************************************************/

INPUTS ARE
CMP_IV_PLAN_EXTRACTION_DATE (text)

DEFAULT FOR CMP_IV_PLAN_EXTRACTION_DATE IS '4012/01/01'
DEFAULT FOR PER_ASG_ORG_LEGAL_EMPLOYER_NAME IS 'N/LE'

HR_EXTRACT_DATE = TO_DATE(CMP_IV_PLAN_EXTRACTION_DATE, 'YYYY/MM/DD')

l_log = SET_LOG('*** INICIO GB_CMP_INC_PLAN_SALARIAL_PCT_R4 ***')

/***** LEGAL EMPLOYER *****/
CHANGE_CONTEXTS(EFFECTIVE_DATE = HR_EXTRACT_DATE)
(
    L_LEGAL_EMPLOYER = PER_ASG_ORG_LEGAL_EMPLOYER_NAME
)

l_log = SET_LOG('Legal Employer: ' || L_LEGAL_EMPLOYER)

/* ============ MAPEO LEGAL EMPLOYER A KEY UDT ============ */
IF L_LEGAL_EMPLOYER = 'Bimbo Morocco, S.A.R.L.A.U.' THEN
    L_KEY_UDT = 'MOR'
ELSE IF L_LEGAL_EMPLOYER = 'Bimbo Donuts Portugal, LDA' THEN
    L_KEY_UDT = 'PT'
ELSE
    L_KEY_UDT = 'ES'

l_log = SET_LOG('Key UDT: ' || L_KEY_UDT)

/************************** OBTENER VALOR DE UDT ****************************/
L_VALOR_RAW = GET_TABLE_VALUE('GB_CMP_INC_PLAN_SALARIAL', 'Valor_Inc_Plan_Salarial', L_KEY_UDT)

l_log = SET_LOG('Valor UDT RAW: ' || L_VALOR_RAW)

/* VALIDACION TEXTO VACIO */
IF L_VALOR_RAW = ' ' THEN
(
    l_log = SET_LOG('Valor vacio, retorna 0')
    L_DEFAULT_VALUE = 0
    RETURN L_DEFAULT_VALUE
)

/* CONVERSION */
L_VALOR_NUM = TO_NUMBER(L_VALOR_RAW)

l_log = SET_LOG('Valor Num: ' || TO_CHAR(L_VALOR_NUM))

/* VALIDACIONES */
IF L_VALOR_NUM < 0 OR L_VALOR_NUM > 100 THEN
(
    l_log = SET_LOG('Valor fuera de rango [0-100], retorna 0')
    L_DEFAULT_VALUE = 0
    RETURN L_DEFAULT_VALUE
)

/* RESULTADO FINAL */
L_DEFAULT_VALUE = L_VALOR_NUM
l_log = SET_LOG('*** RESULTADO GB_CMP_INC_PLAN_SALARIAL_PCT_R4: ' || TO_CHAR(L_DEFAULT_VALUE) || ' ***')
RETURN L_DEFAULT_VALUE