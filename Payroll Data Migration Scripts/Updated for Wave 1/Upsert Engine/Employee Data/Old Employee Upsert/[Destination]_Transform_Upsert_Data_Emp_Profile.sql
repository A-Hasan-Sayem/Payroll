create table cdc.emp_upsert_staging
(
    id                          uuid  not null,
    version                     integer not null,
    created_by                  varchar(255),
    created_date                timestamp with time zone,
    last_modified_by            varchar(255),
    last_modified_date          timestamp with time zone,
    employee_code               varchar(255),
    first_name                  varchar(255),
    middle_name                 varchar(255),
    last_name                   varchar(255),
    father_name                 varchar(255),
    mother_name                 varchar(255),
    national_id                 varchar(255),
    join_date_actual            timestamp,
    confirmation_date           timestamp,
    contract_end_date           timestamp,
    employment_status           integer,
    email_company               varchar(255),
    current_address             text,
    permanent_address           text,
    birth_date                  timestamp,
    gross_salary                double precision,
    bonus_entitlement_status    integer,
    bank_branch_name            varchar(255),
    bank_name                   varchar(255),
    routing_no                  varchar(255),
    empl_bank_account_no        varchar(255),
    empl_bikash_no              varchar(255),
    gender                      varchar(255),
    tin_no                      varchar(255),
    salary_circle               varchar(255),
    empl_create_date            timestamp,
    supervisor_empl_code        varchar(255),
    holiday_calendar_code       varchar(255),
    religion                    varchar(255),
    grade_code                  varchar(255),
    grade_sub_code              varchar(255),
    group_code                  varchar(255),
    section_code                varchar(255),
    empl_category_code          varchar(255),
    work_shift_code             varchar(255),
    work_shift_rotated          boolean,
    work_shift_rotate_rule_code varchar(255),
    nationality_country         varchar(255),
    operating_location_code     varchar(255),
    designation_code            varchar(255),
    pay_struc_code              varchar(255),
    creation_log                text,
    phone_home                  varchar(255),
    phone_work_direct           varchar(255),
    phone_mobile                varchar(255),
    leave_profile_code          varchar(255),
    employee_job_status         varchar(255),
    last_working_day            timestamp
);


CREATE TABLE cdc.mdg_empl_profile AS
SELECT * FROM public.mdg_empl_profile;

CREATE TABLE cdc.integ_separation_imp AS
SELECT * FROM public.integ_separation_imp;

-- Add a unique constraint on employee_code in mdg_empl_profile
ALTER TABLE cdc.mdg_empl_profile
ADD CONSTRAINT unique_employee_code UNIQUE (employee_code);

-- Add a unique constraint on employee_code in integ_separation_imp
ALTER TABLE cdc.integ_separation_imp
ADD CONSTRAINT unique_separation_employee_code UNIQUE (employee_code);







--grade analysis
select count(1) from cdc.emp_upsert_staging where grade_sub_code is null;

select distinct b.salary_band_type from public.mdg_empl_profile a
inner join public.mdg_empl_job_grade b on a.empl_grade_id = b.id;

select * from public.mdg_empl_job_grade where salary_band_type=10;
select * from public.hmd_empl_grade_sub;

select count(1) from public.integ_employee_imp a
where a.grade_code='99';
select count(1) from public.mdg_empl_profile where empl_grade_id is null;

select distinct grade_code from public.integ_employee_imp a;
select * from public.mdg_job_grade a;
select * from public.mdg_empl_job_grade a;