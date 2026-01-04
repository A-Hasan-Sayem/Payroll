--------------------------------------- ATTENDANCE RECONCILE START------------------------------------------------------------

drop table if exists source;
create temporary table source AS
SELECT
    distinct gu.pin as employee_pin,
    -- imp.id as empl_id,
    CONCAT(
            COALESCE(imp.first_name, ''), ' ',
            COALESCE(imp.middle_name, ''), ' ',
            COALESCE(imp.last_name, '')
        ) AS employee_name,
    imp_attend.atten_date
FROM payroll_leave_attend_data.employee_records_beta_30 gu
LEFT JOIN cdc.integ_employee_imp imp on gu.pin = imp.employee_code
LEFT JOIN integ_attend_missed_app_imp imp_attend ON gu.pin = imp_attend.employee_code
LEFT JOIN mdg_empl_profile e on imp.employee_code = e.employee_code
ORDER BY gu.pin;

drop table if exists dest;
create temporary table dest AS
    SELECT
    distinct gu.pin as employee_pin,
    -- e.id as empl_id,
    e.name as employee_name,
    hm.atten_date
FROM payroll_leave_attend_data.employee_records_beta_30 gu
LEFT JOIN mdg_empl_profile e on gu.pin = e.employee_code
LEFT JOIN hr_attend_missed_app hm on e.id = hm.employee_profile_id
ORDER BY gu.pin;

-- check

select employee_pin, employee_name, atten_date from source
except
select employee_pin, employee_name, atten_date from dest;

---------------------------------------------Attendance Reconcile END-------------------------------------------------------

-- issue checking

select * from dest where employee_pin  in (
        SELECT distinct employee_pin FROM (select employee_pin, employee_name, atten_date
                                           from source
                                           except
                                           select employee_pin, employee_name, atten_date
                                           from dest) A);

SELECT * from hr_attend_missed_app where employee_profile_id in (
    SELECT id from mdg_empl_profile where employee_code in ( select employee_pin from dest where employee_pin  in (
        SELECT distinct employee_pin FROM (select employee_pin, employee_name, atten_date
                                           from source
                                           except
                                           select employee_pin, employee_name, atten_date
                                           from dest) A )
                                     )
    );


SELECT * from hr_attend_missed_app where employee_profile_id in (
    SELECT id from mdg_empl_profile where employee_code = '00012600'
    );