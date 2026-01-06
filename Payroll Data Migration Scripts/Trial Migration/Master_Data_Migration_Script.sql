--division
--CREATE EXTENSION IF NOT EXISTS "pgcrypto";
--truncate table public.mdg_upozila, public.mdg_district, public.mdg_division;
INSERT INTO public.mdg_division (id, name, div_code)
SELECT
    gen_random_uuid() AS id,
    division_name::varchar AS name,
    division_code::varchar AS div_code
FROM payroll.division;

SELECT * FROM public.mdg_division;
SELECT count(*) FROM public.mdg_division; --9
SELECT count(*) FROM payroll.division; --9


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
    NULL::uuid AS division_id,
    erpdivision.division_code::varchar AS div_code
FROM payroll.district as erpdistrict
LEFT JOIN payroll.division as erpdivision ON erpdivision.id = erpdistrict.division_id;

UPDATE public.mdg_district as paydistrict
SET division_id = paydivision.id
FROM public.mdg_division as paydivision
WHERE paydistrict.div_code = paydivision.div_code;

SELECT * FROM payroll.mdg_district;
SELECT count(*) FROM public.mdg_district; --65
SELECT count(*) FROM payroll.district; --65


--upozila
INSERT INTO public.mdg_upozila (
    id,
    name,
    district_id,
    dist_code,
    upozila_code
)
SELECT
    gen_random_uuid() AS id,
    erpthana.thana_name::varchar AS name,
    NULL::uuid AS district_id,
    erpdistrict.district_code::varchar AS dist_code,
    erpthana.thana_code::varchar AS upozila_code
FROM payroll.thana AS erpthana
LEFT JOIN payroll.district AS erpdistrict ON erpdistrict.id = erpthana.district_id;

UPDATE public.mdg_upozila as payupozila
SET district_id = paydistrict.id
FROM public.mdg_district as paydistrict
WHERE payupozila.dist_code = paydistrict.dist_code;

SELECT * FROM payroll.mdg_upozila;
SELECT count(*) FROM public.mdg_upozila; --560
SELECT count(*) FROM payroll.thana; --560


--operating location/ office
--truncate table public.integ_oper_location_imp;
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
    upozila_code
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
    erpthana.thana_code::varchar AS upozila_code
FROM
    payroll.physical_office_info AS erppoi
LEFT JOIN
    payroll.office_address AS erpoa ON erppoi.office_ref_code::bigint = erpoa.branch_ref_code
LEFT JOIN
    payroll.geo_info AS erpgeoi ON erppoi.id = erpgeoi.office_id
LEFT JOIN
    payroll.thana AS erpthana ON erpgeoi.thana_id = erpthana.id
WHERE
    erppoi.office_type_id IN (1, 5); --only head office

select * from public.integ_oper_location_imp;
select count(*) from public.integ_oper_location_imp; --6617
select count(*) from payroll.physical_office_info where office_type_id in (1, 5); --6617
select count(*) from public.integ_oper_location_imp where address is null; --4254 (implemented erppoi.office_ref_code::bigint = erpoa.branch_ref_code)
--select count(*) from public.integ_oper_location_imp where address is null; --6365 (when erppoi.business_address_id = erpoa.id)
select count(*) from public.integ_oper_location_imp where upozila_code is null; --616



select * from public.integ_section_imp;
select * from public.integ_department_imp;
select * from public.integ_designation_imp;

--------------------------------------------------------------------------------------

--operating location/office updated with office type 3
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
    upozila_code
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
    erpthana.thana_code::varchar AS upozila_code
FROM
    payroll_master_data.physical_office_info AS erppoi
LEFT JOIN
    payroll_master_data.office_address AS erpoa ON erppoi.office_ref_code::bigint = erpoa.branch_ref_code
LEFT JOIN
    payroll_master_data.geo_info AS erpgeoi ON erppoi.id = erpgeoi.office_id
LEFT JOIN
    payroll_master_data.thana AS erpthana ON erpgeoi.thana_id = erpthana.id
WHERE
    erppoi.office_type_id = 3;

