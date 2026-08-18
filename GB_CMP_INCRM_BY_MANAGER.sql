/******************************************************************************
* FORMULA NAME      : GB_CMP_INCRM_BY_MANAGER                                *
* FORMULA TYPE      : Compensation Default and Override                       *
* DESCRIPTION       : Devuelve el incremento promedio de merito por plan/pais *
*                     para el Budget Page. Resuelve dinamicamente el nombre   *
*                     del plan desde CMP_IV_PLAN_ID via Value Set             *
*                     GB_CMP_VS_PLAN_NAME y deriva la key de pais para leer  *
*                     el promedio desde UDT GB_INCREMENTO_MERITO.             *
*                     Formula unica para todos los planes R4 (ESP/PT/MOR).   *
*-----------------------------------------------------------------------------*
* CREATED BY        : IT-GLOBAL                                               *
* CREATION DATE     : 14-Agosto-2026                                          *
* LAST UPDATE DATE  : 14-Agosto-2026                                          *
*-----------------------------------------------------------------------------*
* Change History:                                                             *
* Author          | Date            | Ver | Comments                          *
*-----------------+-----------------+-----+-----------------------------------*
* IT Global       | 14-Agosto-2026  |  1  | Version inicial. Resolucion       *
*                 |                 |     | dinamica de pais por Plan Name    *
*                 |                 |     | via Value Set + CMP_IV_PLAN_ID.   *
*                 |                 |     | Independiente de Pod/ambiente.    *
******************************************************************************/

INPUTS ARE CMP_IV_PLAN_ID (number),
CMP_IV_PLAN_START_DATE (text),
CMP_IV_PLAN_END_DATE (text),
CMP_IVR_ASSIGNMENT_ID(NUMBER_NUMBER),
CMP_IV_PLAN_EXTRACTION_DATE (text)

DEFAULT FOR CMP_IV_PLAN_ID IS 0

/*============================================================================
  INICIO
============================================================================*/
l_log = SET_LOG('*** INICIO GB_CMP_INCRM_BY_MANAGER ***')
l_log = SET_LOG('Plan ID: ' || TO_CHAR(CMP_IV_PLAN_ID))

/*============================================================================
  OBTENER PLAN NAME DESDE VALUE SET
  Value Set GB_CMP_VS_PLAN_NAME ejecuta:
    SELECT NAME FROM CMP_PLANS_VL WHERE PLAN_ID = :P_PLAN_ID
  Retorna el nombre del plan sin depender del ID fijo (portable entre pods).
============================================================================*/
L_PARAM_PLAN_NAME = '|=P_PLAN_ID=' || TO_CHAR(CMP_IV_PLAN_ID)
l_log = SET_LOG ( 'DEBUG :' || L_PARAM_PLAN_NAME)

L_PLAN_NAME = GET_VALUE_SET('GB_CMP_VS_PLAN_NAME', L_PARAM_PLAN_NAME)

l_log = SET_LOG('Plan Name: ' || L_PLAN_NAME)

/*============================================================================
  DERIVAR KEY PAIS DESDE PLAN NAME
  Se usa el nombre del plan para determinar el pais. Los nombres deben
  coincidir exactamente con lo configurado en Manage Compensation Plans.
  Ajustar los strings si los nombres cambian.
============================================================================*/
IF L_PLAN_NAME = 'MABMO Merit Increase R4' THEN
    L_KEY_PAIS = 'MOR'
ELSE IF L_PLAN_NAME = 'PT Incremento por Mérito R4' THEN
    L_KEY_PAIS = 'PT'
ELSE IF L_PLAN_NAME = 'ES Incremento por Mérito R4' THEN
    L_KEY_PAIS = 'ESP'
ELSE
(
    l_log = SET_LOG('ERROR: Plan Name no reconocido: ' || L_PLAN_NAME)
    L_KEY_PAIS = 'N/A'
)

l_log = SET_LOG('Key pais: ' || L_KEY_PAIS)



/*============================================================================
  PROMEDIO UDT
============================================================================*/
L_UDT_PROM = TO_NUM(GET_TABLE_VALUE('GB_INCREMENTO_MERITO', 'Incremento_Promedio', L_KEY_PAIS))

l_log = SET_LOG('Promedio UDT: ' || TO_CHAR(L_UDT_PROM))

/*============================================================================
  RESULTADO
============================================================================*/
l_log = SET_LOG('*** RESULTADO: ' || TO_CHAR(L_UDT_PROM) || ' ***')
RETURN L_UDT_PROM