--------------------------payroll_master_data--------------------------

--division
create table payroll_master_data.division (like public.division);
insert into payroll_master_data.division
select *
from public.division;

--district
create table payroll_master_data.district (like public.district);
insert into payroll_master_data.district
select *
from public.district;

--thana
create table payroll_master_data.thana (like public.thana);
insert into payroll_master_data.thana
select *
from public.thana;

--physical_office_info
create table payroll_master_data.physical_office_info (like public.physical_office_info);
insert into payroll_master_data.physical_office_info
select *
from public.physical_office_info;

--office_address
create table payroll_master_data.office_address (like public.office_address);
insert into payroll_master_data.office_address
select *
from public.office_address;

--geo_info
create table payroll_master_data.geo_info (like public.geo_info);
insert into payroll_master_data.geo_info
select *
from public.geo_info;

--project_info
create table payroll_master_data.project_info (like public.project_info);
insert into payroll_master_data.project_info
select *
from public.project_info;

--program_info
create table payroll_master_data.program_info (like public.program_info);
insert into payroll_master_data.program_info
select *
from public.program_info;

--employee_designation
create table payroll_master_data.employee_designation (like public.employee_designation);
insert into payroll_master_data.employee_designation
select *
from public.employee_designation;

--dept-func-area-map
create table payroll_master_data.dept_func_area_map  --need to import excel data
(
    dept_code           varchar(4369),
    dept_name           varchar(4369),
    func_area_code      varchar(4369),
    func_area_name      varchar(4369)
);

