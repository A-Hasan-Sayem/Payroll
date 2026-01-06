WITH BASE_CTE AS (
    SELECT u.pin
    FROM payroll_leave_attend_data.system_access_config pro
    INNER JOIN payroll_emp_data.users u ON u.program_code = pro.allowed_program_code

    UNION

    SELECT u.pin
    FROM payroll_leave_attend_data.system_access_config pro
    INNER JOIN payroll_emp_data.users u ON u.project_code = pro.allowed_project_code

    UNION

    SELECT u.pin
    FROM payroll_leave_attend_data.system_access_config pro
    INNER JOIN payroll_emp_data.users u ON u.hrbranchid = pro.allowed_branch_code

    UNION

    SELECT u.pin
    FROM payroll_leave_attend_data.system_access_config pro
    INNER JOIN payroll_emp_data.users u ON u.jobbase = pro.allowed_jobbase

    UNION

    SELECT u.pin
    FROM payroll_leave_attend_data.system_access_config pro
    INNER JOIN payroll_emp_data.users u ON u.id = pro.allowed_employee_id::INTEGER
),wfa_ranked AS (
    SELECT id,doc_date,employee_code,
    ROW_NUMBER() OVER (PARTITION BY employee_code, doc_date ORDER BY id) AS rn
    FROM integ_work_away_office_imp
),Visit_ranked_initial AS(
SELECT u.pin AS Employee_Pin, V.from_date_time,V.to_date_time,V.application_date,V.movement_place,V.employee_id,
    ROW_NUMBER() OVER(PARTITION BY V.employee_id,DATE(V.from_date_time),DATE(V.to_date_time) ORDER BY V.id DESC)row_num
    FROM payroll_leave_attend_data.Visit_Master V
    INNER JOIN payroll_emp_data.users U ON V.employee_id = U.id
    INNER JOIN BASE_CTE B ON U.pin = B.pin
    WHERE V.leavetype_id = 25
  AND EXTRACT('YEAR' FROM V.to_date_time) >= 2024
  AND V.duration > 0 AND V.status = 1 AND V.is_deleted <> 1 AND V.is_manual = 0
),visit_ranked AS (
    SELECT V.Employee_Pin, V.from_date_time,V.to_date_time,V.application_date,V.movement_place,
    ROW_NUMBER() OVER (PARTITION BY employee_id, application_date ORDER BY from_date_time) AS rn
    FROM Visit_ranked_initial V
    WHERE V.row_num = 1
),Generate_CTE_Initial AS(
SELECT DL.pin, DL.generate_date,DL.application_type,DL.flag
,ROW_NUMBER() OVER(PARTITION BY DL.pin,DATE(DL.generate_date),DL.application_type,DL.flag ORDER BY DL.generate_date)row_num
FROM payroll_leave_attend_data.get_day_wise_lv_visit_wfa DL
WHERE DL.application_type = 'Work From Anywhere'
),Generate_CTE AS(
SELECT
    wfa.id AS integ_work_away_office_imp,
    DATE(DL.generate_date) AS generate_date
FROM wfa_ranked wfa
INNER JOIN visit_ranked v ON wfa.employee_code = v.Employee_Pin
 AND DATE(wfa.doc_date) = DATE(v.application_date)
 AND wfa.rn = v.rn
INNER JOIN Generate_CTE_Initial DL
    ON v.Employee_Pin = DL.pin
    AND (DATE(DL.generate_date) >= DATE(V.from_date_time)
    AND DATE(DL.generate_date) <= DATE(V.to_date_time))
)
SELECT
    gen_random_uuid()::uuid AS id
    , 0::integer AS version
    , '1'::varchar AS created_by
    , NOW()::timestamp with time zone AS created_date
    , '1'::varchar AS last_modified_by
    , NOW()::timestamp with time zone AS last_modified_date,
    GC.generate_date::timestamp AS attend_date,
    GC.integ_work_away_office_imp::UUID AS work_away_office_imp_id
FROM Generate_CTE GC;

