/**********************************************************************
FORMULA NAME      : GB_CMP_NEW_HIRE_RETROFIT
CREATED_BY        : IT-GLOBAL
CREATION_DATE     : (segun version original)
LAST_UPDATE_DATE  : 17 de Agosto del 2026
FORMULA TYPE      : Compensation Default and Override
DESCRIPTION       : Identifica si el colaborador es New Hire, usando la ventana
                    de 5 meses antes del cierre del plan. Excluye del New Hire
                    cuando el reinicio de ORIGINAL_DATE_OF_HIRE se origino por
                    un movimiento interno del grupo, detectado via
                    PER_ASG_ACTION_REASON_CODE sobre el Assignment ID anterior
                    (obtenido del array historico PER_HIST_ASG_*).

CHANGE HISTORY:
- 10-Jul-2026 (v1)  : Version base.
- 14-Ago-2026 (v2-v6): Diagnosticos iterativos de action code, Legal Employer
                 historico, y legislation code. Descartados como criterio
                 final. Ver historial completo en v10.
- 15-Ago-2026 (v7-v8): Diagnostico de DBI para Action Reason. Confirmado:
                 PER_ASG_ACTION_REASON_CODE (paf_asg.REASON_CODE).
- 15-Ago-2026 (v9)  : Logica de exclusion con codigo '28'. Validado con
                 assignment 300000631833965 (Sara Patricia, PT->ES).
- 15-Ago-2026 (v10) : Catalogo ampliado a 8 codigos de exclusion.
                 BUG DETECTADO: Cristina Balaguer (30009163) tiene
                 Original Date of Hire (2025/02/01) distinta de
                 Assignment Start Date (2025/05/01). La formula usaba
                 L_ORIGINAL_HIRE_DATE para buscar el assignment anterior
                 y leer el reason code, pero la terminacion por Cambio
                 de Empresa ocurrio en la fecha del Assignment Start,
                 no del Original Hire. Resultado: reason code = N/A.
- 17-Ago-2026 (v11) : CORRECCION. Se usa L_HIRE_DATE (PER_ASG_EFFECTIVE_START_DATE)
                 en vez de L_ORIGINAL_HIRE_DATE para:
                 1) calcular L_DIA_ANTERIOR (buscar assignment anterior)
                 2) EFFECTIVE_DATE del CHANGE_CONTEXTS para leer reason code
                 L_ORIGINAL_HIRE_DATE se sigue usando SOLO para la ventana
                 de 5 meses (deteccion de candidato a New Hire).
                 Validado que v9/v10 de Sara Patricia no se rompe porque
                 en ese caso L_HIRE_DATE = L_ORIGINAL_HIRE_DATE = 2026/02/18.
**********************************************************************/

INPUTS ARE
CMP_IV_PLAN_EXTRACTION_DATE (text),
CMP_IV_PLAN_START_DATE (text),
CMP_IV_PLAN_END_DATE (text)

DEFAULT FOR CMP_IV_PLAN_EXTRACTION_DATE IS '4012/01/01'
DEFAULT FOR CMP_IV_PLAN_START_DATE IS '1900/01/01'
DEFAULT FOR CMP_IV_PLAN_END_DATE IS '4012/01/01'
DEFAULT FOR PER_ASG_EFFECTIVE_START_DATE IS '1981/05/15' (date)
DEFAULT FOR PER_PER_LATEST_REHIRE_DATE IS '1901/01/01' (date)
DEFAULT FOR PER_ASG_REL_ORIGINAL_DATE_OF_HIRE IS '1901/01/01' (date)
DEFAULT FOR PER_ASG_ACTION_REASON_CODE IS 'N/A'

DEFAULT_DATA_VALUE FOR PER_HIST_ASG_EFFECTIVE_START_DATE IS '1900/01/01' (date)
DEFAULT_DATA_VALUE FOR PER_HIST_ASG_EFFECTIVE_END_DATE IS '4712/12/31' (date)
DEFAULT_DATA_VALUE FOR PER_HIST_ASG_ASSIGNMENT_ID IS 0

L_DEFAULT_VALUE = 'N'
L_NEW_HIRE = 'N'
L_ASG_ID_ANTERIOR = 0
L_REASON_CODE = 'N/A'
L_IDX = 0
L_TOTAL_FILAS = 0

HR_EXTRACT_DATE = TO_DATE(CMP_IV_PLAN_EXTRACTION_DATE, 'YYYY/MM/DD')
L_PL_START_DATE = TO_DATE(CMP_IV_PLAN_START_DATE, 'YYYY/MM/DD')
L_PL_END_DATE   = TO_DATE(CMP_IV_PLAN_END_DATE, 'YYYY/MM/DD')

l_log = SET_LOG('*** INICIO GB_CMP_NEW_HIRE_RETROFIT v11 ***')

L_CTX_ASG = GET_CONTEXT(HR_ASSIGNMENT_ID, -1)
l_log = SET_LOG('Assignment ID actual: ' || TO_CHAR(L_CTX_ASG))