insert into payroll_master_data.dept_func_area_map (dept_code, dept_name, func_area_code, func_area_name)
values  ('132', 'Humanitarian Crisis Management Programme (HCMP)', '04', 'HCMP'),
        ('42', 'BRAC Seed and Agro Enterprise', '03', 'Enterprises'),
        ('83', 'BRAC Cold Storage', '03', 'Enterprises'),
        ('129', 'Risk Management Services', '01', 'Development'),
        ('128', 'Security Services', '01', 'Development'),
        ('153', 'Safeguarding & Grievance Management Committee (SGMC)', '01', 'Development'),
        ('95', 'BRAC Health Programme (BHP)', '01', 'Development'),
        ('149', 'Social Compliance', '01', 'Development'),
        ('29', 'Migration Programme', '01', 'Development'),
        ('38', 'Road Safety', '01', 'Development'),
        ('12', 'Water Sanitation and Hygiene Programme (WASH)', '01', 'Development'),
        ('7', 'AARONG', '02', 'Aarong'),
        ('44', 'Aarong-HO', '02', 'Aarong'),
        ('81', 'BRAC Artificial Insemination Enterprise', '03', 'Enterprises'),
        ('82', 'BRAC Dairy and Food Project', '03', 'Enterprises'),
        ('84', 'BRAC Fisheries Enterprise', '03', 'Enterprises'),
        ('91', 'BRAC Healthcare Limited', '03', 'Enterprises'),
        ('85', 'BRAC Nursery', '03', 'Enterprises'),
        ('86', 'BRAC Printing Pack', '03', 'Enterprises'),
        ('88', 'BRAC Sericulture Enterprise', '03', 'Enterprises'),
        ('87', 'BRAC Recycled Handmade Paper Enterprise', '03', 'Enterprises'),
        ('152', 'BRAC Learning Center (BLC)', '01', 'Development'),
        ('15', 'BRAC International', '01', 'Development'),
        ('118', 'Central Store', '01', 'Development'),
        ('122', 'Administration', '01', 'Development'),
        ('117', 'Communications Department', '01', 'Development'),
        ('130', 'Social Innovation Lab (SIL)', '01', 'Development'),
        ('25', 'Legal and Compliance', '01', 'Development'),
        ('092', 'BRAC Global', '01', 'Development'),
        ('116', 'Construction', '01', 'Development'),
        ('28', 'Advocacy for Social Change (ASC)', '01', 'Development'),
        ('3', 'BRAC Education Programme (BEP)', '01', 'Development'),
        ('115', 'Maintenance', '01', 'Development'),
        ('22', 'BRAC Institute of Educational Development (BIED)', '01', 'Development'),
        ('110', 'Procurement', '01', 'Development'),
        ('10', 'Microfinance', '01', 'Development'),
        ('112', 'Telephone', '01', 'Development'),
        ('133', 'Climate Change Programme (CCP)', '01', 'Development'),
        ('23', 'Gender Justice and Diversity (GJD)', '01', 'Development'),
        ('BRAC Artificial Insemination Entr-139', 'BRAC Artificial Insemination Entr', '03', 'Enterprises'),
        ('39', 'BEEL', '01', 'Development'),
        ('45', 'Communicable Disease Programme (CDP)', '01', 'Development'),
        ('41', 'Investigation', '01', 'Development'),
        ('9', 'HEAD OFFICE', '01', 'Development'),
        ('24', 'BRAC Agriculture and Food Security Program (AFS)', '01', 'Development'),
        ('18', 'Community Empowerment Programme (CEP)', '01', 'Development'),
        ('17', 'Human Rights and Legal Aid Services (HRLS)', '01', 'Development'),
        ('11', 'BRAC Enterprises', '03', 'Enterprises'),
        ('26', 'BRAC Services Ltd. (BSL)', '01', 'Development'),
        ('147', 'Travel Management and Protocol', '01', 'Development'),
        ('37', 'Driving Training', '01', 'Development'),
        ('125', 'Tea Garden', '01', 'Development'),
        ('126', 'BRAC Institute of Languages (BIL)', '01', 'Development'),
        ('21', 'Barga Chashi', '01', 'Development'),
        ('8', 'Other Departmental Activities (ODA)', '01', 'Development'),
        ('40', 'BRAC Probashbandhu Ltd (BPL)', '01', 'Development'),
        ('200', 'Overhead', '01', 'Development'),
        ('13', 'Progoti', '01', 'Development'),
        ('137', 'BRAC Project Fund (BPF)', '01', 'Development'),
        ('123', 'BRAC Ombudsperson', '01', 'Development'),
        ('124', 'BRAC University', '01', 'Development'),
        ('27', 'Integrated Development Programme (IDP)', '01', 'Development'),
        ('111', 'Corporate Office', '01', 'Development'),
        ('19', 'Ultra-Poor Graduation (UPG)', '01', 'Development'),
        ('36', 'Estate', '01', 'Development'),
        ('46', 'Urban Development Programme (UDP)', '01', 'Development'),
        ('33', 'Monitoring, Evaluation, Accountability and Learning (MEAL)', '01', 'Development'),
        ('32', 'Internal Audit', '01', 'Development'),
        ('138', 'Safeguarding', '01', 'Development'),
        ('34', 'Partnership Strengthening Unit (PSU)', '01', 'Development'),
        ('16', 'Support Program', '01', 'Development'),
        ('114', 'Transport & Workshop', '01', 'Development'),
        ('131', 'BRAC Daycare Center', '01', 'Development'),
        ('20', 'Disaster Risk Management', '01', 'Development'),
        ('121', 'Global Resource Mobilisation and Partnerships (GRP)', '01', 'Development'),
        ('5', 'Learning and Leadership Development  Division (LLD)', '01', 'Development'),
        ('93', 'Technology Division', '01', 'Development'),
        ('14', 'Skills Development Programme (SDP)', '01', 'Development'),
        ('30', 'Finance and Accounts', '01', 'Development'),
        ('136', 'BRAC Kumon Limited', '01', 'Development'),
        ('113', 'Logistics Services', '01', 'Development'),
        ('134', 'Operations', '01', 'Development'),
        ('2', 'BRAC Programme Support Enterprises (PSE)', '01', 'Development'),
        ('6', 'BRAC Research and Evaluation Division (RED)', '01', 'Development'),
        ('31', 'Human Resource Division', '01', 'Development'),
        ('90', 'Social Empowerment and Legal Protection (SELP)', '01', 'Development'),
        ('test 32525', 'test 1', '01', 'Development'),
        ('programInfo?.programCode', 'programInfo?.programName', '01', 'Development'),
        ('programInfo?.programCode_update', 'programInfo?.programName', '01', 'Development'),
        ('testcode', 'testname22', '01', 'Development'),
        ('testcode24244', 'testname2222', '02', 'Aarong'),
        ('AurnieTesting', 'testname2222', '02', 'Aarong'),
        ('0104', 'Test API', '01', 'Development'),
        ('0100', 'Test API3', '01', 'Development'),
        ('0105', 'Test API0105', '01', 'Development'),
        ('0106', 'Test API0107', '01', 'Development'),
        ('120', 'Executive', '01', 'Development'),
        ('4', 'Health Nutrition and Population Programme (HNPP)', '01', 'Development'),
        ('135', 'Preventing Violence Against Women', '01', 'Development'),
        ('BRAC Recycled Handmade Paper Entr-145', 'BRAC Recycled Handmade Paper Entr', '03', 'Enterprises'),
        ('119', 'Sexual Harassment Redressal Committee (SHRC)', '01', 'Development'),
        ('35', 'Bkash', '01', 'Development'),
        ('43', 'BRAC Center of Development Management (BCDM)', '01', 'Development'),
        ('1', 'Unknown', '01', 'Development'),
        ('0095', 'BRAC Green Packaging', '01', 'Development');



--------------------------payroll_emp_data--------------------------

--employee_information_update
create table payroll_emp_data.employee_information_update (like public.employee_information_update);
insert into payroll_emp_data.employee_information_update
select *
from public.employee_information_update;

