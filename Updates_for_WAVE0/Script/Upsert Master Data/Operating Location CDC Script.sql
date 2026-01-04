-------------------------------------------- Upozila Update ------------------------------------------------------------

;WITH thana AS(
SELECT T.*,row_number() over (PARTITION BY district_id,thana_name ORDER BY thana_code)r,
CONCAT(t.thana_code,d.district_code)::varchar AS upazila_code
FROM payroll_master_data.thana T
LEFT JOIN payroll_master_data.district D ON T.district_id = D.id
),cte as(
SELECT U.id, CONCAT('U', t.thana_code, 'D', d.district_code)::varchar AS upazila_code
,t.thana_code,d.district_code
FROM public.mdg_upazila u
LEFT JOIN thana t ON u.upazila_code = t.upazila_code and r = 1
LEFT JOIN payroll_master_data.district d
ON t.district_id = D.id AND u.dist_code = d.district_code
UNION ALL
SELECT U.id, CONCAT('U', t.thana_code, 'D', d.district_code)::varchar AS upazila_code
,t.thana_code,d.district_code
FROM public.mdg_upazila u
INNER JOIN thana t ON u.upazila_code = t.upazila_code and r = 2
LEFT JOIN payroll_master_data.district d
ON d.id = t.district_id AND u.dist_code = d.district_code
),Final_CTE AS(
SELECT * FROM cte WHERE thana_code IS NOT NULL AND district_code IS NOT NULL
)
UPDATE public.mdg_upazila u
SET upazila_code = F.upazila_code
FROM Final_CTE F
WHERE u.id = F.id

---------------------------------------- Check if any Updates/Insert (oper_location)---------------------------------------------------
SELECT
    n.oper_loc_code,
    n.name,
    n.address,
    n.upozila_code,
    n.district_code,
    n.division_code,
    CASE
        WHEN o.oper_loc_code IS NULL THEN 'Insert'
        WHEN
            n.name IS DISTINCT FROM o.name
            OR n.address IS DISTINCT FROM o.address
            OR n.upozila_code IS DISTINCT FROM o.upozila_code
            OR n.district_code IS DISTINCT FROM o.district_code
            OR n.division_code IS DISTINCT FROM o.division_code
        THEN 'Update'
    END AS FLAG
FROM cdc.integ_oper_location_imp n
LEFT JOIN public.integ_oper_location_imp o
    ON n.oper_loc_code = o.oper_loc_code
WHERE
    o.oper_loc_code IS NULL
    OR n.name IS DISTINCT FROM o.name
    OR n.address IS DISTINCT FROM o.address
    OR n.upozila_code IS DISTINCT FROM o.upozila_code
    OR n.district_code IS DISTINCT FROM o.district_code
    OR n.division_code IS DISTINCT FROM o.division_code;

----------------------------------------- Create Additional Table ------------------------------------------------------
create table cdc.mdg_operating_location_old as select * from public.mdg_operating_location;
create table cdc.mdg_operating_location_co_old as select * from public.mdg_operating_location_co;

--------------------------------------------  Main table ID update -----------------------------------------------------

UPDATE cdc.integ_oper_location_imp imp
SET id = mo.id
FROM public.mdg_operating_location mo
WHERE imp.oper_loc_code = mo.oper_loc_code;

---------------------------------------------- CONSTRAINT adjust (if needed) -------------------------------------------

-- ALTER TABLE cdc.integ_oper_location_imp
-- ADD CONSTRAINT integ_oper_location_imp_pkey PRIMARY KEY (id);

--------------------------------------------- mdg_operating_location Transformation and Load----------------------------
with source as (
    select  s.id ,
            s.oper_loc_code,
            s.name,
            s.address,
            s.upozila_code
            --,s.district_code,
            --s.division_code,
            ,u.id as upazila_id
    from cdc.integ_oper_location_imp s LEFT JOIN public.mdg_upazila u ON u.upazila_code = s.upozila_code --and u.dist_code = s.district_code
    where s.name is not null
      and s.oper_loc_code is not null
    )
INSERT INTO public.mdg_operating_location (
     id, oper_loc_code, name, address, holiday_calendar_id, use_holi_cal_default_to_empl, upazila_id
)
SELECT
v.id,
    v.oper_loc_code,
    v.name,
    v.address,
    NULL,
    FALSE
    ,v.upazila_id
FROM source v
ON CONFLICT (id) DO UPDATE
SET oper_loc_code = EXCLUDED.oper_loc_code,
    name = EXCLUDED.name,
    address = EXCLUDED.address,
    upazila_id = EXCLUDED.upazila_id;


