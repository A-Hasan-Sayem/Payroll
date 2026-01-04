------------------------------------------------NULL COUNT CHECK WITH INTERIM BETA USER ---------------------------



-- Drop temp tables if exist
drop table if exists temp_null_counts_mapping;
drop table if exists temp_null_counts_original;

-- Create temp tables
create temp table temp_null_counts_mapping (
    column_name text,
    null_count bigint
);

create temp table temp_null_counts_original (
    column_name text,
    null_count bigint
);

-- Insert null counts for cdc.integ_employee_imp (Mapping table)
insert into temp_null_counts_mapping (column_name, null_count)
values
('employee_code', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where imp.employee_code is null)),
('first_name', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where first_name is null)),
('middle_name', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where middle_name is null)),
('last_name', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where last_name is null)),
('father_name', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where father_name is null)),
('mother_name', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where mother_name is null)),
('national_id', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where national_id is null)),
('join_date_actual', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where join_date_actual is null)),
('confirmation_date', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where confirmation_date is null)),
('contract_end_date', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where contract_end_date is null)),
('employee_job_status', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where employee_job_status is null)),
('email_company', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where email_company is null)),
('current_address', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where current_address is null)),
('permanent_address', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where permanent_address is null)),
('birth_date', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where  birth_date is null)),
('gross_salary', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where gross_salary is null)),
('bonus_entitlement_status', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where bonus_entitlement_status is null)),
('bank_branch_name', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where bank_branch_name is null)),
('empl_bank_account_no', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where empl_bank_account_no is null)),
('gender', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where gender is null)),
('tin_no', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where tin_no is null)),
('salary_circle', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where salary_circle is null)),
('supervisor_empl_code', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where supervisor_empl_code is null)),
('holiday_calendar_code', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where holiday_calendar_code is null)),
('religion', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where religion is null)),
('grade_code', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where grade_code is null)),
('grade_sub_code', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where grade_sub_code is null)),
('group_code', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where group_code is null)),
('section_code', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where section_code is null)),
('empl_category_code', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where empl_category_code is null)),
('work_shift_code', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where work_shift_code is null)),
('work_shift_rotated', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where work_shift_rotated is null)),
('work_shift_rotate_rule_code', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where work_shift_rotate_rule_code is null)),
('nationality_country', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where nationality_country is null)),
('operating_location_code', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where operating_location_code is null)),
('designation_code', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where designation_code is null)),
('phone_home', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where phone_home is null)),
('phone_work_direct', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where phone_work_direct is null)),
('phone_mobile', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where phone_mobile is null)),
('leave_profile_code', (select count(1) from cdc.integ_employee_imp imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where leave_profile_code is null));

-- Insert null counts for mdg_empl_profile (Original table)
insert into temp_null_counts_original (column_name, null_count)
values
('employee_code', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where employee_code is null)),
('first_name', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where first_name is null)),
('middle_name', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where middle_name is null)),
('last_name', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where last_name is null)),
('father_name', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where father_name is null)),
('mother_name', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where mother_name is null)),
('national_id', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where national_id is null)),
('join_date_actual', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where join_date_actual is null)),
('confirmation_date', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where confirmation_date is null)),
('contract_end_date', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where contract_end_date is null)),
('employment_status', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where employment_status is null)),
('email_company', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where email_company is null)),
('current_address', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where current_address is null)),
('permanent_address', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where permanent_address is null)),
('birth_date', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where birth_date is null)),
('gross_salary', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where gross_salary is null)),
('bonus_entitlement_status', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where bonus_entitlement_status is null)),
('bank_branch_name', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where bank_branch_name is null)),
('bank_account', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where bank_account is null)),
('gender', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where gender is null)),
('tax_identification_no', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where tax_identification_no is null)),
('tax_salary_circle', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where tax_salary_circle is null)),
('manager_id', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where manager_id is null)),
('holiday_calendar_id', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where holiday_calendar_id is null)),
('religion_id', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where religion_id is null)),
('empl_grade_id', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where empl_grade_id is null)),
('empl_grade_sub_id', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where empl_grade_sub_id is null)),
('employee_group_id', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where employee_group_id is null)),
('section_id', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where section_id is null)),
('empl_category_id', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where empl_category_id is null)),
('work_shift_id', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where work_shift_id is null)),
('work_shift_rotated', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where work_shift_rotated is null)),
('work_shift_rotate_rule_id', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where work_shift_rotate_rule_id is null)),
('nationality_id', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where nationality_id is null)),
('operating_location_id', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where operating_location_id is null)),
('designation_id', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where designation_id is null)),
('phone_home', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where phone_home is null)),
('phone_work_direct', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where phone_work_direct is null)),
('phone_mobile', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where phone_mobile is null)),
('leave_profile_id', (select count(1) from mdg_empl_profile imp inner join payroll_leave_attend_data.employee_records_beta_30 gu on imp.employee_code=gu.pin where leave_profile_id is null));