--employee_core_info
create table payroll_emp_data.employee_core_info (like public.employee_core_info);
insert into payroll_emp_data.employee_core_info
select *
from public.employee_core_info;

--employee_bank_info
create table payroll_emp_data.employee_bank_info (like public.employee_bank_info);
insert into payroll_emp_data.employee_bank_info
select *
from public.employee_bank_info;

--emp_core_info_history
create table payroll_emp_data.emp_core_info_history (like public.emp_core_info_history);
insert into payroll_emp_data.emp_core_info_history
select *
from public.emp_core_info_history;

--job_separation_proposal
create table payroll_emp_data.job_separation_proposal (like public.job_separation_proposal);
insert into payroll_emp_data.job_separation_proposal
select *
from public.job_separation_proposal;

--employee_address
create table payroll_emp_data.employee_address (like public.employee_address);
insert into payroll_emp_data.employee_address
select *
from public.employee_address;

--employee_basic_info
create table payroll_emp_data.employee_basic_info (like public.employee_basic_info);
insert into payroll_emp_data.employee_basic_info
select *
from public.employee_basic_info;

--nationality
create table payroll_emp_data.nationality (like public.nationality);
insert into payroll_emp_data.nationality
select *
from public.nationality;

--employee_contact_info
create table payroll_emp_data.employee_contact_info (like public.employee_contact_info);
insert into payroll_emp_data.employee_contact_info
select *
from public.employee_contact_info;

--gender
create table payroll_emp_data.gender (like public.gender);
insert into payroll_emp_data.gender
select *
from public.gender;

--employee_category
create table payroll_emp_data.employee_category (like public.employee_category);
insert into payroll_emp_data.employee_category
select *
from public.employee_category;

--emp_confirmation_date
create table payroll_emp_data.emp_confirmation_date  --need to import excel data provided by brac
(
    staffpin           varchar(4369),
    confirmation_date  date
);

--updated_religion
create table payroll_emp_data.updated_religion  --need to import excel data provided by brac
(
    employee_id         bigint,
    employee_pin        varchar(250),
    emp_job_status_id   bigint,
    emp_job_status_name varchar(100),
    office_id           bigint,
    office_code         varchar(50),
    office_type_id      bigint,
    religion_id         varchar(50),
    religion            varchar(50),
    religion_id_updated bigint
);

--leave_tools.users
create table payroll_emp_data.users      --need to import/ETL data (3lac, 7min)
(
    id                    bigint,
    pin                   varchar(4369),
    name                  varchar(4369),
    sex                   varchar(4369),
    dateofbirth           date,
    joining_date          date,
    contract_start_date   date,
    contract_expiry_date  date,
    erp_created_date      timestamp,
    status                varchar(4369),
    jobstatus             varchar(4369),
    jobbase               varchar(4369),
    designationid         varchar(4369),
    designation           varchar(4369),
    functionaldesignation varchar(4369),
    program_code          varchar(4369),
    program_name          varchar(4369),
    project_code          varchar(4369),
    project_name          varchar(4369),
    branchname            varchar(4369),
    office_code           varchar(4369),
    district_name         varchar(4369),
    thana_name            varchar(4369),
    division_name         varchar(4369),
    level                 integer,
    email                 varchar(4369),
    mobile                varchar(4369),
    group_name            varchar(4369),
    maritalstatus         varchar(4369),
    smart_nid_no          varchar(4369),
    national_id_no        varchar(4369),
    supervisorpin         varchar(4369),
    working_hour          bigint,
    unit_name             varchar(4369),
    slab_id               bigint,
    slab                  varchar(4369),
    salutation            varchar(4369),
    religion_name         varchar(4369),
    nick_name             varchar(4369),
    employee_dob          timestamp,
    has_photo             integer,
    passportno            varchar(4369),
    recruit_req_no        varchar(4369),
    previous_pin          varchar(4369),
    hrbranchid            varchar(4369),
    hrprogramid           varchar(4369),
    erp_confirmation_date date,
    division_id           varchar(4369),
    district_id           varchar(4369),
    upazila_id            varchar(4369),
    password              varchar(4369),
    remember_token        varchar(4369),
    role_id               integer,
    created_at            timestamp,
    updated_at            timestamp,
    is_deleted            integer,
    deleted_at            timestamp,
    deleted_by            integer,
    delete_reason         varchar(4369)
);

--leave_tools.employeeleavegroupmapping
create table payroll_emp_data.employeeleavegroupmapping    --need to import/ETL data
(
    id             bigint,
    employee_id    bigint,
    effectivedate  date,
    leavegroupid   char(3),
    is_active      integer,
    created_by     integer,
    created_at     timestamp,
    updated_by     integer,
    updated_at     timestamp,
    is_deleted     integer,
    deleted_by     integer,
    deleted_at     timestamp,
    deleted_reason varchar(4369)
);

