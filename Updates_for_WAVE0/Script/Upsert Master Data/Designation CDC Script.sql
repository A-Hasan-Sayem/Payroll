---------------------------------------- Check if any Updates/Insert (Designation)---------------------------------------------------
SELECT
    n.code,
    n.name,
    CASE
        WHEN o.code IS NULL THEN 'Insert'
        WHEN
            n.name IS DISTINCT FROM o.name
        THEN 'Update'
    END AS FLAG
FROM cdc.integ_designation_imp n
LEFT JOIN public.integ_designation_imp o
    ON n.code = o.code
WHERE
    o.code IS NULL
    OR n.name IS DISTINCT FROM o.name;

----------------------------------------- Create Additional Table ------------------------------------------------------
create table cdc.hmd_designation_old as select * from public.hmd_designation;

--------------------------------------------  Main table ID update -----------------------------------------------------

UPDATE cdc.integ_designation_imp imp
SET id = mo.id
FROM public.hmd_designation mo
WHERE imp.code = mo.code;

---------------------------------------------- CONSTRAINT adjust -------------------------------------------------------

-- ALTER TABLE cdc.integ_designation_imp
-- ADD CONSTRAINT integ_designation_imp_pkey PRIMARY KEY (id);

--------------------------------------------- Designation Transformation and Load---------------------------------------
  INSERT INTO public.hmd_designation (
    id, version, created_by, created_date, code, name
)
SELECT
    src.id,
    2,
    'CDC',
    NOW(),
    src.code,
    src.name
FROM CDC.integ_designation_imp src
ON CONFLICT (id) DO UPDATE
SET
    name = EXCLUDED.name;


----------------------------------------- Create CDC Snapshot Table ----------------------------------------------------
CREATE TABLE cdc.designation_snapshot (
    id UUID,
    version_old INTEGER,
    version_new INTEGER,
    created_by_old VARCHAR(255),
    created_by_new VARCHAR(255),
    created_date_old TIMESTAMP,
    created_date_new TIMESTAMP,
    code_old VARCHAR(255),
    code_new VARCHAR(255),
    name_old VARCHAR(255),
    name_new VARCHAR(255),
    FLAG TEXT,
    Last_Modified_date TIMESTAMP DEFAULT now()
);


--delete from cdc.operating_location_snapshot
---------------------------------------------------------  Updates track -----------------------------------------------
INSERT INTO cdc.designation_snapshot (
    id,
    version_old, version_new,
    created_by_old, created_by_new,
    created_date_old, created_date_new,
    code_old, code_new,
    name_old, name_new,
    FLAG, Last_Modified_date
)
SELECT
    t1.id,
    CASE WHEN t1.version IS DISTINCT FROM t2.version THEN t1.version END,
    CASE WHEN t1.version IS DISTINCT FROM t2.version THEN t2.version END,

    CASE WHEN t1.created_by IS DISTINCT FROM t2.created_by THEN t1.created_by END,
    CASE WHEN t1.created_by IS DISTINCT FROM t2.created_by THEN t2.created_by END,

    CASE WHEN t1.created_date IS DISTINCT FROM t2.created_date THEN t1.created_date END,
    CASE WHEN t1.created_date IS DISTINCT FROM t2.created_date THEN t2.created_date END,

    CASE WHEN t1.code IS DISTINCT FROM t2.code THEN t1.code END,
    CASE WHEN t1.code IS DISTINCT FROM t2.code THEN t2.code END,

    CASE WHEN t1.name IS DISTINCT FROM t2.name THEN t1.name END,
    CASE WHEN t1.name IS DISTINCT FROM t2.name THEN t2.name END,

    'Update',
    now()
FROM cdc.hmd_designation_old t1
JOIN public.hmd_designation t2 ON t1.id = t2.id
WHERE
    t1.version IS DISTINCT FROM t2.version OR
    t1.created_by IS DISTINCT FROM t2.created_by OR
    t1.created_date IS DISTINCT FROM t2.created_date OR
    t1.code IS DISTINCT FROM t2.code OR
    t1.name IS DISTINCT FROM t2.name;

---------------------------------------------------------  Insert track ------------------------------------------------

INSERT INTO cdc.designation_snapshot (
    id,
    version_new, created_by_new, created_date_new, code_new, name_new,
    FLAG, Last_Modified_date
)
SELECT
    t2.id,
    t2.version, t2.created_by, t2.created_date, t2.code, t2.name,
    'Insert',
    now()
FROM public.hmd_designation t2
LEFT JOIN cdc.hmd_designation_old t1 ON t1.id = t2.id
WHERE t1.id IS NULL;