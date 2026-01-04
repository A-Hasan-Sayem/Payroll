--------------------------------------------- WFA START -----------------------------------------------------------------


drop table if exists source;
create temporary table source AS
SELECT gu.pin as employee_pin,
       CONCAT(
            COALESCE(imp.first_name, ''), ' ',
            COALESCE(imp.middle_name, ''), ' ',
            COALESCE(imp.last_name, '')
        ) AS employee_name,
       w.work_away_type,
       min(wl.attend_date) as from_date,
       max(wl.attend_date) as to_date
FROM payroll_leave_attend_data.employee_records_beta_30 gu
LEFT JOIN cdc.integ_employee_imp imp on gu.pin = imp.employee_code
LEFT JOIN integ_work_away_office_imp w on imp.employee_code = w.employee_code
LEFT JOIN integ_work_away_office_line_imp wl on w.id = wl.work_away_office_imp_id
WHERE w.work_away_type = '10' -- wfa
GROUP BY gu.pin, CONCAT(
            COALESCE(imp.first_name, ''), ' ',
            COALESCE(imp.middle_name, ''), ' ',
            COALESCE(imp.last_name, '')
        ), w.work_away_type
ORDER BY gu.pin;

drop table if exists dest;
create temporary table dest as
SELECT
    gu.pin as employee_pin,
    e.name as employee_name,
    w.work_away_type,
    min(wl.attend_date) as from_date,
    max(wl.attend_date) as to_date
FROM payroll_leave_attend_data.employee_records_beta_30 gu
LEFT JOIN mdg_empl_profile e on gu.pin = e.employee_code
LEFT JOIN hr_work_away_office w on e.id = w.employee_profile_id
LEFT JOIN hr_work_away_office_line wl on w.id = wl.work_away_office_id
WHERE w.work_away_type = '10' -- wfa
GROUP BY gu.pin, e.name, w.work_away_type
ORDER BY gu.pin;

select employee_pin, employee_name, work_away_type, from_date, to_date from source
except
select employee_pin, employee_name, work_away_type, from_date, to_date  from dest;

------------------------------------------------WFA END ------------------------------------------------------------------