---------------------------------------- INTEG_LEAVE_APP_IMP------------------------------------------
INSERT INTO public.integ_leave_app_imp
(
    id,
    version,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    app_number,
    application_date,
    employee_code,
    leave_type_code,
    event_date,
    event_end_date,
    start_date,
    end_date,
    duration_type,
    leave_app_created_date,
    creation_log
)
WITH BASE_CTE AS(
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
)
SELECT
    gen_random_uuid()::uuid AS id
    , 0::integer AS version
    , '1'::varchar AS created_by
    , NOW()::timestamp with time zone AS created_date
    , '1'::varchar AS last_modified_by
    , NOW()::timestamp with time zone AS last_modified_date,
    NULL::varchar AS app_number,
    LM.application_date::DATE AS application_date,
    U.pin::varchar AS employee_code,
    LTS.leavetypeid::varchar AS leave_type_code,
    CASE WHEN LM.leave_type_id = 26 THEN LM.incident_date::timestamp ELSE NULL::TIMESTAMP END AS event_date,
    NULL::timestamp AS event_end_date,
    LM.from_date::timestamp AS start_date,
    LM.to_date::timestamp AS end_date,
    CASE WHEN LM.slot = 'Full-day' THEN 10::INTEGER WHEN LM.slot = 'First-half' THEN 20::INTEGER WHEN LM.slot = 'Second-half' THEN 30::INTEGER ELSE NULL::INTEGER END AS duration_type,
    NULL::timestamp AS leave_app_created_date,
    NULL::TEXT AS creation_log
FROM payroll_leave_attend_data.leave_master LM
INNER JOIN payroll_emp_data.users U ON LM.employee_id = U.id
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
LEFT JOIN payroll_leave_attend_data.leavetypesetup LTS ON LM.leave_type_id = LTS.id
WHERE EXTRACT('YEAR' FROM LM.to_date) >= 2025
    AND LM.leave_duration > 0 AND LM.status = 1 AND LM.is_deleted <> 1 AND LM.is_manual = 0

UNION

SELECT
    gen_random_uuid()::uuid AS id
    , 0::integer AS version
    , '1'::varchar AS created_by
    , NOW()::timestamp with time zone AS created_date
    , '1'::varchar AS last_modified_by
    , NOW()::timestamp with time zone AS last_modified_date,
    NULL::varchar AS app_number,
    LO.application_date::DATE AS application_date,
    U.pin::varchar AS employee_code,
    LTS.leavetypeid::varchar AS leave_type_code,
    NULL::Timestamp AS event_date,
    NULL::timestamp AS event_end_date,
    LO.from_date::timestamp AS start_date,
    LO.to_date::timestamp AS end_date,
    CASE WHEN LO.slot = 'Full-day' THEN 10::INTEGER WHEN LO.slot = 'First-half' THEN 20::INTEGER WHEN LO.slot = 'Second-half' THEN 30::INTEGER ELSE NULL::INTEGER END AS duration_type,
    NULL::timestamp  AS leave_app_created_date,
    NULL::TEXT AS creation_log
FROM payroll_leave_attend_data.leave_others LO
INNER JOIN payroll_emp_data.users U ON LO.employee_id = U.id
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
LEFT JOIN payroll_leave_attend_data.leavetypesetup LTS ON LO.leave_type_id = LTS.id
WHERE EXTRACT('YEAR' FROM LO.to_date) >= 2025
    AND LO.leave_duration > 0 AND LO.status = 1 AND LO.is_deleted <> 1 AND LO.is_manual = 0;




------------------------------------------- INTEG_LEAVE_APP_LINE_IMP -------------------------------

