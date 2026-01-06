INSERT INTO public.integ_employee_imp
(   id,
    version,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    employee_code,
    first_name,
    middle_name,
    last_name ,
    father_name,
    mother_name,
    national_id,
    join_date_actual,
    confirmation_date,
    contract_end_date,
    employment_status,
    email_company,
    current_address ,
    permanent_address,
    birth_date ,
    gross_salary,
    bonus_entitlement_status,
    bank_branch_name,
    bank_name,
    routing_no,
    empl_bank_account_no,
    empl_bikash_no,
    gender,
    tin_no,
    salary_circle,
    empl_create_date,
    supervisor_empl_code,
    holiday_calendar_code,
    religion,
    grade_code,
    grade_sub_code,
    group_code,
    section_code,
    empl_category_code,
    work_shift_code,
    work_shift_rotated,
    work_shift_rotate_rule_code,
    nationality_country,
    operating_location_code,
    designation_code,
    pay_struc_code,
    creation_log,
    phone_home,
    phone_work_direct,
    phone_mobile,
    leave_profile_code,
    employee_job_status,
    last_working_day
)
WITH RECURSIVE Employee_CTE AS(
SELECT eci.id AS Employee_ID, ECI.supervisor_id
FROM payroll_emp_data.employee_information_update e
INNER JOIN payroll_emp_data.employee_core_info eci ON e.employee_core_info_id=eci.id
WHERE e.employee_information_update_change_type_id IN (11, 25) AND date(e.effective_date) > '2024-12-31' and e.new_value != '3' AND E.domain_status_id = 1
UNION
SELECT e.employee_core_info_id::BIGINT AS Employee_ID, ECI.supervisor_id
FROM payroll_emp_data.emp_core_info_history e
INNER JOIN payroll_emp_data.employee_core_info eci ON e.employee_core_info_id::BIGINT=eci.id
WHERE e.value_type = 'Employee Status Change' AND date(e.create_date) > '2024-12-31'
UNION
SELECT eci.id AS Employee_ID, ECI.supervisor_id
FROM payroll_emp_data.job_separation_proposal jsp
INNER JOIN payroll_emp_data.employee_core_info eci ON jsp.employee_core_info_id=eci.id AND jsp.domain_status_id=1 AND eci.cur_job_status_id != 3 AND date(jsp.date_created) > '2024-12-31'
UNION
SELECT eci.id AS Employee_ID, ECI.supervisor_id
FROM payroll_emp_data.employee_core_info eci
WHERE eci.cur_job_status_id = 3 AND eci.domain_status_id=1
),SupervisorHierarchy AS (
    SELECT
        ECI.id AS Employee_id,
        ECI.supervisor_id,
        1 AS level
    FROM Employee_CTE I
    JOIN payroll_emp_data.employee_core_info ECI ON I.supervisor_id = ECI.id
    WHERE I.supervisor_id NOT IN (SELECT employee_id FROM Employee_CTE)
    UNION ALL
    SELECT
        ECI.id AS Employee_id,
        ECI.supervisor_id,
        sh.level + 1 AS level
    FROM SupervisorHierarchy sh
    JOIN payroll_emp_data.employee_core_info ECI ON sh.supervisor_id = ECI.id
    WHERE sh.supervisor_id IS NOT NULL
    AND sh.level < 4
),BASE_CTE AS(
SELECT DISTINCT Employee_id
FROM SupervisorHierarchy
WHERE Employee_id NOT IN (SELECT Employee_id FROM Employee_CTE)
UNION
SELECT Employee_ID
FROM Employee_CTE
UNION
SELECT id AS Employee_ID
FROM payroll_emp_data.employee_core_info WHERE pin_no = '01145674'
),NAME_CTE AS (
SELECT ECI.id,
    first_name AS FUllName,
    (string_to_array(first_name, ' '))[1] AS first_name,
      CASE
          WHEN array_length(string_to_array(first_name, ' '), 1) = 3
              THEN (string_to_array(first_name, ' '))[2]
          WHEN array_length(string_to_array(first_name, ' '), 1) > 3 THEN
              array_to_string(
                      (string_to_array(first_name, ' '))[2:array_length(string_to_array(first_name, ' '), 1) - 1],
                      ' '
              ) ELSE NULL
          END AS middle_name,
      CASE
          WHEN array_length(string_to_array(first_name, ' '), 1) = 1 THEN NULL
          ELSE (string_to_array(first_name, ' '))[array_length(string_to_array(first_name, ' '), 1)]
          END AS last_name
FROM payroll_emp_data.employee_core_info ECI
INNER JOIN BASE_CTE B ON ECI.ID = B.Employee_ID
),ADDRESS_CTE AS(
SELECT employee_info_id,contact_address_line1,address_type_id
    ,ROW_NUMBER() OVER(PARTITION BY employee_info_id,address_type_id ORDER BY EA.ID DESC) AS Row_Num
FROM payroll_emp_data.employee_address EA
INNER JOIN BASE_CTE B ON EA.employee_info_id = B.Employee_ID
WHERE EA.domain_status_id = 1
),ADDRESS_CTE2 AS(
SELECT employee_info_id
, MAX(CASE WHEN address_type_id = 2 THEN contact_address_line1 ELSE NULL END) AS CURRENT_ADDRESS
, MAX(CASE WHEN address_type_id = 1 THEN contact_address_line1 ELSE NULL END) AS PERMANENT_ADDRESS
FROM ADDRESS_CTE
WHERE Row_Num = 1
GROUP BY employee_info_id
),BASIC_INFO_CTE AS(
SELECT employee_info_id, father_name, mother_name
    , ROW_NUMBER() OVER(PARTITION BY employee_info_id ORDER BY ID DESC) ROW_NUM
FROM payroll_emp_data.employee_basic_info
WHERE domain_status_id = 1
),LAST_W_CTE AS (
SELECT eci.pin_no AS Pin, E.effective_date AS last_working_date
FROM payroll_emp_data.employee_information_update e
INNER JOIN payroll_emp_data.employee_core_info eci ON e.employee_core_info_id = eci.id
INNER JOIN BASE_CTE B ON ECI.id = B.Employee_ID
WHERE e.employee_information_update_change_type_id IN (11, 25)
AND date(e.effective_date) > '2024-12-31'
and e.new_value != '3'
AND E.domain_status_id = 1
UNION
SELECT e.pin_no AS Pin, E.create_date AS last_working_date
FROM payroll_emp_data.emp_core_info_history e
INNER JOIN payroll_emp_data.employee_core_info eci ON e.employee_core_info_id::bigint = eci.id
INNER JOIN BASE_CTE B ON ECI.id = B.Employee_ID
WHERE e.value_type = 'Employee Status Change'
AND date(e.create_date) > '2024-12-31'
UNION
SELECT eci.pin_no AS Pin, JSP.last_working_date
FROM payroll_emp_data.job_separation_proposal jsp
INNER JOIN payroll_emp_data.employee_core_info eci
ON jsp.employee_core_info_id = eci.id AND jsp.domain_status_id = 1 AND
eci.cur_job_status_id != 3 AND date(jsp.date_created) > '2024-12-31'
INNER JOIN BASE_CTE B ON ECI.id = B.Employee_ID
),DUP_CTE AS(
SELECT Pin,last_working_date
,ROW_NUMBER() OVER(PARTITION BY Pin ORDER BY last_working_date DESC) row_num
FROM LAST_W_CTE
) SELECT gen_random_uuid()::uuid AS id
    , 0::integer AS version
    , '1'::varchar AS created_by
    , NOW()::timestamp with time zone AS created_date
    , '1'::varchar AS last_modified_by
    , NOW()::timestamp with time zone AS last_modified_date
    , ECI.pin_no::VARCHAR AS employee_code
    , NC.first_name::VARCHAR  AS first_name
    , NC.middle_name::VARCHAR  AS middle_name
    , NC.last_name::VARCHAR  AS last_name
    , BIC.father_name::VARCHAR  AS father_name
    , BIC.mother_name::VARCHAR  AS mother_name
    , ECI.national_id_no::VARCHAR  AS national_id
    , ECI.joining_date::DATE AS join_date_actual
    , ECD.confirmation_date::DATE AS confirmation_date
    , ECI.expiry_date::DATE AS contract_end_date
    , NULL AS employment_status
    , CASE WHEN ECI.email_address ILIKE '%brac.net%' THEN ECI.email_address::VARCHAR ELSE NULL END AS email_company
    , AC.CURRENT_ADDRESS::TEXT AS current_address
    , AC.PERMANENT_ADDRESS::TEXT AS permanent_address
    , ECI.employee_dob::DATE AS birth_date
    , 0::DOUBLE PRECISION AS gross_salary
    , 10::integer AS bonus_entitlement_status               --need to talk about bonus entitlement
    , NULL::VARCHAR AS bank_branch_name
    , NULL::VARCHAR AS bank_name
    , NULL::VARCHAR AS routing_no
    , NULL::VARCHAR AS empl_bank_account_no
    , NULL::VARCHAR AS empl_bikash_no
    , G.gender_type::VARCHAR AS gender
    , ECI.tin_number::VARCHAR AS tin_no                     --only 248 eci.tin in live db
    , NULL::VARCHAR AS salary_circle
    , NULL::timestamp AS empl_create_date
    , ECI2.pin_no::VARCHAR AS supervisor_empl_code
    , EAP.policyid::VARCHAR AS holiday_calendar_code
    , ECI.religion_id::VARCHAR AS religion
    , ECI.employee_level_id::VARCHAR AS grade_code
    , COALESCE(ECI.slab_id::VARCHAR,'0') AS grade_sub_code
    , NULL::VARCHAR AS group_code
    , PI.project_code::VARCHAR AS section_code
    , EC2.short_name::VARCHAR AS empl_category_code
    , EAP.policyid::VARCHAR AS work_shift_code
    , NULL::BOOLEAN AS work_shift_rotated
    , NULL::VARCHAR AS work_shift_rotate_rule_code
    , 'Bangladesh'::VARCHAR AS nationality_country
    , POI.office_code::VARCHAR AS operating_location_code
    , ED.code::VARCHAR AS designation_code
    , NULL::VARCHAR AS pay_struc_code
    , NULL::TEXT AS creation_log
    , EC.mobile_no2::VARCHAR AS phone_home
    , EC.mobile_no1::VARCHAR AS phone_work_direct
    , EC.mobile_no2::VARCHAR AS phone_mobile
    , EL.leavegroupid::VARCHAR AS leave_profile_code
    , ECI.cur_job_status_id::VARCHAR AS employee_job_status    --need to send enum table in excel
    , CASE WHEN DC.row_num = 1 THEN DC.last_working_date END AS last_working_date
