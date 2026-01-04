-------------------------------------------------------Checking inserts and updates--------------------------------------------------------------
SELECT
    n.id,
    n.first_name,
    n.middle_name,
    n.last_name,
    n.national_id,
    n.join_date_actual,
    n.confirmation_date,
    n.contract_end_date,
    n.email_company,
    n.current_address,
    n.permanent_address,
    n.birth_date,
    n.gender,
    n.tin_no,
    n.supervisor_empl_code,
    n.religion,
    n.grade_code,
    n.grade_sub_code,
    n.section_code,
    n.empl_category_code,
    n.operating_location_code,
    n.designation_code,
    n.phone_work_direct,
    CASE
        WHEN o.id IS NULL THEN 'Insert'
        WHEN
            n.first_name IS DISTINCT FROM o.first_name
            OR n.middle_name IS DISTINCT FROM o.middle_name
            OR n.last_name IS DISTINCT FROM o.last_name
            OR n.national_id IS DISTINCT FROM o.national_id
            OR n.join_date_actual IS DISTINCT FROM o.join_date_actual
            OR n.confirmation_date IS DISTINCT FROM o.confirmation_date
            OR n.contract_end_date IS DISTINCT FROM o.contract_end_date
            OR n.email_company IS DISTINCT FROM o.email_company
            OR n.current_address IS DISTINCT FROM o.current_address
            OR n.permanent_address IS DISTINCT FROM o.permanent_address
            OR n.birth_date IS DISTINCT FROM o.birth_date
            OR n.gender IS DISTINCT FROM o.gender
            OR n.tin_no IS DISTINCT FROM o.tin_no
            OR n.supervisor_empl_code IS DISTINCT FROM o.supervisor_empl_code
            OR n.religion IS DISTINCT FROM o.religion
            OR n.grade_code IS DISTINCT FROM o.grade_code
            OR n.grade_sub_code IS DISTINCT FROM o.grade_sub_code
            OR n.section_code IS DISTINCT FROM o.section_code
            OR n.empl_category_code IS DISTINCT FROM o.empl_category_code
            OR n.operating_location_code IS DISTINCT FROM o.operating_location_code
            OR n.designation_code IS DISTINCT FROM o.designation_code
            OR n.phone_work_direct IS DISTINCT FROM o.phone_work_direct
        THEN 'Update'
    END AS FLAG
FROM cdc.integ_employee_imp n
LEFT JOIN public.integ_employee_imp o
    ON n.id = o.id
WHERE
    o.id IS NULL
    OR n.first_name IS DISTINCT FROM o.first_name
    OR n.middle_name IS DISTINCT FROM o.middle_name
    OR n.last_name IS DISTINCT FROM o.last_name
    OR n.national_id IS DISTINCT FROM o.national_id
    OR n.join_date_actual IS DISTINCT FROM o.join_date_actual
    OR n.confirmation_date IS DISTINCT FROM o.confirmation_date
    OR n.contract_end_date IS DISTINCT FROM o.contract_end_date
    OR n.email_company IS DISTINCT FROM o.email_company
    OR n.current_address IS DISTINCT FROM o.current_address
    OR n.permanent_address IS DISTINCT FROM o.permanent_address
    OR n.birth_date IS DISTINCT FROM o.birth_date
    OR n.gender IS DISTINCT FROM o.gender
    OR n.tin_no IS DISTINCT FROM o.tin_no
    OR n.supervisor_empl_code IS DISTINCT FROM o.supervisor_empl_code
    OR n.religion IS DISTINCT FROM o.religion
    OR n.grade_code IS DISTINCT FROM o.grade_code
    OR n.grade_sub_code IS DISTINCT FROM o.grade_sub_code
    OR n.section_code IS DISTINCT FROM o.section_code
    OR n.empl_category_code IS DISTINCT FROM o.empl_category_code
    OR n.operating_location_code IS DISTINCT FROM o.operating_location_code
    OR n.designation_code IS DISTINCT FROM o.designation_code
    OR n.phone_work_direct IS DISTINCT FROM o.phone_work_direct;



---------------------------------------------------Creating a copy of main table for reference---------------------------------------------------

create table cdc.mdg_empl_profile_old as select * from public.mdg_empl_profile;


------------------------------------------------------ Updating UUID ----------------------------------------------------------------------------

UPDATE cdc.integ_employee_imp i
SET id = h.id
FROM public.mdg_empl_profile h
WHERE i.employee_code = h.employee_code;


------------------------------------------------------------ Upsert Engine ----------------------------------------------------------------------