--------------------------------------------- CO Transformation and Load------------------------------------------------

with source as (
    select s.id,
            s.oper_loc_code,
            s.name,
            s.address,
            s.upozila_code,
            s.district_code,
            s.division_code,
            u.id as upazila_id
    from cdc.integ_oper_location_imp s LEFT JOIN public.mdg_upazila u ON u.upazila_code = s.upozila_code --and u.dist_code = s.district_code
    where s.name is not null
      and s.oper_loc_code is not null
    )
INSERT INTO public.mdg_operating_location_co (
    id, version, created_by, created_date,
    company_id, active, operating_location_id
)
SELECT
    gen_random_uuid(), 1, 'CDC', NOW(), c.id, true, v.id
FROM source v
CROSS JOIN public.mdg_company c
LEFT JOIN public.mdg_operating_location_co existing
    ON existing.operating_location_id = v.id
WHERE existing.id IS NULL;

----------------------------------------- Create CDC Snapshot Table ----------------------------------------------------
CREATE TABLE cdc.operating_location_snapshot (
    id UUID,
    oper_loc_code_old VARCHAR(255),
    oper_loc_code_new VARCHAR(255),
    name_old VARCHAR(255),
    name_new VARCHAR(255),
    address_old TEXT,
    address_new TEXT,
    name_local_old VARCHAR(255),
    name_local_new VARCHAR(255),
    address_local_old VARCHAR(255),
    address_local_new VARCHAR(255),
    holiday_calendar_id_old UUID,
    holiday_calendar_id_new UUID,
    use_holi_cal_default_to_empl_old BOOLEAN,
    use_holi_cal_default_to_empl_new BOOLEAN,
    work_shift_default_id_old UUID,
    work_shift_default_id_new UUID,
    upazila_id_old UUID,
    upazila_id_new UUID,
    row_level_role_old UUID,
    row_level_role_new UUID,
    FLAG TEXT,
    Last_Modified_date TIMESTAMP DEFAULT now()
);

--delete from cdc.operating_location_snapshot

---------------------------------------------------------  Updates track -----------------------------------------------

INSERT INTO cdc.operating_location_snapshot (
    id,
    oper_loc_code_old, oper_loc_code_new,
    name_old, name_new,
    address_old, address_new,
    upazila_id_old, upazila_id_new,
    FLAG, Last_Modified_date
)
SELECT
    t1.id,
    CASE WHEN t1.oper_loc_code IS DISTINCT FROM t2.oper_loc_code THEN t1.oper_loc_code END,
    CASE WHEN t1.oper_loc_code IS DISTINCT FROM t2.oper_loc_code THEN t2.oper_loc_code END,
    CASE WHEN t1.name IS DISTINCT FROM t2.name THEN t1.name END,
    CASE WHEN t1.name IS DISTINCT FROM t2.name THEN t2.name END,
    CASE WHEN t1.address IS DISTINCT FROM t2.address THEN t1.address END,
    CASE WHEN t1.address IS DISTINCT FROM t2.address THEN t2.address END,
    CASE WHEN t1.upazila_id IS DISTINCT FROM t2.upazila_id THEN t1.upazila_id END,
    CASE WHEN t1.upazila_id IS DISTINCT FROM t2.upazila_id THEN t2.upazila_id END,
    'Update' AS FLAG,
    now()
FROM cdc.mdg_operating_location_old t1
JOIN public.mdg_operating_location t2 ON t1.id = t2.id
WHERE
   t1.oper_loc_code IS DISTINCT FROM t2.oper_loc_code OR
   t1.name IS DISTINCT FROM t2.name OR
   t1.address IS DISTINCT FROM t2.address OR
   t1.upazila_id IS DISTINCT FROM t2.upazila_id;

---------------------------------------------------------  Insert track ------------------------------------------------

INSERT INTO cdc.operating_location_snapshot (
    id,
    oper_loc_code_new, name_new, address_new, name_local_new, address_local_new,
    holiday_calendar_id_new, use_holi_cal_default_to_empl_new,
    work_shift_default_id_new, upazila_id_new, row_level_role_new,
    FLAG, Last_Modified_date
)
SELECT
    t2.id,
    t2.oper_loc_code, t2.name, t2.address, t2.name_local, t2.address_local,
    t2.holiday_calendar_id, t2.use_holi_cal_default_to_empl,
    t2.work_shift_default_id, t2.upazila_id, t2.row_level_role,
    'Insert' AS FLAG,
    now()
FROM public.mdg_operating_location t2
LEFT JOIN cdc.mdg_operating_location_old t1 ON t1.id = t2.id
WHERE t1.id IS NULL;