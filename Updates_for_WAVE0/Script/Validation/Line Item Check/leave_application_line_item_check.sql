-------------------------------------- LEAVE APPLICATION Line Item Missing Check START --------------------------------------------------------

-- destination line item check
select e.employee_code as employeepin,
       e.name,
       a.id as app_id,
       lt.leave_type_code,
       lt.name as leave_name,
    b.leave_application_id as app_line_id
from mdg_empl_profile e
left join hr_leave_application a on e.id = a.employee_profile_id
left join hr_leave_application_line b on a.id = b.leave_application_id
left join hmd_leave_profile_line hpl on a.leave_profile_line_id = hpl.id
left join hmd_leave_type lt on hpl.leave_type_id = lt.id
where a.id is not null and b.leave_application_id is null
and e.employee_code in (select pin from payroll_leave_attend_data.employee_records_beta_30); -- 30 user
-- and e.employee_code in (select employeepin from payroll_leave_attend_data.employee_records_beta_30); -- general user

-- interim line item check

select
    imp.employee_code as employeepin,
    CONCAT(
            COALESCE(imp.first_name, ''), ' ',
            COALESCE(imp.middle_name, ''), ' ',
            COALESCE(imp.last_name, '')
        ) as name,
    a.id as app_id,
    a.leave_type_code,
    lt.name as leave_name,
    b.leave_app_imp_id as app_line_id
from integ_employee_imp imp
left join integ_leave_app_imp a on imp.employee_code = a.employee_code
left join integ_leave_app_line_imp b on a.id = b.leave_app_imp_id
left join hmd_leave_type as lt on a.leave_type_code = lt.leave_type_code
where a.id is not null and b.leave_app_imp_id is null
and imp.employee_code in (select pin from payroll_leave_attend_data.employee_records_beta_30); -- 30 user
-- and imp.employee_code in (select employeepin from payroll_leave_attend_data.employee_records_beta_30); -- general user


-- effected employees

select distinct employee_code from (
select a.employee_code,  a.id, a.leave_type_code, b.leave_app_imp_id from integ_leave_app_imp a
left join integ_leave_app_line_imp b on a.id = b.leave_app_imp_id
where b.leave_app_imp_id is null) a -- 2137 user list
where employee_code in (select pin from payroll_leave_attend_data.employee_records_beta_30);

-------------------------------------- LEAVE APPLICATION Line Item Missing Check END --------------------------------------------------------
