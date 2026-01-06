--------------------------------Finding Update and Insert data

SELECT
    n.cc_code,
    n.name,
    CASE
        WHEN o.cc_code IS NULL THEN 'Insert'
        WHEN
            n.name IS DISTINCT FROM o.name
        THEN 'Update'
    END AS FLAG
FROM cdc.integ_cost_centre_imp n
LEFT JOIN public.integ_cost_centre_imp o
    ON n.cc_code = o.cc_code
WHERE
    o.cc_code IS NULL
    OR n.name IS DISTINCT FROM o.name;





--------------Creating table as like interim cost centre data
create table cdc.new_integ_cost_centre_imp
(
    id                     uuid,
    version                integer,
    created_by             varchar(255),
    created_date           timestamp,
    last_modified_by       varchar(255),
    last_modified_date     timestamp,
    cc_code                varchar(255),
    name                   varchar(255),
    cost_cent_created_date timestamp,
    creation_log           text
);

----------------------Creating table for project info data


create table cdc.project_info
(
    id                     bigint,
    version                bigint ,
    book_closing           boolean,
    created_by             bigint ,
    date_created           timestamp,
    domain_status_id       bigint ,
    last_updated           timestamp ,
    program_info_id        bigint ,
    project_code           varchar(255),
    project_country_id     bigint ,
    project_description    varchar(255),
    project_effective_date timestamp ,
    project_end_date       timestamp ,
    project_name           varchar(251),
    project_ref_code       varchar(255),
    project_setup_date     timestamp ,
    project_start_date     timestamp,
    proposal_id            varchar(255),
    updated_by             bigint ,
    parent_project_info_id varchar(255),
    old_program_info_id    bigint,
    department_id          bigint,
    project_short_code     varchar(255),
    old_id                 bigint,
    mf_project_ref_code    varchar,
    bo_type                varchar,
    ho_type                varchar,
    is_independent         boolean  ,
    is_overhead            boolean ,
    is_ngo_beuro           boolean,
    beuro_from_date        timestamp,
    beuro_to_date          timestamp,
    is_trendx_project      boolean,
    is_smart_collection    boolean,
    project_status         varchar(30),
    has_mf_operation       boolean,
    start_month            integer,
    end_month              integer,
    has_fin_operation      boolean,
    mf_end_month           integer,
    source_of_fund_id      bigint,
    remarks                "text",
    foreign_currency       varchar(20),
    local_currency         varchar(20),
    foreign_amount         bigint,
    local_amount           bigint,
    signing_date           timestamp
);

-------------------------------

-----------------Data transfer to project info


