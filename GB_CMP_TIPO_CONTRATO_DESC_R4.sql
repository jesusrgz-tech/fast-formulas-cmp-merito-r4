/******************************************************************************
* FORMULA NAME      : GB_CMP_TIPO_CONTRATO_DESC_R4                          *
* FORMULA TYPE      : Compensation Default and Override                       *
* DESCRIPTION       : Retorna la descripcion del tipo de contrato             *
*                     del colaborador a partir de PER_ASG_ATTRIBUTE1.         *
*-----------------------------------------------------------------------------*
* CREATED BY        : IT-GLOBAL                                               *
* CREATION DATE     : 08-Junio-2026                                           *
* LAST UPDATE DATE  : 08-Junio-2026                                           *
*-----------------------------------------------------------------------------*
* Change History:                                                             *
* Author          | Date            | Ver | Comments                          *
*-----------------+-----------------+-----+-----------------------------------*
* IT Global       | 08-Junio-2026   |  1  | Version Inicial                   *
* IT Global       | 08-Junio-2026   |  2  | Mapeo completo ESP/MOR/PT         *
******************************************************************************/

INPUTS ARE CMP_IV_PLAN_START_DATE (text),

CMP_IV_PLAN_END_DATE (text),

CMP_IVR_ASSIGNMENT_ID (NUMBER_NUMBER),

CMP_IV_PLAN_EXTRACTION_DATE (text)
DEFAULT FOR PER_ASG_ATTRIBUTE1 IS 'N/A'
HR_EXTRACT_DATE = TO_DATE(CMP_IV_PLAN_EXTRACTION_DATE, 'YYYY/MM/DD')
l_log = SET_LOG('*** INICIO GB_CMP_TIPO_CONTRATO_R4 ***')
CHANGE_CONTEXTS(EFFECTIVE_DATE = HR_EXTRACT_DATE)

(

L_CODE = PER_ASG_ATTRIBUTE1

)
l_log = SET_LOG('Attribute1 raw: ' || L_CODE)
IF L_CODE = '100' THEN
L_RESULT = 'PERMANENTE'
ELSE IF L_CODE = '109' THEN
L_RESULT = 'PERMANENTE'
ELSE IF L_CODE = '130' THEN

L_RESULT = 'PERMANENTE'

ELSE IF L_CODE = '139' THEN

L_RESULT = 'PERMANENTE'

ELSE IF L_CODE = '150' THEN

L_RESULT = 'PERMANENTE'

ELSE IF L_CODE = '189' THEN

L_RESULT = 'PERMANENTE'

ELSE IF L_CODE = '200' THEN

L_RESULT = 'PERMANENTE'

ELSE IF L_CODE = '230' THEN

L_RESULT = 'PERMANENTE'

ELSE IF L_CODE = '289' THEN

L_RESULT = 'PERMANENTE'

ELSE IF L_CODE = 'MA01' THEN

L_RESULT = 'PERMANENTE'

ELSE IF L_CODE = 'MA02' THEN

L_RESULT = 'PERMANENTE'

ELSE IF L_CODE = 'PT01' THEN

L_RESULT = 'PERMANENTE'

ELSE

L_RESULT = 'N/A'
l_log = SET_LOG('*** RESULTADO TIPO_CONTRATO: ' || L_RESULT || ' ***')
RETURN L_RESULT