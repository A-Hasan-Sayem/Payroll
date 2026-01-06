--division
--CREATE EXTENSION IF NOT EXISTS "pgcrypto";
--truncate table public.mdg_upozila, public.mdg_district, public.mdg_division;
INSERT INTO public.mdg_division (id, name, div_code)
SELECT
    gen_random_uuid() AS id,
    division_name::varchar AS name,
    division_code::varchar AS div_code
FROM payroll_master_data.division;

SELECT * FROM public.mdg_division;
SELECT count(*) FROM public.mdg_division; --9
SELECT count(*) FROM payroll_master_data.division; --9


--district
INSERT INTO public.mdg_district (
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
LEFT JOIN public.mdg_division as paydivision ON erpdivision.division_code = paydivision.div_code;

SELECT * FROM payroll_master_data.mdg_district;
SELECT count(*) FROM public.mdg_district; --65
SELECT count(*) FROM payroll_master_data.district; --65


--upozila
INSERT INTO public.mdg_upazila (
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
    erpthana.thana_code::varchar AS upazila_code,
    '1'::varchar AS created_by,
    NOW()::timestamp with time zone AS created_date,
    '1'::varchar AS last_modified_by,
    NOW()::timestamp with time zone AS last_modified_date,
    0::integer AS version
FROM payroll_master_data.thana AS erpthana
LEFT JOIN payroll_master_data.district AS erpdistrict ON erpdistrict.id = erpthana.district_id
LEFT JOIN public.mdg_district as paydistrict ON erpdistrict.district_code = paydistrict.dist_code;

SELECT * FROM payroll_master_data.mdg_upozila;
SELECT count(*) FROM public.mdg_upazila; --560
SELECT count(*) FROM payroll_master_data.thana; --560


--operating location/ office
INSERT INTO public.integ_oper_location_imp (
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
    erpthana.thana_code::varchar AS upozila_code,
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


select * from public.integ_oper_location_imp;
select count(*) from public.integ_oper_location_imp; --6617
select count(*) from payroll_master_data.physical_office_info where office_type_id in (1, 5); --6617
select count(*) from public.integ_oper_location_imp where address is null; --4254 (implemented erppoi.office_ref_code::bigint = erpoa.branch_ref_code)
--select count(*) from public.integ_oper_location_imp where address is null; --6365 (when erppoi.business_address_id = erpoa.id)
select count(*) from public.integ_oper_location_imp where upozila_code is null; --616



select * from public.integ_section_imp;
select * from public.integ_department_imp;
select * from public.integ_designation_imp;

--------------------------------------------------------------------------------------



--project table insert
INSERT INTO public.INTEG_SECTION_IMP (
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


--program table insert
INSERT INTO public.integ_department_imp
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


--designation table insert
INSERT INTO public.integ_designation_imp
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




--integ_cost_centre_imp
INSERT INTO public.integ_cost_centre_imp(
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