--leave_tools.employeewiseattendancepolicymapping
create table payroll_emp_data.employeewiseattendancepolicymapping    --need to import/ETL data
(
    id             bigint,
    employee_id    integer,
    policyid       varchar(4369),
    workingdays    integer,
    setdate        date,
    is_active      integer,
    created_by     integer,
    created_at     timestamp,
    updated_by     integer,
    updated_at     timestamp,
    is_deleted     integer,
    deleted_by     integer,
    deleted_at     timestamp,
    deleted_reason varchar(4369)
);




--------------------------payroll_leave_attend_data--------------------------

--higher_studies_application
create table payroll_leave_attend_data.higher_studies_application (like public.higher_studies_application);
insert into payroll_leave_attend_data.higher_studies_application
select *
from public.higher_studies_application;

--travel_application
create table payroll_leave_attend_data.travel_application (like public.travel_application);
insert into payroll_leave_attend_data.travel_application
select *
from public.travel_application;

--higher_study_pay_status
create table payroll_leave_attend_data.higher_study_pay_status    --need to import excel data provided by brac
(
    pin                      varchar(100),
    leave_taken_from_date    timestamp,
    leave_taken_to_date      timestamp,
    date_created             timestamp,
    higher_study_type        varchar(100),
    domain_status_id         integer,
    status_id                integer,
    toa_status_id            integer,
    toa_type_id              integer,
    application_type         varchar(100),
    remarks                  varchar(100),
    leave_without_pay_status boolean
);