INSERT INTO public.integ_leave_app_line_imp
(
    id,
    version,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    leave_date,
    leave_type_code,
    leave_day,
    leave_year,
    duration_type,
    seniority_loss_updated,
    leave_app_imp_id
)
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
)
SELECT
    gen_random_uuid()::uuid AS id
    , 0::integer AS version
    , '1'::varchar AS created_by
    , NOW()::timestamp with time zone AS created_date
    , '1'::varchar AS last_modified_by
    , NOW()::timestamp with time zone AS last_modified_date,
    DL.generate_date::timestamp AS leave_date,
    LTS.leavetypeid::varchar AS leave_type_code,
    CASE WHEN DL.flag IN('W','N') THEN 0::DOUBLE PRECISION ELSE 1::DOUBLE PRECISION END AS leave_day,
    EXTRACT('YEAR' FROM DL.generate_date)::varchar AS leave_year,
    CASE WHEN LM.slot = 'Full-day' THEN 10::varchar WHEN LM.slot = 'First-half' THEN 20::varchar WHEN LM.slot = 'Second-half' THEN 30::varchar ELSE NULL END AS duration_type,
    NULL::BOOLEAN AS seniority_loss_updated,
    ILAI.id::UUID AS leave_app_imp_id
FROM payroll_leave_attend_data.leave_master LM
INNER JOIN payroll_emp_data.users U ON LM.employee_id = U.id
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN payroll_leave_attend_data.leavetypesetup LTS ON LM.leave_type_id = LTS.id
INNER JOIN payroll_leave_attend_data.get_day_wise_lv_visit_wfa DL ON U.pin = DL.pin
    AND LTS.leavename = DL.application_type
    AND (DL.generate_date >= LM.from_date AND DL.generate_date <= LM.to_date)
INNER JOIN public.integ_leave_app_imp ILAI ON U.pin = ILAI.employee_code AND LM.from_date = ILAI.start_date AND LM.to_date = ILAI.end_date
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
WHERE EXTRACT('YEAR' FROM LM.to_date) >= 2025
    AND DL.flag NOT IN('V','WFA')
    AND LM.leave_duration > 0 AND LM.status = 1 AND LM.is_deleted <> 1 AND LM.is_manual = 0

UNION

SELECT
    gen_random_uuid()::uuid AS id
    , 0::integer AS version
    , '1'::varchar AS created_by
    , NOW()::timestamp with time zone AS created_date
    , '1'::varchar AS last_modified_by
    , NOW()::timestamp with time zone AS last_modified_date,
    DL.generate_date::timestamp AS leave_date,
    LTS.leavetypeid::varchar AS leave_type_code,
    CASE WHEN DL.flag IN('W','N') THEN 0::DOUBLE PRECISION ELSE 1::DOUBLE PRECISION END AS leave_day,
    EXTRACT('YEAR' FROM DL.generate_date)::varchar AS leave_year,
    CASE WHEN LO.slot = 'Full-day' THEN 10::varchar WHEN LO.slot = 'First-half' THEN 20::varchar WHEN LO.slot = 'Second-half' THEN 30::varchar ELSE NULL END AS duration_type,
    NULL::BOOLEAN AS seniority_loss_updated,
    ILAI.id::UUID AS leave_app_imp_id
FROM payroll_leave_attend_data.leave_others LO
INNER JOIN payroll_emp_data.users U ON LO.employee_id = U.id
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN payroll_leave_attend_data.leavetypesetup LTS ON LO.leave_type_id = LTS.id
INNER JOIN payroll_leave_attend_data.get_day_wise_lv_visit_wfa DL ON U.pin = DL.pin
    AND LTS.leavename = DL.application_type
    AND (DL.generate_date >= LO.from_date AND DL.generate_date <= LO.to_date)
INNER JOIN public.integ_leave_app_imp ILAI ON U.pin = ILAI.employee_code AND LO.from_date = ILAI.start_date AND LO.to_date = ILAI.end_date
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
WHERE EXTRACT('YEAR' FROM LO.to_date) >= 2025
    AND DL.flag NOT IN('V','WFA')
    AND LO.leave_duration > 0 AND LO.status = 1 AND LO.is_deleted <> 1 AND LO.is_manual = 0;






