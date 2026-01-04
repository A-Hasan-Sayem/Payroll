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
),Leave_Master_Dup AS(
SELECT LM.id,
    ROW_NUMBER() OVER (PARTITION BY LM.employee_id, DATE(LM.from_date) ORDER BY recon_status DESC, LM.id DESC) AS from_rn,
    ROW_NUMBER() OVER (PARTITION BY LM.employee_id, DATE(LM.to_date) ORDER BY recon_status DESC, LM.id DESC) AS to_rn
 FROM payroll_leave_attend_data.leave_master LM
INNER JOIN payroll_emp_data.users U ON LM.employee_id = U.id
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
WHERE EXTRACT('YEAR' FROM LM.to_date) >= 2025
    AND LM.leave_duration > 0 AND LM.status = 1 AND LM.is_deleted <> 1 AND LM.is_manual = 0
    and lm.leave_type_id <> 6 AND LM.approval_action_time < '2025-06-02 21:00:00.000000'
),Leave_Others_Dup AS(
  SELECT
    LO.id,
    ROW_NUMBER() OVER (PARTITION BY LO.employee_id, DATE(LO.from_date) ORDER BY LO.recon_status DESC, LO.id DESC) AS from_rn,
    ROW_NUMBER() OVER (PARTITION BY LO.employee_id, DATE(LO.to_date) ORDER BY LO.recon_status DESC, LO.id DESC) AS to_rn
FROM payroll_leave_attend_data.leave_others LO
INNER JOIN payroll_emp_data.users U ON LO.employee_id = U.id
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
WHERE EXTRACT('YEAR' FROM LO.to_date) >= 2025
    AND LO.leave_duration > 0 AND LO.status = 1 AND LO.is_deleted <> 1 AND LO.is_manual = 0
    and lo.leave_type_id <> 6  AND LO.approval_action_time < '2025-06-02 21:00:00.000000'
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
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
LEFT JOIN payroll_leave_attend_data.leavetypesetup LTS ON LM.leave_type_id = LTS.id
LEFT JOIN Leave_Master_Dup L ON LM.id = L.id AND(L.from_rn >=2 OR L.to_rn >=2)
WHERE L.id IS NULL AND  EXTRACT('YEAR' FROM LM.to_date) >= 2025
    AND LM.leave_duration > 0 AND LM.status = 1 AND LM.is_deleted <> 1 AND LM.is_manual = 0
    and lm.leave_type_id <> 6  AND LM.approval_action_time < '2025-06-02 21:00:00.000000'

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
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
LEFT JOIN payroll_leave_attend_data.leavetypesetup LTS ON LO.leave_type_id = LTS.id
LEFT JOIN Leave_Others_Dup L ON LO.id = L.id AND(L.from_rn >=2 OR L.to_rn >=2)
WHERE L.id IS NULL AND EXTRACT('YEAR' FROM LO.to_date) >= 2025
    AND LO.leave_duration > 0 AND LO.status = 1 AND LO.is_deleted <> 1 AND LO.is_manual = 0
    and lo.leave_type_id <> 6 AND LO.approval_action_time < '2025-06-02 21:00:00.000000';

---------------------------------------- INTEG_LEAVE_APP_LINE_IMP ------------------------------------

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
    leave_app_imp_id,
    holiday_weekend_work_date
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
),Leave_Master_Dup AS(
SELECT LM.id,
    ROW_NUMBER() OVER (PARTITION BY LM.employee_id, DATE(LM.from_date) ORDER BY LM.recon_status DESC, LM.id DESC) AS from_rn,
    ROW_NUMBER() OVER (PARTITION BY LM.employee_id, DATE(LM.to_date) ORDER BY LM.recon_status DESC, LM.id DESC) AS to_rn
 FROM payroll_leave_attend_data.leave_master LM
INNER JOIN payroll_emp_data.users U ON LM.employee_id = U.id
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
WHERE EXTRACT('YEAR' FROM LM.to_date) >= 2025
    AND LM.leave_duration > 0 AND LM.status = 1 AND LM.is_deleted <> 1 AND LM.is_manual = 0
    and lm.leave_type_id <> 6  AND LM.approval_action_time < '2025-06-02 21:00:00.000000'
),Leave_Others_Dup AS(
  SELECT
    LO.id,
    ROW_NUMBER() OVER (PARTITION BY LO.employee_id, DATE(LO.from_date) ORDER BY LO.recon_status DESC, LO.id DESC) AS from_rn,
    ROW_NUMBER() OVER (PARTITION BY LO.employee_id, DATE(LO.to_date) ORDER BY LO.recon_status DESC, LO.id DESC) AS to_rn
FROM payroll_leave_attend_data.leave_others LO
INNER JOIN payroll_emp_data.users U ON LO.employee_id = U.id
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
WHERE EXTRACT('YEAR' FROM LO.to_date) >= 2025
    AND LO.leave_duration > 0 AND LO.status = 1 AND LO.is_deleted <> 1 AND LO.is_manual = 0
    and lo.leave_type_id <> 6  AND LO.approval_action_time < '2025-06-02 21:00:00.000000'
),Day_Wise_Dup AS(
 SELECT pin,generate_date,flag,application_type,
        ROW_NUMBER() OVER(PARTITION BY pin,DATE(generate_date) ORDER BY generate_date)rn
 FROM payroll_leave_attend_data.get_day_wise_lv_visit_wfa
 WHERE application_type NOT IN('Visit','Work From Anywhere')
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
    CASE WHEN DL.flag IN('W','N') THEN 0::DOUBLE PRECISION
         WHEN DL.flag NOT IN('W','N') AND LM.slot IN('First-half','Second-half') THEN 0.5::DOUBLE PRECISION
         ELSE 1::DOUBLE PRECISION END AS leave_day,
    EXTRACT('YEAR' FROM DL.generate_date)::varchar AS leave_year,
    CASE WHEN LM.slot = 'Full-day' THEN 10::varchar WHEN LM.slot = 'First-half' THEN 20::varchar WHEN LM.slot = 'Second-half' THEN 30::varchar ELSE NULL END AS duration_type,
    NULL::BOOLEAN AS seniority_loss_updated,
    ILAI.id::UUID AS leave_app_imp_id,
    LM.worked_day_for_compensatory_leave::DATE AS holiday_weekend_work_date
FROM payroll_leave_attend_data.leave_master LM
INNER JOIN payroll_emp_data.users U ON LM.employee_id = U.id
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN payroll_leave_attend_data.leavetypesetup LTS ON LM.leave_type_id = LTS.id
INNER JOIN Day_Wise_Dup DL ON U.pin = DL.pin
    AND LTS.leavename = DL.application_type
    AND (DL.generate_date >= LM.from_date AND DL.generate_date <= LM.to_date) AND DL.rn = 1
INNER JOIN public.integ_leave_app_imp ILAI ON U.pin = ILAI.employee_code AND LM.from_date = ILAI.start_date AND LM.to_date = ILAI.end_date
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
WHERE EXTRACT('YEAR' FROM LM.to_date) >= 2025
    AND LM.leave_duration > 0 AND LM.status = 1 AND LM.is_deleted <> 1 AND LM.is_manual = 0
    and lm.leave_type_id <> 6
    AND LM.id NOT IN(SELECT id FROM Leave_Master_Dup WHERE from_rn >=2 OR to_rn >=2)
     AND LM.approval_action_time < '2025-06-02 21:00:00.000000'

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
    CASE WHEN DL.flag IN('W','N') THEN 0::DOUBLE PRECISION
         WHEN DL.flag NOT IN('W','N') AND LO.slot IN('First-half','Second-half') THEN 0.5::DOUBLE PRECISION
         ELSE 1::DOUBLE PRECISION END AS leave_day,
    EXTRACT('YEAR' FROM DL.generate_date)::varchar AS leave_year,
    CASE WHEN LO.slot = 'Full-day' THEN 10::varchar WHEN LO.slot = 'First-half' THEN 20::varchar WHEN LO.slot = 'Second-half' THEN 30::varchar ELSE NULL END AS duration_type,
    NULL::BOOLEAN AS seniority_loss_updated,
    ILAI.id::UUID AS leave_app_imp_id,
    NULL::DATE AS holiday_weekend_work_date
FROM payroll_leave_attend_data.leave_others LO
INNER JOIN payroll_emp_data.users U ON LO.employee_id = U.id
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN payroll_leave_attend_data.leavetypesetup LTS ON LO.leave_type_id = LTS.id
INNER JOIN Day_Wise_Dup DL ON U.pin = DL.pin
    AND LTS.leavename = DL.application_type
    AND (DL.generate_date >= LO.from_date AND DL.generate_date <= LO.to_date) AND DL.rn = 1
INNER JOIN public.integ_leave_app_imp ILAI ON U.pin = ILAI.employee_code AND LO.from_date = ILAI.start_date AND LO.to_date = ILAI.end_date
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
WHERE EXTRACT('YEAR' FROM LO.to_date) >= 2025
    AND LO.leave_duration > 0 AND LO.status = 1 AND LO.is_deleted <> 1 AND LO.is_manual = 0
    and lo.leave_type_id <> 6
AND LO.id NOT IN(SELECT id FROM Leave_Others_Dup WHERE from_rn >=2 OR to_rn >=2)
 AND LO.approval_action_time < '2025-06-02 21:00:00.000000';

---------------------------------------- INTEG_HIGHER_STUDY_LEAVE_IMP --------------------------------

---higher studies 1st table

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
WITH BASE_CTE AS (
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.employee_information_update e
    INNER JOIN payroll_emp_data.employee_core_info eci ON e.employee_core_info_id=eci.id
    WHERE e.employee_information_update_change_type_id IN (11, 25) AND date(e.effective_date) > '2024-12-31' and e.new_value != '3' AND E.domain_status_id = 1
    UNION
    SELECT e.employee_core_info_id::BIGINT AS Employee_ID
    FROM payroll_emp_data.emp_core_info_history e
    WHERE e.value_type = 'Employee Status Change' AND date(e.create_date) > '2024-12-31'
    UNION
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.job_separation_proposal jsp
    INNER JOIN payroll_emp_data.employee_core_info eci ON jsp.employee_core_info_id=eci.id AND jsp.domain_status_id=1 AND eci.cur_job_status_id != 3 AND date(jsp.date_created) > '2024-12-31'
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
    NULL::varchar AS app_number,
    HSA.date_created::DATE AS application_date,
    ECI.pin_no::varchar  AS employee_code,
    CASE WHEN ps.leave_without_pay_status = true THEN '05'::varchar
    ELSE '28'::varchar END AS leave_type_code,
    NULL::timestamp AS event_date,
    NULL::timestamp AS event_end_date,
    HSA.leave_taken_from_date::timestamp AS start_date,
    HSA.leave_taken_to_date::timestamp AS end_date,
    NULL::INTEGER AS duration_type,
    NULL::timestamp AS leave_app_created_date,
    NULL::TEXT AS creation_log
FROM payroll_leave_attend_data.higher_studies_application HSA
INNER JOIN payroll_emp_data.employee_core_info ECI
    ON HSA.employee_core_info_id = ECI.id
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON ECI.pin_no = ER.pin
INNER JOIN BASE_CTE B
    ON ECI.id = B.Employee_ID
left join payroll_leave_attend_data.higher_study_pay_status ps
    on eci.pin_no=ps.pin
    and date(hsa.leave_taken_from_date)=date(ps.leave_taken_from_date)
    and date(hsa.leave_taken_to_date)=date(ps.leave_taken_to_date)
    and date(hsa.date_created)=date(ps.date_created)
--INNER JOIN public.integ_employee_imp IEI ON ECI.pin_no = IEI.employee_code
WHERE EXTRACT('YEAR' FROM HSA.leave_taken_to_date) >= 2025
    AND HSA.domain_status_id = 1 AND HSA.status_id not in (2, 3, 5, 8);


--higher studies 2nd table

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
    leave_app_imp_id,
    holiday_weekend_work_date
)
WITH RECURSIVE date_series AS(
    SELECT id AS leave_app_imp_id, employee_code,start_date, start_date AS Generate_Date, end_date, application_date, 1 AS leave_day
    ,NULL AS duration_type, leave_type_code, NULL AS seniority_loss_updated, NULL AS holiday_weekend_work_date
    FROM public.integ_leave_app_imp
    WHERE leave_type_code IN ('05','28')
    UNION ALL
    SELECT ds.leave_app_imp_id, ds.employee_code,ds.start_date,
      (ds.Generate_Date + INTERVAL '1 day')::DATE AS Generate_Date,
      ds.end_date,
      ds.application_date, ds.leave_day, ds.duration_type,ds.leave_type_code
    ,ds.seniority_loss_updated,ds.holiday_weekend_work_date
    FROM date_series AS ds
    WHERE ds.Generate_Date < ds.end_date
  )
SELECT
    gen_random_uuid()::uuid AS id
    , 0::integer AS version
    , '1'::varchar AS created_by
    , NOW()::timestamp with time zone AS created_date
    , '1'::varchar AS last_modified_by
    , NOW()::timestamp with time zone AS last_modified_date,
    DS.generate_date::timestamp AS leave_date,
    DS.leave_type_code::varchar AS leave_type_code,
    DS.leave_day::DOUBLE PRECISION AS leave_day,
    EXTRACT('YEAR' FROM DS.generate_date)::varchar AS leave_year,
    DS.duration_type::varchar AS duration_type,
    DS.seniority_loss_updated::BOOLEAN AS seniority_loss_updated,
    DS.leave_app_imp_id::UUID AS leave_app_imp_id,
    DS.holiday_weekend_work_date::DATE AS holiday_weekend_work_date
FROM date_series DS;


-------------------------------------- INTEG_OUTSTATION_IMP (visit entries) ----------------------------


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
    oper_location_code,
    work_away_type,
    work_address,
    deliverables,
    destination_type,
    visit_start_time,
    visit_end_time
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
),Final_CTE AS(
SELECT VM.id,
    ROW_NUMBER() OVER (PARTITION BY VM.employee_id, DATE(VM.from_date_time) ORDER BY VM.recon_status DESC, VM.id DESC) AS from_rn,
    ROW_NUMBER() OVER (PARTITION BY VM.employee_id, DATE(VM.to_date_time) ORDER BY VM.recon_status DESC, VM.id DESC) AS to_rn
FROM payroll_leave_attend_data.visit_master VM
INNER JOIN payroll_emp_data.users U ON VM.employee_id = U.id
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
WHERE VM.leavetype_id = 24
  AND EXTRACT('YEAR' FROM VM.to_date_time) >= 2025
  AND VM.duration > 0
  AND VM.is_international_travel = false AND VM.status = 1 AND VM.is_deleted <> 1 AND VM.is_manual = 0
     AND VM.approval_action_time < '2025-06-02 21:00:00.000000'
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
    IEI.operating_location_code::varchar AS oper_location_code,
    20::INTEGER AS work_away_type,
    VM.movement_place::varchar AS work_address,
    --VM.purpose::varchar AS deliverables,
    NULL::varchar AS deliverables,
    10::INTEGER AS destination_type,
    VM.from_date_time::TIME AS visit_start_time,
    VM.to_date_time::TIME AS visit_end_time
FROM payroll_leave_attend_data.visit_master VM
INNER JOIN payroll_emp_data.users U ON VM.employee_id = U.id
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
INNER JOIN BASE_CTE B ON U.pin = B.pin
--INNER JOIN public.mdg_empl_profile IEI ON U.pin = IEI.employee_code
--INNER JOIN payroll_emp_data.employee_core_info ECI ON IEI.employee_code= ECI.pin_no
--LEFT JOIN payroll_master_data.physical_office_info POI ON ECI.office_info_id = POI.id
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
LEFT JOIN Final_CTE F ON VM.id = F.id AND (F.from_rn >=2 OR F.to_rn >= 2)
WHERE F.id IS NULL AND VM.leavetype_id = 24
  AND EXTRACT('YEAR' FROM VM.to_date_time) >= 2025
  AND VM.duration > 0
  AND VM.is_international_travel = false AND VM.status = 1 AND VM.is_deleted <> 1 AND VM.is_manual = 0
AND VM.approval_action_time < '2025-06-02 21:00:00.000000';


-- select length(purpose) a, to_date_time from payroll_leave_attend_data.visit_master
--                                        where EXTRACT('YEAR' FROM to_date_time) >= 2025
--                                        order by a desc;

------------------------------------- INTEG_OUTSTATIO_DUTY_LINEIMP -------------------------------------

INSERT INTO public.integ_work_away_office_line_imp
(
    id,
    version,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    attend_date,
    work_away_office_imp_id,
    visit_location,
    weekend_or_holiday,
    working_day
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
),wfa_ranked AS (
    SELECT id,doc_date,employee_code,
    ROW_NUMBER() OVER (PARTITION BY employee_code, doc_date ORDER BY id) AS rn
    FROM integ_work_away_office_imp
    WHERE destination_type = 10 AND work_away_type = 20
),Final_CTE AS(
SELECT VM.id,
    ROW_NUMBER() OVER (PARTITION BY VM.employee_id, DATE(VM.from_date_time) ORDER BY VM.recon_status DESC, VM.id DESC) AS from_rn,
    ROW_NUMBER() OVER (PARTITION BY VM.employee_id, DATE(VM.to_date_time) ORDER BY VM.recon_status DESC, VM.id DESC) AS to_rn
FROM payroll_leave_attend_data.visit_master VM
INNER JOIN payroll_emp_data.users U ON VM.employee_id = U.id
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
WHERE VM.leavetype_id = 24
  AND EXTRACT('YEAR' FROM VM.to_date_time) >= 2025
  AND VM.duration > 0
  AND VM.is_international_travel = false AND VM.status = 1 AND VM.is_deleted <> 1 AND VM.is_manual = 0
AND VM.approval_action_time < '2025-06-02 21:00:00.000000'
),visit_ranked AS (
    SELECT V.employee_id,U.pin,V.from_date_time,V.to_date_time,V.application_date,V.movement_place,
    ROW_NUMBER() OVER (PARTITION BY V.employee_id, DATE(V.application_date) ORDER BY V.from_date_time) AS rn
FROM payroll_leave_attend_data.visit_master V
INNER JOIN payroll_emp_data.users U ON V.employee_id = U.id
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
LEFT JOIN Final_CTE F ON V.id = F.id AND (F.from_rn >= 2 OR F.to_rn >= 2)
WHERE F.id IS NULL AND V.leavetype_id = 24
  AND EXTRACT('YEAR' FROM V.to_date_time) >= 2025
  AND V.duration > 0
  AND V.is_international_travel = false AND V.status = 1 AND V.is_deleted <> 1 AND V.is_manual = 0
AND V.approval_action_time < '2025-06-02 21:00:00.000000'
),Generate_CTE_Initial AS(
SELECT DL.pin, DL.generate_date,DL.application_type,DL.flag
,ROW_NUMBER() OVER(PARTITION BY DL.pin,DATE(DL.generate_date) ORDER BY DL.generate_date)row_num
FROM payroll_leave_attend_data.get_day_wise_lv_visit_wfa DL
WHERE DL.application_type = 'Visit'
),Generate_CTE AS(
SELECT
    wfa.id AS integ_work_away_office_imp,
    DATE(DL.generate_date) AS generate_date,
    V.movement_place,
    CASE WHEN DL.flag IN('W','N') THEN TRUE ELSE FALSE END AS weekend_or_holiday
FROM wfa_ranked wfa
INNER JOIN visit_ranked v ON wfa.employee_code = v.Pin
 AND DATE(wfa.doc_date) = DATE(v.application_date)
 AND wfa.rn = v.rn
INNER JOIN Generate_CTE_Initial DL
    ON v.Pin = DL.pin
    AND (DATE(DL.generate_date) >= DATE(V.from_date_time)
    AND DATE(DL.generate_date) <= DATE(V.to_date_time)) AND DL.row_num = 1
)
SELECT
    gen_random_uuid()::uuid AS id
    , 0::integer AS version
    , '1'::varchar AS created_by
    , NOW()::timestamp with time zone AS created_date
    , '1'::varchar AS last_modified_by
    , NOW()::timestamp with time zone AS last_modified_date,
    GC.generate_date::timestamp AS attend_date,
    GC.integ_work_away_office_imp::UUID AS work_away_office_imp_id,
    GC.movement_place::varchar AS visit_location,
    GC.weekend_or_holiday::BOOLEAN,
    CASE WHEN GC.weekend_or_holiday = TRUE THEN 0.0::DOUBLE PRECISION ELSE 1.0::DOUBLE PRECISION END AS working_day
FROM Generate_CTE GC;


------------------------------------ INTEG_LEAVE_OP_BALANCE_IMP -----------------------------------------

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
    entitlement_cy,
    leave_op_balance_date
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
    INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
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
    ROUND(ELB.last_year_closing_leave_balance::NUMERIC,6) days_leave_bf,
    ROUND(COALESCE(LDC.Total_Leave, 0)::NUMERIC,6) AS days_leave_taken_cy,
    ELB.remarks::VARCHAR AS remarks,
    NULL AS creation_log,
    NULL AS leave_op_created_date,
    ELB.current_year_leave_balance::DOUBLE PRECISION AS balance_days,
    ROUND(ABS((coalesce(LDC.Total_Leave,0)+ELB.current_year_leave_balance) - ELB.last_year_closing_leave_balance)::NUMERIC,6) entitlement_cy,
    NOW()::DATE AS leave_op_balance_date
FROM payroll_leave_attend_data.employee_leave_balance ELB
INNER JOIN payroll_emp_data.users U ON ELB.employee_id = U.id
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
LEFT JOIN LEAVE_DURATION_CTE LDC ON U.pin = LDC.pin AND ELB.leave_type_id = LDC.leave_type_id
LEFT JOIN payroll_leave_attend_data.leavetypesetup LTS ON ELB.leave_type_id = LTS.id
WHERE ELB.leave_type_id IN (1,8,18)
  AND ELB.leaveyear_policy_id >= 5 AND ELB.is_deleted <> 1;  --need to check is_manual in ELB?


----------------------------------- INTEG_INTERNATIONAL_TRAVEL_IMP --------------------------------------


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
    oper_location_code,
    work_away_type,
    work_address,
    deliverables,
    destination_type,
    visit_start_time,
    visit_end_time
)
WITH BASE_CTE AS (
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.employee_information_update e
    INNER JOIN payroll_emp_data.employee_core_info eci ON e.employee_core_info_id=eci.id
    WHERE e.employee_information_update_change_type_id IN (11, 25) AND date(e.effective_date) > '2024-12-31' and e.new_value != '3' AND E.domain_status_id = 1
    UNION
    SELECT e.employee_core_info_id::BIGINT AS Employee_ID
    FROM payroll_emp_data.emp_core_info_history e
    WHERE e.value_type = 'Employee Status Change' AND date(e.create_date) > '2024-12-31'
    UNION
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.job_separation_proposal jsp
    INNER JOIN payroll_emp_data.employee_core_info eci ON jsp.employee_core_info_id=eci.id AND jsp.domain_status_id=1 AND eci.cur_job_status_id != 3 AND date(jsp.date_created) > '2024-12-31'
    UNION
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.employee_core_info eci
    WHERE eci.cur_job_status_id = 3 AND eci.domain_status_id=1
),Final_CTE AS(
SELECT TA.id,
    ROW_NUMBER() OVER (PARTITION BY TA.employee_core_info_id, DATE(TA.official_visit_from_date) ORDER BY TA.id DESC) AS from_rn,
    ROW_NUMBER() OVER (PARTITION BY TA.employee_core_info_id, DATE(TA.official_visit_to_date) ORDER BY TA.id DESC) AS to_rn
FROM payroll_leave_attend_data.travel_application TA
INNER JOIN payroll_emp_data.employee_core_info ECI ON TA.employee_core_info_id = ECI.id
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON ECI.pin_no = ER.pin
INNER JOIN BASE_CTE B ON ECI.id = B.Employee_ID
INNER JOIN public.integ_employee_imp IEI ON ECI.pin_no = IEI.employee_code
WHERE TA.domain_status_id = 1
AND EXTRACT('YEAR' FROM TA.official_visit_to_date) >= 2025 AND TA.status_id not in (2, 3, 5, 8)
)
SELECT
    gen_random_uuid()::uuid AS id
    , 0::integer AS version
    , '1'::varchar AS created_by
    , NOW()::timestamp with time zone AS created_date
    , '1'::varchar AS last_modified_by
    , NOW()::timestamp with time zone AS last_modified_date,
    NULL AS doc_no,
    TA.date_created::timestamp AS doc_date,
    ECI.pin_no::varchar AS employee_code,
    IEI.operating_location_code::varchar AS oper_location_code,
    20::INTEGER AS work_away_type,
    TA.destination::varchar AS work_address,
    --TA.purpose_of_travel::varchar AS deliverables,
    NULL::varchar AS deliverables,
    20::INTEGER AS destination_type,
    NULL AS visit_start_time,
    NULL AS visit_end_time
