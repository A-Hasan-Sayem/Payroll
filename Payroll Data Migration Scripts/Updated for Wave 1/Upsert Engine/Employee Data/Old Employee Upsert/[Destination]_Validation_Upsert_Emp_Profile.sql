select count(1) from cdc.mdg_empl_profile where version=2;
select count(1) from cdc.mdg_empl_profile where date(last_modified_date) > '2025-05-30';
select count(1) from cdc.mdg_empl_profile where date(created_date) > '2025-05-30';
select distinct created_date from cdc.mdg_empl_profile;
select count(1) from cdc.integ_separation_imp where version=2;


-- Step 1: Validate Inserts and Updates in mdg_empl_profile
-- Check if any new records were inserted into mdg_empl_profile by comparing employee_code from the staging data
SELECT
    COUNT(*) AS new_inserted_records
FROM cdc.mdg_empl_profile mp
INNER JOIN cdc.emp_upsert_staging e
    ON mp.employee_code = e.employee_code
WHERE e.last_modified_date > '2025-05-29'
    AND mp.created_date = e.created_date;

-- Step 2: Validate Updates in mdg_empl_profile
-- Check if any records were updated in mdg_empl_profile (matching employee_code and checking for recent changes)
SELECT
    COUNT(*) AS updated_records
FROM cdc.mdg_empl_profile mp
INNER JOIN cdc.emp_upsert_staging e ON mp.employee_code = e.employee_code
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
    AND (
        -- Ensure last_modified_date is different (indicating update)
        mp.last_modified_date <> e.last_modified_date
        OR mp.first_name <> e.first_name    -- Check for first_name change
        OR mp.middle_name <> e.middle_name  -- Check for middle_name change
        OR mp.last_name <> e.last_name      -- Check for last_name change
        OR mp.father_name <> e.father_name  -- Check for father_name change
        OR mp.mother_name <> e.mother_name  -- Check for mother_name change
        OR mp.national_id <> e.national_id  -- Check for national_id change
        OR mp.join_date_actual <> e.join_date_actual  -- Check for join_date_actual change
        OR mp.confirmation_date <> e.confirmation_date  -- Check for confirmation_date change
        OR mp.contract_end_date <> e.contract_end_date  -- Check for contract_end_date change
        OR mp.email_company <> e.email_company  -- Check for email_company change
        OR mp.current_address <> e.current_address  -- Check for current_address change
        OR mp.permanent_address <> e.permanent_address  -- Check for permanent_address change
        OR mp.birth_date <> e.birth_date  -- Check for birth_date change
        OR mp.gross_salary <> e.gross_salary  -- Check for gross_salary change
        OR mp.bonus_entitlement_status <> e.bonus_entitlement_status  -- Check for bonus_entitlement_status change
        OR mp.bank_branch_name <> e.bank_branch_name  -- Check for bank_branch_name change
        OR mp.gender <> e.gender  -- Check for gender change
        OR mp.company_id <> dc.company_id  -- Check for company_id change
        OR mp.department_id <> sec.department_id  -- Check for department_id change
        OR mp.operating_location_id <> ol.id  -- Check for operating_location_id change
        OR mp.functional_area_id <> dept.functional_area_id  -- Check for functional_area_id change
        OR mp.designation_id <> desg.id  -- Check for designation_id change
        OR mp.workflow_group_id <> ec.workflow_group_id  -- Check for workflow_group_id change
        OR mp.empl_type <> ec.empl_type  -- Check for empl_type change
        OR mp.name <> CONCAT(
            COALESCE(e.first_name, ''), ' ',
            COALESCE(e.middle_name, ''), ' ',
            COALESCE(e.last_name, '')
        )  -- Check for name change (combination of first_name, middle_name, last_name)
        OR mp.probation_period_months <> COALESCE(ec.prob_period_perm_empl, 0)  -- Check for probation_period_months change
        OR mp.confirmation_due_date <> (CASE
            WHEN e.join_date_actual IS NOT NULL
            THEN e.join_date_actual + INTERVAL '1 month' * ec.prob_period_perm_empl
            ELSE e.join_date_actual
        END)  -- Check for confirmation_due_date change
        OR mp.employment_status <> esm.employment_status  -- Check for employment_status change
        OR mp.work_shift_id <> ws.id  -- Check for work_shift_id change
        OR mp.religion_id <> rel.id  -- Check for religion_id change
        OR mp.empl_category_id <> ec.id  -- Check for empl_category_id change
        OR mp.phone_home <> e.phone_home  -- Check for phone_home change
        OR mp.phone_mobile <> e.phone_mobile  -- Check for phone_mobile change
        OR mp.phone_work_direct <> e.phone_work_direct  -- Check for phone_work_direct change
        OR mp.empl_grade_id <> gr.id  -- Check for empl_grade_id change
        OR mp.empl_grade_sub_id <> grs.id  -- Check for empl_grade_sub_id change
    );

-- Step 3: Validate Missing or Duplicate Employee Records in mdg_empl_profile
-- Check if there are missing or duplicated employee codes (should be unique)
SELECT
    employee_code,
    COUNT(*) AS duplicate_count
FROM cdc.mdg_empl_profile
GROUP BY employee_code
HAVING COUNT(*) > 1;

-- Step 4: Validate Inserts and Updates in integ_separation_imp
-- Check if new separation records were inserted into the integ_separation_imp table
SELECT
    COUNT(*) AS new_separation_records
FROM cdc.integ_separation_imp si
JOIN cdc.emp_upsert_staging e
    ON si.employee_code = e.employee_code
WHERE e.last_modified_date > '2025-05-29'
    AND si.created_date = e.created_date;

-- Step 5: Validate Updates in integ_separation_imp
-- Check if any separation records were updated
-- SELECT
--     COUNT(*) AS updated_separation_records
-- FROM cdc.integ_separation_imp si
-- INNER JOIN cdc.emp_upsert_staging e ON si.employee_code = e.employee_code
-- INNER JOIN public.integ_separation_type_map stm ON e.employee_job_status = stm.sep_type_code
-- WHERE e.last_modified_date > '2025-05-29' and e.last_working_day IS NOT NULL
--     AND (
--         si.last_modified_date <> e.last_modified_date  -- Ensure last_modified_date is different (indicating update)
--         OR si.separation_type_code <> stm.separation_type  -- Check if separation type is changed
--         OR si.effective_date <> (e.last_working_day + INTERVAL '1 day')
--         OR si.acceptance_date <> (e.last_working_day + INTERVAL '1 day')
--     );

-- Step 6: Check for missing or duplicate separation records
-- Ensure that no duplicate or missing separation records exist
SELECT
    employee_code,
    COUNT(*) AS duplicate_separation_count
FROM cdc.integ_separation_imp
GROUP BY employee_code
HAVING COUNT(*) > 1;

-- Step 7: Check for consistency in manager_id assignment in mdg_empl_profile
-- Ensure that manager_id was updated correctly for employees where supervisor_empl_code is available
-- SELECT
--     COUNT(*) AS manager_updates
-- FROM cdc.mdg_empl_profile e
-- INNER JOIN cdc.emp_upsert_staging s
--     ON e.employee_code = s.employee_code
-- WHERE s.last_modified_date > '2025-05-29'
--     AND e.manager_id IS DISTINCT FROM (
--         SELECT m.id
--         FROM cdc.mdg_empl_profile m
--         WHERE m.employee_code = s.supervisor_empl_code
--     );

--
select count(1) from cdc.chk_for_updates_on_mdg where manager_id is not null;