------------------------------------- INTEG_LEAVE_APP_TYPE_IMP -----------------------------------

INSERT INTO public.integ_leave_app_type_imp
(
    id,
    version,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    leave_type_code,
    start_date,
    end_date,
    total_days,
    leave_app_imp_id
)
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
), L1_CTE AS (
    SELECT
        gen_random_uuid()::uuid AS id,
        0::integer AS version,
        '1'::varchar AS created_by,
        NOW()::timestamp with time zone AS created_date,
        '1'::varchar AS last_modified_by,
        NOW()::timestamp with time zone AS last_modified_date,
        LTS.leavetypeid::varchar AS leave_type_code,
        LM.from_date::timestamp AS start_date,
        LM.to_date::timestamp AS end_date,
        LM.leave_duration::DOUBLE PRECISION AS total_days,
        ILAI.id::UUID AS leave_app_imp_id
    FROM payroll_leave_attend_data.leave_master LM
    INNER JOIN payroll_emp_data.users U ON LM.employee_id = U.id
    INNER JOIN BASE_CTE B ON U.pin = B.pin
    INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
    INNER JOIN public.integ_leave_app_imp ILAI
        ON U.pin = ILAI.employee_code
        AND LM.from_date = ILAI.start_date
        AND LM.to_date = ILAI.end_date
        AND ILAI.application_date = LM.application_date
        AND ILAI.leave_type_code::integer = LM.leave_type_id
    LEFT JOIN payroll_leave_attend_data.leavetypesetup LTS ON LM.leave_type_id = LTS.id
    WHERE
        EXTRACT('YEAR' FROM LM.to_date) >= 2025
        AND LM.leave_duration > 0
        AND LM.status = 1
        AND LM.is_deleted <> 1 AND LM.is_manual = 0

    UNION

    SELECT
        gen_random_uuid()::uuid AS id,
        0::integer AS version,
        '1'::varchar AS created_by,
        NOW()::timestamp with time zone AS created_date,
        '1'::varchar AS last_modified_by,
        NOW()::timestamp with time zone AS last_modified_date,
        LTS.leavetypeid::varchar AS leave_type_code,
        LO.from_date::timestamp AS start_date,
        LO.to_date::timestamp AS end_date,
        LO.leave_duration::DOUBLE PRECISION AS total_days,
        ILAI.id::UUID AS leave_app_imp_id
    FROM payroll_leave_attend_data.leave_others LO
    INNER JOIN payroll_emp_data.users U ON LO.employee_id = U.id
    INNER JOIN BASE_CTE B ON U.pin = B.pin
    INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
    INNER JOIN public.integ_leave_app_imp ILAI
        ON U.pin = ILAI.employee_code
        AND LO.from_date = ILAI.start_date
        AND LO.to_date = ILAI.end_date
        AND ILAI.application_date = LO.application_date
        AND ILAI.leave_type_code::integer = LO.leave_type_id
    LEFT JOIN payroll_leave_attend_data.leavetypesetup LTS ON LO.leave_type_id = LTS.id
    WHERE
        EXTRACT('YEAR' FROM LO.to_date) >= 2025
        AND LO.leave_duration > 0
        AND LO.status = 1
        AND LO.is_deleted <> 1 AND LO.is_manual = 0
), LAST_CTE AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY leave_app_imp_id ORDER BY id) AS r
    FROM L1_CTE
)
SELECT
    id,
    version,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    leave_type_code,
    start_date,
    end_date,
    total_days,
    leave_app_imp_id
FROM LAST_CTE WHERE r = 1;





---------------------------------------------- INTEG_HIGHER_STUDY_LEAVE_IMP ----------------------------