INSERT INTO payroll_leave_attend_data.higher_study_pay_status (
    pin,
    leave_taken_from_date,
    leave_taken_to_date,
    date_created,
    higher_study_type,
    domain_status_id,
    status_id,
    toa_status_id,
    toa_type_id,
    application_type,
    remarks,
    leave_without_pay_status
) VALUES
('00175337', '2022-08-08 00:00:00.000000', '2026-06-30 00:00:00.000000', '2022-08-01 12:26:09.512000', 'International', 1, 10, 15, 66, 'higherStudy', 'Leave without pay', FALSE),
('00154237', '2022-09-01 00:00:00.000000', '2024-07-31 00:00:00.000000', '2022-07-18 16:54:55.480000', 'International', 1, 10, 20, 66, 'higherStudy', 'Resign Staff', FALSE),
('00175047', '2023-09-29 00:00:00.000000', '2024-12-16 00:00:00.000000', '2023-09-03 18:03:11.134000', 'International', 1, 4, 15, 66, 'higherStudy', 'Resign Staff', FALSE),
('00155851', '2022-08-01 00:00:00.000000', '2024-09-12 00:00:00.000000', '2022-07-18 14:41:38.701000', 'International', 1, 10, 15, 66, 'higherStudy', 'Leave without pay', FALSE),
('00155851', '2023-06-25 00:00:00.000000', '2024-08-15 00:00:00.000000', '2023-06-06 15:30:35.087000', 'International', 1, 10, 15, 66, 'higherStudy', 'Leave without pay', FALSE),
('00260594', '2023-09-01 00:00:00.000000', '2025-10-15 00:00:00.000000', '2023-08-07 14:16:44.770000', 'International', 1, 4, 15, 66, 'higherStudy', 'Leave without pay', FALSE),
('00252954', '2023-08-17 00:00:00.000000', '2025-01-16 00:00:00.000000', '2023-07-19 09:58:47.590000', 'International', 1, 10, 15, 66, 'higherStudy', 'Leave without pay', FALSE),
('00184321', '2021-11-30 00:00:00.000000', '2024-09-30 00:00:00.000000', '2021-09-21 16:13:02.947000', 'International', 1, 10, 15, 66, 'higherStudy', 'Leave without pay', FALSE),
('00086466', '2023-01-01 00:00:00.000000', '2025-12-30 00:00:00.000000', '2022-11-24 14:53:08.631000', 'International', 1, 10, 15, 66, 'higherStudy', 'Leave without pay', FALSE),
('00080190', '2023-04-30 00:00:00.000000', '2024-05-07 00:00:00.000000', '2023-04-11 10:49:27.562000', 'International', 1, 10, 15, 66, 'higherStudy', 'Leave without pay', FALSE),
('00175199', '2023-09-03 00:00:00.000000', '2024-09-30 00:00:00.000000', '2023-07-27 14:03:42.190000', 'International', 1, 10, 15, 66, 'higherStudy', 'Leave without pay', FALSE),
('00156000', '2022-01-10 00:00:00.000000', '2024-03-20 00:00:00.000000', '2021-12-19 16:29:27.908000', 'International', 1, 10, 15, 66, 'higherStudy', 'Leave without pay', FALSE),
('00155644', '2023-01-01 00:00:00.000000', '2025-02-02 00:00:00.000000', '2022-12-08 15:15:01.678000', 'International', 1, 10, 15, 66, 'higherStudy', 'Leave without pay', FALSE),
('00183093', '2023-03-01 00:00:00.000000', '2025-03-10 00:00:00.000000', '2023-02-05 09:51:05.237000', 'International', 1, 10, 15, 66, 'higherStudy', 'Leave without pay', FALSE),
('00138260', '2023-08-16 00:00:00.000000', '2027-12-31 00:00:00.000000', '2023-07-18 11:33:01.805000', 'International', 1, 10, 15, 66, 'higherStudy', 'Leave without pay', FALSE),
('00189840', '2022-08-31 00:00:00.000000', '2024-01-31 00:00:00.000000', '2022-08-01 12:48:49.916000', 'International', 1, 10, 15, 66, 'higherStudy', 'Resign Staff', FALSE),
('00183119', '2022-08-04 00:00:00.000000', '2024-08-30 00:00:00.000000', '2022-07-31 10:04:44.007000', 'International', 1, 4, 15, 66, 'higherStudy', 'Leave without pay', FALSE),
('00167581', '2023-09-01 00:00:00.000000', '2025-08-15 00:00:00.000000', '2023-08-01 18:19:37.734000', 'International', 1, 10, 15, 66, 'higherStudy', 'Leave without pay', FALSE),
('00197257', '2022-08-28 00:00:00.000000', '2024-12-31 00:00:00.000000', '2022-08-08 10:38:06.007000', 'International', 1, 4, 15, 66, 'higherStudy', 'Leave without pay', FALSE),
('00155705', '2024-07-05 00:00:00.000000', '2024-07-13 00:00:00.000000', '2024-04-15 17:27:29.000000', 'International', 1, 4, 15, 63, 'training', 'With pay official training', TRUE),
('00155982', '2024-07-05 00:00:00.000000', '2024-07-12 00:00:00.000000', '2024-04-15 16:51:11.000000', 'International', 1, 4, 15, 63, 'training', 'With pay official training', TRUE),
('00177005', '2024-04-20 00:00:00.000000', '2026-05-15 00:00:00.000000', '2023-11-26 09:25:27.000000', 'International', 1, 8, 20, 66, 'higherStudy', 'Please cancel this application, staff is resign', FALSE),
('00183102', '2024-12-01 00:00:00.000000', '2024-12-05 00:00:00.000000', '2024-11-20 15:19:56.000000', 'Domestic', 1, 3, 15, 62, 'training', 'Training has been cancelled.', FALSE),
('00189860', '2024-01-16 00:00:00.000000', '2025-01-15 00:00:00.000000', '2023-12-13 13:03:01.000000', 'Domestic', 1, 4, 15, 65, 'higherStudy', 'Higher study leave without pay', FALSE),
('00250489', '2024-08-10 00:00:00.000000', '2028-08-09 00:00:00.000000', '2024-07-15 16:47:13.000000', 'International', 1, 4, 15, 66, 'higherStudy', 'Duplicate', FALSE),
('00254626', '2024-09-17 00:00:00.000000', '2024-09-19 00:00:00.000000', '2024-09-12 12:16:59.000000', 'International', 1, 2, 12, 63, 'training', 'Training has been cancelled, already ERP shown cancelled', FALSE),
('00259915', '2024-09-17 00:00:00.000000', '2024-09-19 00:00:00.000000', '2024-09-12 12:17:00.000000', 'International', 1, 2, 12, 63, 'training', 'Training has been cancelled, already ERP shown cancelled', FALSE),
('00260569', '2024-12-01 00:00:00.000000', '2024-12-05 00:00:00.000000', '2024-11-20 15:55:29.000000', 'Domestic', 1, 3, 15, 62, 'training', 'Training has been cancelled, already ERP shown cancelled', FALSE),
('00260572', '2024-12-01 00:00:00.000000', '2024-12-05 00:00:00.000000', '2024-11-20 17:41:13.000000', 'Domestic', 1, 3, 15, 62, 'training', 'Training has been cancelled, already ERP shown cancelled', FALSE),
('00260702', '2024-08-10 00:00:00.000000', '2026-01-10 00:00:00.000000', '2024-07-27 11:29:48.000000', 'International', 1, 4, 15, 66, 'higherStudy', 'Higher study leave without pay', FALSE),
('00260823', '2024-09-17 00:00:00.000000', '2024-09-19 00:00:00.000000', '2024-09-12 12:16:56.000000', 'International', 1, 2, 12, 63, 'training', 'Training has been cancelled, already ERP shown cancelled', FALSE),
('00264785', '2024-09-03 00:00:00.000000', '2024-10-03 00:00:00.000000', '2024-08-07 16:57:47.000000', 'International', 1, 4, 15, 63, 'training', 'Training with pay leave', TRUE);


