/******************************************************************************
* FORMULA NAME      : GB_CMP_TIPO_CONTRATO_R4                               *
* FORMULA TYPE      : Compensation Default and Override                       *
* DESCRIPTION       : Retorna el tipo de contrato del colaborador.            *
*                     1 = Permanente, 2 = No permanente.                      *
*                     Lee PER_ASG_ATTRIBUTE1 sin dependencia de region.       *
*-----------------------------------------------------------------------------*
* CREATED BY        : IT-GLOBAL                                               *
* CREATION DATE     : 07-Abril-2026                                           *
* LAST UPDATE DATE  : 27-Mayo-2026                                            *
*-----------------------------------------------------------------------------*
* Change History:                                                             *
* Author          | Date            | Ver | Comments                          *
*-----------------+-----------------+-----+-----------------------------------*
* IT Global       | 15-Abril-2026   |  1  | Version Inicial                   *
* IT Global       | 21-Abril-2026   |  2  | Reestructura dinamica UDT         *
* IT Global       | 27-Mayo-2026    |  3  | Validacion R4: sin cambios        *
*                 |                 |     | funcionales, logica agnostica     *
*                 |                 |     | a region                          *
******************************************************************************/

INPUTS ARE CMP_IV_PLAN_START_DATE (text),
CMP_IV_PLAN_END_DATE (text),
CMP_IVR_ASSIGNMENT_ID (NUMBER_NUMBER),
CMP_IV_PLAN_EXTRACTION_DATE (text)

DEFAULT FOR PER_ASG_ATTRIBUTE1 IS 'PERMANENTE'

HR_EXTRACT_DATE = TO_DATE(CMP_IV_PLAN_EXTRACTION_DATE, 'YYYY/MM/DD')

l_log = SET_LOG('*** INICIO GB_CMP_TIPO_CONTRATO_R4 ***')

/***** TIPO DE CONTRATO *****/
CHANGE_CONTEXTS(EFFECTIVE_DATE = HR_EXTRACT_DATE)
(
    L_TIPO_CONTRATO = PER_ASG_ATTRIBUTE1
)

L_DEFAULT_VALUE = TO_NUMBER(L_TIPO_CONTRATO)

l_log = SET_LOG('*** RESULTADO TIPO_CONTRATO: ' || TO_CHAR(L_DEFAULT_VALUE) || ' ***')
RETURN L_DEFAULT_VALUE