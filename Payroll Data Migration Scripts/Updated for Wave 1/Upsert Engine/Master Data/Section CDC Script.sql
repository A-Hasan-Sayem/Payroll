----------------------Finding Updates and Inserts Data (Section) ----------------------------------------------
SELECT
    n.sec_code,
    n.name,
    n.dept_code,
    n.cost_cent_code,
    CASE
        WHEN o.sec_code IS NULL THEN 'Insert'
        WHEN
            n.name IS DISTINCT FROM o.name
            OR n.dept_code IS DISTINCT FROM o.dept_code
            OR n.cost_cent_code IS DISTINCT FROM o.cost_cent_code
        THEN 'Update'
    END AS FLAG
FROM cdc.integ_section_imp n
LEFT JOIN public.integ_section_imp o
    ON n.sec_code = o.sec_code
WHERE
    o.sec_code IS NULL
    OR n.name IS DISTINCT FROM o.name
    OR n.dept_code IS DISTINCT FROM o.dept_code
    OR n.cost_cent_code IS DISTINCT FROM o.cost_cent_code;

------------------------------------------

create table cdc.mdg_dept_section_old as select * from public.mdg_dept_section;

-------------------------

UPDATE cdc.INTEG_SECTION_IMP imp
SET id = mo.id
FROM public.mdg_dept_section mo
WHERE imp.sec_code = mo.sec_code;




-------------------------------------------------------

INSERT INTO public.mdg_dept_section (
id, version, created_by, created_date, sec_code,
name, cost_centre_id, department_id, dtype
)
WITH SECTION_CTE AS(
SELECT NIS.id AS id,1 AS version,'data migration' AS created_by, CURRENT_TIMESTAMP AS created_date,NIS.sec_code, NIS.name, MCC.id AS cost_centre_id
,MD.id AS department_id,'hmd_section' AS dtype
FROM cdc.integ_section_imp NIS
LEFT JOIN public.mdg_department  MD ON NIS.dept_code = MD.dept_code
LEFT JOIN public.mdg_cost_centre MCC ON NIS.cost_cent_code = MCC.cc_code
)
SELECT id, version, created_by, created_date, sec_code,
name, cost_centre_id, department_id, dtype
FROM SECTION_CTE
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    department_id = EXCLUDED.department_id;





-------------------------------------------For Section snapshot

CREATE TABLE cdc.mdg_dept_section_snapshot (
    id uuid,

    dtype_old                 varchar(31),
    dtype_new                 varchar(31),

    version_old               integer,
    version_new               integer,

    created_by_old            varchar(255),
    created_by_new            varchar(255),

    created_date_old          timestamp,
    created_date_new          timestamp,

    last_modified_by_old      varchar(255),
    last_modified_by_new      varchar(255),

    last_modified_date_old    timestamp,
    last_modified_date_new    timestamp,

    sec_code_old              varchar(255),
    sec_code_new              varchar(255),

    name_old                  varchar(255),
    name_new                  varchar(255),

    sec_head_id_old           uuid,
    sec_head_id_new           uuid,

    cost_centre_id_old        uuid,
    cost_centre_id_new        uuid,

    department_id_old         uuid,
    department_id_new         uuid,

    control_account_pr_id_old uuid,
    control_account_pr_id_new uuid,

    flag                      varchar(20),   -- Update / Insert
    last_modified_date        timestamp DEFAULT now()
);


