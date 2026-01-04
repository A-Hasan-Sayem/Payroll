
------------------------------------------------------ Table Map Cross Check START ----------------------------------------------------

drop table if exists public.table_map_migration;

create table table_map_migration
(
    mapping_table  text,
    original_table text
);

INSERT INTO public.table_map_migration (mapping_table, original_table) VALUES ('integ_work_away_office_imp', 'hr_work_away_office');
INSERT INTO public.table_map_migration (mapping_table, original_table) VALUES ('integ_work_away_office_line_imp', 'hr_work_away_office_line');
INSERT INTO public.table_map_migration (mapping_table, original_table) VALUES ('integ_attend_missed_app_imp', 'hr_attend_missed_app');
INSERT INTO public.table_map_migration (mapping_table, original_table) VALUES ('INTEG_LEAVE_APP_IMP', 'HR_LEAVE_APPLICATION');
INSERT INTO public.table_map_migration (mapping_table, original_table) VALUES ('INTEG_LEAVE_APP_LINE_IMP', 'HR_LEAVE_APPLICATION_LINE');
INSERT INTO public.table_map_migration (mapping_table, original_table) VALUES ('INTEG_EMPLOYEE_IMP', 'MDG_EMPL_PROFILE');
INSERT INTO public.table_map_migration (mapping_table, original_table) VALUES ('INTEG_DEPARTMENT_IMP', 'MDG_DEPARTMENT');
INSERT INTO public.table_map_migration (mapping_table, original_table) VALUES ('INTEG_SECTION_IMP', 'MDG_DEPT_SECTION');
INSERT INTO public.table_map_migration (mapping_table, original_table) VALUES ('INTEG_OPER_LOCATION_IMP', 'MDG_OPERATING_LOCATION');
INSERT INTO public.table_map_migration (mapping_table, original_table) VALUES ('INTEG_DESIGNATION_IMP', 'HMD_DESIGNATION');
INSERT INTO public.table_map_migration (mapping_table, original_table) VALUES ('integ_leave_op_balance_imp', 'HR_LEAVE_OPENING_BALANCE');




drop table data_migration_cross_check;
---  Data Migration cross check
Create TEMPORARY TABLE data_migration_cross_check
(original_table varchar(250),mapping_table varchar(250), original_Count integer,mapping_Count integer,match_yes varchar
                                                  );

delete from data_migration_cross_check;
DO $$
DECLARE
    rec RECORD;
    original_count BIGINT;
    mapping_count BIGINT;
BEGIN
    FOR rec IN SELECT lower(mapping_table) mapping_table,lower(original_table) original_table
               FROM table_map_migration a -- where ltrim(rtrim(a.mapping_table))='INTEG_DEPARTMENT_IMP'
    LOOP
        EXECUTE format('SELECT COUNT(*) FROM %I', rec.original_table) INTO original_count;
        EXECUTE format('SELECT COUNT(*) FROM %I', rec.mapping_table) INTO mapping_count;

        insert into data_migration_cross_check
        values (rec.original_table,
            rec.mapping_table,
            original_count,
            mapping_count,
            CASE WHEN original_count = mapping_count THEN 'Yes' ELSE 'No' END);
    END LOOP;
END$$;

select * from data_migration_cross_check;

------------------------------------------------------ Table Map Cross Check END ----------------------------------------------------





-------------------------------- NULL COUNT CHECK WITH Interim Columns Start General User --------------------------------------------


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

