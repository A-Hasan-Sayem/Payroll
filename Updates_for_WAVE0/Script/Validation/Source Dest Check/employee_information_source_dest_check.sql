---------------------------------------------EMPLOYEE INFORMATION START-----------------------------------------------------

DROP TABLE IF EXISTS source_data;

Create temporary table source_data
(employee_pin varchar,
employee_name varchar,
empl_type integer,
empl_category_code varchar,
employment_name varchar,
join_date date,
confirmation_date date,
contract_end_date date,
job_grade varchar,
oper_loc_code varchar,
oper_location varchar,
thana varchar,
district varchar,
designation varchar,
program varchar,
program_code varchar,
project varchar,
project_code varchar,
supervisor_name varchar,
supervisor_pin varchar,
supervisor_job_grade varchar);



INSERT INTO source_data (employee_pin, employee_name, empl_type, empl_category_code,
  employment_name, join_date, confirmation_date, contract_end_date,  job_grade, oper_loc_code, oper_location, thana, district, designation, program, program_code, project, project_code, supervisor_name, supervisor_pin, supervisor_job_grade
)
SELECT
        gu.pin as employee_pin,
        CONCAT(
            COALESCE(imp.first_name, ''), ' ',
            COALESCE(imp.middle_name, ''), ' ',
            COALESCE(imp.last_name, '')
        ) AS employee_name,
        ec.empl_type,
        ec.empl_category_code,
        ec.name as employment_name,
        imp.join_date_actual as join_date,
        imp.confirmation_date,
        imp.contract_end_date,
        g.grade_name as job_grade,
        ol.oper_loc_code,
        ol.name as oper_location,
        mu.name as thana,
        md.name as district,
        d.name as designation,
        dept.name as program,
        dept.dept_code as program_code,
        sec.name as project,
        sec.sec_code as project_code,
        CONCAT(
            COALESCE(m.first_name, ''), ' ',
            COALESCE(m.middle_name, ''), ' ',
            COALESCE(m.last_name, '')
        ) AS supervisor_name,
        m.employee_code as supervisor_pin,
        g1.grade_name as supervisor_job_grade
    FROM payroll_leave_attend_data.employee_records_beta_30 gu
    LEFT JOIN cdc.integ_employee_imp imp on gu.pin = imp.employee_code
    LEFT JOIN public.hmd_empl_category ec ON imp.empl_category_code = ec.empl_category_code
    LEFT JOIN public.mdg_empl_profile e on imp.employee_code = e.employee_code
    LEFT JOIN cdc.integ_employee_imp m on TRIM(imp.supervisor_empl_code) = TRIM(m.employee_code)
    LEFT JOIN public.mdg_dept_section sec ON imp.section_code = sec.sec_code
    LEFT JOIN mdg_operating_location ol ON imp.operating_location_code = ol.oper_loc_code
    LEFT join public.mdg_upazila mu on ol.upazila_id = mu.id
    left join public.mdg_district md on mu.district_id = md.id
    LEFT JOIN public.hmd_designation d on imp.designation_code = d.code
    LEFT JOIN public.mdg_department dept ON sec.department_id = dept.id
    LEFT JOIN public.mdg_department_comp dc ON dc.department_id = dept.id
    LEFT JOIN public.mdg_job_grade g ON imp.grade_code = TRIM(g.grade_code)
    LEFT JOIN public.mdg_job_grade g1 ON m.grade_code = TRIM(g1.grade_code)
ORDER BY gu.pin;




drop table if exists dest_data;

Create temporary table dest_data
(employee_pin varchar,
employee_name varchar,
empl_type integer,
empl_category_code varchar,
employment_name varchar,
join_date date ,
confirmation_date date,
contract_end_date date,
job_grade varchar,
oper_loc_code varchar,
oper_location varchar,
thana varchar,
district varchar,
designation varchar,
program varchar,
program_code varchar,
project varchar,
project_code varchar,
supervisor_name varchar,
supervisor_pin varchar,
supervisor_job_grade varchar);

INSERT INTO dest_data (employee_pin, employee_name, empl_type, empl_category_code,
  employment_name, join_date, confirmation_date, contract_end_date,  job_grade, oper_loc_code, oper_location, thana, district, designation, program, program_code, project, project_code, supervisor_name, supervisor_pin, supervisor_job_grade
)