INSERT INTO public.integ_higher_study_leave_imp
(
    id,
    version,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    doc_no,
    doc_date,
    employee_code,
    date_to,
    date_from,
    leave_without_pay,
    leave_created_date,
    creation_log
)
WITH BASE_CTE AS (
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
)
SELECT
    gen_random_uuid()::uuid AS id
    , 0::integer AS version
    , '1'::varchar AS created_by
    , NOW()::timestamp with time zone AS created_date
    , '1'::varchar AS last_modified_by
    , NOW()::timestamp with time zone AS last_modified_date,
    NULL AS doc_no,
    HSA.date_created::timestamp AS doc_date,
    ECI.pin_no::varchar  AS employee_code,
    HSA.leave_taken_to_date::timestamp AS date_to,
    HSA.leave_taken_from_date::timestamp AS date_from,
    TRUE::Boolean AS leave_without_pay,                      --default 'True', will update after getting data from brac.
    NULL AS leave_created_date,
    NULL AS creation_log
FROM payroll_leave_attend_data.higher_studies_application HSA
INNER JOIN payroll_emp_data.employee_core_info ECI
    ON HSA.employee_core_info_id = ECI.id
INNER JOIN BASE_CTE B
    ON ECI.id = B.Employee_ID
--INNER JOIN public.integ_employee_imp IEI ON ECI.pin_no = IEI.employee_code
WHERE EXTRACT('YEAR' FROM HSA.leave_taken_to_date) >= 2025
    AND HSA.domain_status_id = 1;






-------------------------------- "INTEG_OUTSTATION_IMP (visit entries)" ----------------------------


INSERT INTO public.integ_outstation_imp
(
    id,
    version,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    app_no,
    app_date,
    employee_code,
    date_from,
    date_to,
    duration_type,
    total_days,
    location,
    purpose
)
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
)
SELECT
    gen_random_uuid()::uuid AS id
    , 0::integer AS version
    , '1'::varchar AS created_by
    , NOW()::timestamp with time zone AS created_date
    , '1'::varchar AS last_modified_by
    , NOW()::timestamp with time zone AS last_modified_date,
    NULL AS app_no,
    VM.application_date::timestamp AS app_date,
    U.pin::varchar AS employee_code,
    DATE(VM.from_date_time)::timestamp AS date_from,
    DATE(VM.to_date_time)::timestamp AS date_to,
    NULL AS duration_type,
    VM.duration::DOUBLE PRECISION AS total_days,
    VM.movement_place::varchar AS location,
    VM.purpose::TEXT AS purpose
FROM payroll_leave_attend_data.visit_master VM
INNER JOIN payroll_emp_data.users U ON VM.employee_id = U.id
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
WHERE VM.leavetype_id = 24
  AND EXTRACT('YEAR' FROM VM.to_date_time) >= 2025
  AND VM.duration > 0
  AND VM.is_international_travel = false AND VM.status = 1 AND VM.is_deleted <> 1; --need to check is_manual in VM?




------------------------------ INTEG_OUTSTATIO_DUTY_LINEIMP -------------------------------------


INSERT INTO public.integ_outstatio_duty_lineimp
(
    id,
    version,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    out_date,
    purpose,
    location,
    outstation_imp_id
)
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
)
SELECT
    gen_random_uuid()::uuid AS id
    , 0::integer AS version
    , '1'::varchar AS created_by
    , NOW()::timestamp with time zone AS created_date
    , '1'::varchar AS last_modified_by
    , NOW()::timestamp with time zone AS last_modified_date,
    DL.generate_date::timestamp AS out_date,
    VM.purpose::TEXT AS purpose,
    VM.movement_place::varchar AS location,
    IOI.id::UUID AS outstation_imp_id
FROM payroll_leave_attend_data.visit_master VM
INNER JOIN payroll_emp_data.users U ON VM.employee_id = U.id
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN payroll_leave_attend_data.leavetypesetup LTS
    ON VM.leavetype_id = LTS.id