-- Insert null counts for integ_employee_imp (Mapping table)
insert into temp_null_counts_mapping (column_name, null_count)
values
('employee_code', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where imp.employee_code is null)),
('first_name', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where first_name is null)),
('middle_name', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where middle_name is null)),
('last_name', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where last_name is null)),
('father_name', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where father_name is null)),
('mother_name', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where mother_name is null)),
('national_id', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where national_id is null)),
('join_date_actual', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where join_date_actual is null)),
('confirmation_date', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where confirmation_date is null)),
('contract_end_date', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where contract_end_date is null)),
('employee_job_status', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where employee_job_status is null)),
('email_company', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where email_company is null)),
('current_address', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where current_address is null)),
('permanent_address', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where permanent_address is null)),
('birth_date', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where  birth_date is null)),
('gross_salary', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where gross_salary is null)),
('bonus_entitlement_status', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where bonus_entitlement_status is null)),
('bank_branch_name', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where bank_branch_name is null)),
('empl_bank_account_no', (select count(*) from integ_employee_imp where imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin empl_bank_account_no is null)),
('gender', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where gender is null)),
('tin_no', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where tin_no is null)),
('salary_circle', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where salary_circle is null)),
('supervisor_empl_code', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where supervisor_empl_code is null)),
('holiday_calendar_code', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where holiday_calendar_code is null)),
('religion', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where religion is null)),
('grade_code', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where grade_code is null)),
('grade_sub_code', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where grade_sub_code is null)),
('group_code', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where group_code is null)),
('section_code', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where section_code is null)),
('empl_category_code', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where empl_category_code is null)),
('work_shift_code', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where work_shift_code is null)),
('work_shift_rotated', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where work_shift_rotated is null)),
('work_shift_rotate_rule_code', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where work_shift_rotate_rule_code is null)),
('nationality_country', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where nationality_country is null)),
('operating_location_code', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where operating_location_code is null)),
('designation_code', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where designation_code is null)),
('phone_home', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where phone_home is null)),
('phone_work_direct', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where phone_work_direct is null)),
('phone_mobile', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where phone_mobile is null)),
('leave_profile_code', (select count(*) from integ_employee_imp imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where leave_profile_code is null));

-- Insert null counts for mdg_empl_profile (Original table)
insert into temp_null_counts_original (column_name, null_count)
values
('employee_code', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where employee_code is null)),
('first_name', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where first_name is null)),
('middle_name', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where middle_name is null)),
('last_name', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where last_name is null)),
('father_name', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where father_name is null)),
('mother_name', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where mother_name is null)),
('national_id', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where national_id is null)),
('join_date_actual', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where join_date_actual is null)),
('confirmation_date', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where confirmation_date is null)),
('contract_end_date', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where contract_end_date is null)),
('employment_status', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where employment_status is null)),
('email_company', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where email_company is null)),
('current_address', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where current_address is null)),
('permanent_address', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where permanent_address is null)),
('birth_date', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where birth_date is null)),
('gross_salary', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where gross_salary is null)),
('bonus_entitlement_status', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where bonus_entitlement_status is null)),
('bank_branch_name', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where bank_branch_name is null)),
('bank_account', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where bank_account is null)),
('gender', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where gender is null)),
('tax_identification_no', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where tax_identification_no is null)),
('tax_salary_circle', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where tax_salary_circle is null)),
('manager_id', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where manager_id is null)),
('holiday_calendar_id', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where holiday_calendar_id is null)),
('religion_id', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where religion_id is null)),
('empl_grade_id', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where empl_grade_id is null)),
('empl_grade_sub_id', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where empl_grade_sub_id is null)),
('employee_group_id', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where employee_group_id is null)),
('section_id', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where section_id is null)),
('empl_category_id', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where empl_category_id is null)),
('work_shift_id', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where work_shift_id is null)),
('work_shift_rotated', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where work_shift_rotated is null)),
('work_shift_rotate_rule_id', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where work_shift_rotate_rule_id is null)),
('nationality_id', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where nationality_id is null)),
('operating_location_id', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where operating_location_id is null)),
('designation_id', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where designation_id is null)),
('phone_home', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where phone_home is null)),
('phone_work_direct', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where phone_work_direct is null)),
('phone_mobile', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where phone_mobile is null)),
('leave_profile_id', (select count(*) from mdg_empl_profile imp inner join general_user_with_default_role gu on imp.employee_code=gu.employeepin where leave_profile_id is null));

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


------------------------------------------------ NULL COUNT CHECK WITH Interim Columns General User END --------------------------------------------


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