INSERT INTO mdg_dept_section_snapshot (
    id,
    dtype_old, dtype_new,
    version_old, version_new,
    created_by_old, created_by_new,
    created_date_old, created_date_new,
    last_modified_by_old, last_modified_by_new,
    last_modified_date_old, last_modified_date_new,
    sec_code_old, sec_code_new,
    name_old, name_new,
    sec_head_id_old, sec_head_id_new,
    cost_centre_id_old, cost_centre_id_new,
    department_id_old, department_id_new,
    control_account_pr_id_old, control_account_pr_id_new,
    flag, last_modified_date
)
SELECT
    t1.id,

    CASE WHEN t1.dtype IS DISTINCT FROM t2.dtype THEN t1.dtype END,
    CASE WHEN t1.dtype IS DISTINCT FROM t2.dtype THEN t2.dtype END,

    CASE WHEN t1.version IS DISTINCT FROM t2.version THEN t1.version END,
    CASE WHEN t1.version IS DISTINCT FROM t2.version THEN t2.version END,

    CASE WHEN t1.created_by IS DISTINCT FROM t2.created_by THEN t1.created_by END,
    CASE WHEN t1.created_by IS DISTINCT FROM t2.created_by THEN t2.created_by END,

    CASE WHEN t1.created_date IS DISTINCT FROM t2.created_date THEN t1.created_date END,
    CASE WHEN t1.created_date IS DISTINCT FROM t2.created_date THEN t2.created_date END,

    CASE WHEN t1.last_modified_by IS DISTINCT FROM t2.last_modified_by THEN t1.last_modified_by END,
    CASE WHEN t1.last_modified_by IS DISTINCT FROM t2.last_modified_by THEN t2.last_modified_by END,

    CASE WHEN t1.last_modified_date IS DISTINCT FROM t2.last_modified_date THEN t1.last_modified_date END,
    CASE WHEN t1.last_modified_date IS DISTINCT FROM t2.last_modified_date THEN t2.last_modified_date END,

    CASE WHEN t1.sec_code IS DISTINCT FROM t2.sec_code THEN t1.sec_code END,
    CASE WHEN t1.sec_code IS DISTINCT FROM t2.sec_code THEN t2.sec_code END,

    CASE WHEN t1.name IS DISTINCT FROM t2.name THEN t1.name END,
    CASE WHEN t1.name IS DISTINCT FROM t2.name THEN t2.name END,

    CASE WHEN t1.sec_head_id IS DISTINCT FROM t2.sec_head_id THEN t1.sec_head_id END,
    CASE WHEN t1.sec_head_id IS DISTINCT FROM t2.sec_head_id THEN t2.sec_head_id END,

    CASE WHEN t1.cost_centre_id IS DISTINCT FROM t2.cost_centre_id THEN t1.cost_centre_id END,
    CASE WHEN t1.cost_centre_id IS DISTINCT FROM t2.cost_centre_id THEN t2.cost_centre_id END,

    CASE WHEN t1.department_id IS DISTINCT FROM t2.department_id THEN t1.department_id END,
    CASE WHEN t1.department_id IS DISTINCT FROM t2.department_id THEN t2.department_id END,

    CASE WHEN t1.control_account_pr_id IS DISTINCT FROM t2.control_account_pr_id THEN t1.control_account_pr_id END,
    CASE WHEN t1.control_account_pr_id IS DISTINCT FROM t2.control_account_pr_id THEN t2.control_account_pr_id END,

    'Update',
    now()
FROM public.mdg_dept_section t1
JOIN cdc.mdg_dept_section_old t2 ON t1.id = t2.id
WHERE t1 IS DISTINCT FROM t2;





INSERT INTO cdc.mdg_dept_section_snapshot (
    id,
    dtype_new, version_new,
    created_by_new, created_date_new,
    last_modified_by_new, last_modified_date_new,
    sec_code_new, name_new,
    sec_head_id_new, cost_centre_id_new,
    department_id_new, control_account_pr_id_new,
    flag, last_modified_date
)
SELECT
    t2.id,
    t2.dtype, t2.version,
    t2.created_by, t2.created_date,
    t2.last_modified_by, t2.last_modified_date,
    t2.sec_code, t2.name,
    t2.sec_head_id, t2.cost_centre_id,
    t2.department_id, t2.control_account_pr_id,
    'Insert',
    now()
FROM public.mdg_dept_section t2
LEFT JOIN cdc.mdg_dept_section_old t1 ON t1.id = t2.id
WHERE t1.id IS NULL;














