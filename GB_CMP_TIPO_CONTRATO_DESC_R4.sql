/******************************************************************************
* FORMULA NAME      : GB_CMP_TIPO_CONTRATO_DESC_R4                          *
* FORMULA TYPE      : Compensation Default and Override                       *
* DESCRIPTION       : Retorna la descripcion del tipo de contrato             *
*                     del colaborador. Lee PER_ASG_CONTRACT_TYPE_MEANING.     *
*-----------------------------------------------------------------------------*
* CREATED BY        : IT-GLOBAL                                               *
* CREATION DATE     : 08-Junio-2026                                           *
* LAST UPDATE DATE  : 08-Junio-2026                                           *
*-----------------------------------------------------------------------------*
* Change History:                                                             *
* Author          | Date            | Ver | Comments                          *
*-----------------+-----------------+-----+-----------------------------------*
* IT Global       | 08-Junio-2026   |  1  | Version Inicial                   *
******************************************************************************/

INPUTS ARE CMP_IV_PLAN_START_DATE (text),
CMP_IV_PLAN_END_DATE (text),
CMP_IVR_ASSIGNMENT_ID (NUMBER_NUMBER),
CMP_IV_PLAN_EXTRACTION_DATE (text)

DEFAULT FOR PER_ASG_CONTRACT_TYPE_MEANING IS 'N/A'

HR_EXTRACT_DATE = TO_DATE(CMP_IV_PLAN_EXTRACTION_DATE, 'YYYY/MM/DD')

l_log = SET_LOG('*** INICIO GB_CMP_TIPO_CONTRATO_DESC_R4 ***')

/***** DESCRIPCION TIPO DE CONTRATO *****/
CHANGE_CONTEXTS(EFFECTIVE_DATE = HR_EXTRACT_DATE)
(
    L_DESC = PER_ASG_CONTRACT_TYPE_MEANING
)

l_log = SET_LOG('*** RESULTADO TIPO_CONTRATO_DESC: ' || L_DESC || ' ***')

RETURN L_DESC