-- Insert null counts for integ_employee_imp (Mapping table)
insert into temp_null_counts_mapping (column_name, null_count)
values
('employee_code', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where imp.employee_code is null)),
('first_name', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where first_name is null)),
('middle_name', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where middle_name is null)),
('last_name', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where last_name is null)),
('father_name', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where father_name is null)),
('mother_name', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where mother_name is null)),
('national_id', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where national_id is null)),
('join_date_actual', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where join_date_actual is null)),
('confirmation_date', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where confirmation_date is null)),
('contract_end_date', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where contract_end_date is null)),
('employee_job_status', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where employee_job_status is null)),
('email_company', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where email_company is null)),
('current_address', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where current_address is null)),
('permanent_address', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where permanent_address is null)),
('birth_date', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where  birth_date is null)),
('gross_salary', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where gross_salary is null)),
('bonus_entitlement_status', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where bonus_entitlement_status is null)),
('bank_branch_name', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where bank_branch_name is null)),
('empl_bank_account_no', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where empl_bank_account_no is null)),
('gender', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where gender is null)),
('tin_no', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where tin_no is null)),
('salary_circle', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where salary_circle is null)),
('supervisor_empl_code', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where supervisor_empl_code is null)),
('holiday_calendar_code', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where holiday_calendar_code is null)),
('religion', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where religion is null)),
('grade_code', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where grade_code is null)),
('grade_sub_code', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where grade_sub_code is null)),
('group_code', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where group_code is null)),
('section_code', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where section_code is null)),
('empl_category_code', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where empl_category_code is null)),
('work_shift_code', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where work_shift_code is null)),
('work_shift_rotated', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where work_shift_rotated is null)),
('work_shift_rotate_rule_code', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where work_shift_rotate_rule_code is null)),
('nationality_country', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where nationality_country is null)),
('operating_location_code', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where operating_location_code is null)),
('designation_code', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where designation_code is null)),
('phone_home', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where phone_home is null)),
('phone_work_direct', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where phone_work_direct is null)),
('phone_mobile', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where phone_mobile is null)),
('leave_profile_code', (select count(*) from integ_employee_imp imp inner join beta_user gu on imp.employee_code=gu.employeepin where leave_profile_code is null));

-- Insert null counts for mdg_empl_profile (Original table)
insert into temp_null_counts_original (column_name, null_count)
values
('employee_code', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where employee_code is null)),
('first_name', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where first_name is null)),
('middle_name', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where middle_name is null)),
('last_name', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where last_name is null)),
('father_name', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where father_name is null)),
('mother_name', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where mother_name is null)),
('national_id', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where national_id is null)),
('join_date_actual', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where join_date_actual is null)),
('confirmation_date', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where confirmation_date is null)),
('contract_end_date', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where contract_end_date is null)),
('employment_status', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where employment_status is null)),
('email_company', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where email_company is null)),
('current_address', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where current_address is null)),
('permanent_address', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where permanent_address is null)),
('birth_date', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where birth_date is null)),
('gross_salary', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where gross_salary is null)),
('bonus_entitlement_status', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where bonus_entitlement_status is null)),
('bank_branch_name', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where bank_branch_name is null)),
('bank_account', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where bank_account is null)),
('gender', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where gender is null)),
('tax_identification_no', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where tax_identification_no is null)),
('tax_salary_circle', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where tax_salary_circle is null)),
('manager_id', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where manager_id is null)),
('holiday_calendar_id', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where holiday_calendar_id is null)),
('religion_id', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where religion_id is null)),
('empl_grade_id', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where empl_grade_id is null)),
('empl_grade_sub_id', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where empl_grade_sub_id is null)),
('employee_group_id', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where employee_group_id is null)),
('section_id', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where section_id is null)),
('empl_category_id', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where empl_category_id is null)),
('work_shift_id', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where work_shift_id is null)),
('work_shift_rotated', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where work_shift_rotated is null)),
('work_shift_rotate_rule_id', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where work_shift_rotate_rule_id is null)),
('nationality_id', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where nationality_id is null)),
('operating_location_id', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where operating_location_id is null)),
('designation_id', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where designation_id is null)),
('phone_home', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where phone_home is null)),
('phone_work_direct', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where phone_work_direct is null)),
('phone_mobile', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where phone_mobile is null)),
('leave_profile_id', (select count(*) from mdg_empl_profile imp inner join beta_user gu on imp.employee_code=gu.employeepin where leave_profile_id is null));

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




---------------------------------------------  NUll count checking START -------------------------------------------------------------------------



drop table if exists redundant_table_cols;
create temporary table redundant_table_cols(table_name varchar, column_name varchar);

INSERT INTO redundant_table_cols (table_name, column_name) VALUES
-- hmd_designation
('hmd_designation', 'id'),
('hmd_designation', 'created_by'),
('hmd_designation', 'version'),
('hmd_designation', 'created_date'),
('hmd_designation', 'last_modified_by'),
('hmd_designation', 'last_modified_date'),

-- mdg_department
('mdg_department', 'id'),
('mdg_department', 'created_by'),
('mdg_department', 'created_date'),
('mdg_department', 'version'),
('mdg_department', 'last_modified_by'),
('mdg_department', 'last_modified_date'),