INNER JOIN payroll_leave_attend_data.get_day_wise_lv_visit_wfa DL
    ON U.pin = DL.pin
    AND LTS.leavename = DL.application_type
    AND DATE(DL.generate_date >= DATE(VM.from_date_time)
    AND DATE(DL.generate_date) <= DATE(VM.to_date_time))
INNER JOIN public.integ_outstation_imp IOI ON U.pin = IOI.employee_code AND date(VM.from_date_time) = IOI.date_from AND date(VM.to_date_time) = IOI.date_to
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
WHERE VM.leavetype_id = 24
  AND EXTRACT('YEAR' FROM VM.to_date_time) >= 2025
  AND VM.duration > 0
  AND VM.is_international_travel = false
  AND DL.application_type = 'Visit' AND VM.status = 1 AND VM.is_deleted <> 1;






-----------------------INTEG_LEAVE_OP_BALANCE_IMP -----------------------------------------

INSERT INTO public.integ_leave_op_balance_imp
(
    id,
    version,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    employee_code,
    leave_year_code,
    leave_type_code,
    days_leave_bf,
    days_leave_taken_cy,
    remarks,
    creation_log,
    leave_op_created_date,
    balance_days,
    entitlement_cy
)
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
), LEAVE_DURATION_CTE AS (
    SELECT U.pin, LM.leave_type_id, SUM(LM.leave_duration) AS Total_Leave
    FROM payroll_leave_attend_data.leave_master LM
    INNER JOIN payroll_emp_data.users U ON LM.employee_id = U.id
    INNER JOIN BASE_CTE B ON U.pin = B.pin
    INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
    WHERE EXTRACT('YEAR' FROM LM.to_date) >= 2025 AND LM.leave_duration > 0 AND LM.leave_type_id IN (1,8,18)
    AND LM.status = 1 AND LM.is_deleted <> 1 AND LM.is_manual = 0
    GROUP BY U.pin, LM.leave_type_id
)
SELECT
    gen_random_uuid()::uuid AS id
    , 0::integer AS version
    , '1'::varchar AS created_by
    , NOW()::timestamp with time zone AS created_date
    , '1'::varchar AS last_modified_by
    , NOW()::timestamp with time zone AS last_modified_date,
    U.pin::varchar AS employee_code,
    '2025'::varchar AS leave_year_code,
    LTS.leavetypeid::varchar AS leave_type_code,
    ROUND(ELB.last_year_closing_leave_balance::DOUBLE PRECISION,6) days_leave_bf,
    ROUND(COALESCE(LDC.Total_Leave, 0)::NUMERIC,6) AS days_leave_taken_cy,
    ELB.remarks::VARCHAR AS remarks,
    NULL AS creation_log,
    NULL AS leave_op_created_date,
    ELB.current_year_leave_balance::DOUBLE PRECISION AS balance_days,
    ROUND(ABS((coalesce(LDC.Total_Leave,0)+ELB.current_year_leave_balance) - ELB.last_year_closing_leave_balance)::NUMERIC,6) entitlement_cy
FROM payroll_leave_attend_data.employee_leave_balance ELB
INNER JOIN payroll_emp_data.users U ON ELB.employee_id = U.id
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
LEFT JOIN LEAVE_DURATION_CTE LDC ON U.pin = LDC.pin AND ELB.leave_type_id = LDC.leave_type_id
LEFT JOIN payroll_leave_attend_data.leavetypesetup LTS ON ELB.leave_type_id = LTS.id
WHERE ELB.leave_type_id IN (1,8,18)
  AND ELB.leaveyear_policy_id >= 5 AND ELB.is_deleted <> 1;  --need to check is_manual in ELB?



--------------------------------- INTEG_INTERNATIONAL_TRAVEL_IMP ----------------------------------


