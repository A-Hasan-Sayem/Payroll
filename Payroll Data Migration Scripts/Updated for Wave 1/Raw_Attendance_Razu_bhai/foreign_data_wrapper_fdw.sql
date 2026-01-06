
-- checking 
SELECT * FROM pg_extension WHERE extname = 'postgres_fdw';
SELECT srvname, srvoptions FROM pg_foreign_server;
SELECT * FROM pg_user_mappings;
SELECT * FROM pg_foreign_table;

-- Delete foreign table first then bellow 
drop foreign table public.hr_attend_log;
DROP SERVER IF EXISTS payroll_db_server CASCADE;
DROP USER MAPPING IF EXISTS FOR current_user SERVER payroll_db_server;
DROP EXTENSION IF EXISTS postgres_fdw CASCADE;
SELECT * FROM pg_extension WHERE extname = 'postgres_fdw';

SELECT * FROM attendance_raw_data_new LIMIT 5;


CREATE EXTENSION postgres_fdw;

CREATE SERVER payroll_db_server FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (dbname 'inteacchcm_uat', host 'localhost', port '5432');

CREATE USER MAPPING FOR razu SERVER payroll_db_server
OPTIONS (user 'razu', password 'razU1*');-- if access denied then need to use super user


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

INSERT INTO public.hr_attend_log (id, version, empl_id_machine, atten_date, atten_date_time, processed, machine_code)
select  gen_random_uuid(),1,empl_id_machine , atten_date,atten_date_time, false,machine_code
from attendance_raw_data.public.attendance_raw_data_new where empl_id_machine='00275067'
;

insert into attendance_raw_data.public.attendance_raw_data_archive
select *,now() as archive_date  from attendance_raw_data.public.attendance_raw_data_new where empl_id_machine='00275067';

delete from attendance_raw_data.public.attendance_raw_data_new where empl_id_machine='00275067';

select * from public.hr_attend_log;