FROM payroll_emp_data.employee_core_info ECI
INNER JOIN BASE_CTE B ON ECI.id = B.Employee_ID
INNER JOIN NAME_CTE NC ON ECI.id = NC.id
LEFT JOIN payroll_emp_data.employee_core_info ECI2 ON ECI.supervisor_id = ECI2.id
LEFT JOIN payroll_master_data.employee_designation ED ON ECI.e_designation_id = ED.id
LEFT JOIN payroll_emp_data.nationality N ON ECI.country_level_id = N.id
LEFT JOIN payroll_master_data.physical_office_info POI ON ECI.office_info_id = POI.id
LEFT JOIN payroll_master_data.project_info PI ON ECI.core_project_id = PI.id
LEFT JOIN BASIC_INFO_CTE BIC ON ECI.id = BIC.employee_info_id AND ROW_NUM = 1
LEFT JOIN payroll_emp_data.employee_contact_info EC ON ECI.id = EC.employee_info_id AND EC.domain_status_id = 1
LEFT JOIN ADDRESS_CTE2 AC ON ECI.id = AC.employee_info_id
LEFT JOIN payroll_emp_data.users U ON ECI.pin_no = U.pin
LEFT JOIN payroll_emp_data.employeeleavegroupmapping EL ON U.id = EL.employee_id
LEFT JOIN payroll_emp_data.employeewiseattendancepolicymapping EAP ON U.id = EAP.employee_id
LEFT JOIN payroll_emp_data.emp_confirmation_date ECD ON ECI.pin_no = ECD.staffpin
LEFT JOIN payroll_emp_data.gender G ON ECI.gender_id = G.id
LEFT JOIN payroll_emp_data.employee_category EC2 ON ECI.emp_category_id = EC2.id
LEFT JOIN DUP_CTE DC ON ECI.pin_no = DC.Pin AND DC.row_num=1;