INSERT INTO public.integ_international_travel_imp
(
    id,
    version,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    travel_doc_no,
    travel_doc_date,
    employee_code,
    travel_date_from,
    travel_date_to,
    leave_type_code,
    leave_from_date,
    leave_date_to,
    intltravel_created_date,
    leave_app_created_date,
    creation_log
)
WITH BASE_CTE AS (
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
)
SELECT
    gen_random_uuid()::uuid AS id
    , 0::integer AS version
    , '1'::varchar AS created_by
    , NOW()::timestamp with time zone AS created_date
    , '1'::varchar AS last_modified_by
    , NOW()::timestamp with time zone AS last_modified_date,
    NULL AS travel_doc_no,
    TA.date_created::timestamp AS travel_doc_date,
    ECI.pin_no::varchar AS employee_code,
    TA.official_visit_from_date::timestamp AS travel_date_from,
    TA.official_visit_to_date::timestamp AS travel_date_to,
    NULL AS leave_type_code,
    NULL AS leave_from_date,
    NULL AS leave_date_to,
    NULL AS intltravel_created_date,
    NULL AS leave_app_created_date,
    NULL AS creation_log
FROM payroll_leave_attend_data.travel_application TA
INNER JOIN payroll_emp_data.employee_core_info ECI ON TA.employee_core_info_id = ECI.id
INNER JOIN BASE_CTE B ON ECI.id = B.Employee_ID
--INNER JOIN public.integ_employee_imp IEI ON ECI.pin_no = IEI.employee_code
WHERE TA.domain_status_id = 1
  AND EXTRACT('YEAR' FROM TA.official_visit_to_date) >= 2025;





-------------------------------- INTEG_WORK_AWAY_OFFICE_IMP -----------------------------------

INSERT INTO public.integ_work_away_office_imp
(
    id,
    version,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    doc_no,
    doc_date,
    employee_code,
    oper_location_code
)
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
)
SELECT
    gen_random_uuid()::uuid AS id
    , 0::integer AS version
    , '1'::varchar AS created_by
    , NOW()::timestamp with time zone AS created_date
    , '1'::varchar AS last_modified_by
    , NOW()::timestamp with time zone AS last_modified_date,
    NULL AS doc_no,
    VM.application_date::timestamp AS doc_date,
    U.pin::varchar AS employee_code,
    IEI.operating_location_id::varchar AS oper_location_code
FROM payroll_leave_attend_data.visit_master VM
INNER JOIN payroll_emp_data.users U ON VM.employee_id = U.id
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN public.mdg_empl_profile IEI ON U.pin = IEI.employee_code
--INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
WHERE EXTRACT('YEAR' FROM VM.to_date_time) >= 2025
  AND VM.duration > 0
  AND VM.leavetype_id = 25 AND VM.status = 1 AND VM.is_deleted <> 1;  --need to check is_manual in VM?



------------------------------- INTEG_WORK_AWAY_OFFICE_LINE_IMP ------------------------------

INSERT INTO public.integ_work_away_office_line_imp
(
    id,
    version,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    attend_date,
    work_away_office_imp_id
)
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
)
SELECT
    gen_random_uuid()::uuid AS id
    , 0::integer AS version
    , '1'::varchar AS created_by
    , NOW()::timestamp with time zone AS created_date
    , '1'::varchar AS last_modified_by
    , NOW()::timestamp with time zone AS last_modified_date,
    DL.generate_date::timestamp AS attend_date,
    IWAOI.id::UUID AS work_away_office_imp_id
FROM payroll_leave_attend_data.visit_master VM
INNER JOIN payroll_emp_data.users U ON VM.employee_id = U.id
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN payroll_leave_attend_data.leavetypesetup LTS ON VM.leavetype_id = LTS.id
INNER JOIN payroll_leave_attend_data.get_day_wise_lv_visit_wfa DL
    ON U.pin = DL.pin
    AND LTS.leavename = DL.application_type
    AND (DATE(DL.generate_date) >= DATE(VM.from_date_time) AND DATE(DL.generate_date) <= DATE(VM.to_date_time))
