WITH source as (
select CONCAT(
            COALESCE(imp.first_name, ''), ' ',
            COALESCE(imp.middle_name, ''), ' ',
            COALESCE(imp.last_name, '')
        ) AS employee_name,
    imp.employee_code,
    imp.join_date_actual,
    imp.confirmation_date,
    ec.empl_type,
    imp.contract_end_date
    from cdc.integ_employee_imp imp
    left join hmd_empl_category ec on imp.empl_category_code = ec.empl_category_code
WHERE imp.employee_code in (select a.pin from payroll_leave_attend_data.employee_records_beta_30 a)
and ec.empl_type = 60
and (imp.contract_end_date is null or  EXTRACT(YEAR FROM imp.contract_end_date)*100+EXTRACT(MONTH FROM imp.contract_end_date)<202508)
  and ec.empl_category_code='C')
  ,
dest as (
    select  a.name, a.employee_code, a.join_date_actual,a.confirmation_date,a.empl_type,a.contract_end_date
from mdg_empl_profile a
inner join hmd_empl_category b on a.empl_category_id=b.id
where a.employee_code in (select a.pin from payroll_leave_attend_data.employee_records_beta_30 a)and a.empl_type=60 and
      (a.contract_end_date is null or  EXTRACT(YEAR FROM a.contract_end_date)*100+EXTRACT(MONTH FROM a.contract_end_date)<202508)
  and b.empl_category_code='C'
)

select * from source
EXCEPT
select * from dest;

------------------------------------------- Checking if contractual employees have contract end dates or not END -------



