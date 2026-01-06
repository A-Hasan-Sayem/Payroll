--CREATE DATABASE attendance_raw_data;

create table public.attendance_punch_data
(
    pin           varchar(10),
    machine_id    varchar(4),
    punchdate     date,
    punchdatetime timestamp
);

create table public.attendance_raw_data_new
(
    id              uuid,
    version         integer     not null,
    empl_id_machine varchar(10),
    atten_date      date,
    atten_date_time timestamp,
    processed       integer     not null,
    machine_code    varchar(4),
    created_by      varchar(11) not null,
    created_date    timestamp   not null
);

CREATE TABLE public.attendance_raw_data_archive (
	id              uuid,
    version         integer     not null,
    empl_id_machine varchar(10),
    atten_date      date,
    atten_date_time timestamp,
    processed       integer     not null,
    machine_code    varchar(4),
    created_by      varchar(11) not null,
    created_date    timestamp   not null,
	archive_date timestamp   not null
);

-----------------FDW----------------------

-- checking
SELECT * FROM pg_extension WHERE extname = 'postgres_fdw';
SELECT srvname, srvoptions FROM pg_foreign_server;
SELECT * FROM pg_user_mappings;
SELECT * FROM pg_foreign_table;

CREATE EXTENSION postgres_fdw;

CREATE SERVER payroll_db_server FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (dbname 'blank_db_uat', host 'localhost', port '4550');

CREATE USER MAPPING FOR bits SERVER payroll_db_server
OPTIONS (user 'bits', password 'biTS@#123');-- if access denied then need to use super user

CREATE FOREIGN TABLE hr_attend_log (
    id                 uuid    not null,
    version            integer not null,
    created_by         varchar(255),
    created_date       timestamp,
    last_modified_by   varchar(255),
    last_modified_date timestamp,
    empl_id_machine    varchar(255),
    atten_date         date,
    atten_date_time    timestamp,
    processed          boolean,
    machine_code       varchar(255)
) SERVER payroll_db_server
OPTIONS (schema_name 'public', table_name 'hr_attend_log');


---------------------------------------------------

--attendance_raw_data_new
INSERT INTO attendance_raw_data_new (id,version,empl_id_machine,atten_date,atten_date_time,processed,machine_code,created_by,created_date)
    SELECT gen_random_uuid() as id,1 as version, LPAD(CAST(pin AS TEXT), 8, '0') pin,cast(punchdate as DATE) ,CAST(punchdatetime as timestamp),0,machine_id,'backend_job',now()
from attendance_punch_data;

--attendance_raw_data_archive
insert into public.attendance_raw_data_archive
select *,now() as archive_date from attendance_raw_data.public.attendance_raw_data_new;

--hr_attend_log
INSERT INTO public.hr_attend_log (id, version, empl_id_machine, atten_date, atten_date_time, processed, machine_code)
select  gen_random_uuid(),1,empl_id_machine,atten_date,atten_date_time,false,machine_code
from attendance_raw_data.public.attendance_raw_data_new;

--delete attendance_raw_data_new
delete from public.attendance_raw_data_new;

