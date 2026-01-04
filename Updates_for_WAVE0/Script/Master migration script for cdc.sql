---------------------------------------------- Create mdg_division ------------------------------------------------
create table cdc.mdg_division
(
    id       uuid not null
        constraint pk_mdg_div
            primary key,
    name     varchar(255),
    div_code varchar(255)
);

---------------------------------------------- Insert mdg_division ------------------------------------------------
INSERT INTO cdc.mdg_division (id, name, div_code)
SELECT
    gen_random_uuid() AS id,
    division_name::varchar AS name,
    division_code::varchar AS div_code
FROM payroll_master_data.division;

---------------------------------------------- Create mdg_district ------------------------------------------------
create table cdc.mdg_district
(
    id                 uuid    not null
        constraint pk_mdg_dis
            primary key,
    version            integer not null,
    created_by         varchar(255),
    created_date       timestamp,
    last_modified_by   varchar(255),
    last_modified_date timestamp,
    dist_code          varchar(255),
    name               varchar(255),
    division_id        uuid
        constraint fk_mdg_district_on_div
            references cdc.mdg_division,
    div_code           varchar(255)
);

---------------------------------------------- Insert mdg_district ------------------------------------------------
INSERT INTO cdc.mdg_district (
    id,
    version,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    dist_code,
    name,
    division_id,
    div_code
)
SELECT
    gen_random_uuid() AS id,
    0::integer AS version,
    '1'::varchar AS created_by,
    NOW()::timestamp AS created_date,
    '1'::varchar AS last_modified_by,
    NOW()::timestamp AS last_modified_date,
    erpdistrict.district_code::varchar AS dist_code,
    erpdistrict.district_name::varchar AS name,
    paydivision.id::uuid AS division_id,
    erpdivision.division_code::varchar AS div_code
FROM payroll_master_data.district as erpdistrict
LEFT JOIN payroll_master_data.division as erpdivision ON erpdivision.id = erpdistrict.division_id
LEFT JOIN cdc.mdg_division as paydivision ON erpdivision.division_code = paydivision.div_code;

---------------------------------------------- Create mdg_upazila ------------------------------------------------
create table cdc.mdg_upazila
(
    id                 uuid    not null
        constraint pk_mdg_upoz
            primary key,
    name               varchar(255),
    district_id        uuid
        constraint fk_mdg_upozila_on_dis
            references cdc.mdg_district,
    dist_code          varchar(255),
    upazila_code       varchar(255),
    created_by         varchar(255),
    created_date       timestamp,
    last_modified_by   varchar(255),
    last_modified_date timestamp,
    version            integer not null
);

---------------------------------------------- Insert mdg_upazila ------------------------------------------------
INSERT INTO cdc.mdg_upazila (
    id,
    name,
    district_id,
    dist_code,
    upazila_code,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    version
)
SELECT
    gen_random_uuid() AS id,
    erpthana.thana_name::varchar AS name,
    paydistrict.id::uuid AS district_id,
    erpdistrict.district_code::varchar AS dist_code,
    --CONCAT(erpthana.thana_code, erpdistrict.district_code)::varchar AS upazila_code,
    CONCAT('U', erpthana.thana_code, 'D', erpdistrict.district_code)::varchar AS upazila_code,
    '1'::varchar AS created_by,
    NOW()::timestamp with time zone AS created_date,
    '1'::varchar AS last_modified_by,
    NOW()::timestamp with time zone AS last_modified_date,
    0::integer AS version
FROM payroll_master_data.thana AS erpthana
LEFT JOIN payroll_master_data.district AS erpdistrict ON erpdistrict.id = erpthana.district_id
LEFT JOIN cdc.mdg_district as paydistrict ON erpdistrict.district_code = paydistrict.dist_code;

