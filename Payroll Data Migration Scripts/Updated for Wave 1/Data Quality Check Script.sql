--------------------------------------- FOR INTERIM VALIDATION---------------------------------------
--1.
SELECT
    COUNT(CASE WHEN LGS.workingdays = 5 AND LB.entitlement_cy > 20 THEN LB.id END) AS Days_5,
    COUNT(CASE WHEN LGS.workingdays = 6 AND LB.entitlement_cy > 24 THEN LB.id END) AS Days_6,
    COUNT(CASE WHEN LB.entitlement_cy = 0 THEN LB.id END) AS AllO_BAL_0,
    COUNT(CASE WHEN LB.balance_days < 0 THEN LB.id END) AS NEG_BAL -- Check any balance value is negative.
FROM public.integ_leave_op_balance_imp LB
INNER JOIN payroll_emp_data.employee_core_info ECI ON LB.employee_code = ECI.pin_no
LEFT JOIN payroll_emp_data.employeeleavegroupmapping EGM ON ECI.id = EGM.employee_id
LEFT JOIN payroll_emp_data.leavegroupsetup LGS ON EGM.leavegroupid = LGS.leavegroupid


--2. Checking if there are any leave types which has carry forward other than annual leave
SELECT COUNT(1)
FROM public.integ_leave_op_balance_imp
WHERE leave_type_code <> '00' AND days_leave_bf > 0

--------------------------------------- FOR SOURCE VALIDATION---------------------------------------
-- 1.
WITH BASE_CTE AS (
    SELECT u.pin
    FROM payroll_leave_attend_data.system_access_config pro
    INNER JOIN payroll_emp_data.users u ON u.program_code = pro.allowed_program_code

    UNION

    SELECT u.pin
    FROM payroll_leave_attend_data.system_access_config pro
    INNER JOIN payroll_emp_data.users u ON u.project_code = pro.allowed_project_code

    UNION

    SELECT u.pin
    FROM payroll_leave_attend_data.system_access_config pro
    INNER JOIN payroll_emp_data.users u ON u.hrbranchid = pro.allowed_branch_code

    UNION

    SELECT u.pin
    FROM payroll_leave_attend_data.system_access_config pro
    INNER JOIN payroll_emp_data.users u ON u.jobbase = pro.allowed_jobbase

    UNION

    SELECT u.pin
    FROM payroll_leave_attend_data.system_access_config pro
    INNER JOIN payroll_emp_data.users u ON u.id = pro.allowed_employee_id::INTEGER
), LEAVE_DURATION_CTE AS (
    SELECT U.pin, LM.leave_type_id, SUM(LM.leave_duration) AS Total_Leave
    FROM payroll_leave_attend_data.leave_master_20jan25 LM
    INNER JOIN payroll_emp_data.users U ON LM.employee_id = U.id
    INNER JOIN BASE_CTE B ON U.pin = B.pin
    INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
    WHERE EXTRACT('YEAR' FROM LM.to_date) >= 2025 AND LM.leave_duration > 0 AND LM.leave_type_id IN (1,8,18)
    AND LM.status = 1 AND LM.is_deleted <> 1 AND LM.is_manual = 0
    GROUP BY U.pin, LM.leave_type_id
)
SELECT
COUNT(CASE WHEN LGS.workingdays = 5 AND ROUND(ABS((coalesce(LDC.Total_Leave,0)+ LB.current_year_leave_balance) - LB.last_year_closing_leave_balance)::NUMERIC,6) > 20 THEN LB.id END) AS Days_5,
    COUNT(CASE WHEN LGS.workingdays = 6 AND ROUND(ABS((coalesce(LDC.Total_Leave,0)+ LB.current_year_leave_balance) - LB.last_year_closing_leave_balance)::NUMERIC,6) > 24 THEN LB.id END) AS Days_6,
    COUNT(CASE WHEN ROUND(ABS((coalesce(LDC.Total_Leave,0)+ LB.current_year_leave_balance) - LB.last_year_closing_leave_balance)::NUMERIC,6) = 0 THEN LB.id END) AS AllO_BAL_0,
    COUNT(CASE WHEN LB.current_year_leave_balance < 0 THEN LB.id END) AS NEG_BAL -- Check any balance value is negative.
FROM payroll_leave_attend_data.employee_leave_balance LB
INNER JOIN payroll_emp_data.employee_core_info ECI ON LB.employee_id = ECI.id
INNER JOIN BASE_CTE B ON ECI.pin_no = B.pin
LEFT JOIN LEAVE_DURATION_CTE LDC ON ECI.pin_no = LDC.pin
LEFT JOIN payroll_emp_data.employeeleavegroupmapping EGM ON ECI.id = EGM.employee_id
LEFT JOIN payroll_emp_data.leavegroupsetup LGS ON EGM.leavegroupid = LGS.leavegroupid
WHERE LB.leave_type_id IN (1,8,18)
  AND LB.leaveyear_policy_id >= 5 AND LB.is_deleted <> 1;


--2. Checking if there are any leave types which has carry forward other than annual leave

WITH BASE_CTE AS (
    SELECT u.pin
    FROM payroll_leave_attend_data.system_access_config pro
    INNER JOIN payroll_emp_data.users u ON u.program_code = pro.allowed_program_code

    UNION

    SELECT u.pin
    FROM payroll_leave_attend_data.system_access_config pro
    INNER JOIN payroll_emp_data.users u ON u.project_code = pro.allowed_project_code

    UNION

    SELECT u.pin
    FROM payroll_leave_attend_data.system_access_config pro
    INNER JOIN payroll_emp_data.users u ON u.hrbranchid = pro.allowed_branch_code

    UNION

    SELECT u.pin
    FROM payroll_leave_attend_data.system_access_config pro
    INNER JOIN payroll_emp_data.users u ON u.jobbase = pro.allowed_jobbase

    UNION

    SELECT u.pin
    FROM payroll_leave_attend_data.system_access_config pro
    INNER JOIN payroll_emp_data.users u ON u.id = pro.allowed_employee_id::INTEGER
)
SELECT COUNT(1)
FROM payroll_leave_attend_data.employee_leave_balance LB
INNER JOIN payroll_emp_data.employee_core_info ECI ON LB.employee_id = ECI.id
INNER JOIN BASE_CTE B ON ECI.pin_no = B.pin
WHERE leave_type_id IN ('8','18') AND last_year_closing_leave_balance > 0




