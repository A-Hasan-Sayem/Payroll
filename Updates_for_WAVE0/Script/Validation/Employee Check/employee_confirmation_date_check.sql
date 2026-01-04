------------------------------------------- Checking regular employees whether they have confirmation date or not START ----------

-- source
with source as (
select CONCAT(
            COALESCE(imp.first_name, ''), ' ',
            COALESCE(imp.middle_name, ''), ' ',
            COALESCE(imp.last_name, '')
        ) AS employee_name,
    imp.employee_code,
    imp.join_date_actual,
    imp.confirmation_date,
    ec.empl_type
    from cdc.integ_employee_imp imp -- we're using the cdc schema, because the change capture is happening in cdc and from there it is getting inserted into destination
    left join hmd_empl_category ec on imp.empl_category_code = ec.empl_category_code
WHERE imp.employee_code in (select a.pin from payroll_leave_attend_data.employee_records_beta_30 a)
and ec.empl_type=10 and imp.confirmation_date is null
),
-- dest
dest as (
select a.name, a.employee_code,a.join_date_actual,a.confirmation_date,a.empl_type from mdg_empl_profile a
where a.employee_code in (select a.pin from payroll_leave_attend_data.employee_records_beta_30 a)
and a.empl_type= 10 and a.confirmation_date is null)

select * from source -- first check up to source always!!! and then check dest
except
select * from dest;
------------------------------------------- Checking regular employees whether they have confirmation date or not END ----------


---------------------------- Employees with confirmation date null but have completed 6 months of work Start---------------


--source
with source as (
            select CONCAT(
            COALESCE(imp.first_name, ''), ' ',
            COALESCE(imp.middle_name, ''), ' ',
            COALESCE(imp.last_name, '')
        ) AS employee_name,
    imp.employee_code,
    imp.join_date_actual,
    imp.confirmation_date,
    ec.empl_type
    from cdc.integ_employee_imp imp
    left join hmd_empl_category ec on imp.empl_category_code = ec.empl_category_code
WHERE imp.employee_code in (select a.pin from payroll_leave_attend_data.employee_records_beta_30 a)
and ec.empl_type=10 and (imp.join_date_actual+ INTERVAL '6 months') <> imp.confirmation_date
),
dest as (
-- dest
select a.name, a.employee_code, a.join_date_actual,a.confirmation_date,a.empl_type from mdg_empl_profile a
where a.employee_code in (select a.pin from payroll_leave_attend_data.employee_records_beta_30 a)
and  (a.join_date_actual+ INTERVAL '6 months') <> a.confirmation_date)

select * from source
except
select * from dest;


---------------------------- Employees with confirmation date null but have completed 6 months of work END---------------