INSERT INTO public.mdg_empl_profile (
	        id, dtype, version, created_by, created_date, empl_number, employee_code, attend_card_id, first_name,
	        middle_name, last_name, father_name, mother_name, national_id, join_date_actual, confirmation_date,
	        contract_end_date, email_company, current_address, permanent_address, birth_date,
	        gross_salary, salary_amount, bonus_entitlement_status, bank_branch_name, gender, tax_identification_no,
	        tax_salary_circle, company_id, department_id, operating_location_id, functional_area_id, designation_id,
	        workflow_group_id, empl_type, name, probation_period_months, confirmation_due_date,

            pr_payment_method_id,pr_payment_method_sec_id, nationality_id, current_country_id,
            permanent_country_id,employment_status, work_shift_id, religion_id, work_shift_rotated, pay_overtime, attend_tracking_type,
            empl_category_id, pay_type, payscale_or_paystructure, pay_period, salary_amt_period, basic_salary,
            salary_ready_for_app, salary_approved, with_hold_salary, schedule_work_calendar, temp_separated, tax_resident,
            job_offered, phone_home, phone_mobile, phone_work_direct,empl_grade_id, empl_grade_sub_id,manager_id, section_id

            ,email_personal,marital_status,bank_account,permanent_district_id,current_district_id,job_title
	    )
	    WITH FIRST_CTE AS(
	        SELECT *,
	               row_number() over (PARTITION BY grade_level ORDER BY name)r
	        FROM public.mdg_empl_job_grade
        ),MAIN_CTE AS(
	    SELECT
	        e.id,
	        'hr_EmployeeProfile',
	        1,
	        'CDC',
	        NOW(),
	        e.employee_code AS empl_number,
	        e.employee_code,
			e.employee_code AS attend_card_id,
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
	        e.tin_no,
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
	        ) AS employee_name,
	        COALESCE(ec.prob_period_perm_empl, 0) AS prob_period_perm_empl,
	        CASE
	            WHEN e.join_date_actual IS NOT NULL
	            THEN e.join_date_actual + INTERVAL '1 month' * ec.prob_period_perm_empl
	            ELSE e.join_date_actual
	        END AS confirmation_due_date,
	        '23710db3-27c4-d754-e065-7f74e2a693e6'::UUID AS pr_payment_method_id,
	        '6e60ffde-871c-4443-7e57-09e0344f2154'::UUID AS pr_payment_method_sec_id,
	        '4a7b49c1-173c-5794-f4a1-a5e0649ac658'::UUID AS nationality_id,
	        '4a7b49c1-173c-5794-f4a1-a5e0649ac658'::UUID AS current_country_id,
	        '4a7b49c1-173c-5794-f4a1-a5e0649ac658'::UUID AS permanent_country_id,
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
            grs.id AS empl_grade_sub_id,
            e2.id AS manager_id,
            sec.id AS section_id,
            e.email_personal,
            e.marital_status,
            e.empl_bank_account_no,
            MDT2.id AS permanent_district_id,
            MDT.id AS current_district_id,
            e.job_title
	    FROM
	        cdc.integ_employee_imp e
	    --INNER JOIN payroll_leave_attend_data.employee_records_beta_116_30 ERB ON e.employee_code = ERB.pin
	    LEFT JOIN cdc.integ_employee_imp e2 ON e.supervisor_empl_code = e2.employee_code
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
        LEFT JOIN FIRST_CTE gr ON gr.job_grade_id = g.id AND gr.r = 1
        LEFT JOIN public.hmd_empl_grade_sub grs ON e.grade_sub_code = grs.sub_code AND gr.id = grs.empl_grade_id
        LEFT JOIN public.mdg_district MDT ON e.CURRENT_District_Code = MDT.dist_code
        LEFT JOIN public.mdg_district MDT2 ON e.Permanent_District_Code = MDT2.dist_code
	    )
	    SELECT
	        id,
	        'hr_EmployeeProfile',
	        1,
	        'CDC',
	        NOW(),
	        empl_number,
	        employee_code,
			attend_card_id,
	        first_name,
	        middle_name,
	        last_name,
	        father_name,
	        mother_name,
	        national_id,
	        join_date_actual,
	        confirmation_date,
	        contract_end_date,
	        email_company,
	        current_address,
	        permanent_address,
	        birth_date,
	        gross_salary,
	        salary_amount,
	        bonus_entitlement_status,
	        bank_branch_name,
	        gender,
	        tin_no AS tax_identification_no,
	        salary_circle,
	        company_id,
	        department_id,
	        operating_location_id,
	        functional_area_id,
			designation_id,
	        workflow_group_id,
	        empl_type,
	        employee_name,
	        prob_period_perm_empl,
	        confirmation_due_date,
	        pr_payment_method_id,
	        pr_payment_method_sec_id,
	        nationality_id,
	        current_country_id,
	        permanent_country_id,
	        employment_status,
            work_shift_id,
            religion_id,
            work_shift_rotated,
            pay_overtime,
            attend_tracking_type,
            empl_category_id,
            pay_type,
            payscale_or_paystructure,
            pay_period,
            salary_amt_period,
            basic_salary,
            salary_ready_for_app,
            salary_approved,
            with_hold_salary,
            schedule_work_calendar,
            temp_separated,
            tax_resident,
            job_offered,
            phone_home,
            phone_mobile,
            phone_work_direct,
            empl_grade_id,
            empl_grade_sub_id,
            manager_id,
            section_id,
            email_personal,
            marital_status,
            empl_bank_account_no,
            permanent_district_id,
            current_district_id,
            job_title
	     FROM MAIN_CTE
	     ON CONFLICT (id) DO UPDATE
        SET
           last_modified_date = EXCLUDED.last_modified_date,
            first_name = EXCLUDED.first_name,
            middle_name = EXCLUDED.middle_name,
            last_name = EXCLUDED.last_name,
            name = EXCLUDED.name,
           father_name = EXCLUDED.father_name,
           mother_name = EXCLUDED.mother_name,
           national_id = EXCLUDED.national_id,
           join_date_actual = EXCLUDED.join_date_actual,
           contract_end_date = EXCLUDED.contract_end_date,
            email_company = EXCLUDED.email_company,
            current_address = EXCLUDED.current_address,
            permanent_address = EXCLUDED.permanent_address,
            birth_date = EXCLUDED.birth_date,
            gender = EXCLUDED.gender,
            operating_location_id = EXCLUDED.operating_location_id,
            designation_id = EXCLUDED.designation_id,
            employment_status = EXCLUDED.employment_status,
            tax_identification_no = EXCLUDED.tax_identification_no,
            manager_id = EXCLUDED.manager_id,
            religion_id = EXCLUDED.religion_id,
            phone_work_direct = EXCLUDED.phone_work_direct,
            empl_grade_id = EXCLUDED.empl_grade_id,
            empl_grade_sub_id = EXCLUDED.empl_grade_sub_id,
            section_id = EXCLUDED.section_id,
            empl_category_id = EXCLUDED.empl_category_id,
            marital_status = EXCLUDED.marital_status,
            bank_account = EXCLUDED.bank_account,
            permanent_district_id = EXCLUDED.permanent_district_id,
            current_district_id = EXCLUDED.current_district_id,
            job_title = EXCLUDED.job_title,
            confirmation_date = EXCLUDED.confirmation_date;