FROM payroll_leave_attend_data.travel_application TA
INNER JOIN payroll_emp_data.employee_core_info ECI ON TA.employee_core_info_id = ECI.id
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON ECI.pin_no = ER.pin
INNER JOIN BASE_CTE B ON ECI.id = B.Employee_ID
--INNER JOIN public.mdg_empl_profile IEI ON ECI.pin_no = IEI.employee_code
INNER JOIN public.integ_employee_imp IEI ON ECI.pin_no = IEI.employee_code
LEFT JOIN Final_CTE F ON TA.id = F.id AND (F.from_rn >= 2 OR F.to_rn >=2)
WHERE F.id IS NULL AND TA.domain_status_id = 1
  AND EXTRACT('YEAR' FROM TA.official_visit_to_date) >= 2025 AND TA.status_id not in (2, 3, 5, 8);


---------------------------------- INTEG_INTERNATIONAL_TRAVEL_LINE_IMP ----------------------------------


INSERT INTO public.integ_work_away_office_line_imp
(
    id,
    version,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    attend_date,
    work_away_office_imp_id,
    visit_location,
    weekend_or_holiday,
    working_day
)
WITH RECURSIVE
  base_app AS (
    SELECT
      TA.id,
--    ROW_NUMBER() OVER (PARTITION BY employee_core_info_id,DATE(official_visit_from_date), DATE(official_visit_to_date) ORDER BY ID DESC) AS rn
    ROW_NUMBER() OVER (PARTITION BY TA.employee_core_info_id, DATE(TA.official_visit_from_date) ORDER BY TA.id DESC) AS from_rn,
    ROW_NUMBER() OVER (PARTITION BY TA.employee_core_info_id, DATE(TA.official_visit_to_date) ORDER BY TA.id DESC) AS to_rn
    FROM payroll_leave_attend_data.travel_application TA
    INNER JOIN payroll_emp_data.employee_core_info ECI ON TA.employee_core_info_id = ECI.id
    INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON ECI.pin_no = ER.pin
    WHERE TA.domain_status_id = 1
      AND EXTRACT(YEAR FROM TA.official_visit_to_date) >= 2025
      AND TA.status_id NOT IN (2, 3, 5, 8)
  ),date_series AS(
    SELECT
      ta3.employee_core_info_id,
      ta3.official_visit_from_date,
      ta3.official_visit_to_date,
      ta3.date_created
    FROM payroll_leave_attend_data.travel_application ta3
    INNER JOIN payroll_emp_data.employee_core_info ECI ON ta3.employee_core_info_id = ECI.id
    INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON ECI.pin_no = ER.pin
    LEFT JOIN base_app ba on ta3.id = ba.id and (from_rn >= 2 or to_rn >= 2)
    WHERE ba.id IS NULL AND ta3.domain_status_id = 1
      AND EXTRACT(YEAR FROM ta3.official_visit_to_date) >= 2025
      AND ta3.status_id NOT IN (2, 3, 5, 8)
    UNION ALL
    SELECT
      ds.employee_core_info_id,
      (ds.official_visit_from_date + INTERVAL '1 day')::DATE AS travel_date,
      ds.official_visit_to_date,
      ds.date_created
    FROM date_series AS ds
    WHERE ds.official_visit_from_date < ds.official_visit_to_date
  ),BASE_CTE AS (
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.employee_information_update e
    INNER JOIN payroll_emp_data.employee_core_info eci ON e.employee_core_info_id=eci.id
    WHERE e.employee_information_update_change_type_id IN (11, 25) AND date(e.effective_date) > '2024-12-31' and e.new_value != '3' AND E.domain_status_id = 1
    UNION
    SELECT e.employee_core_info_id::BIGINT AS Employee_ID
    FROM payroll_emp_data.emp_core_info_history e
    WHERE e.value_type = 'Employee Status Change' AND date(e.create_date) > '2024-12-31'
    UNION
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.job_separation_proposal jsp
    INNER JOIN payroll_emp_data.employee_core_info eci ON jsp.employee_core_info_id=eci.id AND jsp.domain_status_id=1 AND eci.cur_job_status_id != 3 AND date(jsp.date_created) > '2024-12-31'
    UNION
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.employee_core_info eci
    WHERE eci.cur_job_status_id = 3 AND eci.domain_status_id=1
),wfa_ranked AS (
    SELECT id,doc_date,employee_code,
           ROW_NUMBER() OVER (PARTITION BY employee_code, doc_date ORDER BY id) AS rn
    FROM integ_work_away_office_imp
    WHERE work_away_type  = 20 AND destination_type = 20
),visit_ranked_Initial AS (
    SELECT TA.id, TA.employee_core_info_id AS Employee_ID,TA.official_visit_from_date,TA.official_visit_to_date,TA.date_created
           ,TA.destination,ECI.pin_no,
           ROW_NUMBER() OVER (PARTITION BY TA.employee_core_info_id,DATE(TA.date_created) ORDER BY TA.leave_taken_from_date) AS rn
    FROM payroll_leave_attend_data.travel_application TA
    INNER JOIN BASE_CTE B ON TA.employee_core_info_id = B.Employee_ID
    INNER JOIN payroll_emp_data.employee_core_info ECI ON ECI.id = TA.employee_core_info_id
    INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON ECI.pin_no = ER.pin
    WHERE TA.domain_status_id = 1
    AND EXTRACT('YEAR' FROM TA.official_visit_to_date) >= 2025 AND TA.status_id not in (2, 3, 5, 8)
),visit_ranked AS(
    SELECT id,
    ROW_NUMBER() OVER (PARTITION BY Employee_ID, DATE(official_visit_from_date) ORDER BY id DESC) AS from_rn,
    ROW_NUMBER() OVER (PARTITION BY Employee_ID, DATE(official_visit_to_date) ORDER BY id DESC) AS to_rn
    FROM visit_ranked_Initial
),Raw_Data AS(
SELECT staffpin,att_date,flag,
ROW_NUMBER() OVER(PARTITION BY staffpin,att_date ORDER BY att_date)row_num
FROM payroll_leave_attend_data.get_attendance_raw_data_with_flag
),Holiday_CTE AS(
SELECT ep.employee_code,hcd.holiday_date,
ROW_NUMBER() OVER(PARTITION BY ep.employee_code,hcd.holiday_date ORDER BY holiday_weekend)rn
FROM mdg_empl_profile ep
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON ep.employee_code = ER.pin
LEFT JOIN mdg_holiday_calendar hc on ep.holiday_calendar_id = hc.id
LEFT JOIN mdg_holiday_calendar_detail hcd on hc.id = hcd.holiday_calendar_id
),Generate_CTE AS(
SELECT
    wfa.id AS integ_work_away_office_imp,
    wfa.employee_code,
    v.official_visit_from_date::date AS from_date,
    v.official_visit_to_date::date AS to_date,
    wfa.doc_date,
    DATE(DL.official_visit_from_date) AS generate_date,
    V.destination,
    CASE WHEN HC.employee_code IS NOT NULL THEN TRUE ELSE FALSE END AS weekend_or_holiday
FROM wfa_ranked wfa
INNER JOIN visit_ranked_Initial v ON wfa.employee_code = v.pin_no
 AND DATE(wfa.doc_date) = DATE(v.date_created)
 AND wfa.rn = v.rn
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON V.pin_no = ER.pin
INNER JOIN date_series DL
    ON v.Employee_ID = DL.employee_core_info_id
    AND (DATE(DL.official_visit_from_date) >= DATE(V.official_visit_from_date)
    AND DATE(DL.official_visit_from_date) <= DATE(V.official_visit_to_date))
LEFT JOIN visit_ranked VR ON V.id = VR.id AND (VR.from_rn >= 2 OR VR.to_rn >= 2)
-- LEFT JOIN Raw_Data GAR ON V.pin_no = GAR.staffpin AND DL.official_visit_from_date = GAR.att_date AND GAR.row_num = 1
LEFT JOIN Holiday_CTE HC ON wfa.employee_code = HC.employee_code AND DATE(DL.official_visit_from_date) = DATE(HC.holiday_date) AND HC.rn = 1
WHERE VR.id IS NULL
)
SELECT
    gen_random_uuid()::uuid AS id
    , 0::integer AS version
    , '1'::varchar AS created_by
    , NOW()::timestamp with time zone AS created_date
    , '1'::varchar AS last_modified_by
    , NOW()::timestamp with time zone AS last_modified_date,
    GC.generate_date::timestamp AS attend_date,
    GC.integ_work_away_office_imp::UUID AS work_away_office_imp_id,
    GC.destination::VARCHAR AS visit_location,
    GC.weekend_or_holiday::BOOLEAN,
    CASE WHEN GC.weekend_or_holiday = TRUE THEN 0.0::DOUBLE PRECISION ELSE 1.0::DOUBLE PRECISION END AS working_day
