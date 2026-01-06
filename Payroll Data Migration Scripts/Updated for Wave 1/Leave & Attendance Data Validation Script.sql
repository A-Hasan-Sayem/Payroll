
--------------------------------------- FOR INTERIM VALIDATION ---------------------------------------
--1.
SELECT
    COUNT(CASE WHEN LGS.workingdays = 5 AND LB.entitlement_cy > 20 THEN LB.id END) AS Days_5,
    COUNT(CASE WHEN LGS.workingdays = 6 AND LB.entitlement_cy > 24 THEN LB.id END) AS Days_6,
    COUNT(CASE WHEN LB.entitlement_cy = 0 THEN LB.id END) AS AllO_BAL_0,
    COUNT(CASE WHEN LB.balance_days < 0 THEN LB.id END) AS NEG_BAL -- Check any balance value is negative.
FROM public.integ_leave_op_balance_imp LB
INNER JOIN payroll_emp_data.employee_core_info ECI ON LB.employee_code = ECI.pin_no
LEFT JOIN payroll_emp_data.employeeleavegroupmapping EGM ON ECI.id = EGM.employee_id
LEFT JOIN payroll_emp_data.leavegroupsetup LGS ON EGM.leavegroupid = LGS.leavegroupid;



--2. Checking if there are any leave types which has carry forward other than annual leave
SELECT COUNT(1)
FROM public.integ_leave_op_balance_imp
WHERE leave_type_code <> '00' AND days_leave_bf > 0;


--3. Missing day wise line data in interim

--integ leave app line imp
SELECT L.employee_code,L.start_date,L.end_date,L.leave_type_code
FROM public.integ_leave_app_imp L
LEFT JOIN public.integ_leave_app_line_imp LI ON L.id = LI.leave_app_imp_id
WHERE LI.leave_app_imp_id IS NULL;

--integ work away line imp
SELECT L.employee_code,L.doc_date
FROM public.integ_work_away_office_imp L
LEFT JOIN public.integ_work_away_office_line_imp LI ON L.id = LI.work_away_office_imp_id
WHERE LI.work_away_office_imp_id IS NULL;



--4. Duplicate application in get_day_wise_lv_visit_wfa has any effect in iterim?

SELECT W.employee_code, WL.attend_date, COUNT(W.id) AS Total_Duplicate
FROM public.integ_work_away_office_imp W
INNER JOIN public.integ_work_away_office_line_imp WL ON W.id = WL.work_away_office_imp_id
GROUP BY W.employee_code, DATE(WL.attend_date)
HAVING COUNT(W.id) > 1;

SELECT W.employee_code, WL.leave_date,W.leave_type_code, COUNT(W.id) AS Total_Duplicate
FROM public.integ_leave_app_imp W
INNER JOIN public.integ_leave_app_line_imp WL ON W.id = WL.leave_app_imp_id
GROUP BY W.employee_code, DATE(WL.leave_date),W.leave_type_code
HAVING COUNT(W.id) > 1;


--5. Duplicate application in get_attend_raw_data_with_flag has any effect in interim?

SELECT employee_profile_id,DATE(atten_date), COUNT(id) AS Total_Duplicate
FROM hr_attend_summary_daily
GROUP BY employee_profile_id,DATE(atten_date)
HAVING COUNT(id) > 1;



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
    FROM payroll_leave_attend_data.leave_master LM
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
WHERE leave_type_id IN ('8','18') AND last_year_closing_leave_balance > 0;





--3. Missing day wise line data in source----


--leave tools application missing in detailed day wise data (after merging them both)
WITH BASE_CTE AS(
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
), merge_sqlserver AS(
    select a.pin, a.generate_date, a.flag, a.application_type from payroll_leave_attend_data.get_day_wise_lv_visit_wfa a
--     UNION
--     select b.staffpin pin, b.att_date generate_date, b.flag, null as application_type from payroll_leave_attend_data.get_attendance_raw_data_with_flag_8may25_2 b
)
select lm.id ignore_me, u.pin, lm.employee_id, lm.leave_year, lts.leavename, lm.application_date, lm.from_date, lm.to_date, lm.leave_duration, lm.status, lm.is_deleted, lm.is_manual, lm.recon_status, lm.recon_from_date, lm.recon_to_date, lm.approval_action_time
-- select lts.leavename, count(lm.id) total_missing
from payroll_leave_attend_data.leave_master LM
INNER JOIN payroll_emp_data.users U ON LM.employee_id = U.id
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
INNER JOIN payroll_leave_attend_data.employee_records_wave0 wave0 ON U.pin = wave0.pin
-- INNER JOIN payroll_leave_attend_data.employee_records_beta beta ON U.pin = beta.pin
LEFT JOIN payroll_leave_attend_data.leavetypesetup LTS ON LM.leave_type_id = LTS.id
-- left JOIN payroll_leave_attend_data.get_day_wise_lv_visit_wfa_8may25 DL ON U.pin = DL.pin
--     AND LTS.leavename = DL.application_type
--     AND (DATE(DL.generate_date) >= DATE(lm.from_date)
--     AND DATE(DL.generate_date) <= DATE(lm.to_date))
left JOIN merge_sqlserver DL ON U.pin = DL.pin
    AND (DATE(DL.generate_date) >= DATE(lm.from_date)
    AND DATE(DL.generate_date) <= DATE(lm.to_date))