L_HIRE_DATE = PER_ASG_EFFECTIVE_START_DATE
L_ORIGINAL_HIRE_DATE = PER_ASG_REL_ORIGINAL_DATE_OF_HIRE
L_LATEST_REHIRE_DATE = PER_PER_LATEST_REHIRE_DATE

l_log = SET_LOG('Assignment Start Date: ' || TO_CHAR(L_HIRE_DATE, 'YYYY/MM/DD'))
l_log = SET_LOG('Original Date of Hire: ' || TO_CHAR(L_ORIGINAL_HIRE_DATE, 'YYYY/MM/DD'))
l_log = SET_LOG('Latest Rehire Date: ' || TO_CHAR(L_LATEST_REHIRE_DATE, 'YYYY/MM/DD'))

L_CINCO_MESES = ADD_MONTHS(L_PL_END_DATE, -5)
l_log = SET_LOG('Ventana New Hire (5 meses antes de cierre): ' || TO_CHAR(L_CINCO_MESES, 'YYYY/MM/DD'))

IF L_ORIGINAL_HIRE_DATE >= L_CINCO_MESES THEN
(
    l_log = SET_LOG('Candidato a New Hire por ventana de fecha. Buscando Assignment ID anterior en historial...')

    /*============================================================================
      CORRECCION v11: L_DIA_ANTERIOR se calcula desde L_HIRE_DATE (fecha de inicio
      del assignment actual, que coincide con la fecha de terminacion del anterior),
      NO desde L_ORIGINAL_HIRE_DATE (que puede ser anterior si el empleado fue
      contratado originalmente en otra fecha y luego transferido).
    ============================================================================*/
    L_DIA_ANTERIOR = ADD_DAYS(L_HIRE_DATE, -1)
    l_log = SET_LOG('Dia anterior al inicio del assignment actual: ' || TO_CHAR(L_DIA_ANTERIOR, 'YYYY/MM/DD'))

    L_TOTAL_FILAS = PER_HIST_ASG_EFFECTIVE_START_DATE.LAST(-1)
    l_log = SET_LOG('Total filas historial: ' || TO_CHAR(L_TOTAL_FILAS))
    L_IDX = L_TOTAL_FILAS
    WHILE L_IDX >= 1 LOOP
    (
        L_FILA_INICIO = PER_HIST_ASG_EFFECTIVE_START_DATE[L_IDX]
        L_FILA_FIN = PER_HIST_ASG_EFFECTIVE_END_DATE[L_IDX]
        L_FILA_ASG_ID = PER_HIST_ASG_ASSIGNMENT_ID[L_IDX]

        IF L_FILA_ASG_ID <> L_CTX_ASG AND L_DIA_ANTERIOR >= L_FILA_INICIO AND L_DIA_ANTERIOR <= L_FILA_FIN AND L_ASG_ID_ANTERIOR = 0 THEN
        (
            L_ASG_ID_ANTERIOR = L_FILA_ASG_ID
            L_IDX = 0
        )
        ELSE
            L_IDX = L_IDX - 1
    )

    l_log = SET_LOG('Assignment ID anterior encontrado: ' || TO_CHAR(L_ASG_ID_ANTERIOR))

    /*============================================================================
      CORRECCION v11: EFFECTIVE_DATE usa L_HIRE_DATE (fecha de inicio del
      assignment actual = fecha de terminacion del anterior), NO
      L_ORIGINAL_HIRE_DATE. Es en esa fecha donde Oracle registra el action
      reason de la terminacion/transfer.
    ============================================================================*/
    IF L_ASG_ID_ANTERIOR <> 0 THEN
    (
        CHANGE_CONTEXTS(HR_ASSIGNMENT_ID = L_ASG_ID_ANTERIOR, EFFECTIVE_DATE = L_HIRE_DATE)
        (
            L_REASON_CODE = PER_ASG_ACTION_REASON_CODE
        )
        l_log = SET_LOG('Action Reason Code del assignment anterior: ' || L_REASON_CODE)

        IF L_REASON_CODE = '28'
        OR L_REASON_CODE = '098'
        OR L_REASON_CODE = 'ES098'
        OR L_REASON_CODE = 'ES98'
        OR L_REASON_CODE = 'BUK_30'
        OR L_REASON_CODE = 'INTERNREC'
        OR L_REASON_CODE = 'REORG'
        OR L_REASON_CODE = 'WORKERREQ'
        THEN
        (
            L_NEW_HIRE = 'N'
            l_log = SET_LOG('Excluido de New Hire: movimiento interno detectado (codigo ' || L_REASON_CODE || ')')
        )
        ELSE
        (
            L_NEW_HIRE = 'Y'
            l_log = SET_LOG('Se mantiene como New Hire: Action Reason no corresponde a movimiento interno')
        )
    )
    ELSE
    (
        L_NEW_HIRE = 'Y'
        l_log = SET_LOG('Se mantiene como New Hire: no se encontro asignacion anterior en historial (alta real)')
    )
)

L_DEFAULT_VALUE = L_NEW_HIRE

l_log = SET_LOG('*** RESULTADO NEW HIRE: ' || L_NEW_HIRE || ' ***')
RETURN L_DEFAULT_VALUE