-- leave tools application missing in detailed day wise data (after merging them both)
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


--00153763 -> 29 jan 2025
--Annual Leave application missing in day wise data 13396
--Compensatory Leave application missing in day wise data 3222
--Leave Without Pay application missing in day wise data 301
--Sick Leave application missing in day wise data 6327
--Bereavement Leave application missing in day wise data 54

--Accidental Leave application missing in day wise data 40
--Extra Ordinary Leave application missing in day wise data 2
--Maternity Leave application missing in day wise data 37
--Maternity Leave - without pay application missing in day wise data 2
--Paternity Leave application missing in day wise data 134
--Quarantine Leave application missing in day wise data 22
--Transfer Leave application missing in day wise data 10
--With pay application missing in day wise data 23

--Visit application missing in day wise data 20860
--Work From Anywhere application missing in day wise data 3570

-- select (23300+270+24430) --> total missing application 48000


------------------------------1597


select * from payroll_leave_attend_data.get_day_wise_lv_visit_wfa DL
where pin='00197198' and date(generate_date) = '2025-04-17';


select count(1) from payroll_leave_attend_data.get_day_wise_lv_visit_wfa;

SELECT count(1), min(generate_date), max(generate_date)
FROM payroll_leave_attend_data.get_day_wise_lv_visit_wfa
where EXTRACT('YEAR' FROM generate_date) <= 2025;


select count(1) from payroll_leave_attend_data.get_day_wise_lv_visit_wfa;
select count(1) from payroll_leave_attend_data.get_attendance_raw_data_with_flag;


