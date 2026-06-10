/**********************************************************************
FORMULA NAME: GB_CMP_NEW_HIRE_RETROFIT
FORMULA TYPE : Compensation Default and Override
DESCRIPTION : identifica si la fecha de contratación es posterior a la fecha de inicio del ciclo
***********************************************************************/

/*=========== INPUT VALUES DEFAULTS BEGIN =====================*/
INPUTS ARE CMP_IV_PLAN_EXTRACTION_DATE (text), CMP_IV_PLAN_START_DATE (text) ,CMP_IV_PLAN_END_DATE (text)

/*=========== INPUT VALUES DEFAULTS END =====================*/

/* +========================= DEFAULT SECTION BEGIN ============================== */

DEFAULT FOR CMP_IV_PLAN_EXTRACTION_DATE IS  '4012/01/01'
DEFAULT FOR CMP_IV_PLAN_START_DATE IS  '1900/01/01'
DEFAULT FOR CMP_IV_PLAN_END_DATE IS  '4012/01/01'
DEFAULT FOR PER_ASG_EFFECTIVE_START_DATE IS '1981/05/15' (date)
DEFAULT FOR PER_PER_LATEST_REHIRE_DATE IS '1901/01/01' (date)
DEFAULT FOR PER_ASG_REL_ORIGINAL_DATE_OF_HIRE IS '1901/01/01' (date)


/* +========================= DEFAULT SECTION ENDS =============================== */

/* +========================= FORMULA SECTION BEGIN ============================== */
/* +========================= LOCAL VARIABLES BEGIN ============================== */
DEFAULT_VALUE = 'N'
NEW_HIRE = 'N'
ASG_START_DATE = PER_ASG_EFFECTIVE_START_DATE
HR_EXTRACT_DATE = TO_DATE(CMP_IV_PLAN_EXTRACTION_DATE,'YYYY/MM/DD')
PL_START_DATE = TO_DATE(CMP_IV_PLAN_START_DATE,'YYYY/MM/DD')
PL_END_DATE = TO_DATE(CMP_IV_PLAN_END_DATE,'YYYY/MM/DD') 
HIRE_DATE = PER_PER_LATEST_REHIRE_DATE
ORIGINAL_HIRE_DATE = PER_ASG_REL_ORIGINAL_DATE_OF_HIRE
/*GB_NEW_HIRE = TO_DATE('1950/01/01','YYYY/MM/DD')*/


/* +========================= LOCAL VARIABLES ENDS =============================== */


IF ORIGINAL_HIRE_DATE >= PL_START_DATE THEN
(
NEW_HIRE = 'Y'
)

DEFAULT_VALUE = NEW_HIRE


/* +========================= FORMULA SECTION ENDS =============================== */

RETURN DEFAULT_VALUE