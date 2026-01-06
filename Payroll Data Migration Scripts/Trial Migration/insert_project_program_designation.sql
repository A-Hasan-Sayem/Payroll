--project table insert
INSERT INTO payroll.INTEG_SECTION_IMP (
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
     ,null as cost_cent_code
     , null as sec_created_date
     , null as creation_log
FROM public.project_info as pj
INNER JOIN public.program_info as pg ON pg.id = pj.program_info_id;--1331


--program table insert
INSERT INTO payroll.integ_department_imp
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
FROM public.program_info as pg;--94


--designation table insert
INSERT INTO payroll.integ_designation_imp
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
FROM employee_designation;--5679
