-- Update existing records and insert new records into mdg_empl_profile and integ_separation_imp
INSERT INTO cdc.mdg_empl_profile (
    id, dtype, version, created_by, created_date, last_modified_by, last_modified_date, empl_number, employee_code, attend_card_id, first_name,middle_name, last_name, father_name, mother_name, national_id, join_date_actual, confirmation_date,contract_end_date, email_company, current_address, permanent_address, birth_date, gross_salary, salary_amount,
    bonus_entitlement_status, bank_branch_name, gender, tax_salary_circle, tax_identification_no, company_id,
    department_id, operating_location_id, functional_area_id, designation_id, workflow_group_id, empl_type,
    name, probation_period_months, confirmation_due_date,
    pr_payment_method_id, pr_payment_method_sec_id, nationality_id, current_country_id, permanent_country_id,
    employment_status, work_shift_id, religion_id, work_shift_rotated, pay_overtime, attend_tracking_type,
    empl_category_id, pay_type, payscale_or_paystructure, pay_period, salary_amt_period, basic_salary,
    salary_ready_for_app, salary_approved, with_hold_salary, schedule_work_calendar, temp_separated, tax_resident,
    job_offered, phone_home, phone_mobile, phone_work_direct, empl_grade_id, empl_grade_sub_id
)
WITH updated_data AS (
    SELECT
        e.id,
        'hr_EmployeeProfile' AS dtype,
        2 AS version,
        e.created_by,
        e.created_date,
        e.last_modified_by,
        e.last_modified_date,
        e.employee_code,
        NULL as attend_card_id,
        e.employee_code AS empl_number,
        e.first_name,
        e.middle_name,
        e.last_name,
        e.father_name,
        e.mother_name,
        e.national_id,
        e.join_date_actual,
        e.confirmation_date,
        e.contract_end_date,
        e.email_company,
        e.current_address,
        e.permanent_address,
        e.birth_date,
        CASE WHEN e.gross_salary IS NULL THEN 0 ELSE e.gross_salary END AS gross_salary,
        e.gross_salary AS salary_amount,
        e.bonus_entitlement_status,
        e.bank_branch_name,
        CASE e.gender
            WHEN 'Male' THEN 10
            WHEN 'Female' THEN 20
            ELSE 30
        END AS gender,
        NULL as tax_salary_circle,
        NULL as tax_identification_no,
        e.salary_circle,
        dc.company_id,
        sec.department_id,
        ol.id AS operating_location_id,
        dept.functional_area_id,
        desg.id AS designation_id,
        ec.workflow_group_id,
        ec.empl_type,
        CONCAT(
            COALESCE(e.first_name, ''), ' ',
            COALESCE(e.middle_name, ''), ' ',
            COALESCE(e.last_name, '')
        ) AS name,
        COALESCE(ec.prob_period_perm_empl, 0) AS probation_period_months,
        CASE
            WHEN e.join_date_actual IS NOT NULL
            THEN e.join_date_actual + INTERVAL '1 month' * ec.prob_period_perm_empl
            ELSE e.join_date_actual
        END AS confirmation_due_date,
        '23710db3-27c4-d754-e065-7f74e2a693e6'::uuid AS pr_payment_method_id,
        '6e60ffde-871c-4443-7e57-09e0344f2154'::uuid AS pr_payment_method_sec_id,
        '4a7b49c1-173c-5794-f4a1-a5e0649ac658'::uuid AS nationality_id,
        '4a7b49c1-173c-5794-f4a1-a5e0649ac658'::uuid AS current_country_id,
        '4a7b49c1-173c-5794-f4a1-a5e0649ac658'::uuid AS permanent_country_id,
        esm.employment_status,
        ws.id AS work_shift_id,
        rel.id AS religion_id,
        FALSE AS work_shift_rotated,
        FALSE AS pay_overtime,
        20 AS attend_tracking_type,
        ec.id AS empl_category_id,
        10 AS pay_type,
        10 AS payscale_or_paystructure,
        10 AS pay_period,
        10 AS salary_amt_period,
        0 AS basic_salary,
        FALSE AS salary_ready_for_app,
        FALSE AS salary_approved,
        FALSE AS with_hold_salary,
        FALSE AS schedule_work_calendar,
        FALSE AS temp_separated,
        TRUE AS tax_resident,
        TRUE AS job_offered,
        e.phone_home,
        e.phone_mobile,
        e.phone_work_direct,
        gr.id AS empl_grade_id,
        grs.id AS empl_grade_sub_id
    FROM
        cdc.emp_upsert_staging e
    LEFT JOIN public.mdg_dept_section sec ON e.section_code = sec.sec_code
    LEFT JOIN public.mdg_operating_location ol ON e.operating_location_code = ol.oper_loc_code
    LEFT JOIN public.mdg_department dept ON sec.department_id = dept.id
    LEFT JOIN public.mdg_department_comp dc ON dc.department_id = dept.id
    LEFT JOIN public.hmd_empl_category ec ON e.empl_category_code = ec.empl_category_code
    LEFT JOIN public.hmd_designation desg ON e.designation_code = desg.code
    LEFT JOIN public.INTEG_EMPLOYMENT_STATUS_MAP esm ON e.employee_job_status = esm.status_code
    LEFT JOIN public.MDG_WORK_SHIFT ws ON e.work_shift_code = ws.shift_code
    LEFT JOIN public.MDG_RELIGION rel ON e.religion = rel.religion_code
    LEFT JOIN public.mdg_job_grade g ON e.grade_code = g.grade_code
    LEFT JOIN public.mdg_empl_job_grade gr ON gr.job_grade_id = g.id
    LEFT JOIN public.hmd_empl_grade_sub grs ON e.grade_sub_code = grs.sub_code AND gr.id = grs.empl_grade_id
    WHERE e.last_modified_date > '2025-05-29' and (gr.salary_band_type=10 or gr.salary_band_type is null)
)
SELECT
    id, dtype, version, created_by, created_date, last_modified_by, last_modified_date, empl_number, employee_code, attend_card_id, first_name,
    middle_name, last_name, father_name, mother_name, national_id, join_date_actual, confirmation_date,
    contract_end_date, email_company, current_address, permanent_address, birth_date, gross_salary, salary_amount,
    bonus_entitlement_status, bank_branch_name, gender, tax_salary_circle, tax_identification_no, company_id,
    department_id, operating_location_id, functional_area_id, designation_id, workflow_group_id, empl_type,
    name, probation_period_months, confirmation_due_date,
    pr_payment_method_id, pr_payment_method_sec_id, nationality_id, current_country_id, permanent_country_id,
    employment_status, work_shift_id, religion_id, work_shift_rotated, pay_overtime, attend_tracking_type,
    empl_category_id, pay_type, payscale_or_paystructure, pay_period, salary_amt_period, basic_salary,
    salary_ready_for_app, salary_approved, with_hold_salary, schedule_work_calendar, temp_separated, tax_resident,
    job_offered, phone_home, phone_mobile, phone_work_direct, empl_grade_id, empl_grade_sub_id