---------------------------------------------------------------------------------------------
--Updating First Name
UPDATE public.integ_employee_imp
SET first_name = (string_to_array(middle_name, ' '))[1]
WHERE first_name IS NULL OR first_name = ''
AND employee_code IN(SELECT employee_code FROM integ_employee_imp WHERE first_name IS NULL OR first_name = '');

--Updating middle name
UPDATE public.integ_employee_imp
SET middle_name = CASE
    WHEN position(' ' IN middle_name) > 0 THEN substring(middle_name FROM position(' ' IN middle_name) + 1)
    ELSE ''  -- Set to an empty string if there's no space
END
WHERE employee_code IN('00158619',
        '00010692',
        '00126255',
        '00041642',
        '00028508',
        '00098701',
        '00080409',
        '00151951',
        '00152641',
        '00157529',
        '00022295',
        '00034932');


--religion updated
UPDATE integ_employee_imp I
SET religion = R.religion_id_updated
FROM payroll_emp_data.updated_religion R
-- WHERE I.employee_code = LPAD(R.employee_pin,8,'0')
WHERE I.employee_code = R.employee_pin;





select * from public.integ_employee_imp; --96,635




select count(1) from payroll_emp_data.updated_religion u
inner join public.integ_employee_imp i on I.employee_code = u.employee_pin
--where u.emp_job_status_id=3;

select count(1) from payroll_emp_data.updated_religion u where emp_job_status_id=3;