WHERE EXTRACT('YEAR' FROM LM.to_date) >= 2025 --and EXTRACT('YEAR' FROM LM.to_date) < 2025
    --AND LTS.leavename = 'Annual Leave '
    AND LM.leave_duration > 0 AND LM.status = 1 AND LM.is_deleted <> 1 AND LM.is_manual = 0 and dl.pin is null and lm.approval_action_time < '2025-05-25 23:34:00.000000'
-- group by lts.leavename

UNION

select lo.id ignore_me, u.pin, lo.employee_id, lo.leave_year, lts.leavename, lo.application_date, LO.from_date, LO.to_date, lo.leave_duration, lo.status, lo.is_deleted, lo.is_manual, lo.recon_status, lo.recon_from_date, lo.recon_to_date, lo.approval_action_time
-- select lts.leavename, count(LO.id) total_missing
from payroll_leave_attend_data.leave_others LO
INNER JOIN payroll_emp_data.users U ON LO.employee_id = U.id
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
INNER JOIN payroll_leave_attend_data.employee_records_wave0 wave0 ON U.pin = wave0.pin
-- INNER JOIN payroll_leave_attend_data.employee_records_beta beta ON U.pin = beta.pin
LEFT JOIN payroll_leave_attend_data.leavetypesetup LTS ON LO.leave_type_id = LTS.id
-- left JOIN payroll_leave_attend_data.get_day_wise_lv_visit_wfa_8may25 DL ON U.pin = DL.pin
--     AND LTS.leavename = DL.application_type
--     AND (DATE(DL.generate_date) >= DATE(LO.from_date)
--     AND DATE(DL.generate_date) <= DATE(LO.to_date))
left JOIN merge_sqlserver DL ON U.pin = DL.pin
    AND (DATE(DL.generate_date) >= DATE(lo.from_date)
    AND DATE(DL.generate_date) <= DATE(lo.to_date))
WHERE EXTRACT('YEAR' FROM LO.to_date) >= 2025 --and EXTRACT('YEAR' FROM LM.to_date) < 2025
    --AND LTS.leavename = 'Accidental Leave'
    AND LO.leave_duration > 0 AND LO.status = 1 AND LO.is_deleted <> 1 AND LO.is_manual = 0 and dl.pin is null and lo.approval_action_time < '2025-05-25 23:34:00.000000'
-- group by lts.leavename

UNION

select vm.id ignore_me, u.pin, vm.employee_id, vm.leave_year, lts.leavename, vm.application_date, VM.from_date_time, VM.to_date_time, vm.duration, vm.status, vm.is_deleted, vm.is_manual, VM.recon_status, VM.recon_from_date_time, VM.recon_to_date_time, vm.approval_action_time
-- select lts.leavename, count(VM.id) total_missing
from payroll_leave_attend_data.visit_master VM
INNER JOIN payroll_emp_data.users U ON VM.employee_id = U.id
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
INNER JOIN payroll_leave_attend_data.employee_records_wave0 wave0 ON U.pin = wave0.pin
-- INNER JOIN payroll_leave_attend_data.employee_records_beta beta ON U.pin = beta.pin
LEFT JOIN payroll_leave_attend_data.leavetypesetup LTS ON VM.leavetype_id = LTS.id
-- left JOIN payroll_leave_attend_data.get_day_wise_lv_visit_wfa_8may25 DL ON U.pin = DL.pin
--     AND LTS.leavename = DL.application_type
--     AND (DATE(DL.generate_date) >= DATE(VM.from_date_time)
--     AND DATE(DL.generate_date) <= DATE(VM.to_date_time))
left JOIN merge_sqlserver DL ON U.pin = DL.pin
    AND (DATE(DL.generate_date) >= DATE(vm.from_date_time)
    AND DATE(DL.generate_date) <= DATE(vm.to_date_time))
WHERE EXTRACT('YEAR' FROM VM.to_date_time) >= 2025 --and EXTRACT('YEAR' FROM LM.to_date_time) < 2025
--     AND LTS.leavename = 'Work From Anywhere'
    AND VM.is_international_travel = false
    AND VM.duration > 0 AND VM.status = 1 AND VM.is_deleted <> 1 AND VM.is_manual = 0 and dl.pin is null
    and vm.approval_action_time < '2025-05-25 23:34:00.000000';
-- group by lts.leavename;




--4. Duplicate application in get_day_wise_lv_visit_wfa

WITH MAIN_CTE AS(
 SELECT pin,generate_date,COUNT(pin) AS Duplicate_Count,STRING_AGG(Flag,',') AS Duplicate_Flag
    FROM payroll_leave_attend_data.get_day_wise_lv_visit_wfa
WHERE application_type NOT IN('Visit','Work From Anywhere')
GROUP BY pin,generate_date
HAVING count(pin) > 1
),Last_CTE AS(
    SELECT pin,generate_date,Flag,COUNT(pin),STRING_AGG(Flag,',')
    FROM payroll_leave_attend_data.get_day_wise_lv_visit_wfa
WHERE application_type NOT IN('Visit','Work From Anywhere')
GROUP BY pin,generate_date,Flag
HAVING count(pin) > 1
)
SELECT M.*
FROM MAIN_CTE M
LEFT JOIN Last_CTE L ON M.pin = L.pin AND M.generate_date = L.generate_date
WHERE L.pin IS NULL AND EXTRACT('YEAR' FROM M.generate_date) >= 2025;


--5. Duplicate application in get_attend_raw_data_with_flag

SELECT staffpin,att_date,COUNT(staffpin)--,STRING_AGG(Flag,',')
    FROM payroll_leave_attend_data.get_attendance_raw_data_with_flag
GROUP BY staffpin,att_date
HAVING count(staffpin) > 1;