select
    gu.pin as employee_pin,
    e.name as employee_name,
    e.empl_type,
    ec.empl_category_code,
    ec.name as employment_name,
    e.join_date_actual as join_date,
    e.confirmation_date,
    e.contract_end_date,
    jj.grade_name as job_grade,
    m.oper_loc_code,
    m.name as oper_location,
    mu.name as thana,
    md.name as district,
    d.name as designation,
    dept.name as program,
    dept.dept_code as program_code,
    s.name as project,
    s.sec_code as project_code,
    e1.name as supervisor_name,
    e1.employee_code as supervisor_pin,
    jj2.grade_name as supervisor_job_grade
    FROM payroll_leave_attend_data.employee_records_beta_30 gu
    LEFT JOIN mdg_empl_profile e on gu.pin = e.employee_code
    LEFT JOIN hmd_empl_category ec on e.empl_category_id = ec.id
    LEFT JOIN mdg_operating_location m on e.operating_location_id = m.id
    LEFT JOIN mdg_empl_job_grade j on e.empl_grade_id = j.id
    LEFT JOIN mdg_job_grade jj on j.job_grade_id = jj.id
    LEFT join public.mdg_upazila mu on m.upazila_id = mu.id
    left join public.mdg_district md on mu.district_id = md.id
    left join mdg_empl_profile e1 on e.manager_id = e1.id
    left join hmd_designation d on e.designation_id = d.id
    left join mdg_dept_section s on e.section_id = s.id
--     left join mdg_department dept on e.department_id = dept.id
    left join mdg_department dept on s.department_id = dept.id
    left JOIN mdg_empl_job_grade j1 on e1.empl_grade_id = j1.id
    left join mdg_job_grade jj2 on j1.job_grade_id = jj2.id
    ORDER BY gu.pin;

SELECT employee_pin, employee_name, job_grade,oper_loc_code, oper_location, thana, district, designation,
    program, program_code, project, project_code, supervisor_name, supervisor_pin, supervisor_job_grade
FROM source_data
EXCEPT
select employee_pin, employee_name, job_grade,oper_loc_code,
       oper_location, thana, district, designation,
    program, program_code, project,
    project_code, supervisor_name, supervisor_pin, supervisor_job_grade
from dest_data
ORDER BY employee_pin;

---------------------------------------------EMPLOYEE INFORMATION END-------------------------------------------------------


---------------------------------------- MISC queries for debugging ------------------------------------------------

select employee_pin, employee_name, job_grade,oper_loc_code,
       oper_location, thana, district, designation,
    program, program_code, project,
    project_code, supervisor_name, supervisor_pin, supervisor_job_grade
from dest_data where employee_pin = '01532225';

-- dest
select e.name, e.employee_code, e.manager_id, m.id as man_emp_id, m.name, m.employee_code
from mdg_empl_profile e
left join mdg_empl_profile m on e.manager_id = m.id
where e.employee_code = '00138561';

-- source
select  CONCAT(
            COALESCE(e.first_name, ''), ' ',
            COALESCE(e.middle_name, ''), ' ',
            COALESCE(e.last_name, '')
        ) AS employee_name, e.employee_code, e.supervisor_empl_code,
        CONCAT(
            COALESCE(m.first_name, ''), ' ',
            COALESCE(m.middle_name, ''), ' ',
            COALESCE(m.last_name, '')
        ) AS employee_name, m.employee_code
from cdc.integ_employee_imp e
inner join cdc.integ_employee_imp m on e.supervisor_empl_code = m.employee_code
where e.employee_code = '00260565';


select supervisor_empl_code from cdc.integ_employee_imp where employee_code = '00138561';


select id, domain_status_id, first_name, pin_no, cur_job_status_id
from payroll_emp_data.employee_core_info where pin_no = '01625681';


-- source

select CONCAT(
            COALESCE(e.first_name, ''), ' ',
            COALESCE(e.middle_name, ''), ' ',
            COALESCE(e.last_name, '')
        ) AS employee_name, e.employee_code, e.section_code
                            --dept.name as program_name, dept.dept_code as program_code
from cdc.integ_employee_imp e
-- inner join mdg_dept_section s on e.section_code = s.sec_code
-- inner join mdg_department dept on s.department_id = dept.id
where e.employee_code = '01625681';

--dest
Select e.employee_code, e.name,
       s.sec_code,
       e.department_id as from_emp_dept_id,
       s.department_id as from_section_dept_id,
       dept.name,
       dept.dept_code from mdg_empl_profile e
inner join mdg_dept_section s
on e.section_id = s.id
left join mdg_department dept on e.department_id = dept.id
where e.employee_code = '00145659';


Select e.employee_code, e.name
--        s.sec_code,
--        e.department_id as from_emp_dept_id,
--        s.department_id as from_section_dept_id,
--        dept.name,
--        dept.dept_code
from mdg_empl_profile e
-- inner join mdg_dept_section s
-- on e.section_id = s.id
-- left join mdg_department dept on e.department_id = dept.id
where e.employee_code = '00260565';