INNER JOIN public.integ_work_away_office_imp IWAOI ON U.pin = IWAOI.employee_code AND DATE(IWAOI.doc_date) = DATE(VM.application_date)
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
WHERE VM.leavetype_id <> 24
  AND EXTRACT('YEAR' FROM VM.to_date_time) >= 2025
  AND VM.duration > 0
  AND DL.flag = 'WFA' AND VM.status = 1 AND VM.is_deleted <> 1;  --need to check is_manual in VM?



----------------------------------- HR_ATTEND_SUMMARY_DAILY ----------------------------------

INSERT INTO public.hr_attend_summary_daily
(
    id,
    version,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    company_id,
    operating_location_id,
    employee_profile_id,
    atten_date,
    day_name,
    entry_date,
    exit_date,
    entry_time,
    exit_time,
    work_shift_id,
    shift_start_time,
    shift_end_time,
    late_in,
    absent_half_day,
    early_out,
    absent,
    on_leave,
    leave_day,
    leave_wo_pay_day,
    late_minutes,
    hours_overtime,
    hours_overtime_adj,
    minutes_overtime,
    outstation_am,
    outstation_pm,
    holiday,
    weekend,
    present,
    present_night,
    single_punch,
    manual_attend_entry,
    manual_overtime_adj,
    holiday_weekend_present,
    manual_attend_note,
    manual_overtime_note,
    outstation_note,
    leave_app_note,
    absent_days,
    remarks,
    atten_status,
    attendance_day_type,
    overtime_hours_plan,
    attend_missed_entry,
    total_hours,
    attend_card_id,
    attend_tracking_type,
    break_time_minute,
    break_time_start,
    check_in_early_start_minute,
    check_out_end_max_minute,
    early_out_as_absent,
    flexi_hour,
    grace_minute_absent,
    grace_minute_late,
    gross_hours,
    halfday_present_minute,
    holiday_calendar_id,
    single_time_entry_as_absent,
    tol_minute_half_day_present,
    work_shift_rotated
)
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
)
SELECT
    gen_random_uuid()::uuid AS id
    , 0::integer AS version
    , '1'::varchar AS created_by
    , NOW()::timestamp with time zone AS created_date
    , '1'::varchar AS last_modified_by
    , NOW()::timestamp with time zone AS last_modified_date,
    '93647f60-d696-ada6-9b28-cee3c3793e02' AS company_id, --need to copy again the uuid of brac from mdg_company
    IEI.operating_location_id AS operating_location_id,
    IEI.id::UUID AS employee_profile_id,
    GA.att_date::timestamp AS atten_date,
    TO_CHAR(GA.att_date, 'Day')::varchar AS day_name,
    GA.att_date::timestamp AS entry_date,
    GA.att_date::timestamp AS exit_date,
    GA.intime::time AS entry_time,
    GA.outtime::time AS exit_time,
    IEI.work_shift_id AS work_shift_id, --need to discuss
    NULL AS shift_start_time,
    NULL AS shift_end_time,
    NULL AS late_in,
    NULL AS absent_half_day,
    NULL AS early_out,
    CASE WHEN GA.flag = 'A' THEN TRUE::BOOLEAN ELSE FALSE::BOOLEAN END AS absent,
    CASE WHEN GA.flag IN ('L','Y','F','M','U','J','K','B','C') THEN TRUE::BOOLEAN ELSE FALSE::BOOLEAN END AS on_leave,
    NULL AS leave_day,
    CASE WHEN GA.flag = 'U' THEN 1.0::DOUBLE PRECISION ELSE 0.0::DOUBLE PRECISION END AS leave_wo_pay_day,
    NULL AS late_minutes,
    NULL AS hours_overtime,
    NULL AS hours_overtime_adj,
    NULL AS minutes_overtime,
    NULL AS outstation_am,
    NULL AS outstation_pm,
    CASE WHEN GA.flag = 'N' THEN TRUE::BOOLEAN ELSE FALSE::BOOLEAN END AS holiday,
    CASE WHEN GA.flag = 'W' THEN TRUE::BOOLEAN ELSE FALSE::BOOLEAN END AS weekend,
    CASE WHEN GA.flag = '' THEN TRUE::BOOLEAN ELSE FALSE::BOOLEAN END AS present,
    NULL AS present_night,
    NULL AS single_punch,
    NULL AS manual_attend_entry,
    NULL AS manual_overtime_adj,
    NULL AS holiday_weekend_present,
    NULL AS manual_attend_note,
    NULL AS manual_overtime_note,
    NULL AS outstation_note,
    NULL AS leave_app_note,
    NULL AS absent_days,
    NULL AS remarks,
    CASE
        WHEN GA.flag = 'A' THEN 'A'::varchar
        WHEN GA.flag = 'W' THEN 'W'::varchar
        WHEN GA.flag = 'U' THEN 'LWP'::varchar
        WHEN GA.flag = 'V' THEN 'OS'::varchar
        WHEN GA.flag = 'N' THEN 'H'::varchar
        WHEN GA.flag IN ('L','Y','F','M','J','K','B','C') THEN 'LV'::varchar
        WHEN (GA.flag = 'WFA' OR GA.flag = '') THEN 'P'::varchar
        ELSE NULL
    END AS atten_status,
    NULL AS attendance_day_type,
    NULL AS overtime_hours_plan,
    NULL AS attend_missed_entry,
    NULL AS total_hours,
    NULL AS attend_card_id,
    NULL AS attend_tracking_type,
    NULL AS break_time_minute,
    NULL AS break_time_start,
    NULL AS check_in_early_start_minute,
    NULL AS check_out_end_max_minute,
    NULL AS early_out_as_absent,
    NULL AS flexi_hour,
    NULL AS grace_minute_absent,
    NULL AS grace_minute_late,
    NULL AS gross_hours,
    NULL AS halfday_present_minute,
    NULL AS holiday_calendar_id,
    NULL AS single_time_entry_as_absent,
    NULL AS tol_minute_half_day_present,
    NULL AS work_shift_rotated
