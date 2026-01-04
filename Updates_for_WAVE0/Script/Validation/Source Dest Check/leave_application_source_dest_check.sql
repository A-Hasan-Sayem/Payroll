--------------------------------------------- LEAVE APPLICATION SOURCE DEST CHECK START ------------------------------------------------------
drop table if exists source;
create temporary table source AS
SELECT
    DISTINCT gu.pin as employee_pin,
    CONCAT(
            COALESCE(imp.first_name, ''), ' ',
            COALESCE(imp.middle_name, ''), ' ',
            COALESCE(imp.last_name, '')
        ) AS employee_name,
    lt.name as leave_name,
    lt.leave_type_code as leave_code,
    la.duration_type,
    la.start_date,
    la.end_date
FROM payroll_leave_attend_data.employee_records_beta_30 gu
LEFT JOIN cdc.integ_employee_imp imp on gu.pin = imp.employee_code
LEFT JOIN integ_leave_app_imp la on imp.employee_code = la.employee_code
LEFT JOIN hmd_leave_type lt on la.leave_type_code = lt.leave_type_code
ORDER BY gu.pin;

drop table if exists dest;
create temporary table dest as
    SELECT
    DISTINCT
    gu.pin as employee_pin,
    e.name as employee_name,
    lt.name as leave_name,
    lt.leave_type_code as leave_code,
    ha.duration_type,
    ha.start_date,
    ha.end_date
from payroll_leave_attend_data.employee_records_beta_30 gu
LEFT JOIN mdg_empl_profile e on gu.pin = e.employee_code
LEFT JOIN hr_leave_application ha on e.id = ha.employee_profile_id
LEFT JOIN hmd_leave_profile_line hpl on ha.leave_profile_line_id = hpl.id
LEFT JOIN hmd_leave_type lt on hpl.leave_type_id = lt.id
ORDER BY gu.pin;

select employee_pin, employee_name, leave_name, leave_code, duration_type, start_date, end_date from source
except
select employee_pin, employee_name, leave_name, leave_code, duration_type, start_date, end_date from dest;

--------------------------------------------- LEAVE APPLICATION SOURCE DEST CHECK END ------------------------------------------------------

select * from integ_employee_imp where employee_code = '01532225';

select * from payroll_leave_attend_data.employee_records_beta_30 where pin = '01532225'
select * from payroll_leave_attend_data.leave_master where employee_id = 163019
select * from payroll_emp_data.users where pin = '01532225'