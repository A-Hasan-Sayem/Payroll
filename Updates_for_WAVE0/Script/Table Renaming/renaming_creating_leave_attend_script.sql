/*
    FIRST PART: Rename all existing leave and attendance tables and their constraints (pks and fks) to something new
*/

-- pk_integ_leave_app_imp


----------------------------- 1. Rename INTEG_LEAVE_APP_IMP to integ_leave_app_imp_beta -------------------------

ALTER TABLE integ_leave_app_imp RENAME TO integ_leave_app_imp_beta;

-- Change PK name of integ_leave_app_imp
ALTER TABLE integ_leave_app_imp_beta -- newly renamed table
RENAME CONSTRAINT pk_integ_leave_app_imp TO pk_integ_leave_app_imp_beta; -- newly renamed pk

-- FK constraints, no needed.

------------------------------ 2. Rename integ_leave_app_line_imp to integ_leave_app_line_imp_beta -------------------
-- before that, change fk relation

-- first drop the current relation
ALTER TABLE integ_leave_app_line_imp
DROP CONSTRAINT fk_integ_leave_app_line_imp_on_leave_app_imp;


-- Add constraint to newly renamed beta master table
ALTER TABLE integ_leave_app_line_imp
ADD CONSTRAINT fk_intg_lve_app_lne_imp_on_lve_app_imp_beta -- new fk
FOREIGN KEY (leave_app_imp_id)
REFERENCES integ_leave_app_imp_beta -- new master table
ON DELETE CASCADE;

-- Finally rename integ_leave_app_line_imp to integ_leave_app_line_imp_beta

ALTER TABLE integ_leave_app_line_imp RENAME TO integ_leave_app_line_imp_beta;

-- Rename pk of integ_leave_app_line_imp_beta

ALTER TABLE integ_leave_app_line_imp_beta -- newly renamed table
RENAME CONSTRAINT pk_integ_leave_app_line_imp TO pk_integ_leave_app_line_imp_beta; -- newly renamed pk

-- Rename index as well
ALTER INDEX idx_integ_leave_app_line_imp_leave_app_imp RENAME TO idx_itg_lve_app_lne_imp_lve_app_imp_beta;


---------------------------- 3. integ_leave_op_balance_imp to integ_leave_op_balance_imp_beta ---------------------------

ALTER TABLE integ_leave_op_balance_imp RENAME TO integ_leave_op_balance_imp_beta;

-- Change pk name of integ_leave_op_balance_imp
ALTER TABLE integ_leave_op_balance_imp_beta -- newly renamed_table
RENAME CONSTRAINT pk_integ_leave_op_balance_imp TO pk_integ_leave_op_balance_imp_beta; -- new pk

-- No foreign keys here.

---------------------------- 4. integ_work_away_office_imp to integ_work_away_office_imp_beta ---------------------------

ALTER TABLE integ_work_away_office_imp RENAME TO integ_work_away_office_imp_beta;

-- Change pk name of integ_leave_op_balance_imp
ALTER TABLE integ_work_away_office_imp_beta -- newly renamed_table
RENAME CONSTRAINT pk_integ_work_away_office_imp TO pk_integ_work_away_office_imp_beta; -- new pk

-- No fk here

---------------------------- 5. integ_work_away_office_line_imp to integ_work_away_office_line_imp_beta ------------------

-- before that, change fk relation

-- first drop the current relation
ALTER TABLE integ_work_away_office_line_imp
DROP CONSTRAINT fk_integ_work_away_office_line_imp_on_work_away_office_imp;


-- Add constraint to newly renamed beta master table
ALTER TABLE integ_work_away_office_line_imp
ADD CONSTRAINT fk_intg_work_away_offc_lne_imp_on_work_away_offc_imp_beta -- new fk
FOREIGN KEY (work_away_office_imp_id)
REFERENCES integ_work_away_office_imp_beta -- new master table
ON DELETE CASCADE;

-- Finally rename integ_work_away_office_line_imp to integ_work_away_office_line_imp_beta

ALTER TABLE integ_work_away_office_line_imp RENAME TO integ_work_away_office_line_imp_beta;


-- Rename pk of integ_leave_app_line_imp_beta

ALTER TABLE integ_work_away_office_line_imp_beta -- newly renamed table
RENAME CONSTRAINT pk_integ_work_away_office_line_imp TO pk_integ_work_away_office_line_imp_beta; -- newly renamed pk

-- Rename index as well
ALTER INDEX idx_integ_work_away_office_line_imp_work_away_office_imp
RENAME TO idx_intg_work_away_offc_ln_imp_work_away_offc_imp_beta;

------------------------------- 6. integ_attend_missed_app_imp to integ_attend_missed_app_imp_beta -----------------------

-- Rename table name
ALTER TABLE integ_attend_missed_app_imp RENAME TO integ_attend_missed_app_imp_beta;

-- Change PK name of integ_leave_app_imp
ALTER TABLE integ_attend_missed_app_imp_beta -- newly renamed table
RENAME CONSTRAINT pk_integ_attend_missed_app_imp TO pk_integ_attend_missed_app_imp_beta; -- newly renamed pk



----------------------- table creation --------------------------------------

/*
    SECOND PART: create all leave and attendance interim tables so that no conflicts can occur when migrating data from interim to destination
*/