---------------------------------------- Upsert Separation Data (integ_separation_imp table)---------------------------------------------------

INSERT INTO public.integ_separation_imp (
    id, version, created_by, created_date, last_modified_by, last_modified_date, separation_doc_date,
    employee_code, separation_type_code, effective_date, acceptance_date
)
WITH valid_source AS (
    SELECT
        gen_random_uuid() AS id,
        e.employee_code,
        e.last_working_day,
        stm.separation_type,
        e.created_by,
        e.created_date,
        e.last_modified_by,
        e.last_modified_date
    FROM cdc.integ_employee_imp e
    INNER JOIN public.integ_separation_type_map stm
        ON e.employee_job_status = stm.sep_type_code
    WHERE e.last_working_day IS NOT NULL AND e.employee_code NOT IN(SELECT employee_code FROM public.integ_separation_imp)

    )
SELECT
    id,
    1,
    created_by,
    created_date,
    last_modified_by,
    last_modified_date,
    now(),
    employee_code,
    separation_type,
    last_working_day + INTERVAL '1 day',
    last_working_day + INTERVAL '1 day'
FROM valid_source;


------------------------------------------------------- create snapshot table -------------------------------------------------------------------

CREATE TABLE cdc.snapshot_mdg_empl_profile (
    id uuid,
    empl_number_old text, empl_number_new text,
    employee_code_old text, employee_code_new text,
    attend_card_id_old text, attend_card_id_new text,
    first_name_old text, first_name_new text,
    middle_name_old text, middle_name_new text,
    last_name_old text, last_name_new text,
    father_name_old text, father_name_new text,
    mother_name_old text, mother_name_new text,
    national_id_old text, national_id_new text,
    join_date_actual_old text, join_date_actual_new text,
    confirmation_date_old text, confirmation_date_new text,
    contract_end_date_old text, contract_end_date_new text,
    email_company_old text, email_company_new text,
    current_address_old text, current_address_new text,
    permanent_address_old text, permanent_address_new text,
    birth_date_old text, birth_date_new text,
    gross_salary_old text, gross_salary_new text,
    salary_amount_old text, salary_amount_new text,
    bonus_entitlement_status_old text, bonus_entitlement_status_new text,
    bank_branch_name_old text, bank_branch_name_new text,
    gender_old text, gender_new text,
    tax_identification_no_old text, tax_identification_no_new text,
    tax_salary_circle_old text, tax_salary_circle_new text,
    company_id_old text, company_id_new text,
    department_id_old text, department_id_new text,
    operating_location_id_old text, operating_location_id_new text,
    functional_area_id_old text, functional_area_id_new text,
    designation_id_old text, designation_id_new text,
    workflow_group_id_old text, workflow_group_id_new text,
    empl_type_old text, empl_type_new text,
    name_old text, name_new text,
    probation_period_months_old text, probation_period_months_new text,
    confirmation_due_date_old text, confirmation_due_date_new text,
    pr_payment_method_id_old text, pr_payment_method_id_new text,
    pr_payment_method_sec_id_old text, pr_payment_method_sec_id_new text,
    nationality_id_old text, nationality_id_new text,
    current_country_id_old text, current_country_id_new text,
    permanent_country_id_old text, permanent_country_id_new text,
    employment_status_old text, employment_status_new text,
    work_shift_id_old text, work_shift_id_new text,
    religion_id_old text, religion_id_new text,
    work_shift_rotated_old text, work_shift_rotated_new text,
    pay_overtime_old text, pay_overtime_new text,
    attend_tracking_type_old text, attend_tracking_type_new text,
    empl_category_id_old text, empl_category_id_new text,
    pay_type_old text, pay_type_new text,
    payscale_or_paystructure_old text, payscale_or_paystructure_new text,
    pay_period_old text, pay_period_new text,
    salary_amt_period_old text, salary_amt_period_new text,
    basic_salary_old text, basic_salary_new text,
    salary_ready_for_app_old text, salary_ready_for_app_new text,
    salary_approved_old text, salary_approved_new text,
    with_hold_salary_old text, with_hold_salary_new text,
    schedule_work_calendar_old text, schedule_work_calendar_new text,
    temp_separated_old text, temp_separated_new text,
    tax_resident_old text, tax_resident_new text,
    job_offered_old text, job_offered_new text,
    phone_home_old text, phone_home_new text,
    phone_mobile_old text, phone_mobile_new text,
    phone_work_direct_old text, phone_work_direct_new text,
    empl_grade_id_old text, empl_grade_id_new text,
    empl_grade_sub_id_old text, empl_grade_sub_id_new text,
    manager_id_old text, manager_id_new text,
    section_id_old text, section_id_new text,
    email_personal_old text, email_personal_new text,
    marital_status_old text, marital_status_new text,
    bank_account_old text, bank_account_new text,
    permanent_district_id_old text, permanent_district_id_new text,
    current_district_id_old text, current_district_id_new text,
    job_title_old text, job_title_new text,
    flag text,
    last_modified_date timestamp
);

----------------------------------------------------------------- Update Track -------------------------------------------------------------------