-- mdg_operating_location
('mdg_operating_location', 'id'),
('mdg_operating_location', 'name_local'),
('mdg_operating_location', 'address_local'),

-- hr_leave_application
('hr_leave_application', 'id'),
('hr_leave_application', 'version'),
('hr_leave_application', 'created_by'),
('hr_leave_application', 'created_date'),
('hr_leave_application', 'last_modified_by'),
('hr_leave_application', 'last_modified_date'),
('hr_leave_application', 'note'),
('hr_leave_application', 'deleted_by'),
('hr_leave_application', 'deleted_date'),
('hr_leave_application', 'leave_app_reversed_id'),
('hr_leave_application', 'exceeds_leave_entitlement'),
('hr_leave_application', 'doc_sent_to_hr_date'),
('hr_leave_application', 'doc_recvd_by_hr'),
('hr_leave_application', 'balance_days'),
('hr_leave_application', 'calendar_days'),
('hr_leave_application', 'working_days'),
('hr_leave_application', 'approver_username'),
('hr_leave_application', 'approver_date'),
('hr_leave_application', 'recall_date'),
('hr_leave_application', 'reference_application_id'),
('hr_leave_application', 'custom1'),

-- hr_leave_application_line
('hr_leave_application_line', 'id'),
('hr_leave_application_line', 'version'),
('hr_leave_application_line', 'created_by'),
('hr_leave_application_line', 'created_date'),
('hr_leave_application_line', 'last_modified_by'),
('hr_leave_application_line', 'last_modified_date'),
('hr_leave_application_line', 'remarks'),
('hr_leave_application_line', 'processed'),
('hr_leave_application_line', 'leave_app_line_reversed_id'),
('hr_leave_application_line', 'deleted_by'),
('hr_leave_application_line', 'deleted_date'),

-- hr_work_away_office
('hr_work_away_office', 'id'),
('hr_work_away_office', 'version'),
('hr_work_away_office', 'created_by'),
('hr_work_away_office', 'created_date'),
('hr_work_away_office', 'last_modified_by'),
('hr_work_away_office', 'last_modified_date'),
('hr_work_away_office', 'recall_date'),
('hr_work_away_office', 'file_ref_itinerary'),

-- hr_work_away_office_line
('hr_work_away_office_line', 'id'),
('hr_work_away_office_line', 'version'),
('hr_work_away_office_line', 'created_by'),
('hr_work_away_office_line', 'created_date'),
('hr_work_away_office_line', 'last_modified_by'),
('hr_work_away_office_line', 'last_modified_date'),

-- mdg_dept_section
('mdg_dept_section', 'id'),
('mdg_dept_section', 'version'),
('mdg_dept_section', 'created_by'),
('mdg_dept_section', 'created_date'),
('mdg_dept_section', 'last_modified_by'),
('mdg_dept_section', 'last_modified_date'),

-- hr_leave_opening_balance
('hr_leave_opening_balance', 'id'),
('hr_leave_opening_balance', 'version'),
('hr_leave_opening_balance', 'created_by'),
('hr_leave_opening_balance', 'created_date'),
('hr_leave_opening_balance', 'last_modified_by'),
('hr_leave_opening_balance', 'last_modified_date'),
('hr_leave_opening_balance', 'deleted_by'),
('hr_leave_opening_balance', 'deleted_date'),

-- hr_attend_missed_app
('hr_attend_missed_app', 'id'),
('hr_attend_missed_app', 'version'),
('hr_attend_missed_app', 'created_by'),
('hr_attend_missed_app', 'created_date'),
('hr_attend_missed_app', 'approver_username'),
('hr_attend_missed_app', 'approver_date'),
('hr_attend_missed_app', 'last_modified_by'),
('hr_attend_missed_app', 'last_modified_date'),
('hr_attend_missed_app', 'comments'),