FROM updated_data
ON CONFLICT (employee_code) DO UPDATE
SET
    version = excluded.version,
    last_modified_by = EXCLUDED.last_modified_by,
    last_modified_date = EXCLUDED.last_modified_date,
    empl_number = EXCLUDED.empl_number,
    first_name = EXCLUDED.first_name,
    middle_name = EXCLUDED.middle_name,
    last_name = EXCLUDED.last_name,
    father_name = EXCLUDED.father_name,
    mother_name = EXCLUDED.mother_name,
    national_id = EXCLUDED.national_id,
    join_date_actual = EXCLUDED.join_date_actual,
    confirmation_date = EXCLUDED.confirmation_date,
    contract_end_date = EXCLUDED.contract_end_date,
    email_company = EXCLUDED.email_company,
    current_address = EXCLUDED.current_address,
    permanent_address = EXCLUDED.permanent_address,
    birth_date = EXCLUDED.birth_date,
    gross_salary = EXCLUDED.gross_salary,
    salary_amount = EXCLUDED.salary_amount,
    bonus_entitlement_status = EXCLUDED.bonus_entitlement_status,
    bank_branch_name = EXCLUDED.bank_branch_name,
    gender = EXCLUDED.gender,
    tax_salary_circle = EXCLUDED.tax_salary_circle,
    company_id = EXCLUDED.company_id,
    department_id = EXCLUDED.department_id,
    operating_location_id = EXCLUDED.operating_location_id,
    functional_area_id = EXCLUDED.functional_area_id,
    designation_id = EXCLUDED.designation_id,
    workflow_group_id = EXCLUDED.workflow_group_id,
    empl_type = EXCLUDED.empl_type,
    name = EXCLUDED.name,
    probation_period_months = EXCLUDED.probation_period_months,
    confirmation_due_date = EXCLUDED.confirmation_due_date,
    pr_payment_method_id = EXCLUDED.pr_payment_method_id,
    pr_payment_method_sec_id = EXCLUDED.pr_payment_method_sec_id,
    nationality_id = EXCLUDED.nationality_id,
    current_country_id = EXCLUDED.current_country_id,
    permanent_country_id = EXCLUDED.permanent_country_id,
    employment_status = EXCLUDED.employment_status,
    work_shift_id = EXCLUDED.work_shift_id,
    religion_id = EXCLUDED.religion_id,
    work_shift_rotated = EXCLUDED.work_shift_rotated,
    pay_overtime = EXCLUDED.pay_overtime,
    attend_tracking_type = EXCLUDED.attend_tracking_type,
    empl_category_id = EXCLUDED.empl_category_id,
    pay_type = EXCLUDED.pay_type,
    payscale_or_paystructure = EXCLUDED.payscale_or_paystructure,
    pay_period = EXCLUDED.pay_period,
    salary_amt_period = EXCLUDED.salary_amt_period,
    basic_salary = EXCLUDED.basic_salary,
    salary_ready_for_app = EXCLUDED.salary_ready_for_app,
    salary_approved = EXCLUDED.salary_approved,
    with_hold_salary = EXCLUDED.with_hold_salary,
    schedule_work_calendar = EXCLUDED.schedule_work_calendar,
    temp_separated = EXCLUDED.temp_separated,
    tax_resident = EXCLUDED.tax_resident,
    job_offered = EXCLUDED.job_offered,
    phone_home = EXCLUDED.phone_home,
    phone_mobile = EXCLUDED.phone_mobile,
    phone_work_direct = EXCLUDED.phone_work_direct,
    empl_grade_id = EXCLUDED.empl_grade_id,
    empl_grade_sub_id = EXCLUDED.empl_grade_sub_id;


