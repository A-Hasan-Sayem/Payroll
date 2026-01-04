----------------------------------- WFA Application Total days check Start -----------------------------------------------
drop table if exists wfa_app;
create temporary table wfa_app AS
select b.pin as employee_code, e.name, w.id as app_id, w.total_days
from payroll_leave_attend_data.employee_records_beta_30 b
LEFT JOIN mdg_empl_profile e on b.pin = e.employee_code
LEFT JOIN hr_work_away_office w on e.id = w.employee_profile_id
WHERE w.work_away_type = '10'; -- wfa

drop table if exists wfa_app_line;
create temporary table wfa_app_line AS
select b.pin as employee_code, e.name, wl.work_away_office_id as line_app_id, count(wl.id) as total_days
from payroll_leave_attend_data.employee_records_beta_30 b
LEFT JOIN mdg_empl_profile e on b.pin = e.employee_code
LEFT JOIN hr_work_away_office w on e.id = w.employee_profile_id
LEFT JOIN hr_work_away_office_line wl on w.id = wl.work_away_office_id
WHERE w.work_away_type = '10' --wfa
GROUP BY b.pin, e.name, wl.work_away_office_id;

select la.employee_code as employeepin,
       la.name,
       la.app_id,
       ll.line_app_id,
       la.total_days as app_total_days,
       ll.total_days as line_total_days,
       la.total_days - ll.total_days as diff
from wfa_app la
LEFT JOIN wfa_app_line ll on la.app_id = ll.line_app_id
where la.total_days - ll.total_days <> 0;

----------------------------------------- WFA Application Total days check END -----------------------------------------------