INSERT INTO cdc.snapshot_mdg_empl_profile (
    id,
    empl_number_old, empl_number_new,
    employee_code_old, employee_code_new,
    attend_card_id_old, attend_card_id_new,
    first_name_old, first_name_new,
    middle_name_old, middle_name_new,
    last_name_old, last_name_new,
    father_name_old, father_name_new,
    mother_name_old, mother_name_new,
    national_id_old, national_id_new,
    join_date_actual_old, join_date_actual_new,
    confirmation_date_old, confirmation_date_new,
    contract_end_date_old, contract_end_date_new,
    email_company_old, email_company_new,
    current_address_old, current_address_new,
    permanent_address_old, permanent_address_new,
    birth_date_old, birth_date_new,
    gross_salary_old, gross_salary_new,
    salary_amount_old, salary_amount_new,
    bonus_entitlement_status_old, bonus_entitlement_status_new,
    bank_branch_name_old, bank_branch_name_new,
    gender_old, gender_new,
    tax_identification_no_old, tax_identification_no_new,
    tax_salary_circle_old, tax_salary_circle_new,
    company_id_old, company_id_new,
    department_id_old, department_id_new,
    operating_location_id_old, operating_location_id_new,
    functional_area_id_old, functional_area_id_new,
    designation_id_old, designation_id_new,
    workflow_group_id_old, workflow_group_id_new,
    empl_type_old, empl_type_new,
    name_old, name_new,
    probation_period_months_old, probation_period_months_new,
    confirmation_due_date_old, confirmation_due_date_new,
    pr_payment_method_id_old, pr_payment_method_id_new,
    pr_payment_method_sec_id_old, pr_payment_method_sec_id_new,
    nationality_id_old, nationality_id_new,
    current_country_id_old, current_country_id_new,
    permanent_country_id_old, permanent_country_id_new,
    employment_status_old, employment_status_new,
    work_shift_id_old, work_shift_id_new,
    religion_id_old, religion_id_new,
    work_shift_rotated_old, work_shift_rotated_new,
    pay_overtime_old, pay_overtime_new,
    attend_tracking_type_old, attend_tracking_type_new,
    empl_category_id_old, empl_category_id_new,
    pay_type_old, pay_type_new,
    payscale_or_paystructure_old, payscale_or_paystructure_new,
    pay_period_old, pay_period_new,
    salary_amt_period_old, salary_amt_period_new,
    basic_salary_old, basic_salary_new,
    salary_ready_for_app_old, salary_ready_for_app_new,
    salary_approved_old, salary_approved_new,
    with_hold_salary_old, with_hold_salary_new,
    schedule_work_calendar_old, schedule_work_calendar_new,
    temp_separated_old, temp_separated_new,
    tax_resident_old, tax_resident_new,
    job_offered_old, job_offered_new,
    phone_home_old, phone_home_new,
    phone_mobile_old, phone_mobile_new,
    phone_work_direct_old, phone_work_direct_new,
    empl_grade_id_old, empl_grade_id_new,
    empl_grade_sub_id_old, empl_grade_sub_id_new,
    manager_id_old, manager_id_new,
    section_id_old, section_id_new,
    email_personal_old, email_personal_new,
    marital_status_old, marital_status_new,
    bank_account_old, bank_account_new,
    permanent_district_id_old, permanent_district_id_new,
    current_district_id_old, current_district_id_new,
    job_title_old, job_title_new,
    flag,
    last_modified_date
)
SELECT
    t1.id,

    CASE WHEN t1.empl_number IS DISTINCT FROM t2.empl_number THEN t1.empl_number::text END,
    CASE WHEN t1.empl_number IS DISTINCT FROM t2.empl_number THEN t2.empl_number::text END,

    CASE WHEN t1.employee_code IS DISTINCT FROM t2.employee_code THEN t1.employee_code::text END,
    CASE WHEN t1.employee_code IS DISTINCT FROM t2.employee_code THEN t2.employee_code::text END,

    CASE WHEN t1.attend_card_id IS DISTINCT FROM t2.attend_card_id THEN t1.attend_card_id::text END,
    CASE WHEN t1.attend_card_id IS DISTINCT FROM t2.attend_card_id THEN t2.attend_card_id::text END,

    CASE WHEN t1.first_name IS DISTINCT FROM t2.first_name THEN t1.first_name::text END,
    CASE WHEN t1.first_name IS DISTINCT FROM t2.first_name THEN t2.first_name::text END,

    CASE WHEN t1.middle_name IS DISTINCT FROM t2.middle_name THEN t1.middle_name::text END,
    CASE WHEN t1.middle_name IS DISTINCT FROM t2.middle_name THEN t2.middle_name::text END,

    CASE WHEN t1.last_name IS DISTINCT FROM t2.last_name THEN t1.last_name::text END,
    CASE WHEN t1.last_name IS DISTINCT FROM t2.last_name THEN t2.last_name::text END,

    CASE WHEN t1.father_name IS DISTINCT FROM t2.father_name THEN t1.father_name::text END,
    CASE WHEN t1.father_name IS DISTINCT FROM t2.father_name THEN t2.father_name::text END,

    CASE WHEN t1.mother_name IS DISTINCT FROM t2.mother_name THEN t1.mother_name::text END,
    CASE WHEN t1.mother_name IS DISTINCT FROM t2.mother_name THEN t2.mother_name::text END,

    CASE WHEN t1.national_id IS DISTINCT FROM t2.national_id THEN t1.national_id::text END,
    CASE WHEN t1.national_id IS DISTINCT FROM t2.national_id THEN t2.national_id::text END,

    CASE WHEN t1.join_date_actual IS DISTINCT FROM t2.join_date_actual THEN t1.join_date_actual::text END,
    CASE WHEN t1.join_date_actual IS DISTINCT FROM t2.join_date_actual THEN t2.join_date_actual::text END,

    CASE WHEN t1.confirmation_date IS DISTINCT FROM t2.confirmation_date THEN t1.confirmation_date::text END,
    CASE WHEN t1.confirmation_date IS DISTINCT FROM t2.confirmation_date THEN t2.confirmation_date::text END,

    CASE WHEN t1.contract_end_date IS DISTINCT FROM t2.contract_end_date THEN t1.contract_end_date::text END,
    CASE WHEN t1.contract_end_date IS DISTINCT FROM t2.contract_end_date THEN t2.contract_end_date::text END,

    CASE WHEN t1.email_company IS DISTINCT FROM t2.email_company THEN t1.email_company::text END,
    CASE WHEN t1.email_company IS DISTINCT FROM t2.email_company THEN t2.email_company::text END,

    CASE WHEN t1.current_address IS DISTINCT FROM t2.current_address THEN t1.current_address::text END,
    CASE WHEN t1.current_address IS DISTINCT FROM t2.current_address THEN t2.current_address::text END,

    CASE WHEN t1.permanent_address IS DISTINCT FROM t2.permanent_address THEN t1.permanent_address::text END,
    CASE WHEN t1.permanent_address IS DISTINCT FROM t2.permanent_address THEN t2.permanent_address::text END,

    CASE WHEN t1.birth_date IS DISTINCT FROM t2.birth_date THEN t1.birth_date::text END,
    CASE WHEN t1.birth_date IS DISTINCT FROM t2.birth_date THEN t2.birth_date::text END,

    CASE WHEN t1.gross_salary IS DISTINCT FROM t2.gross_salary THEN t1.gross_salary::text END,
    CASE WHEN t1.gross_salary IS DISTINCT FROM t2.gross_salary THEN t2.gross_salary::text END,

    CASE WHEN t1.salary_amount IS DISTINCT FROM t2.salary_amount THEN t1.salary_amount::text END,
    CASE WHEN t1.salary_amount IS DISTINCT FROM t2.salary_amount THEN t2.salary_amount::text END,

    CASE WHEN t1.bonus_entitlement_status IS DISTINCT FROM t2.bonus_entitlement_status THEN t1.bonus_entitlement_status::text END,
    CASE WHEN t1.bonus_entitlement_status IS DISTINCT FROM t2.bonus_entitlement_status THEN t2.bonus_entitlement_status::text END,

    CASE WHEN t1.bank_branch_name IS DISTINCT FROM t2.bank_branch_name THEN t1.bank_branch_name::text END,
    CASE WHEN t1.bank_branch_name IS DISTINCT FROM t2.bank_branch_name THEN t2.bank_branch_name::text END,

    CASE WHEN t1.gender IS DISTINCT FROM t2.gender THEN t1.gender::text END,
    CASE WHEN t1.gender IS DISTINCT FROM t2.gender THEN t2.gender::text END,

    CASE WHEN t1.tax_identification_no IS DISTINCT FROM t2.tax_identification_no THEN t1.tax_identification_no::text END,
    CASE WHEN t1.tax_identification_no IS DISTINCT FROM t2.tax_identification_no THEN t2.tax_identification_no::text END,

    CASE WHEN t1.tax_salary_circle IS DISTINCT FROM t2.tax_salary_circle THEN t1.tax_salary_circle::text END,
    CASE WHEN t1.tax_salary_circle IS DISTINCT FROM t2.tax_salary_circle THEN t2.tax_salary_circle::text END,

    CASE WHEN t1.company_id IS DISTINCT FROM t2.company_id THEN t1.company_id::text END,
    CASE WHEN t1.company_id IS DISTINCT FROM t2.company_id THEN t2.company_id::text END,

    CASE WHEN t1.department_id IS DISTINCT FROM t2.department_id THEN t1.department_id::text END,
    CASE WHEN t1.department_id IS DISTINCT FROM t2.department_id THEN t2.department_id::text END,

    CASE WHEN t1.operating_location_id IS DISTINCT FROM t2.operating_location_id THEN t1.operating_location_id::text END,
    CASE WHEN t1.operating_location_id IS DISTINCT FROM t2.operating_location_id THEN t2.operating_location_id::text END,

    CASE WHEN t1.functional_area_id IS DISTINCT FROM t2.functional_area_id THEN t1.functional_area_id::text END,
    CASE WHEN t1.functional_area_id IS DISTINCT FROM t2.functional_area_id THEN t2.functional_area_id::text END,

    CASE WHEN t1.designation_id IS DISTINCT FROM t2.designation_id THEN t1.designation_id::text END,
    CASE WHEN t1.designation_id IS DISTINCT FROM t2.designation_id THEN t2.designation_id::text END,

    CASE WHEN t1.workflow_group_id IS DISTINCT FROM t2.workflow_group_id THEN t1.workflow_group_id::text END,
    CASE WHEN t1.workflow_group_id IS DISTINCT FROM t2.workflow_group_id THEN t2.workflow_group_id::text END,

    CASE WHEN t1.empl_type IS DISTINCT FROM t2.empl_type THEN t1.empl_type::text END,
    CASE WHEN t1.empl_type IS DISTINCT FROM t2.empl_type THEN t2.empl_type::text END,

    CASE WHEN t1.name IS DISTINCT FROM t2.name THEN t1.name::text END,
    CASE WHEN t1.name IS DISTINCT FROM t2.name THEN t2.name::text END,

    CASE WHEN t1.probation_period_months IS DISTINCT FROM t2.probation_period_months THEN t1.probation_period_months::text END,
    CASE WHEN t1.probation_period_months IS DISTINCT FROM t2.probation_period_months THEN t2.probation_period_months::text END,

    CASE WHEN t1.confirmation_due_date IS DISTINCT FROM t2.confirmation_due_date THEN t1.confirmation_due_date::text END,
    CASE WHEN t1.confirmation_due_date IS DISTINCT FROM t2.confirmation_due_date THEN t2.confirmation_due_date::text END,

    CASE WHEN t1.pr_payment_method_id IS DISTINCT FROM t2.pr_payment_method_id THEN t1.pr_payment_method_id::text END,
    CASE WHEN t1.pr_payment_method_id IS DISTINCT FROM t2.pr_payment_method_id THEN t2.pr_payment_method_id::text END,

    CASE WHEN t1.pr_payment_method_sec_id IS DISTINCT FROM t2.pr_payment_method_sec_id THEN t1.pr_payment_method_sec_id::text END,
    CASE WHEN t1.pr_payment_method_sec_id IS DISTINCT FROM t2.pr_payment_method_sec_id THEN t2.pr_payment_method_sec_id::text END,

    CASE WHEN t1.nationality_id IS DISTINCT FROM t2.nationality_id THEN t1.nationality_id::text END,
    CASE WHEN t1.nationality_id IS DISTINCT FROM t2.nationality_id THEN t2.nationality_id::text END,

    CASE WHEN t1.current_country_id IS DISTINCT FROM t2.current_country_id THEN t1.current_country_id::text END,
    CASE WHEN t1.current_country_id IS DISTINCT FROM t2.current_country_id THEN t2.current_country_id::text END,

    CASE WHEN t1.permanent_country_id IS DISTINCT FROM t2.permanent_country_id THEN t1.permanent_country_id::text END,
    CASE WHEN t1.permanent_country_id IS DISTINCT FROM t2.permanent_country_id THEN t2.permanent_country_id::text END,

    CASE WHEN t1.employment_status IS DISTINCT FROM t2.employment_status THEN t1.employment_status::text END,
    CASE WHEN t1.employment_status IS DISTINCT FROM t2.employment_status THEN t2.employment_status::text END,

    CASE WHEN t1.work_shift_id IS DISTINCT FROM t2.work_shift_id THEN t1.work_shift_id::text END,
    CASE WHEN t1.work_shift_id IS DISTINCT FROM t2.work_shift_id THEN t2.work_shift_id::text END,

    CASE WHEN t1.religion_id IS DISTINCT FROM t2.religion_id THEN t1.religion_id::text END,
    CASE WHEN t1.religion_id IS DISTINCT FROM t2.religion_id THEN t2.religion_id::text END,

    CASE WHEN t1.work_shift_rotated IS DISTINCT FROM t2.work_shift_rotated THEN t1.work_shift_rotated::text END,
    CASE WHEN t1.work_shift_rotated IS DISTINCT FROM t2.work_shift_rotated THEN t2.work_shift_rotated::text END,

    CASE WHEN t1.pay_overtime IS DISTINCT FROM t2.pay_overtime THEN t1.pay_overtime::text END,
    CASE WHEN t1.pay_overtime IS DISTINCT FROM t2.pay_overtime THEN t2.pay_overtime::text END,

    CASE WHEN t1.attend_tracking_type IS DISTINCT FROM t2.attend_tracking_type THEN t1.attend_tracking_type::text END,
    CASE WHEN t1.attend_tracking_type IS DISTINCT FROM t2.attend_tracking_type THEN t2.attend_tracking_type::text END,

    CASE WHEN t1.empl_category_id IS DISTINCT FROM t2.empl_category_id THEN t1.empl_category_id::text END,
    CASE WHEN t1.empl_category_id IS DISTINCT FROM t2.empl_category_id THEN t2.empl_category_id::text END,

    CASE WHEN t1.pay_type IS DISTINCT FROM t2.pay_type THEN t1.pay_type::text END,
    CASE WHEN t1.pay_type IS DISTINCT FROM t2.pay_type THEN t2.pay_type::text END,

    CASE WHEN t1.payscale_or_paystructure IS DISTINCT FROM t2.payscale_or_paystructure THEN t1.payscale_or_paystructure::text END,
    CASE WHEN t1.payscale_or_paystructure IS DISTINCT FROM t2.payscale_or_paystructure THEN t2.payscale_or_paystructure::text END,

    CASE WHEN t1.pay_period IS DISTINCT FROM t2.pay_period THEN t1.pay_period::text END,
    CASE WHEN t1.pay_period IS DISTINCT FROM t2.pay_period THEN t2.pay_period::text END,

    CASE WHEN t1.salary_amt_period IS DISTINCT FROM t2.salary_amt_period THEN t1.salary_amt_period::text END,
    CASE WHEN t1.salary_amt_period IS DISTINCT FROM t2.salary_amt_period THEN t2.salary_amt_period::text END,

    CASE WHEN t1.basic_salary IS DISTINCT FROM t2.basic_salary THEN t1.basic_salary::text END,
    CASE WHEN t1.basic_salary IS DISTINCT FROM t2.basic_salary THEN t2.basic_salary::text END,

    CASE WHEN t1.salary_ready_for_app IS DISTINCT FROM t2.salary_ready_for_app THEN t1.salary_ready_for_app::text END,
    CASE WHEN t1.salary_ready_for_app IS DISTINCT FROM t2.salary_ready_for_app THEN t2.salary_ready_for_app::text END,

    CASE WHEN t1.salary_approved IS DISTINCT FROM t2.salary_approved THEN t1.salary_approved::text END,
    CASE WHEN t1.salary_approved IS DISTINCT FROM t2.salary_approved THEN t2.salary_approved::text END,

    CASE WHEN t1.with_hold_salary IS DISTINCT FROM t2.with_hold_salary THEN t1.with_hold_salary::text END,
    CASE WHEN t1.with_hold_salary IS DISTINCT FROM t2.with_hold_salary THEN t2.with_hold_salary::text END,

    CASE WHEN t1.schedule_work_calendar IS DISTINCT FROM t2.schedule_work_calendar THEN t1.schedule_work_calendar::text END,
    CASE WHEN t1.schedule_work_calendar IS DISTINCT FROM t2.schedule_work_calendar THEN t2.schedule_work_calendar::text END,

    CASE WHEN t1.temp_separated IS DISTINCT FROM t2.temp_separated THEN t1.temp_separated::text END,
    CASE WHEN t1.temp_separated IS DISTINCT FROM t2.temp_separated THEN t2.temp_separated::text END,

    CASE WHEN t1.tax_resident IS DISTINCT FROM t2.tax_resident THEN t1.tax_resident::text END,
    CASE WHEN t1.tax_resident IS DISTINCT FROM t2.tax_resident THEN t2.tax_resident::text END,

    CASE WHEN t1.job_offered IS DISTINCT FROM t2.job_offered THEN t1.job_offered::text END,
    CASE WHEN t1.job_offered IS DISTINCT FROM t2.job_offered THEN t2.job_offered::text END,

    CASE WHEN t1.phone_home IS DISTINCT FROM t2.phone_home THEN t1.phone_home::text END,
    CASE WHEN t1.phone_home IS DISTINCT FROM t2.phone_home THEN t2.phone_home::text END,

    CASE WHEN t1.phone_mobile IS DISTINCT FROM t2.phone_mobile THEN t1.phone_mobile::text END,
    CASE WHEN t1.phone_mobile IS DISTINCT FROM t2.phone_mobile THEN t2.phone_mobile::text END,

    CASE WHEN t1.phone_work_direct IS DISTINCT FROM t2.phone_work_direct THEN t1.phone_work_direct::text END,
    CASE WHEN t1.phone_work_direct IS DISTINCT FROM t2.phone_work_direct THEN t2.phone_work_direct::text END,

    CASE WHEN t1.empl_grade_id IS DISTINCT FROM t2.empl_grade_id THEN t1.empl_grade_id::text END,
    CASE WHEN t1.empl_grade_id IS DISTINCT FROM t2.empl_grade_id THEN t2.empl_grade_id::text END,

    CASE WHEN t1.empl_grade_sub_id IS DISTINCT FROM t2.empl_grade_sub_id THEN t1.empl_grade_sub_id::text END,
    CASE WHEN t1.empl_grade_sub_id IS DISTINCT FROM t2.empl_grade_sub_id THEN t2.empl_grade_sub_id::text END,

    CASE WHEN t1.manager_id IS DISTINCT FROM t2.manager_id THEN t1.manager_id::text END,
    CASE WHEN t1.manager_id IS DISTINCT FROM t2.manager_id THEN t2.manager_id::text END,

    CASE WHEN t1.section_id IS DISTINCT FROM t2.section_id THEN t1.section_id::text END,
    CASE WHEN t1.section_id IS DISTINCT FROM t2.section_id THEN t2.section_id::text END,

    CASE WHEN t1.email_personal IS DISTINCT FROM t2.email_personal THEN t1.email_personal::text END,
    CASE WHEN t1.email_personal IS DISTINCT FROM t2.email_personal THEN t2.email_personal::text END,

    CASE WHEN t1.marital_status IS DISTINCT FROM t2.marital_status THEN t1.marital_status::text END,
    CASE WHEN t1.marital_status IS DISTINCT FROM t2.marital_status THEN t2.marital_status::text END,

    CASE WHEN t1.bank_account IS DISTINCT FROM t2.bank_account THEN t1.bank_account::text END,
    CASE WHEN t1.bank_account IS DISTINCT FROM t2.bank_account THEN t2.bank_account::text END,

    CASE WHEN t1.permanent_district_id IS DISTINCT FROM t2.permanent_district_id THEN t1.permanent_district_id::text END,
    CASE WHEN t1.permanent_district_id IS DISTINCT FROM t2.permanent_district_id THEN t2.permanent_district_id::text END,

    CASE WHEN t1.current_district_id IS DISTINCT FROM t2.current_district_id THEN t1.current_district_id::text END,
    CASE WHEN t1.current_district_id IS DISTINCT FROM t2.current_district_id THEN t2.current_district_id::text END,

    CASE WHEN t1.job_title IS DISTINCT FROM t2.job_title THEN t1.job_title::text END,
    CASE WHEN t1.job_title IS DISTINCT FROM t2.job_title THEN t2.job_title::text END,

    'Update',
    now()
