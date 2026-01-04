---------------------------------- DESTINATION Leave application Total days check START --------------------------------------------------
drop table if exists leave_app;
create temporary table leave_app AS
select b.pin as employee_code,
       e.name,
       lp.id as app_id,
       lt.leave_type_code,
       lt.name as leave_name,
       lp.total_days
from payroll_leave_attend_data.employee_records_beta_30 b
LEFT JOIN mdg_empl_profile e on b.pin = e.employee_code
LEFT JOIN hr_leave_application lp on e.id = lp.employee_profile_id
LEFT JOIN hmd_leave_profile_line hpl on lp.leave_profile_line_id = hpl.id
LEFT JOIN hmd_leave_type lt on hpl.leave_type_id = lt.id;

drop table if exists leave_app_line;
create temporary table leave_app_line AS
select b.pin as employee_code,
       e.name,
       lpl.leave_application_id as line_app_id,
       lt.leave_type_code,
       lt.name as leave_name,
       sum(lpl.leave_day) as total_days
from payroll_leave_attend_data.employee_records_beta_30 b
LEFT JOIN mdg_empl_profile e on b.pin = e.employee_code
LEFT JOIN hr_leave_application lp on e.id = lp.employee_profile_id
LEFT JOIN hr_leave_application_line lpl on lp.id = lpl.leave_application_id
LEFT JOIN hmd_leave_profile_line hpl on lp.leave_profile_line_id = hpl.id
LEFT JOIN hmd_leave_type lt on hpl.leave_type_id = lt.id
GROUP BY b.pin, e.name, lpl.leave_application_id, lt.leave_type_code, lt.name;

select la.employee_code,
       la.name,
       la.app_id,
       la.leave_type_code,
       la.leave_name,
       ll.line_app_id,
       la.total_days as app_total_days,
       ll.total_days as line_total_days,
       la.total_days - ll.total_days as diff
from leave_app la
LEFT JOIN leave_app_line ll on la.app_id = ll.line_app_id
WHERE (la.total_days - ll.total_days <> 0)
ORDER BY la.employee_code;
--    or ll.line_app_id is null;

---------------------------------- DESTINATION Leave application Total days check END --------------------------------------------------