FROM Generate_CTE GC;

--------------------------------- INTEG_WORK_AWAY_OFFICE_IMP --------------------------------------------

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
    oper_location_code,
    work_away_type,
    work_address,
    deliverables,
    destination_type,
    visit_start_time,
    visit_end_time
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
),Final_CTE AS(
SELECT VM.id,
    ROW_NUMBER() OVER (PARTITION BY VM.employee_id, DATE(VM.from_date_time) ORDER BY recon_status DESC, VM.id DESC) AS from_rn,
    ROW_NUMBER() OVER (PARTITION BY VM.employee_id, DATE(VM.to_date_time) ORDER BY recon_status DESC, VM.id DESC) AS to_rn
FROM payroll_leave_attend_data.visit_master VM
INNER JOIN payroll_emp_data.users U ON VM.employee_id = U.id
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
WHERE EXTRACT('YEAR' FROM VM.to_date_time) >= 2025
  AND VM.duration > 0
  AND VM.leavetype_id = 25 AND VM.status = 1 AND VM.is_deleted <> 1 AND VM.is_manual = 0
AND VM.approval_action_time < '2025-06-02 21:00:00.000000'
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
    IEI.operating_location_code::varchar AS oper_location_code,
    10::INTEGER AS work_away_type,
    VM.movement_place::varchar AS work_address,
    --VM.purpose::varchar AS deliverables,
    NULL::varchar AS deliverables,
    10::INTEGER AS destination_type,
    NULL AS visit_start_time,
    NULL AS visit_end_time
FROM payroll_leave_attend_data.visit_master VM
INNER JOIN payroll_emp_data.users U ON VM.employee_id = U.id
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
INNER JOIN BASE_CTE B ON U.pin = B.pin
--INNER JOIN public.mdg_empl_profile IEI ON U.pin = IEI.employee_code
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
LEFT JOIN Final_CTE F ON VM.id =  F.id AND (F.from_rn >=2 OR F.to_rn >= 2)
WHERE F.id IS NULL AND EXTRACT('YEAR' FROM VM.to_date_time) >= 2025
  AND VM.duration > 0
  AND VM.leavetype_id = 25 AND VM.status = 1 AND VM.is_deleted <> 1 AND VM.is_manual = 0
AND VM.approval_action_time < '2025-06-02 21:00:00.000000';

-------------------------------- INTEG_WORK_AWAY_OFFICE_LINE_IMP ----------------------------------------

INSERT INTO public.integ_work_away_office_line_imp
(
    id,
    version,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    attend_date,
    work_away_office_imp_id,
    visit_location,
    weekend_or_holiday,
    working_day
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
),wfa_ranked AS (
    SELECT id,doc_date,employee_code,
    ROW_NUMBER() OVER (PARTITION BY employee_code, doc_date ORDER BY id) AS rn
    FROM integ_work_away_office_imp
    WHERE destination_type = 10 AND work_away_type = 10
),Final_CTE AS(
SELECT VM.id,
    ROW_NUMBER() OVER (PARTITION BY VM.employee_id, DATE(VM.from_date_time) ORDER BY VM.recon_status DESC, VM.id DESC) AS from_rn,
    ROW_NUMBER() OVER (PARTITION BY VM.employee_id, DATE(VM.to_date_time) ORDER BY VM.recon_status DESC, VM.id DESC) AS to_rn
FROM payroll_leave_attend_data.visit_master VM
INNER JOIN payroll_emp_data.users U ON VM.employee_id = U.id
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
WHERE VM.leavetype_id = 25
  AND EXTRACT('YEAR' FROM VM.to_date_time) >= 2025
  AND VM.duration > 0
  AND VM.status = 1 AND VM.is_deleted <> 1 AND VM.is_manual = 0
AND VM.approval_action_time < '2025-06-02 21:00:00.000000'
),visit_ranked AS (
    SELECT V.employee_id,U.pin,V.from_date_time,V.to_date_time,V.application_date,V.movement_place,
    ROW_NUMBER() OVER (PARTITION BY V.employee_id, V.application_date ORDER BY V.from_date_time) AS rn
    FROM payroll_leave_attend_data.visit_master V
INNER JOIN payroll_emp_data.users U ON V.employee_id = U.id
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code
LEFT JOIN Final_CTE F ON V.id = F.id AND (F.from_rn >= 2 OR F.to_rn >= 2)
WHERE F.id IS NULL AND V.leavetype_id = 25
  AND EXTRACT('YEAR' FROM V.to_date_time) >= 2025
  AND V.duration > 0
  AND V.status = 1 AND V.is_deleted <> 1 AND V.is_manual = 0
AND V.approval_action_time < '2025-06-02 21:00:00.000000'
),Generate_CTE_Initial AS(
SELECT DL.pin, DL.generate_date,DL.application_type,DL.flag
,ROW_NUMBER() OVER(PARTITION BY DL.pin,DATE(DL.generate_date) ORDER BY DL.generate_date)row_num
FROM payroll_leave_attend_data.get_day_wise_lv_visit_wfa DL
WHERE DL.application_type = 'Work From Anywhere'
),Generate_CTE AS(
SELECT
    wfa.id AS integ_work_away_office_imp,
    DATE(DL.generate_date) AS generate_date,
    V.movement_place,
    CASE WHEN DL.flag IN('W','N') THEN TRUE ELSE FALSE END AS weekend_or_holiday
FROM wfa_ranked wfa
INNER JOIN visit_ranked v ON wfa.employee_code = v.Pin
 AND DATE(wfa.doc_date) = DATE(v.application_date)
 AND wfa.rn = v.rn
INNER JOIN Generate_CTE_Initial DL
    ON v.Pin = DL.pin
    AND (DATE(DL.generate_date) >= DATE(V.from_date_time)
    AND DATE(DL.generate_date) <= DATE(V.to_date_time)) AND DL.row_num = 1
)
SELECT
    gen_random_uuid()::uuid AS id
    , 0::integer AS version
    , '1'::varchar AS created_by
    , NOW()::timestamp with time zone AS created_date
    , '1'::varchar AS last_modified_by
    , NOW()::timestamp with time zone AS last_modified_date,
    GC.generate_date::timestamp AS attend_date,
    GC.integ_work_away_office_imp::UUID AS work_away_office_imp_id,
    GC.movement_place::varchar AS visit_location,
    GC.weekend_or_holiday::BOOLEAN,
    CASE WHEN GC.weekend_or_holiday = TRUE THEN 0.0::DOUBLE PRECISION ELSE 1.0::DOUBLE PRECISION END AS working_day
FROM Generate_CTE GC;

-------------------------------- HR_ATTEND_SUMMARY_DAILY -----------------------------------------------

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
    work_shift_rotated,
    attendance_day_type
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
),Holiday_CTE AS(
SELECT ep.employee_code,hcd.holiday_date,
CASE WHEN HCD.holiday_weekend = 10 THEN 'H' WHEN HCD.holiday_weekend = 20 THEN 'W' END AS Holly_Week,
ROW_NUMBER() OVER(PARTITION BY ep.employee_code,hcd.holiday_date ORDER BY holiday_weekend)rn
FROM mdg_empl_profile ep
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON ep.employee_code = ER.pin
LEFT JOIN mdg_holiday_calendar hc on ep.holiday_calendar_id = hc.id
LEFT JOIN mdg_holiday_calendar_detail hcd on hc.id = hcd.holiday_calendar_id
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
    CONCAT(GA.att_date::DATE,' ',COALESCE(GA.intime::VARCHAR,'00:00:00.000000')::TIME)::timestamp AS entry_date,
    CONCAT(GA.att_date::DATE,' ',COALESCE(GA.outtime::VARCHAR,'00:00:00.000000')::TIME)::timestamp AS exit_date,
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
    NULL AS work_shift_rotated,
    CASE WHEN HC.employee_code IS NOT NULL AND HC.Holly_Week = 'H' AND IEI.work_shift_rotated = FALSE THEN 20
    WHEN HC.employee_code IS NOT NULL AND HC.Holly_Week = 'W' AND IEI.work_shift_rotated = FALSE THEN 30
    WHEN IEI.work_shift_rotated = TRUE AND GA.flag = 'W' THEN 30
    WHEN IEI.work_shift_rotated = TRUE AND GA.flag = 'H' THEN 20
    WHEN GA.flag IN ('L','Y','F','M','U','J','K','B','C') THEN 40
    ELSE 10 END AS attendance_day_type
FROM payroll_leave_attend_data.get_attendance_raw_data_with_flag GA
INNER JOIN public.mdg_empl_profile IEI ON GA.staffpin = IEI.employee_code
INNER JOIN payroll_emp_data.users U ON GA.staffpin = U.pin
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
INNER JOIN BASE_CTE B ON U.pin = B.pin
LEFT JOIN payroll_emp_data.employeewiseattendancepolicymapping EAM ON U.id = EAM.employee_id
LEFT JOIN Holiday_CTE HC ON GA.staffpin = HC.employee_code AND DATE(GA.att_date) = HC.holiday_date AND HC.rn = 1
--LEFT JOIN public.mdg_empl_profile M ON IEI.id = M.id
WHERE GA.flag <> '-' AND EXTRACT('YEAR' FROM GA.att_date) >= 2025;


-------------------------------- UPDATE hr_attend_summary_daily ----------------------------------------

UPDATE hr_attend_summary_daily H
SET work_shift_id = M.work_shift_id
  ,work_shift_rotated = M.work_shift_rotated
  ,holiday_calendar_id = M.holiday_calendar_id
  ,attend_tracking_type = M.attend_tracking_type
FROM mdg_empl_profile M
WHERE H.employee_profile_id = M.id

------------------------------- UPDATE attendance_day_type ---------------------------------------------


UPDATE hr_attend_summary_daily
SET attendance_day_type = 10
WHERE atten_date IN ('2025-05-17','2025-05-24')

------------------------------- INTEG_ATTEND_MISSED_APP_IMP (Attendance reconcilation applications) ----


INSERT INTO public.integ_attend_missed_app_imp
(
    id,
    atten_miss_entry_no,
    appl_date,
    employee_code,
    atten_date,
    in_time,
    out_time,
    workshift_code,
    out_date
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
    EAM.policyid::VARCHAR AS workshift_code,
    AR.daily_out_time::DATE AS out_date
FROM payroll_leave_attend_data.attendance_reconciliation AR
INNER JOIN payroll_emp_data.users U ON AR.employee_id = U.id
INNER JOIN payroll_leave_attend_data.employee_records_beta_30 ER ON U.pin = ER.pin
INNER JOIN BASE_CTE B ON U.pin = B.pin
INNER JOIN payroll_emp_data.employee_core_info ECI ON U.pin = ECI.pin_no
INNER JOIN payroll_emp_data.employeewiseattendancepolicymapping EAM ON U.id = EAM.employee_id
INNER JOIN public.integ_employee_imp IEI ON U.pin = IEI.employee_code;