-- mdg_empl_profile
('mdg_empl_profile', 'id'),
('mdg_empl_profile', 'version'),
('mdg_empl_profile', 'created_by'),
('mdg_empl_profile', 'created_date'),
('mdg_empl_profile', 'last_modified_by'),
('mdg_empl_profile', 'last_modified_date'),
('mdg_empl_profile', 'empl_photo'),
('mdg_empl_profile', 'market_hierarchy_id'),
('mdg_empl_profile', 'manager_matrix_id'),
('mdg_empl_profile', 'job_family_id'),
('mdg_empl_profile', 'hr_business_part_prof_id'),
('mdg_empl_profile', 'workflow_group_id'),
('mdg_empl_profile', 'job_title'),
('mdg_empl_profile', 'ot_hourly_rate'),
('mdg_empl_profile', 'job_offer_no'),
('mdg_empl_profile', 'job_appointment_issued'),
('mdg_empl_profile', 'salary_approve_date'),
('mdg_empl_profile', 'payscale_id'),
('mdg_empl_profile', 'payscale_cmp_id'),
('mdg_empl_profile', 'basic_salary_cmp'),
('mdg_empl_profile', 'update_date'),

('mdg_empl_profile', 'hr_business_partner_id'),
('mdg_empl_profile', 'attend_location_id'),
('mdg_empl_profile', 'attend_latitude'),
('mdg_empl_profile', 'attend_longitude'),

('mdg_empl_profile', 'total_salary_amount'),
('mdg_empl_profile', 'allowance_second_pmt_id'),
('mdg_empl_profile', 'second_pmt_mehod_percent'),
('mdg_empl_profile', 'salary_amt_second_pmt'),
('mdg_empl_profile', 'salary_amount'),

('mdg_empl_profile', 'pf_member_id'),
('mdg_empl_profile', 'gratuity_member_id'),
('mdg_empl_profile', 'dps_member_id'),
('mdg_empl_profile', 'gratuity_effective_date'),
('mdg_empl_profile', 'spouse'),
('mdg_empl_profile', 'number_of_child'),
('mdg_empl_profile', 'empl_date'),
('mdg_empl_profile', 'join_date_planned'),
('mdg_empl_profile', 'curr_position_since'),
('mdg_empl_profile', 'marriage_date'),
('mdg_empl_profile', 'job_description'),
('mdg_empl_profile', 'phone_work_pabx'),
('mdg_empl_profile', 'phone_work_pabx_ext'),
('mdg_empl_profile', 'tax_zone'),
('mdg_empl_profile', 'marital_status'),
('mdg_empl_profile', 'signature_speciman'),
('mdg_empl_profile', 'signature_update_date'),
('mdg_empl_profile', 'deleted_by'),
('mdg_empl_profile', 'deleted_date');

---------------------------------------------------------------------------------------------------

drop table if exists temp_null_counts ;
DO $$
DECLARE
    col RECORD;
    query TEXT;
BEGIN
    CREATE TEMP TABLE temp_null_counts (
        schema_name TEXT,
        table_name TEXT,
        column_name TEXT,
        null_count BIGINT
    );

    FOR col IN
        SELECT a.table_schema,
               a.table_name,
               a.column_name
        FROM information_schema.columns a
        LEFT JOIN redundant_table_cols b
            ON (a.table_name = b.table_name) and (a.column_name = b.column_name)
        WHERE a.table_schema NOT IN ('information_schema', 'pg_catalog')
          -- AND table_schema NOT LIKE 'pg_toast%'
            AND a.is_nullable = 'YES'
            and a.table_schema='public'
            and a.table_name in (select lower(a.original_table) from table_map_migration a)
--             and a.table_name = 'hmd_designation'
        and b.column_name is null
    LOOP
        IF col.table_schema = 'public' AND col.table_name = 'mdg_empl_profile' THEN
        query := FORMAT(
            'INSERT INTO temp_null_counts ' ||
            'SELECT %L, %L, %L, COUNT(*) FROM %I.%I WHERE %I IS NULL AND employee_code in (select employeepin from general_user_with_default_role)',
            col.table_schema, col.table_name, col.column_name,
            col.table_schema, col.table_name, col.column_name
        );
        else

            query := FORMAT(
            'INSERT INTO temp_null_counts ' ||
            'SELECT %L, %L, %L, COUNT(*) FROM %I.%I WHERE %I IS NULL',
            col.table_schema, col.table_name, col.column_name,
            col.table_schema, col.table_name, col.column_name
        );
            END IF;
        EXECUTE query;
    END LOOP;

    -- View the results
    RAISE NOTICE 'Column-wise null counts:';
    FOR col IN SELECT * FROM temp_null_counts ORDER BY null_count DESC
    LOOP
        RAISE NOTICE '%', col;
    END LOOP;
END $$;

select * from temp_null_counts a where a.null_count>0;


---------------------------------------------  NUll count checking END -------------------------------------------------------------------------

