INSERT INTO mdg_empl_profile (
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
	    ;WITH MAIN_CTE AS(
	    SELECT
	        e.id,
	        'hr_EmployeeProfile',
	        1,
	        'api',
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
	        '23710db3-27c4-d754-e065-7f74e2a693e6' AS pr_payment_method_id,
	        '6e60ffde-871c-4443-7e57-09e0344f2154' AS pr_payment_method_sec_id,
	        '4a7b49c1-173c-5794-f4a1-a5e0649ac658' AS nationality_id,
	        '4a7b49c1-173c-5794-f4a1-a5e0649ac658' AS current_country_id,
	        '4a7b49c1-173c-5794-f4a1-a5e0649ac658' AS permanent_country_id,
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
            m.id AS section_id,
            e.email_personal,
            e.marital_status,
            e.bank_account,
            MDT2.id AS permanent_district_id,
            MDT.id AS current_district_id,
            e.job_title
	    FROM
	        public.integ_employee_imp e
	    LEFT JOIN public.integ_employee_imp e2 ON e.supervisor_empl_code = e2.employee_code
	    LEFT JOIN mdg_dept_section sec ON e.section_code = sec.sec_code
	    LEFT JOIN mdg_operating_location ol ON e.operating_location_code = ol.oper_loc_code
	    LEFT JOIN mdg_department dept ON sec.department_id = dept.id
	    LEFT JOIN mdg_department_comp dc ON dc.department_id = dept.id
	    LEFT JOIN hmd_empl_category ec ON e.empl_category_code = ec.empl_category_code
		LEFT JOIN hmd_designation desg ON e.designation_code = desg.code
        LEFT JOIN INTEG_EMPLOYMENT_STATUS_MAP esm ON e.employee_job_status = esm.status_code
        LEFT JOIN MDG_WORK_SHIFT ws ON e.work_shift_code = ws.shift_code
        LEFT JOIN MDG_RELIGION rel ON e.religion = rel.religion_code
        LEFT JOIN public.mdg_job_grade g ON e.grade_code = g.grade_code
        LEFT JOIN public.mdg_empl_job_grade gr ON gr.job_grade_id = g.id
        LEFT JOIN public.hmd_empl_grade_sub grs ON e.grade_sub_code = grs.sub_code AND gr.id = grs.empl_grade_id
        LEFT JOIN public.mdg_dept_section m ON e.section_code = m.sec_code
        LEFT JOIN public.mdg_district MDT ON e.CURRENT_District_Code = MDT.dist_code
        LEFT JOIN public.mdg_district MDT2 ON e.Permanent_District_Code = MDT.dist_code
	    )
	    SELECT
	        id,
	        'hr_EmployeeProfile',
	        1,
	        'api',
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
	        tin_no,
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
            bank_account,
            permanent_district_id,
            current_district_id,
            job_title
	     FROM MAIN_CTE
	     ON CONFLICT (id) DO UPDATE
        SET
           last_modified_date = EXCLUDED.last_modified_date,
            first_name = EXCLUDED.first_name,
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
            tin_no = EXCLUDED.tin_no
            manager_id = EXCLUDED.manager_id
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
            job_title = EXCLUDED.job_title;