---------------------------------------------- Create integ_oper_location_imp -------------------------------------
create table cdc.integ_oper_location_imp
(
    id                     uuid    not null
        constraint pk_integ_oper_loc
            primary key,
    version                integer not null,
    created_by             varchar(255),
    created_date           timestamp with time zone,
    last_modified_by       varchar(255),
    last_modified_date     timestamp with time zone,
    oper_loc_code          varchar(255),
    name                   varchar(255),
    address                text,
    holiday_calendar_code  varchar(255),
    oper_loc_created_date  timestamp,
    creation_log           text,
    workshift_default_code varchar(255),
    holiday_calendar_id    uuid
        constraint fk_integ_oper_location_imp_on_holiday_cal
            references public.mdg_holiday_calendar,
    work_shift_id          uuid
        constraint fk_integ_oper_location_imp_on_work_shi
            references public.mdg_work_shift,
    upozila_code           varchar(255),
    district_code          varchar(255),
    division_code          varchar(255)
);

---------------------------------------------- Insert integ_oper_location_imp -------------------------------------
INSERT INTO cdc.integ_oper_location_imp (
    id,
    version,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    oper_loc_code,
    name,
    address,
    holiday_calendar_code,
    oper_loc_created_date,
    creation_log,
    workshift_default_code,
    holiday_calendar_id,
    work_shift_id,
    upozila_code,
    district_code,
    division_code
)
SELECT
    gen_random_uuid() AS id,
    0::integer AS version,
    '1'::varchar AS created_by,
    NOW()::timestamp with time zone AS created_date,
    '1'::varchar AS last_modified_by,
    NOW()::timestamp with time zone AS last_modified_date,
    erppoi.office_code::varchar AS oper_loc_code,
    erppoi.office_name::varchar AS name,
    erpoa.address_line1::text AS address,
    NULL::varchar AS holiday_calendar_code,
    NULL::timestamp AS oper_loc_created_date,
    NULL::text AS creation_log,
    NULL::varchar AS workshift_default_code,
    NULL::uuid AS holiday_calendar_id,
    NULL::uuid AS work_shift_id,
    (case when erpthana.thana_code is null then erpthana.thana_code
    else CONCAT('U',erpthana.thana_code,'D', erpdistrict.district_code) end)::varchar AS upozila_code,
    erpdistrict.district_code::varchar AS district_code,
    erpdivision.division_code::varchar AS division_code
FROM
    payroll_master_data.physical_office_info AS erppoi
LEFT JOIN
    payroll_master_data.office_address AS erpoa ON erppoi.office_ref_code::bigint = erpoa.branch_ref_code
LEFT JOIN
    payroll_master_data.geo_info AS erpgeoi ON erppoi.id = erpgeoi.office_id
LEFT JOIN
    payroll_master_data.thana AS erpthana ON erpgeoi.thana_id = erpthana.id
LEFT JOIN
    payroll_master_data.district AS erpdistrict ON erpdistrict.id = erpthana.district_id
LEFT JOIN
    payroll_master_data.division as erpdivision ON erpdivision.id = erpdistrict.division_id
WHERE
    erppoi.office_type_id IN (1, 3, 5); --only head office

---------------------------------------------- Create INTEG_SECTION_IMP -------------------------------------------
create table cdc.integ_section_imp
(
    id               uuid    not null
        constraint pk_integ_secti
            primary key,
    version          integer not null,
    created_by       varchar(255),
    created_date     timestamp with time zone,
    sec_code         varchar(255),
    name             varchar(255),
    dept_code        varchar(255),
    cost_cent_code   varchar(255),
    sec_created_date timestamp,
    creation_log     text
);

---------------------------------------------- Insert INTEG_SECTION_IMP -------------------------------------------
INSERT INTO cdc.INTEG_SECTION_IMP (
    id,
    version,
    created_by,
    created_date,
    sec_code,
    name,
    dept_code,
    cost_cent_code,
    sec_created_date,
    creation_log
)
SELECT
    gen_random_uuid() AS id
       ,0::integer AS version
       ,'1'::character varying AS created_by
     ,NOW()::timestamp AS created_date
     ,pj.project_code::character varying as sec_code
     ,pj.project_name::character varying as name
     ,pg.program_code::character varying as dept_code
     ,pj.project_code as cost_cent_code
     , null as sec_created_date
     , null as creation_log