-- Leave & Attendance DDL Script

-- These tables were originally like this. But we had to change the names to _beta and create these tables fresh. To avoid fk and pk object
-- conflicts, we're adding _new suffix in every fk and pk in these tables.


-- 1.INTEG_LEAVE_APP_IMP

-- auto-generated definition
create table integ_leave_app_imp
(
    id                     uuid    not null
        constraint pk_integ_leave_app_imp
            primary key,
    version                integer not null,
    created_by             varchar(255),
    created_date           timestamp,
    last_modified_by       varchar(255),
    last_modified_date     timestamp,
    app_number             varchar(255),
    application_date       date,
    employee_code          varchar(255),
    leave_type_code        varchar(255),
    event_date             date,
    event_end_date         date,
    start_date             date,
    end_date               date,
    duration_type          integer,
    leave_app_created_date timestamp,
    creation_log           text
);

alter table integ_leave_app_imp
    owner to postgres;



-- 2.INTEG_LEAVE_APP_LINE_IMP

-- auto-generated definition
create table integ_leave_app_line_imp
(
    id                        uuid    not null
        constraint pk_integ_leave_app_line_imp
            primary key,
    version                   integer not null,
    created_by                varchar(255),
    created_date              timestamp,
    last_modified_by          varchar(255),
    last_modified_date        timestamp,
    leave_date                date,
    leave_type_code           varchar(255),
    leave_day                 double precision,
    leave_year                varchar(255),
    duration_type             varchar(255),
    seniority_loss_updated    boolean,
    leave_app_imp_id          uuid    not null
        constraint fk_integ_leave_app_line_imp_on_leave_app_imp
            references integ_leave_app_imp
            on delete cascade,
    holiday_weekend_work_date date
);

alter table integ_leave_app_line_imp
    owner to postgres;

create index idx_integ_leave_app_line_imp_leave_app_imp
    on integ_leave_app_line_imp (leave_app_imp_id);



-- 3.integ_leave_op_balance_imp

-- auto-generated definition
create table integ_leave_op_balance_imp
(
    id                    uuid    not null
        constraint pk_integ_leave_op_balance_imp
            primary key,
    version               integer not null,
    created_by            varchar(255),
    created_date          timestamp,
    last_modified_by      varchar(255),
    last_modified_date    timestamp,
    employee_code         varchar(255),
    leave_year_code       varchar(255),
    leave_type_code       varchar(255),
    days_leave_bf         double precision,
    days_leave_taken_cy   double precision,
    remarks               varchar,
    creation_log          text,
    leave_op_created_date timestamp,
    balance_days          double precision,
    entitlement_cy        double precision,
    leave_op_balance_date date
);

alter table integ_leave_op_balance_imp
    owner to postgres;



-- 4.integ_work_away_office_imp

-- auto-generated definition
create table integ_work_away_office_imp
(
    id                 uuid    not null
        constraint pk_integ_work_away_office_imp
            primary key,
    version            integer not null,
    created_by         varchar(255),
    created_date       timestamp,
    last_modified_by   varchar(255),
    last_modified_date timestamp,
    doc_no             varchar(255),
    doc_date           date,
    employee_code      varchar(255),
    oper_location_code varchar(255),
    deliverables       varchar(255),
    destination_type   integer,
    work_address       varchar(255),
    work_away_type     integer,
    visit_end_time     time,
    visit_start_time   time
);

alter table integ_work_away_office_imp
    owner to postgres;

-- 5.integ_work_away_office_line_imp

-- auto-generated definition
create table integ_work_away_office_line_imp
(
    id                      uuid    not null
        constraint pk_integ_work_away_office_line_imp
            primary key,
    version                 integer not null,
    created_by              varchar(255),
    created_date            timestamp,
    last_modified_by        varchar(255),
    last_modified_date      timestamp,
    attend_date             date,
    work_away_office_imp_id uuid    not null
        constraint fk_integ_work_away_office_line_imp_on_work_away_office_imp
            references integ_work_away_office_imp
            on delete cascade,
    visit_location          varchar(255),
    weekend_or_holiday      boolean,
    working_day             double precision
);

alter table integ_work_away_office_line_imp
    owner to postgres;

create index idx_integ_work_away_office_line_imp_work_away_office_imp
    on integ_work_away_office_line_imp (work_away_office_imp_id);



-- 6.integ_attend_missed_app_imp

-- auto-generated definition
create table integ_attend_missed_app_imp
(
    id                  uuid not null
        constraint pk_integ_attend_missed_app_imp
            primary key,
    atten_miss_entry_no varchar(255),
    appl_date           date,
    employee_code       varchar(255),
    atten_date          date,
    in_time             time,
    out_time            time,
    workshift_code      varchar(255),
    out_date            date
);

alter table integ_attend_missed_app_imp
    owner to postgres;


-- Check:

SELECT COUNT(1) FROM integ_leave_app_imp;

SELECT COUNT(1) FROM integ_leave_app_line_imp;

SELECT COUNT(1) FROM integ_leave_op_balance_imp;

SELECT COUNT(1) FROM integ_work_away_office_imp;

SELECT COUNT(1) FROM integ_work_away_office_line_imp;

SELECT COUNT(1) FROM integ_attend_missed_app_imp;