-----------------inserting only matched data which already migrated for the uuid to capture updates
INSERT INTO cdc.new_integ_cost_centre_imp(
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
    I.id AS id
       ,0::integer AS version
       ,'1'::character varying AS created_by
     ,NOW()::timestamp AS created_date
     ,'1'::character varying AS last_modified_by
     ,NOW()::timestamp AS last_modified_date
     ,pj.project_code::character varying as cc_code
     ,pj.project_name::character varying as name
     , null as cost_cent_created_date
     , null as creation_log
FROM cdc.project_info as pj
INNER JOIN public.integ_cost_centre_imp I ON Pj.project_code = I.cc_code



---------------------------------inserting new data only

INSERT INTO cdc.new_integ_cost_centre_imp(
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
FROM cdc.project_info as pj
LEFT JOIN public.integ_cost_centre_imp I ON Pj.project_code = I.cc_code
WHERE I.cc_code IS NULL

----------------------------Updaing main table 1


INSERT INTO cdc.mdg_cost_centre_2 (
id, version, created_by, created_date, last_modified_by, last_modified_date,
cc_code, name)
SELECT id, 1, 'api',NOW(), NULL,NULL,cc_code,name
FROM cdc.new_integ_cost_centre_imp
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    last_modified_date = NOW()
WHERE cdc.mdg_cost_centre_2.name IS DISTINCT FROM EXCLUDED.name;

-----------------------------Updating main table 2

INSERT INTO cdc.mdg_cost_centre_company (
id, version, created_by, created_date,
company_id, cost_centre_id)
SELECT gen_random_uuid(), 1, 'api', NOW(), '93647f60-d696-ada6-9b28-cee3c3793e02', id
FROM cdc.new_integ_cost_centre_imp
WHERE id NOT IN(SELECT cost_centre_id FROM cdc.mdg_cost_centre_company);





-------------------------------FOR SNAPSHOT


CREATE TABLE mdg_cost_centre_snapshot (
    id                      uuid,
    version_old             integer,
    version_new             integer,
    created_by_old          varchar(255),
    created_by_new          varchar(255),
    created_date_old        timestamp,
    created_date_new        timestamp,
    last_modified_by_old    varchar(255),
    last_modified_by_new    varchar(255),
    last_modified_date_old  timestamp,
    last_modified_date_new  timestamp,
    cc_code_old             varchar(255),
    cc_code_new             varchar(255),
    name_old                varchar(255),
    name_new                varchar(255),
    cost_centre_group_id_old    uuid,
    cost_centre_group_id_new    uuid,
    person_responsible_old      varchar(255),
    person_responsible_new      varchar(255),
    description_old             text,
    description_new             text,
    cost_centre_category_id_old uuid,
    cost_centre_category_id_new uuid,
    flag                        varchar(20),   -- Update / Insert
    last_modified_date          timestamp DEFAULT now()
);

------------------------Inserting the updated data

INSERT INTO cdc.mdg_cost_centre_snapshot (
    id, version_old, version_new,
    created_by_old, created_by_new,
    created_date_old, created_date_new,
    last_modified_by_old, last_modified_by_new,
    last_modified_date_old, last_modified_date_new,
    cc_code_old, cc_code_new,
    name_old, name_new,
    cost_centre_group_id_old, cost_centre_group_id_new,
    person_responsible_old, person_responsible_new,
    description_old, description_new,
    cost_centre_category_id_old, cost_centre_category_id_new,
    flag, last_modified_date
)
SELECT
    t1.id,
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
    CASE WHEN t1.cc_code IS DISTINCT FROM t2.cc_code THEN t1.cc_code END,
    CASE WHEN t1.cc_code IS DISTINCT FROM t2.cc_code THEN t2.cc_code END,
    CASE WHEN t1.name IS DISTINCT FROM t2.name THEN t1.name END,
    CASE WHEN t1.name IS DISTINCT FROM t2.name THEN t2.name END,
    CASE WHEN t1.cost_centre_group_id IS DISTINCT FROM t2.cost_centre_group_id THEN t1.cost_centre_group_id END,
    CASE WHEN t1.cost_centre_group_id IS DISTINCT FROM t2.cost_centre_group_id THEN t2.cost_centre_group_id END,
    CASE WHEN t1.person_responsible IS DISTINCT FROM t2.person_responsible THEN t1.person_responsible END,
    CASE WHEN t1.person_responsible IS DISTINCT FROM t2.person_responsible THEN t2.person_responsible END,
    CASE WHEN t1.description IS DISTINCT FROM t2.description THEN t1.description END,
    CASE WHEN t1.description IS DISTINCT FROM t2.description THEN t2.description END,
    CASE WHEN t1.cost_centre_category_id IS DISTINCT FROM t2.cost_centre_category_id THEN t1.cost_centre_category_id END,
    CASE WHEN t1.cost_centre_category_id IS DISTINCT FROM t2.cost_centre_category_id THEN t2.cost_centre_category_id END,
    'Update',
    now()
FROM public.mdg_cost_centre t1
JOIN cdc.mdg_cost_centre_2 t2 ON t1.id = t2.id
WHERE (t1 IS DISTINCT FROM t2);

---------------------------------------inserting the insert data


INSERT INTO cdc.mdg_cost_centre_snapshot (
    id, version_new, created_by_new, created_date_new,
    last_modified_by_new, last_modified_date_new,
    cc_code_new, name_new, cost_centre_group_id_new,
    person_responsible_new, description_new, cost_centre_category_id_new,
    flag, last_modified_date
)
SELECT
    t2.id, t2.version, t2.created_by, t2.created_date,
    t2.last_modified_by, t2.last_modified_date,
    t2.cc_code, t2.name, t2.cost_centre_group_id,
    t2.person_responsible, t2.description, t2.cost_centre_category_id,
    'Insert',
    now()
FROM cdc.mdg_cost_centre_2 t2
LEFT JOIN public.mdg_cost_centre  t1 ON t1.id = t2.id
WHERE t1.id IS NULL;