FROM payroll_master_data.project_info as pj
INNER JOIN payroll_master_data.program_info as pg ON pg.id = pj.program_info_id;--1331

---------------------------------------------- Create integ_department_imp -----------------------------------------
create table cdc.integ_department_imp
(
    id                   uuid    not null
        constraint pk_integ_dept
            primary key,
    version              integer not null,
    created_by           varchar(255),
    created_date         timestamp with time zone,
    last_modified_by     varchar(255),
    last_modified_date   timestamp with time zone,
    dept_code            varchar(255),
    name                 varchar(255),
    functional_area_code varchar(255),
    dept_created_date    timestamp,
    creation_log         text
);

---------------------------------------------- Insert integ_department_imp -----------------------------------------
INSERT INTO cdc.integ_department_imp
(
    id,
    version,
    created_by ,
    created_date ,
    last_modified_by ,
    last_modified_date ,
    dept_code,
    name,
    functional_area_code,
    dept_created_date,
    creation_log
)
SELECT
    gen_random_uuid() AS id
       ,0::integer AS version
       ,'1'::character varying AS created_by
     ,NOW()::timestamp AS created_date
     ,'1'::character varying AS last_modified_by
    ,NOW()::timestamp AS last_modified_date
     ,pg.program_code::character varying as dept_code
     ,pg.program_name::character varying as name
     , 'A'::character varying as functional_area_code
     , null as dept_created_date
     , null as creation_log
FROM payroll_master_data.program_info as pg;--94

---------------------------------------------- Updating func area code in integ_department_imp ----------------------
update cdc.integ_department_imp a
set functional_area_code = b.func_area_code
from payroll_master_data.dept_func_area_map b
where a.dept_code = b.dept_code;

---------------------------------------------- Create integ_designation_imp ----------------------------------------
create table cdc.integ_designation_imp
(
    id                 uuid    not null
        constraint pk_integ_desig
            primary key,
    version            integer not null,
    created_by         varchar(255),
    created_date       timestamp with time zone,
    last_modified_by   varchar(255),
    last_modified_date timestamp with time zone,
    code               varchar(255),
    name               varchar(255),
    desig_created_date timestamp,
    creation_log       text
);

---------------------------------------------- Insert integ_designation_imp ----------------------------------------
INSERT INTO cdc.integ_designation_imp
(
    id ,
    version ,
    created_by,
    created_date ,
    last_modified_by ,
    last_modified_date,
    code,
    name,
    desig_created_date ,
    creation_log
)
SELECT
    gen_random_uuid() AS id
       ,0::integer AS version
       ,'1'::character varying AS created_by
     ,NOW()::timestamp AS created_date
     ,'1'::character varying AS last_modified_by
    ,NOW()::timestamp AS last_modified_date
     , code::character varying
     , name::character varying
     , null as desig_created_date
     , null as creation_log
FROM payroll_master_data.employee_designation;--5679


---------------------------------------------- Create integ_cost_centre_imp ----------------------------------------
create table cdc.integ_cost_centre_imp
(
    id                     uuid    not null
        constraint pk_integ_cost_cen
            primary key,
    version                integer not null,
    created_by             varchar(255),
    created_date           timestamp,
    last_modified_by       varchar(255),
    last_modified_date     timestamp,
    cc_code                varchar(255),
    name                   varchar(255),
    cost_cent_created_date timestamp,
    creation_log           text
);

---------------------------------------------- Insert integ_cost_centre_imp ----------------------------------------
INSERT INTO cdc.integ_cost_centre_imp(
    id,
    version,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    cc_code,
    name,
    cost_cent_created_date,
    creation_log
)
SELECT
    gen_random_uuid() AS id
       ,0::integer AS version
       ,'1'::character varying AS created_by
     ,NOW()::timestamp AS created_date
     ,'1'::character varying AS last_modified_by
     ,NOW()::timestamp AS last_modified_date
     ,pj.project_code::character varying as cc_code
     ,pj.project_name::character varying as name
     , null as cost_cent_created_date
     , null as creation_log
FROM payroll_master_data.project_info as pj;