-- Updating the manager_id for the staging table's records only
WITH manager_update AS (
    SELECT
        e.employee_code,
        e.supervisor_empl_code
    FROM cdc.emp_upsert_staging e
    WHERE e.last_modified_date > '2025-05-29'
)
UPDATE cdc.mdg_empl_profile e
SET manager_id = m.id,
    version = 2
FROM manager_update mu
LEFT JOIN cdc.mdg_empl_profile m
    ON mu.supervisor_empl_code = m.employee_code
WHERE e.employee_code = mu.employee_code;


-- Upsert Separation Data (integ_separation_imp table)
WITH valid_source AS (
    SELECT
        e.employee_code,
        e.last_working_day,
        stm.separation_type,
        e.created_by,
        e.created_date,
        e.last_modified_by,
        e.last_modified_date
    FROM cdc.emp_upsert_staging e
    JOIN public.integ_separation_type_map stm
        ON e.employee_job_status = stm.sep_type_code
    WHERE e.last_working_day IS NOT NULL
)
INSERT INTO cdc.integ_separation_imp (
    id, version, created_by, created_date, last_modified_by, last_modified_date, separation_doc_date,
    employee_code, separation_type_code, effective_date, acceptance_date
)
SELECT
    gen_random_uuid(),
    2,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    now(),
    employee_code,
    separation_type,
    last_working_day + INTERVAL '1 day',
    last_working_day + INTERVAL '1 day'
FROM valid_source
ON CONFLICT (employee_code) DO UPDATE
SET
    version = excluded.version,
    last_modified_by = excluded.last_modified_by,
    last_modified_date = excluded.last_modified_date,
    separation_type_code = EXCLUDED.separation_type_code,
    effective_date = EXCLUDED.effective_date,
    acceptance_date = EXCLUDED.acceptance_date,
    separation_doc_date = EXCLUDED.separation_doc_date;




select count(1) from cdc.mdg_empl_profile where version=2;
select count(1) from cdc.mdg_empl_profile where date(last_modified_date) > '2025-05-30';
select count(1) from cdc.mdg_empl_profile where date(created_date) > '2025-05-30';
select distinct created_date from cdc.mdg_empl_profile;
select count(1) from cdc.integ_separation_imp where version=2;