--sql_server.get_day_wise_lv_visit_wfa
create table payroll_leave_attend_data.get_day_wise_lv_visit_wfa    --need to import/ETL data
(
    pin              varchar(4369),
    flag             varchar(4369),
    application_type varchar(4369),
    generate_date    timestamp
);

--sql_server.get_attendance_raw_data_with_flag
create table payroll_leave_attend_data.get_attendance_raw_data_with_flag    --need to import/ETL data
(
    staffpin varchar,
    intime   timestamp,
    outtime  timestamp,
    att_date timestamp,
    flag     varchar
);

--leave_tools.system_access_config
create table payroll_leave_attend_data.system_access_config    --need to import/ETL data
(
    id                   integer,
    access_code          integer,
    access_name          varchar(4369),
    is_entire_org        smallint,
    allowed_program_code varchar(4369),
    allowed_project_code varchar(4369),
    allowed_branch_code  varchar(4369),
    allowed_jobbase      varchar(4369),
    allowed_employee_id  varchar(4369),
    denied_employee_id   varchar(4369),
    status               smallint,
    created_at           timestamp,
    created_by           integer,
    updated_at           timestamp,
    updated_by           integer,
    is_deleted           smallint,
    deleted_by           integer,
    delete_reason        varchar(4369)
);

--leave_tools.leave_master
create table payroll_leave_attend_data.leave_master    --need to import/ETL data
(
    id                                integer,
    leave_sl_no                       varchar(4369),
    leave_year                        smallint,
    application_date                  date,
    employee_id                       bigint,
    leave_type_id                     integer,
    from_date                         date,
    to_date                           date,
    worked_day_for_compensatory_leave date,
    leave_duration                    double precision,
    slot                              varchar(4369),
    relation_with_staff               varchar(4369),
    incident_date                     date,
    leave_purpose                     varchar(4369),
    withpay_days                      integer,
    withoutpay_days                   integer,
    after_leave_joining_date          date,
    with_pay_yn                       integer,
    is_seniority_loss                 integer,
    seniority_loss_month              integer,
    seniority_loss_days               integer,
    status                            integer,
    counter                           smallint,
    is_recommendation_needed          bigint,
    otp                               varchar(4369),
    feedback_msg                      varchar(4369),
    approver_id                       bigint,
    approval_action_time              timestamp,
    approval_remarks                  varchar(4369),
    is_delegated                      integer,
    delegator_id                      integer,
    delegator_remarks                 varchar(4369),
    is_deducted                       integer,
    is_admin_apply                    smallint,
    recon_status                      smallint,
    recon_apply_date                  date,
    recon_slot                        varchar(4369),
    recon_from_date                   date,
    recon_to_date                     date,
    recon_duration                    double precision,
    recon_apply_reason                varchar(4369),
    recon_approved_date               date,
    recon_approval_remarks            varchar(4369),
    recon_approver_id                 integer,
    created_at                        timestamp,
    created_by                        integer,
    updated_at                        timestamp,
    updated_by                        integer,
    is_deleted                        integer,
    deleted_by                        integer,
    deleted_at                        timestamp,
    delete_reason                     varchar(4369),
    req_from                          varchar(4369),
    is_manual                         smallint,
    operation_status                  smallint
);

--leave_tools.leave_others
create table payroll_leave_attend_data.leave_others    --need to import/ETL data
(
    id                       bigint,
    employee_id              bigint,
    leave_sl_no              varchar(4369),
    leave_year               smallint,
    leave_type_id            integer,
    application_date         date,
    from_date                date,
    to_date                  date,
    leave_duration           double precision,
    slot                     varchar(4369),
    withpay_days             bigint,
    withoutpay_days          bigint,
    after_leave_joining_date date,
    leave_purpose            varchar(4369),
    with_pay_yn              bigint,
    is_seniority_loss        bigint,
    seniority_loss_month     bigint,
    seniority_loss_days      bigint,
    status                   integer,
    feedback_msg             varchar(4369),
    approver_id              bigint,
    approval_action_time     timestamp,
    approval_remarks         varchar(4369),
    is_delegated             integer,
    delegator_id             bigint,
    delegator_remarks        varchar(4369),
    is_deducted              integer,
    recon_status             smallint,
    recon_apply_date         date,
    recon_slot               varchar(4369),
    recon_from_date          date,
    recon_to_date            date,
    recon_duration           double precision,
    recon_apply_reason       varchar(4369),
    recon_approved_date      date,
    recon_approver_id        integer,
    recon_approval_remarks   varchar(4369),
    created_at               timestamp,
    created_by               integer,
    updated_at               timestamp,
    updated_by               integer,
    is_deleted               integer,
    deleted_by               integer,
    deleted_at               timestamp,
    delete_reason            varchar(4369),
    req_from                 varchar(4369),
    is_manual                smallint
);