FROM payroll_leave_attend_data.get_attendance_raw_data_with_flag GA
INNER JOIN public.mdg_empl_profile IEI ON GA.staffpin = IEI.employee_code
INNER JOIN payroll_emp_data.users U ON GA.staffpin = U.pin
INNER JOIN BASE_CTE B ON U.pin = B.pin
LEFT JOIN payroll_emp_data.employeewiseattendancepolicymapping EAM ON U.id = EAM.employee_id
--LEFT JOIN public.mdg_empl_profile M ON IEI.id = M.id
WHERE GA.flag <> '-' AND EXTRACT('YEAR' FROM GA.att_date) = 2025;






--------------------------------- "INTEG_ATTEND_MISSED_APP_IMP (Attendance reconcilation applications)"----


INSERT INTO public.integ_attend_missed_app_imp
(
    id,
    atten_miss_entry_no,
    appl_date,
    employee_code,
    atten_date,
    in_time,
    out_time,
    workshift_code
)
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
)
SELECT
    gen_random_uuid()::uuid AS id,
    NULL AS atten_miss_entry_no,
    AR.created_at::TIMESTAMP AS appl_date,
    U.pin::VARCHAR AS employee_code,
    AR.attendance_date::TIMESTAMP AS atten_date,
    AR.daily_in_time::TIME AS in_time,
    AR.daily_out_time::TIME AS out_time,
    EAM.policyid::VARCHAR AS workshift_code
FROM payroll_leave_attend_data.attendance_reconciliation AR
INNER JOIN payroll_emp_data.users U ON AR.employee_id = U.id
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN payroll_emp_data.employee_core_info ECI ON U.pin = ECI.pin_no
INNER JOIN payroll_emp_data.employeewiseattendancepolicymapping EAM ON U.id = EAM.employee_id
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code;

