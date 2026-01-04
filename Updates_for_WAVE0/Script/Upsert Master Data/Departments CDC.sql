---------------------------------------- Check if any Updates/Insert (Department)---------------------------------------------------
SELECT
    n.dept_code,
    n.name,
    n.functional_area_code,
    CASE
        WHEN o.dept_code IS NULL THEN 'Insert'
        WHEN
            n.name IS DISTINCT FROM o.name
            OR n.functional_area_code IS DISTINCT FROM o.functional_area_code
        THEN 'Update'
    END AS FLAG
FROM cdc.integ_department_imp n
LEFT JOIN public.integ_department_imp o
    ON n.dept_code = o.dept_code
WHERE
    o.dept_code IS NULL
    OR n.name IS DISTINCT FROM o.name
    OR n.functional_area_code IS DISTINCT FROM o.functional_area_code;

----------------------------------------- Create Additional Table ------------------------------------------------------
create table cdc.mdg_department_old as select * from public.mdg_department;

--------------------------------------------  Main table ID update -----------------------------------------------------
UPDATE cdc.integ_department_imp imp
SET id = mo.id
FROM public.mdg_department mo
WHERE imp.dept_code = mo.dept_code;

---------------------------------------------- CONSTRAINT adjust -------------------------------------------------------

-- ALTER TABLE cdc.integ_department_imp
-- ADD CONSTRAINT integ_department_imp_pkey PRIMARY KEY (id);

--------------------------------------------- mdg_department Transformation and Load----------------------------
WITH src AS (
    SELECT
        imp.id,
        imp.dept_code,
        imp.name,
        imp.functional_area_code,
        fa.id AS functional_area_id
    FROM cdc.integ_department_imp imp
    LEFT JOIN public.mdg_functional_area fa
        ON fa.func_area_code = imp.functional_area_code
    WHERE imp.functional_area_code IS NOT NULL
)
    INSERT INTO public.mdg_department (
        id, version, created_by, created_date,
        dept_code, name, functional_area_id
    )
    SELECT
        s.id,
        1,
        'cdc',
        NOW(),
        s.dept_code,
        s.name,
        s.functional_area_id
    FROM src s
    ON CONFLICT (id) DO UPDATE
    SET
        name = EXCLUDED.name,
        functional_area_id = EXCLUDED.functional_area_id;

--------------------------------------------- mdg_department_comp Transformation and Load----------------------------
WITH src AS (
    SELECT
        imp.id AS department_id,
        imp.dept_code,
        imp.name,
        fa.id AS functional_area_id
    FROM public.integ_department_imp imp
    LEFT JOIN public.mdg_functional_area fa
        ON fa.func_area_code = imp.functional_area_code
    WHERE imp.functional_area_code IS NOT NULL
)
INSERT INTO public.mdg_department_comp (
    id, version, created_by, created_date,
    company_id, active, department_id
)
SELECT
    gen_random_uuid(),
    1,
    'cdc',
    NOW(),
    c.id,
    TRUE,
    s.department_id
FROM src s
CROSS JOIN public.mdg_company c
LEFT JOIN public.mdg_department_comp existing
    ON existing.department_id = s.department_id
   AND existing.company_id = c.id
WHERE existing.id IS NULL;

----------------------------------------- Create CDC Snapshot Table ----------------------------------------------------
CREATE TABLE cdc.mdg_department_snapshot
(
    id uuid,
    dept_code_old varchar(255),
    dept_code_new varchar(255),
    name_old varchar(255),
    name_new varchar(255),
    functional_area_id_old uuid,
    functional_area_id_new uuid,
    flag varchar(10),
    last_modified_date timestamp
);

------------------------------------------  Updates track --------------------------------------------------------------
INSERT INTO cdc.mdg_department_snapshot (
    id,
    dept_code_old, dept_code_new,
    name_old, name_new,
    functional_area_id_old, functional_area_id_new,
    flag,
    last_modified_date
)
SELECT
    t1.id,
    CASE WHEN t1.dept_code IS DISTINCT FROM t2.dept_code THEN t1.dept_code END,
    CASE WHEN t1.dept_code IS DISTINCT FROM t2.dept_code THEN t2.dept_code END,

    CASE WHEN t1.name IS DISTINCT FROM t2.name THEN t1.name END,
    CASE WHEN t1.name IS DISTINCT FROM t2.name THEN t2.name END,

    CASE WHEN t1.functional_area_id IS DISTINCT FROM t2.functional_area_id THEN t1.functional_area_id END,
    CASE WHEN t1.functional_area_id IS DISTINCT FROM t2.functional_area_id THEN t2.functional_area_id END,

    'Update',
    now()
FROM cdc.mdg_department_old t1
JOIN public.mdg_department t2 ON t1.id = t2.id
WHERE
    t1.dept_code IS DISTINCT FROM t2.dept_code
    OR t1.name IS DISTINCT FROM t2.name
    OR t1.functional_area_id IS DISTINCT FROM t2.functional_area_id;

------------------------------------------  Insert track ---------------------------------------------------------------
INSERT INTO cdc.mdg_department_snapshot (
    id,
    dept_code_old, dept_code_new,
    name_old, name_new,
    functional_area_id_old, functional_area_id_new,
    flag,
    last_modified_date
)
SELECT
    t2.id,
    NULL, t2.dept_code,
    NULL, t2.name,
    NULL, t2.functional_area_id,
    'Insert',
    now()
FROM public.mdg_department t2
LEFT JOIN cdc.mdg_department_old  t1 ON t1.id = t2.id
WHERE t1.id IS NULL;