--leave_tools.leavetypesetup
create table payroll_leave_attend_data.leavetypesetup    --need to import/ETL data
(
    id                   integer,
    leavetypeid          varchar(4369),
    leavename            varchar(4369),
    flag                 varchar(4369),
    halfflag             varchar(4369),
    is_leave             bigint,
    is_apply             bigint,
    is_compensatory      bigint,
    flag_color           varchar(4369),
    allowed_program_code varchar(4369),
    allowed_project_code varchar(4369),
    allowed_branch_code  varchar(4369),
    allowed_employee_id  varchar(4369),
    forbidden_jobbase    varchar(4369),
    is_active            bigint,
    is_deleted           integer,
    created_by           integer,
    created_at           timestamp,
    updated_by           integer,
    updated_at           timestamp,
    deleted_by           integer,
    deleted_at           timestamp,
    deleted_reason       varchar(4369)
);

--leave_tools.employee_leave_balance
create table payroll_leave_attend_data.employee_leave_balance    --need to import/ETL data
(
    id                                     bigint,
    leaveyear_policy_id                    bigint,
    employee_id                            bigint,
    leave_type_id                          integer,
    joining_balance                        decimal,
    last_year_closing_leave_balance        decimal,
    current_year_allocated_leave           decimal,
    current_year_opening_leave_balance     decimal,
    current_year_leave_balance             decimal,
    is_active                              integer,
    asofdate                               date,
    remarks                                varchar(4369),
    earnleave_lock                         smallint,
    created_by                             integer,
    created_at                             timestamp,
    updated_by                             integer,
    updated_at                             timestamp,
    is_deleted                             integer,
    deleted_by                             integer,
    deleted_at                             timestamp,
    deleted_reason                         varchar(4369),
    operation_status                       smallint,
    last_year_closing_leave_actual_balance decimal
);

--leave_tools.visit_master
create table payroll_leave_attend_data.visit_master    --need to import/ETL data
(
    id                     integer,
    visit_sl_no            varchar(4369),
    leave_year             smallint,
    employee_id            bigint,
    application_date       date,
    leavetype_id           integer,
    from_date_time         timestamp,
    to_date_time           timestamp,
    purpose                varchar(4369),
    duration               decimal,
    station_leave_yn       smallint,
    movement_place         varchar(4369),
    status                 integer,
    counter                smallint,
    otp                    varchar(4369),
    feedback_msg           varchar(4369),
    approver_id            bigint,
    approval_action_time   timestamp,
    approval_remarks       varchar(4369),
    is_delegated           integer,
    delegator_id           integer,
    delegator_remarks      varchar(4369),
    is_deleted             integer,
    is_deducted            integer,
    recon_status           smallint,
    recon_apply_date       date,
    recon_from_date_time   timestamp,
    recon_to_date_time     timestamp,
    recon_duration         decimal,
    recon_apply_reason     varchar(4369),
    recon_approved_date    date,
    recon_approver_id      integer,
    recon_approval_remarks varchar(4369),
    created_at             timestamp,
    created_by             integer,
    updated_at             timestamp,
    updated_by             integer,
    deleted_by             integer,
    deleted_at             timestamp,
    delete_reason          varchar(4369),
    req_from               varchar(4369),
    is_manual              smallint
);

--is_international_travel column add to visit_master with logic
ALTER TABLE payroll_leave_attend_data.visit_master
ADD is_international_travel Boolean default false;

WITH INT_TRA_CTE AS (
SELECT VM.id
FROM payroll_leave_attend_data.visit_master VM
INNER JOIN payroll_emp_data.users U ON VM.employee_id = U.id
INNER JOIN payroll_emp_data.employee_core_info ECI ON U.pin = ECI.pin_no
INNER JOIN payroll_leave_attend_data.travel_application TA ON ECI.id = TA.employee_core_info_id
AND
((DATE(TA.official_visit_from_date) BETWEEN DATE(VM.from_date_time) AND DATE(VM.to_date_time))
OR
(DATE(TA.official_visit_to_date) BETWEEN DATE(VM.from_date_time) AND DATE(VM.to_date_time)))
WHERE VM.leavetype_id = 24 and ta.domain_status_id=1 and ta.status_id not in (2,3,5,8)
AND EXTRACT('YEAR' FROM VM.to_date_time) >= 2024
AND VM.duration > 0 AND VM.status = 1 AND VM.is_deleted <> 1 AND VM.is_manual = 0
)
UPDATE payroll_leave_attend_data.visit_master V
SET is_international_travel = true
FROM INT_TRA_CTE ITC
WHERE V.id = ITC.id;

select distinct is_international_travel from payroll_leave_attend_data.visit_master;
select count(is_international_travel) from payroll_leave_attend_data.visit_master
                                      where is_international_travel is true; --256