-- Now use custom column mapping for final comparison
with column_mapping as (
    select * from (values
        ('employee_code', 'employee_code'),
        ('first_name', 'first_name'),
        ('middle_name', 'middle_name'),
        ('last_name', 'last_name'),
        ('father_name', 'father_name'),
        ('mother_name', 'mother_name'),
        ('national_id', 'national_id'),
        ('join_date_actual', 'join_date_actual'),
        ('confirmation_date', 'confirmation_date'),
        ('contract_end_date', 'contract_end_date'),
        ('employee_job_status', 'employment_status'),
        ('email_company', 'email_company'),
        ('current_address', 'current_address'),
        ('permanent_address', 'permanent_address'),
        ('birth_date', 'birth_date'),
        ('gross_salary', 'gross_salary'),
        ('bonus_entitlement_status', 'bonus_entitlement_status'),
        ('bank_branch_name', 'bank_branch_name'),
        ('empl_bank_account_no', 'bank_account'),
        ('gender', 'gender'),
        ('tin_no', 'tax_identification_no'),
        ('salary_circle', 'tax_salary_circle'),
        ('supervisor_empl_code', 'manager_id'),
        ('holiday_calendar_code', 'holiday_calendar_id'),
        ('religion', 'religion_id'),
        ('grade_code', 'empl_grade_id'),
        ('grade_sub_code', 'empl_grade_sub_id'),
        ('group_code', 'employee_group_id'),
        ('section_code', 'section_id'),
        ('empl_category_code', 'empl_category_id'),
        ('work_shift_code', 'work_shift_id'),
        ('work_shift_rotated', 'work_shift_rotated'),
        ('work_shift_rotate_rule_code', 'work_shift_rotate_rule_id'),
        ('nationality_country', 'nationality_id'),
        ('operating_location_code', 'operating_location_id'),
        ('designation_code', 'designation_id'),
        ('phone_home', 'phone_home'),
        ('phone_work_direct', 'phone_work_direct'),
        ('phone_mobile', 'phone_mobile'),
        ('leave_profile_code', 'leave_profile_id')
    ) as t(mapping_column, original_column)
)
select
    c.mapping_column,
    m.null_count as mapping_nulls,
    c.original_column,
    o.null_count as original_nulls,
    case
        when m.null_count is null then 'Mapping missing'
        when o.null_count is null then 'Original missing'
        when m.null_count = o.null_count then 'null count matched'
        when m.null_count is not null and o.null_count = 0 then 'handled null values'
        else 'null count mismatched'
    end as match_status
from column_mapping c
left join temp_null_counts_mapping m on c.mapping_column = m.column_name
left join temp_null_counts_original o on c.original_column = o.column_name
order by c.mapping_column;
 -------------------------------------------------END ------------------------------------------------------------------

 select employee_code, confirmation_date from cdc.integ_employee_imp
where employee_code in ('00264114','00275307');
--       (select pin from payroll_leave_attend_data.employee_records_beta_30) and confirmation_date is null;


select name, employee_code, confirmation_date from mdg_empl_profile
where employee_code in (select pin from payroll_leave_attend_data.employee_records_beta_30) and confirmation_date is null;