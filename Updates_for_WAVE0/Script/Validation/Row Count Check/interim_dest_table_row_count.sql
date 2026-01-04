drop table if exists public.table_map_migration;

create table public.table_map_migration
(
    mapping_table  text,
    mapping_schema text,
    original_table text,
    condition text
);

truncate  table public.table_map_migration;

INSERT INTO public.table_map_migration (mapping_table, mapping_schema, original_table, condition)
VALUES ('integ_work_away_office_imp', 'public', 'hr_work_away_office',
        'a inner join mdg_empl_profile e on a.employee_profile_id = e.id where e.employee_code not in (select pin from payroll_leave_attend_data_old.employee_records_beta);');

INSERT INTO public.table_map_migration(mapping_table, mapping_schema, original_table, condition)
VALUES ('integ_work_away_office_line_imp', 'public', 'hr_work_away_office_line', 'l inner join hr_work_away_office a on l.work_away_office_id = a.id inner join mdg_empl_profile e on a.employee_profile_id = e.id where e.employee_code not in (select pin from payroll_leave_attend_data_old.employee_records_beta);');

INSERT INTO public.table_map_migration (mapping_table, mapping_schema, original_table, condition)
VALUES ('integ_attend_missed_app_imp', 'public', 'hr_attend_missed_app',
        'a inner join mdg_empl_profile e on a.employee_profile_id = e.id where e.employee_code not in (select pin from payroll_leave_attend_data_old.employee_records_beta);');

INSERT INTO public.table_map_migration (mapping_table, mapping_schema, original_table, condition)
VALUES ('INTEG_LEAVE_APP_IMP', 'public', 'HR_LEAVE_APPLICATION',
        'a inner join mdg_empl_profile e on a.employee_profile_id = e.id where e.employee_code not in (select pin from payroll_leave_attend_data_old.employee_records_beta);');

INSERT INTO public.table_map_migration (mapping_table, mapping_schema, original_table, condition)
VALUES ('INTEG_LEAVE_APP_LINE_IMP', 'public', 'HR_LEAVE_APPLICATION_LINE', 'l inner join hr_leave_application a on l.leave_application_id = a.id inner join mdg_empl_profile e on a.employee_profile_id = e.id where e.employee_code not in (select pin from payroll_leave_attend_data_old.employee_records_beta);');

INSERT INTO public.table_map_migration (mapping_table, mapping_schema, original_table, condition)
VALUES ('integ_employee_imp', 'cdc', 'MDG_EMPL_PROFILE', ';');

INSERT INTO public.table_map_migration (mapping_table, mapping_schema, original_table, condition)
VALUES ('INTEG_DEPARTMENT_IMP', 'public', 'MDG_DEPARTMENT', ';');

INSERT INTO public.table_map_migration (mapping_table, mapping_schema, original_table, condition)
VALUES ('integ_section_imp', 'cdc', 'MDG_DEPT_SECTION', ';');

INSERT INTO public.table_map_migration (mapping_table, mapping_schema, original_table, condition)
VALUES ('integ_oper_location_imp', 'cdc', 'MDG_OPERATING_LOCATION', ';');

INSERT INTO public.table_map_migration (mapping_table, mapping_schema, original_table, condition)
VALUES ('INTEG_DESIGNATION_IMP', 'cdc','HMD_DESIGNATION', ';');

INSERT INTO public.table_map_migration (mapping_table, mapping_schema, original_table, condition)
VALUES ('integ_leave_op_balance_imp', 'public','HR_LEAVE_OPENING_BALANCE', 'a inner join mdg_empl_profile e on a.employee_profile_id = e.id where e.employee_code not in (select pin from payroll_leave_attend_data_old.employee_records_beta);');


select * from public.table_map_migration;

---------------------------------------------- Table Map Row Count Cross Check --------------------------------------------------

drop table IF Exists data_migration_cross_check;
---  Data Migration cross check
Create TEMPORARY TABLE data_migration_cross_check
(original_table varchar(250),
 mapping_table varchar(250),
 mapping_schema varchar(250),
 original_Count integer,
 mapping_Count integer,
 match_yes varchar);


 /*
------------------------------------------------ Lets see whats happening under the hood ------------------------------------
DO $$
DECLARE
    rec RECORD;
    original_count BIGINT;
    mapping_count BIGINT;
    sql_original TEXT;
    sql_mapping TEXT;
BEGIN
    FOR rec IN
        SELECT
            lower(mapping_table) as mapping_table,
            mapping_schema as mapping_schema,
            lower(original_table) as original_table,
            condition
            FROM table_map_migration a -- where ltrim(rtrim(a.mapping_table))='INTEG_DEPARTMENT_IMP'
    LOOP
        RAISE NOTICE 'Processing: mapping_table=%, mapping_schema=%, original_table=%, condition=%',
            rec.mapping_table, rec.mapping_schema, rec.original_table, rec.condition;

        -- Build query for original_count
        sql_original := format('SELECT COUNT(1) FROM %I %s', rec.original_table, rec.condition);
        RAISE NOTICE 'Original query: %', sql_original;
        EXECUTE sql_original INTO original_count;

        -- Build query for mapping_count
        sql_mapping := format('SELECT COUNT(1) FROM %I.%I', rec.mapping_schema, rec.mapping_table);
        RAISE NOTICE 'Mapping query: %', sql_mapping;
        EXECUTE sql_mapping INTO mapping_count;
    END LOOP;
END$$;

-------------------------------------------------------------------------------------------------------------------------------------

*/