select distinct is_international_travel from payroll_leave_attend_data.visit_master;

--leave_tools.attendance_reconciliation
create table payroll_leave_attend_data.attendance_reconciliation    --need to import/ETL data
(
    id                   integer,
    employee_id          bigint,
    application_serial   bigint,
    attendance_slot      varchar(4369),
    attendance_date      date,
    daily_in_time        timestamp,
    daily_out_time       timestamp,
    remarks              varchar(4369),
    status               integer,
    counter              smallint,
    otp                  varchar(4369),
    feedback_msg         varchar(4369),
    approver_id          bigint,
    approval_action_time timestamp,
    approval_remarks     varchar(4369),
    is_delegated         integer,
    delegator_id         integer,
    delegator_remarks    varchar(4369),
    created_at           timestamp,
    created_by           integer,
    updated_at           timestamp,
    updated_by           integer,
    is_deleted           integer,
    deleted_by           integer,
    deleted_at           timestamp,
    delete_reason        varchar(4369),
    req_from             varchar(4369)
);

--2137.employee_records_wave0
CREATE TABLE payroll_leave_attend_data.employee_records_wave0 (
    pin VARCHAR(8),
    staffname VARCHAR(100),
    job_base VARCHAR(50),
    designation VARCHAR(100),
    grade INTEGER,
    program_name VARCHAR(100),
    project_name VARCHAR(100),
    hr_project_id VARCHAR(10),
    branch_name VARCHAR(100),
    hr_branch_id VARCHAR(10),
    upazila_name VARCHAR(50),
    district_name VARCHAR(50),
    wing VARCHAR(50),
    work_shift VARCHAR(100),
    is_shift_rotate BOOLEAN,
    is_ot_eligible BOOLEAN,
    employee_group VARCHAR(100),
    is_weekend_different BOOLEAN,
    attendance_tracking_type VARCHAR(50),
    bao_pin VARCHAR(10),
    name_of_bao VARCHAR(100),
    hr_pin VARCHAR(10),
    hr_name VARCHAR(100),
    base VARCHAR(10)
);


UPDATE payroll_leave_attend_data.employee_records_wave0
SET grade = 2
WHERE pin = '00271994' AND hr_project_id = 'H03';

DELETE FROM payroll_leave_attend_data.employee_records_wave0
WHERE pin = '00271994' AND hr_project_id = '113';


--116.employee_records_beta_30
CREATE TABLE payroll_leave_attend_data.employee_records_beta_30 (
    pin VARCHAR(8),
    staffname VARCHAR(100),
    job_base VARCHAR(50),
    designation VARCHAR(100),
    grade INTEGER,
    program_name VARCHAR(100),
    project_name VARCHAR(100),
    hr_project_id VARCHAR(10),
    branch_name VARCHAR(100),
    erp_office_code  VARCHAR(100),
    hr_branch_id VARCHAR(10),
    upazila_name VARCHAR(50),
    district_name VARCHAR(50),
    wing VARCHAR(50),
    work_shift VARCHAR(100),
    is_shift_rotate BOOLEAN,
    is_ot_eligible BOOLEAN,
    employee_group VARCHAR(100),
    is_weekend_different BOOLEAN,
    attendance_tracking_type VARCHAR(50),
    bao_pin VARCHAR(10),
    name_of_bao VARCHAR(100),
    hr_pin VARCHAR(10),
    hr_name VARCHAR(100),
    base VARCHAR(10)
);





--ALL_INDEXING


CREATE INDEX idx_employee_records_wave0_pin
ON payroll_leave_attend_data.employee_records_wave0 (pin);

CREATE INDEX idx_get_day_wise_lv_visit_wfa_pin
ON payroll_leave_attend_data.get_day_wise_lv_visit_wfa (pin);

CREATE INDEX idx_get_day_wise_lv_visit_wfa_generate_date
ON payroll_leave_attend_data.get_day_wise_lv_visit_wfa (generate_date);

CREATE INDEX idx_get_day_wise_lv_visit_wfa_application_type
ON payroll_leave_attend_data.get_day_wise_lv_visit_wfa (application_type);

CREATE INDEX idx_get_day_wise_lv_visit_wfa_flag
ON payroll_leave_attend_data.get_day_wise_lv_visit_wfa (flag);

CREATE INDEX idx_users_pin
ON payroll_emp_data.users (pin);

CREATE INDEX idx_users_id
ON payroll_emp_data.users (id);

CREATE INDEX idx_leave_master_employee_id
ON payroll_leave_attend_data.leave_master (employee_id);

CREATE INDEX idx_leave_others_employee_id
ON payroll_leave_attend_data.leave_others(employee_id);

CREATE INDEX idx_visit_master_employee_id
ON payroll_leave_attend_data.visit_master(employee_id);




