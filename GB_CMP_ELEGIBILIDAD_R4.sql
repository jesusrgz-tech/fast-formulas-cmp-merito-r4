/*****************************************************************************
FORMULA NAME: GB_CMP_ELEGIBILIDAD_R4
CREATED_BY : IT-GLOBAL
CREATION_DATE : 07 de Abril del 2026
LAST_UPDATE_DATE : 22 de Junio del 2026
FORMULA TYPE : Participation and Rate Eligibility
DESCRIPTION : Elegibilidad para el plan MABMO Merito R4. Incluye solo
              colaboradores con nivel 4 en adelante y con tipo de
              contrato permanente en regiones ESP/MOR/PT.
*****************************************************************************/

INPUTS ARE CMP_IV_PLAN_ELIG_DATE (text)

DEFAULT FOR CMP_IV_PLAN_ELIG_DATE IS '4012/01/01'
DEFAULT FOR PER_ASG_JOB_MANAGER_LEVEL IS 'NO_MGR_LVL'
DEFAULT FOR PER_ASG_ATTRIBUTE1 IS 'N/A'

ELIGIBLE = 'N'
MGR_LVL = 'NO_MGR_LVL'
MGR_LVL_NUM = 0
L_CODE = 'N/A'

ELIG_DATE = TO_DATE(CMP_IV_PLAN_ELIG_DATE, 'YYYY/MM/DD')

l_log = SET_LOG('*** INICIO GB_CMP_ELEGIBILIDAD_R4 ***')

CHANGE_CONTEXTS(EFFECTIVE_DATE = ELIG_DATE)
(
    MGR_LVL = PER_ASG_JOB_MANAGER_LEVEL
    L_CODE = PER_ASG_ATTRIBUTE1

    IF MGR_LVL <> 'NO_MGR_LVL' THEN
        MGR_LVL_NUM = TO_NUM(MGR_LVL)
)

l_log = SET_LOG('Manager Level raw: ' || MGR_LVL)
l_log = SET_LOG('Manager Level num: ' || TO_CHAR(MGR_LVL_NUM))
l_log = SET_LOG('Attribute1 raw: ' || L_CODE)

IF L_CODE = '100' THEN
    L_CONTRATO_OK = 'Y'
ELSE IF L_CODE = '109' THEN
    L_CONTRATO_OK = 'Y'
ELSE IF L_CODE = '130' THEN
    L_CONTRATO_OK = 'Y'
ELSE IF L_CODE = '139' THEN
    L_CONTRATO_OK = 'Y'
ELSE IF L_CODE = '150' THEN
    L_CONTRATO_OK = 'Y'
ELSE IF L_CODE = '189' THEN
    L_CONTRATO_OK = 'Y'
ELSE IF L_CODE = '200' THEN
    L_CONTRATO_OK = 'Y'
ELSE IF L_CODE = '230' THEN
    L_CONTRATO_OK = 'Y'
ELSE IF L_CODE = '289' THEN
    L_CONTRATO_OK = 'Y'
ELSE IF L_CODE = 'MA01' THEN
    L_CONTRATO_OK = 'Y'
ELSE IF L_CODE = 'MA02' THEN
    L_CONTRATO_OK = 'Y'
ELSE IF L_CODE = 'PT01' THEN
    L_CONTRATO_OK = 'Y'
ELSE
    L_CONTRATO_OK = 'N'

l_log = SET_LOG('Contrato OK: ' || L_CONTRATO_OK)

IF MGR_LVL_NUM >= 4 AND L_CONTRATO_OK = 'Y' THEN
    ELIGIBLE = 'Y'

l_log = SET_LOG('Resultado elegibilidad: ' || ELIGIBLE)
l_log = SET_LOG('*** FIN GB_CMP_ELEGIBILIDAD_R4 ***')

RETURN ELIGIBLE