TRUNCATE table data_migration_cross_check;

DO $$
DECLARE
    rec RECORD;
    original_count BIGINT;
    mapping_count BIGINT;
BEGIN
    FOR rec IN
        SELECT
            lower(mapping_table) as mapping_table,
            mapping_schema as mapping_schema,
            lower(original_table) as original_table,
            condition
            FROM table_map_migration a -- where ltrim(rtrim(a.mapping_table))='INTEG_DEPARTMENT_IMP'
    LOOP
        raise notice 'mapping table: %, mapping schema: % original table: %, condition: %', rec.mapping_table, rec.mapping_schema, rec.original_table, rec.condition;
        execute format('SELECT COUNT(1) FROM %I %s', rec.original_table, rec.condition) INTO original_count;
        execute format('SELECT COUNT(1) FROM %I.%I', rec.mapping_schema, rec.mapping_table) INTO mapping_count;

        insert into data_migration_cross_check
        values (rec.original_table,
            rec.mapping_table,
            rec.mapping_schema,
            original_count,
            mapping_count,
            CASE WHEN original_count = mapping_count THEN 'Yes' ELSE 'No' END);
    END LOOP;
END$$;


select original_table, mapping_schema, mapping_table, original_Count, mapping_Count, match_yes from data_migration_cross_check;
------------------------------------------------------ Table Map Row Count Cross Check END ----------------------------------------------------

-- Misc queries

-- destination (leave application) (check public to public)
select count(1) from hr_leave_application a inner join mdg_empl_profile e on a.employee_profile_id = e.id
where e.employee_code in (select pin from payroll_leave_attend_data.employee_records_beta_30);

-- Source (leave application) (check public to public)
SELECT count(1) from integ_leave_app_imp where employee_code
in (select pin from payroll_leave_attend_data.employee_records_beta_30);

-- Destination (leave opening balance) (check public to public)
select count(1) from hr_leave_opening_balance a inner join mdg_empl_profile e on a.employee_profile_id = e.id
where e.employee_code in (select pin from payroll_leave_attend_data.employee_records_beta_30);

-- Source (check public to public)
SELECT count(1) from integ_leave_op_balance_imp where employee_code in (
    select pin from payroll_leave_attend_data.employee_records_beta_30
    );

-- dest (leave application line) (check public to public)
select count(1) from HR_LEAVE_APPLICATION_LINE l
inner join hr_leave_application a on l.leave_application_id = a.id
    inner join mdg_empl_profile e on a.employee_profile_id = e.id
where e.employee_code in (select pin from payroll_leave_attend_data.employee_records_beta_30);

-- source( leave application line ) (check public to public)
SELECT count(1) FROM integ_leave_app_line_imp l
inner join integ_leave_app_imp a on l.leave_app_imp_id = a.id
where a.employee_code in (select pin from payroll_leave_attend_data.employee_records_beta_30);

-- Dest employee (check cdc to public)
SELECT count(1) FROM mdg_empl_profile e where employee_code IN (
    select pin from payroll_leave_attend_data.employee_records_beta_30
    );

-- source (check cdc to public)
SELECT COUNT(1) FROM cdc.integ_employee_imp where employee_code IN (
    select pin from payroll_leave_attend_data.employee_records_beta_30
    );


-- Dest Section (check cdc to public)
SELECT count(1) FROM mdg_dept_section;

-- Source Section (check cdc to public)
SELECT COUNT(1) FROM cdc.integ_section_imp;


-- dest (public to public)
SELECT COUNT(1) FROM hr_work_away_office w
inner join mdg_empl_profile e on w.employee_profile_id = e.id
where e.employee_code in (select pin from payroll_leave_attend_data.employee_records_beta_30);


-- source (public to public)
SELECT COUNT(1) FROM integ_work_away_office_imp where employee_code IN (
    select pin from payroll_leave_attend_data.employee_records_beta_30
    );

-- dest (public to public)
SELECT COUNT(1) FROM hr_work_away_office_line l
INNER JOIN hr_work_away_office w on l.work_away_office_id = w.id
INNER JOIN mdg_empl_profile p ON w.employee_profile_id = p.id
WHERE p.employee_code in (
    select pin from payroll_leave_attend_data.employee_records_beta_30
    );

-- source (public to public)
SELECT COUNT(1) FROM integ_work_away_office_line_imp l
INNER JOIN integ_work_away_office_imp w ON l.work_away_office_imp_id = w.id
WHERE w.employee_code IN (
    select pin from payroll_leave_attend_data.employee_records_beta_30
    );

-- source (public to public)
select count(1) from integ_attend_missed_app_imp;

-- dest (public to public)
select count(1) from hr_attend_missed_app a inner join mdg_empl_profile e on a.employee_profile_id = e.id
where e.employee_code not in (select pin from payroll_leave_attend_data.employee_records_beta_30);
