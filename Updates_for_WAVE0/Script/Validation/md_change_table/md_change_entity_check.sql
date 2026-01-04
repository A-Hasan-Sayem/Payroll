---------------------------------------- Md change --------------------------
/* Ideally, each employee should have 4 entities, so any less than that are not okay.
   This query below finds out the employees which do not have 4 entities associated with them.
   */

SELECT employeepin, staffname, empl_profile_id, 4 - count(distinct entity_name) as missing_entity_count
    FROM
(SELECT a.pin as employeepin,
        a.staffname,
       e.id as empl_profile_id,
       case
           when mc.entity_name = mc.entity_name then mc.entity_name
           when ((mc.entity_name is null) and (mc.attend_tracking_type is not null)) then 'attend_tracking_type_exists'
        end as entity_name,
       mc.attend_tracking_type
FROM payroll_leave_attend_data.employee_records_beta_30 a
LEFT JOIN mdg_empl_profile e on a.pin = e.employee_code
LEFT JOIN hr_empl_leave_atten_md_change mc on e.id = mc.employee_profile_id
ORDER BY a.pin) A
GROUP BY employeepin, staffname, empl_profile_id
HAVING count(distinct entity_name) < 4
ORDER BY employeepin, missing_entity_count;