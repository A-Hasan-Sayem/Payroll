WITH RECURSIVE
  base_app AS (
    SELECT
      employee_core_info_id,
      official_visit_from_date::DATE AS travel_date,
      official_visit_to_date::DATE,
      date_created,
      ROW_NUMBER() OVER (
        PARTITION BY employee_core_info_id,DATE(official_visit_from_date), DATE(official_visit_to_date)
        ORDER BY ID DESC) AS rn
    FROM payroll_leave_attend_data.travel_application
    WHERE domain_status_id = 1
      AND EXTRACT(YEAR FROM official_visit_to_date) >= 2024
      AND status_id NOT IN (2, 3, 5, 8)
  ),date_series AS(
    SELECT
      employee_core_info_id,
      travel_date,
      official_visit_to_date,
      date_created
    FROM base_app
    WHERE rn = 1
    UNION ALL
    SELECT
      ds.employee_core_info_id,
      (ds.travel_date + INTERVAL '1 day')::DATE AS travel_date,
      ds.official_visit_to_date,
      ds.date_created
    FROM date_series AS ds
    WHERE ds.travel_date < ds.official_visit_to_date
  ),BASE_CTE AS (
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.employee_information_update e
    INNER JOIN payroll_emp_data.employee_core_info eci ON e.employee_core_info_id=eci.id
    WHERE e.employee_information_update_change_type_id IN (11, 25) AND date(e.effective_date) > '2023-12-31' and e.new_value != '3' AND E.domain_status_id = 1
    UNION
    SELECT e.employee_core_info_id::BIGINT AS Employee_ID
    FROM payroll_emp_data.emp_core_info_history e
    WHERE e.value_type = 'Employee Status Change' AND date(e.create_date) > '2023-12-31'
    UNION
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.job_separation_proposal jsp
    INNER JOIN payroll_emp_data.employee_core_info eci ON jsp.employee_core_info_id=eci.id AND jsp.domain_status_id=1 AND eci.cur_job_status_id != 3 AND date(jsp.date_created) > '2023-12-31'
    UNION
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.employee_core_info eci
    WHERE eci.cur_job_status_id = 3 AND eci.domain_status_id=1
),wfa_ranked AS (
    SELECT id,doc_date,employee_code,
           ROW_NUMBER() OVER (PARTITION BY employee_code, doc_date ORDER BY id) AS rn
    FROM integ_work_away_office_imp
    WHERE work_away_type  = 20-----should I have this?
),visit_ranked_Initial AS (
    SELECT TA.id, TA.employee_core_info_id AS Employee_ID,TA.official_visit_from_date,TA.official_visit_to_date,TA.date_created
           ,TA.destination,ECI.pin_no,
           ROW_NUMBER() OVER (PARTITION BY TA.employee_core_info_id,DATE(TA.date_created) ORDER BY TA.leave_taken_from_date) AS rn
    FROM payroll_leave_attend_data.travel_application TA
    INNER JOIN BASE_CTE B ON TA.employee_core_info_id = B.Employee_ID
    INNER JOIN payroll_emp_data.employee_core_info ECI ON ECI.id = TA.employee_core_info_id
    WHERE TA.domain_status_id = 1
    AND EXTRACT('YEAR' FROM TA.official_visit_to_date) >= 2024 AND TA.status_id not in (2, 3, 5, 8)
),visit_ranked AS(
    SELECT *,
    ROW_NUMBER() OVER(PARTITION BY Employee_ID,DATE(official_visit_from_date),DATE(official_visit_to_date) ORDER BY ID DESC)row_num
    FROM visit_ranked_Initial
),Generate_CTE AS(
SELECT
    wfa.id AS integ_work_away_office_imp,
    wfa.employee_code,
    v.official_visit_from_date::date AS from_date,
    v.official_visit_to_date::date AS to_date,
    wfa.doc_date,
    DATE(DL.travel_date) AS generate_date,
    V.destination
FROM wfa_ranked wfa
INNER JOIN visit_ranked v ON wfa.employee_code = v.pin_no
 AND DATE(wfa.doc_date) = DATE(v.date_created)
 AND wfa.rn = v.rn
INNER JOIN date_series DL
    ON v.Employee_ID = DL.employee_core_info_id
    AND (DATE(DL.travel_date) >= DATE(V.official_visit_from_date)
    AND DATE(DL.travel_date) <= DATE(V.official_visit_to_date))
WHERE v.row_num = 1
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
