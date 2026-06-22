/*****************************************************************************
FORMULA NAME: GB_CMP_ELIG_TIPO_CONTRATO_R4
CREATED_BY : IT-GLOBAL
CREATION_DATE : 22 de Junio del 2026
LAST_UPDATE_DATE : 22 de Junio del 2026
FORMULA TYPE : Participation and Rate Eligibility
DESCRIPTION : Retorna Y para colaboradores con contrato permanente en
              regiones ESP/MOR/PT. Retorna N para el resto.
*****************************************************************************/

INPUTS ARE CMP_IV_PLAN_START_DATE (text),
CMP_IV_PLAN_END_DATE (text),
CMP_IVR_ASSIGNMENT_ID (NUMBER_NUMBER),
CMP_IV_PLAN_EXTRACTION_DATE (text)

DEFAULT FOR PER_ASG_ATTRIBUTE1 IS 'N/A'

HR_EXTRACT_DATE = TO_DATE(CMP_IV_PLAN_EXTRACTION_DATE, 'YYYY/MM/DD')

l_log = SET_LOG('*** INICIO GB_CMP_ELIG_TIPO_CONTRATO_R4 ***')

CHANGE_CONTEXTS(EFFECTIVE_DATE = HR_EXTRACT_DATE)
(
    L_CODE = PER_ASG_ATTRIBUTE1
)

l_log = SET_LOG('Attribute1 raw: ' || L_CODE)

IF L_CODE = '100' THEN
    L_ELIGIBLE = 'Y'
ELSE IF L_CODE = '109' THEN
    L_ELIGIBLE = 'Y'
ELSE IF L_CODE = '130' THEN
    L_ELIGIBLE = 'Y'
ELSE IF L_CODE = '139' THEN
    L_ELIGIBLE = 'Y'
ELSE IF L_CODE = '150' THEN
    L_ELIGIBLE = 'Y'
ELSE IF L_CODE = '189' THEN
    L_ELIGIBLE = 'Y'
ELSE IF L_CODE = '200' THEN
    L_ELIGIBLE = 'Y'
ELSE IF L_CODE = '230' THEN
    L_ELIGIBLE = 'Y'
ELSE IF L_CODE = '289' THEN
    L_ELIGIBLE = 'Y'
ELSE IF L_CODE = 'MA01' THEN
    L_ELIGIBLE = 'Y'
ELSE IF L_CODE = 'MA02' THEN
    L_ELIGIBLE = 'Y'
ELSE IF L_CODE = 'PT01' THEN
    L_ELIGIBLE = 'Y'
ELSE
    L_ELIGIBLE = 'N'

l_log = SET_LOG('*** RESULTADO ELEGIBILIDAD: ' || L_ELIGIBLE || ' ***')

RETURN L_ELIGIBLE