FROM cdc.mdg_empl_profile_old t1
JOIN public.mdg_empl_profile t2 ON t1.id = t2.id
WHERE
    t1.* IS DISTINCT FROM t2.*;


----------------------------------------------------------------- Insert Track -------------------------------------------------------------------

INSERT INTO cdc.snapshot_mdg_empl_profile (
    id,
    empl_number_old, empl_number_new,
    employee_code_old, employee_code_new,
    attend_card_id_old, attend_card_id_new,
    first_name_old, first_name_new,
    middle_name_old, middle_name_new,
    last_name_old, last_name_new,
    father_name_old, father_name_new,
    mother_name_old, mother_name_new,
    national_id_old, national_id_new,
    join_date_actual_old, join_date_actual_new,
    confirmation_date_old, confirmation_date_new,
    contract_end_date_old, contract_end_date_new,
    email_company_old, email_company_new,
    current_address_old, current_address_new,
    permanent_address_old, permanent_address_new,
    birth_date_old, birth_date_new,
    gross_salary_old, gross_salary_new,
    salary_amount_old, salary_amount_new,
    bonus_entitlement_status_old, bonus_entitlement_status_new,
    bank_branch_name_old, bank_branch_name_new,
    gender_old, gender_new,
    tax_identification_no_old, tax_identification_no_new,
    tax_salary_circle_old, tax_salary_circle_new,
    company_id_old, company_id_new,
    department_id_old, department_id_new,
    operating_location_id_old, operating_location_id_new,
    functional_area_id_old, functional_area_id_new,
    designation_id_old, designation_id_new,
    workflow_group_id_old, workflow_group_id_new,
    empl_type_old, empl_type_new,
    name_old, name_new,
    probation_period_months_old, probation_period_months_new,
    confirmation_due_date_old, confirmation_due_date_new,
    pr_payment_method_id_old, pr_payment_method_id_new,
    pr_payment_method_sec_id_old, pr_payment_method_sec_id_new,
    nationality_id_old, nationality_id_new,
    current_country_id_old, current_country_id_new,
    permanent_country_id_old, permanent_country_id_new,
    employment_status_old, employment_status_new,
    work_shift_id_old, work_shift_id_new,
    religion_id_old, religion_id_new,
    work_shift_rotated_old, work_shift_rotated_new,
    pay_overtime_old, pay_overtime_new,
    attend_tracking_type_old, attend_tracking_type_new,
    empl_category_id_old, empl_category_id_new,
    pay_type_old, pay_type_new,
    payscale_or_paystructure_old, payscale_or_paystructure_new,
    pay_period_old, pay_period_new,
    salary_amt_period_old, salary_amt_period_new,
    basic_salary_old, basic_salary_new,
    salary_ready_for_app_old, salary_ready_for_app_new,
    salary_approved_old, salary_approved_new,
    with_hold_salary_old, with_hold_salary_new,
    schedule_work_calendar_old, schedule_work_calendar_new,
    temp_separated_old, temp_separated_new,
    tax_resident_old, tax_resident_new,
    job_offered_old, job_offered_new,
    phone_home_old, phone_home_new,
    phone_mobile_old, phone_mobile_new,
    phone_work_direct_old, phone_work_direct_new,
    empl_grade_id_old, empl_grade_id_new,
    empl_grade_sub_id_old, empl_grade_sub_id_new,
    manager_id_old, manager_id_new,
    section_id_old, section_id_new,
    email_personal_old, email_personal_new,
    marital_status_old, marital_status_new,
    bank_account_old, bank_account_new,
    permanent_district_id_old, permanent_district_id_new,
    current_district_id_old, current_district_id_new,
    job_title_old, job_title_new,
    flag,
    last_modified_date
)
SELECT
    t2.id,
    NULL, t2.empl_number::text,
    NULL, t2.employee_code::text,
    NULL, t2.attend_card_id::text,
    NULL, t2.first_name::text,
    NULL, t2.middle_name::text,
    NULL, t2.last_name::text,
    NULL, t2.father_name::text,
    NULL, t2.mother_name::text,
    NULL, t2.national_id::text,
    NULL, t2.join_date_actual::text,
    NULL, t2.confirmation_date::text,
    NULL, t2.contract_end_date::text,
    NULL, t2.email_company::text,
    NULL, t2.current_address::text,
    NULL, t2.permanent_address::text,
    NULL, t2.birth_date::text,
    NULL, t2.gross_salary::text,
    NULL, t2.salary_amount::text,
    NULL, t2.bonus_entitlement_status::text,
    NULL, t2.bank_branch_name::text,
    NULL, t2.gender::text,
    NULL, t2.tax_identification_no::text,
    NULL, t2.tax_salary_circle::text,
    NULL, t2.company_id::text,
    NULL, t2.department_id::text,
    NULL, t2.operating_location_id::text,
    NULL, t2.functional_area_id::text,
    NULL, t2.designation_id::text,
    NULL, t2.workflow_group_id::text,
    NULL, t2.empl_type::text,
    NULL, t2.name::text,
    NULL, t2.probation_period_months::text,
    NULL, t2.confirmation_due_date::text,
    NULL, t2.pr_payment_method_id::text,
    NULL, t2.pr_payment_method_sec_id::text,
    NULL, t2.nationality_id::text,
    NULL, t2.current_country_id::text,
    NULL, t2.permanent_country_id::text,
    NULL, t2.employment_status::text,
    NULL, t2.work_shift_id::text,
    NULL, t2.religion_id::text,
    NULL, t2.work_shift_rotated::text,
    NULL, t2.pay_overtime::text,
    NULL, t2.attend_tracking_type::text,
    NULL, t2.empl_category_id::text,
    NULL, t2.pay_type::text,
    NULL, t2.payscale_or_paystructure::text,
    NULL, t2.pay_period::text,
    NULL, t2.salary_amt_period::text,
    NULL, t2.basic_salary::text,
    NULL, t2.salary_ready_for_app::text,
    NULL, t2.salary_approved::text,
    NULL, t2.with_hold_salary::text,
    NULL, t2.schedule_work_calendar::text,
    NULL, t2.temp_separated::text,
    NULL, t2.tax_resident::text,
    NULL, t2.job_offered::text,
    NULL, t2.phone_home::text,
    NULL, t2.phone_mobile::text,
    NULL, t2.phone_work_direct::text,
    NULL, t2.empl_grade_id::text,
    NULL, t2.empl_grade_sub_id::text,
    NULL, t2.manager_id::text,
    NULL, t2.section_id::text,
    NULL, t2.email_personal::text,
    NULL, t2.marital_status::text,
    NULL, t2.bank_account::text,
    NULL, t2.permanent_district_id::text,
    NULL, t2.current_district_id::text,
    NULL, t2.job_title::text,
    'Insert',
    now()
FROM public.mdg_empl_profile t2
LEFT JOIN cdc.mdg_empl_profile_old t1 ON t1.id = t2.id
WHERE t1.id IS NULL;

