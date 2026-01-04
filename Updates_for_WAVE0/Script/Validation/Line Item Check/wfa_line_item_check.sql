
--------------------------------------- WFA LINE ITEM MISSING START--------------------------------------------------------------
-- destination side

select
       e.employee_code as employeepin,
       e.name,
       w.id as application_id,
       w.work_away_type,
       wl.work_away_office_id as application_line_id
 from mdg_empl_profile e
left join hr_work_away_office w on e.id = w.employee_profile_id
left join hr_work_away_office_line wl on w.id = wl.work_away_office_id
where w.work_away_type = 10 and  wl.work_away_office_id is null
and e.employee_code in (select pin from payroll_leave_attend_data.employee_records_beta_30);

--

-- source

select a.employee_code as employeepin,
       CONCAT(
            COALESCE(e.first_name, ''), ' ',
            COALESCE(e.middle_name, ''), ' ',
            COALESCE(e.last_name, '')
        ) as name,
    a.id as application_id,
    a.work_away_type,
    b.work_away_office_imp_id as application_line_id
from cdc.integ_employee_imp e
inner join integ_work_away_office_imp a on e.employee_code = a.employee_code
left join integ_work_away_office_line_imp b on a.id = b.work_away_office_imp_id
where a.work_away_type = 10 and b.work_away_office_imp_id is null
and  a.employee_code in (select pin from payroll_leave_attend_data.employee_records_beta_30);

-- 21 beta user found
select distinct a.employee_code from (
select a.employee_code, a.id, a.work_away_type, b.work_away_office_imp_id from integ_work_away_office_imp a
left join integ_work_away_office_line_imp b on a.id = b.work_away_office_imp_id
where a.work_away_type = 10 and b.work_away_office_imp_id is null
and a.employee_code in (select pin from payroll_leave_attend_data.employee_records_beta_30)) a;

-- 44 general user found
select distinct a.employee_code from (
select a.employee_code, a.id, a.work_away_type, b.work_away_office_imp_id from integ_work_away_office_imp a
left join integ_work_away_office_line_imp b on a.id = b.work_away_office_imp_id
where a.work_away_type = 10 and b.work_away_office_imp_id is null
-- and a.employee_code in (select employeepin from payroll_leave_attend_data.employee_records_beta_30)
) a;

--------------------------------------- WFA LINE ITEM MISSING END--------------------------------------------------------------