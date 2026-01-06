create table chk_for_updates_on_mdg as select * from public.mdg_empl_profile where 1=2;
create table chk_for_updates_on_mdg_2 as select * from public.mdg_empl_profile where 1=2;

ALTER TABLE chk_for_updates_on_mdg
ADD COLUMN operation_type VARCHAR(10),
ADD COLUMN is_done BOOLEAN DEFAULT FALSE,
ADD COLUMN last_updated_at TIMESTAMP,
ADD COLUMN updated_at TIMESTAMP DEFAULT NOW();

--delete from chk_for_updates_on_mdg;

INSERT INTO chk_for_updates_on_mdg
    SELECT
        e.*,                                -- all columns from mdg_empl_profile
        'Insert' AS operation_type,         -- fixed value
        FALSE AS is_done,                   -- boolean default
        NOW() AS last_updated_at,           -- timestamp
        NOW() AS updated_at                 -- default timestamp
    FROM mdg_empl_profile e
    WHERE NOT EXISTS (
        SELECT 1
        FROM mdg_empl_prof_old chk
        WHERE chk.id = e.id
);


INSERT INTO chk_for_updates_on_mdg (
    id, dtype, version, created_by, created_date, last_modified_by, last_modified_date,
    empl_number, employee_code, first_name, middle_name, last_name, name, father_name,
    mother_name, empl_photo, market_hierarchy_id, manager_id, manager_matrix_id, company_id,
    department_id, operating_location_id, functional_area_id, job_family_id, hr_business_part_prof_id,
    birth_date, join_date_actual, employment_status, confirmation_date, contract_end_date,
    workflow_group_id, pf_member_id, gratuity_member_id, dps_member_id, gross_salary, basic_salary,
    empl_type, gratuity_effective_date, bonus_entitlement_status, attend_card_id, spouse, number_of_child,
    empl_date, join_date_planned, curr_position_since, marriage_date, job_description, national_id,
    gender, phone_home, phone_work_direct, phone_work_pabx, phone_work_pabx_ext, phone_mobile,
    emergency_contact, probation_period_months, confirmation_due_date, tax_identification_no, tax_salary_circle,
    tax_zone, tax_resident, passport_no, passport_issue_date, passport_expiry_date, passport_issued_by,
    driving_license_no, driving_license_issued_by, blood_group, pay_type, nationality_id, marital_status,
    email_company, email_personal, job_title, designation_id, job_profile_id, job_position_id, empl_grade_id,
    empl_grade_sub_id, pay_period, salary_amt_period, pay_overtime, total_salary_amount,
    allowance_second_pmt_id, second_pmt_mehod_percent, salary_amt_second_pmt, salary_amount, with_hold_salary,
    empl_category_id, section_id, employee_group_id, bank_branch_id, bank_branch_name, bank_account,
    current_address, current_district_id, current_country_id, permanent_address, permanent_district_id,
    permanent_country_id, holiday_calendar_id, leave_profile_id, ot_hourly_rate, work_shift_id, work_shift_rotated,
    work_shift_rotate_rule_id, work_shift_effect_date, job_offered, job_offer_no, job_appointment_issued,
    salary_ready_for_app, salary_approved, salary_approve_date, salary_approved_user, empl_separation_id,
    payscale_or_paystructure, payscale_structure_id, payscale_id, payscale_cmp_id, basic_salary_cmp, update_date,
    religion_id, birth_certificate_no, signature_speciman, signature_update_date, schedule_work_calendar,
    hr_business_partner_id, temp_separated, attend_location_id, attend_latitude, attend_longitude,
    cost_alloc_many_cost_cent, deleted_by, deleted_date, pr_payment_method_id, pr_payment_method_sec_id,
    separation_date, attend_tracking_type, attend_track_type_effect_date, holiday_cal_effective_date, route_no, operation_type,is_done,last_updated_at,updated_at
)
SELECT 
    e.id,
    CASE WHEN e.dtype IS DISTINCT FROM chk.dtype THEN e.dtype ELSE NULL END,
    CASE WHEN e.version IS DISTINCT FROM chk.version THEN e.version ELSE NULL END,
    CASE WHEN e.created_by IS DISTINCT FROM chk.created_by THEN e.created_by ELSE NULL END,
    CASE WHEN e.created_date IS DISTINCT FROM chk.created_date THEN e.created_date ELSE NULL END,
    CASE WHEN e.last_modified_by IS DISTINCT FROM chk.last_modified_by THEN e.last_modified_by ELSE NULL END,
    CASE WHEN e.last_modified_date IS DISTINCT FROM chk.last_modified_date THEN e.last_modified_date ELSE NULL END,
    e.empl_number,
    CASE WHEN e.employee_code IS DISTINCT FROM chk.employee_code THEN e.employee_code ELSE NULL END,
    CASE WHEN e.first_name IS DISTINCT FROM chk.first_name THEN e.first_name ELSE NULL END,
    CASE WHEN e.middle_name IS DISTINCT FROM chk.middle_name THEN e.middle_name ELSE NULL END,
    CASE WHEN e.last_name IS DISTINCT FROM chk.last_name THEN e.last_name ELSE NULL END,
    CASE WHEN e.name IS DISTINCT FROM chk.name THEN e.name ELSE NULL END,
    CASE WHEN e.father_name IS DISTINCT FROM chk.father_name THEN e.father_name ELSE NULL END,
    CASE WHEN e.mother_name IS DISTINCT FROM chk.mother_name THEN e.mother_name ELSE NULL END,
    CASE WHEN e.empl_photo IS DISTINCT FROM chk.empl_photo THEN e.empl_photo ELSE NULL END,
    CASE WHEN e.market_hierarchy_id IS DISTINCT FROM chk.market_hierarchy_id THEN e.market_hierarchy_id ELSE NULL END,
    CASE WHEN e.manager_id IS DISTINCT FROM chk.manager_id THEN e.manager_id ELSE NULL END,
    CASE WHEN e.manager_matrix_id IS DISTINCT FROM chk.manager_matrix_id THEN e.manager_matrix_id ELSE NULL END,
    CASE WHEN e.company_id IS DISTINCT FROM chk.company_id THEN e.company_id ELSE NULL END,
    CASE WHEN e.department_id IS DISTINCT FROM chk.department_id THEN e.department_id ELSE NULL END,
    CASE WHEN e.operating_location_id IS DISTINCT FROM chk.operating_location_id THEN e.operating_location_id ELSE NULL END,
    CASE WHEN e.functional_area_id IS DISTINCT FROM chk.functional_area_id THEN e.functional_area_id ELSE NULL END,
    CASE WHEN e.job_family_id IS DISTINCT FROM chk.job_family_id THEN e.job_family_id ELSE NULL END,
    CASE WHEN e.hr_business_part_prof_id IS DISTINCT FROM chk.hr_business_part_prof_id THEN e.hr_business_part_prof_id ELSE NULL END,
    CASE WHEN e.birth_date IS DISTINCT FROM chk.birth_date THEN e.birth_date ELSE NULL END,
    CASE WHEN e.join_date_actual IS DISTINCT FROM chk.join_date_actual THEN e.join_date_actual ELSE NULL END,
    CASE WHEN e.employment_status IS DISTINCT FROM chk.employment_status THEN e.employment_status ELSE NULL END,
    CASE WHEN e.confirmation_date IS DISTINCT FROM chk.confirmation_date THEN e.confirmation_date ELSE NULL END,
    CASE WHEN e.contract_end_date IS DISTINCT FROM chk.contract_end_date THEN e.contract_end_date ELSE NULL END,
    CASE WHEN e.workflow_group_id IS DISTINCT FROM chk.workflow_group_id THEN e.workflow_group_id ELSE NULL END,
    CASE WHEN e.pf_member_id IS DISTINCT FROM chk.pf_member_id THEN e.pf_member_id ELSE NULL END,
    CASE WHEN e.gratuity_member_id IS DISTINCT FROM chk.gratuity_member_id THEN e.gratuity_member_id ELSE NULL END,
    CASE WHEN e.dps_member_id IS DISTINCT FROM chk.dps_member_id THEN e.dps_member_id ELSE NULL END,
    CASE WHEN e.gross_salary IS DISTINCT FROM chk.gross_salary THEN e.gross_salary ELSE NULL END,
    CASE WHEN e.basic_salary IS DISTINCT FROM chk.basic_salary THEN e.basic_salary ELSE NULL END,
    CASE WHEN e.empl_type IS DISTINCT FROM chk.empl_type THEN e.empl_type ELSE NULL END,
    CASE WHEN e.gratuity_effective_date IS DISTINCT FROM chk.gratuity_effective_date THEN e.gratuity_effective_date ELSE NULL END,
    CASE WHEN e.bonus_entitlement_status IS DISTINCT FROM chk.bonus_entitlement_status THEN e.bonus_entitlement_status ELSE NULL END,
    CASE WHEN e.attend_card_id IS DISTINCT FROM chk.attend_card_id THEN e.attend_card_id ELSE NULL END,
    CASE WHEN e.spouse IS DISTINCT FROM chk.spouse THEN e.spouse ELSE NULL END,
    CASE WHEN e.number_of_child IS DISTINCT FROM chk.number_of_child THEN e.number_of_child ELSE NULL END,
    CASE WHEN e.empl_date IS DISTINCT FROM chk.empl_date THEN e.empl_date ELSE NULL END,
    CASE WHEN e.join_date_planned IS DISTINCT FROM chk.join_date_planned THEN e.join_date_planned ELSE NULL END,
    CASE WHEN e.curr_position_since IS DISTINCT FROM chk.curr_position_since THEN e.curr_position_since ELSE NULL END,
    CASE WHEN e.marriage_date IS DISTINCT FROM chk.marriage_date THEN e.marriage_date ELSE NULL END,
    CASE WHEN e.job_description IS DISTINCT FROM chk.job_description THEN e.job_description ELSE NULL END,
    CASE WHEN e.national_id IS DISTINCT FROM chk.national_id THEN e.national_id ELSE NULL END,
    CASE WHEN e.gender IS DISTINCT FROM chk.gender THEN e.gender ELSE NULL END,
    CASE WHEN e.phone_home IS DISTINCT FROM chk.phone_home THEN e.phone_home ELSE NULL END,
    CASE WHEN e.phone_work_direct IS DISTINCT FROM chk.phone_work_direct THEN e.phone_work_direct ELSE NULL END,
    CASE WHEN e.phone_work_pabx IS DISTINCT FROM chk.phone_work_pabx THEN e.phone_work_pabx ELSE NULL END,
    CASE WHEN e.phone_work_pabx_ext IS DISTINCT FROM chk.phone_work_pabx_ext THEN e.phone_work_pabx_ext ELSE NULL END,
    CASE WHEN e.phone_mobile IS DISTINCT FROM chk.phone_mobile THEN e.phone_mobile ELSE NULL END,
    CASE WHEN e.emergency_contact IS DISTINCT FROM chk.emergency_contact THEN e.emergency_contact ELSE NULL END,
    CASE WHEN e.probation_period_months IS DISTINCT FROM chk.probation_period_months THEN e.probation_period_months ELSE NULL END,
    CASE WHEN e.confirmation_due_date IS DISTINCT FROM chk.confirmation_due_date THEN e.confirmation_due_date ELSE NULL END,
    CASE WHEN e.tax_identification_no IS DISTINCT FROM chk.tax_identification_no THEN e.tax_identification_no ELSE NULL END,
    CASE WHEN e.tax_salary_circle IS DISTINCT FROM chk.tax_salary_circle THEN e.tax_salary_circle ELSE NULL END,
    CASE WHEN e.tax_zone IS DISTINCT FROM chk.tax_zone THEN e.tax_zone ELSE NULL END,
    CASE WHEN e.tax_resident IS DISTINCT FROM chk.tax_resident THEN e.tax_resident ELSE NULL END,
    CASE WHEN e.passport_no IS DISTINCT FROM chk.passport_no THEN e.passport_no ELSE NULL END,
    CASE WHEN e.passport_issue_date IS DISTINCT FROM chk.passport_issue_date THEN e.passport_issue_date ELSE NULL END,
    CASE WHEN e.passport_expiry_date IS DISTINCT FROM chk.passport_expiry_date THEN e.passport_expiry_date ELSE NULL END,
    CASE WHEN e.passport_issued_by IS DISTINCT FROM chk.passport_issued_by THEN e.passport_issued_by ELSE NULL END,
    CASE WHEN e.driving_license_no IS DISTINCT FROM chk.driving_license_no THEN e.driving_license_no ELSE NULL END,
    CASE WHEN e.driving_license_issued_by IS DISTINCT FROM chk.driving_license_issued_by THEN e.driving_license_issued_by ELSE NULL END,
    CASE WHEN e.blood_group IS DISTINCT FROM chk.blood_group THEN e.blood_group ELSE NULL END,
    CASE WHEN e.pay_type IS DISTINCT FROM chk.pay_type THEN e.pay_type ELSE NULL END,
    CASE WHEN e.nationality_id IS DISTINCT FROM chk.nationality_id THEN e.nationality_id ELSE NULL END,
    CASE WHEN e.marital_status IS DISTINCT FROM chk.marital_status THEN e.marital_status ELSE NULL END,
    CASE WHEN e.email_company IS DISTINCT FROM chk.email_company THEN e.email_company ELSE NULL END,
    CASE WHEN e.email_personal IS DISTINCT FROM chk.email_personal THEN e.email_personal ELSE NULL END,
    CASE WHEN e.job_title IS DISTINCT FROM chk.job_title THEN e.job_title ELSE NULL END,
    CASE WHEN e.designation_id IS DISTINCT FROM chk.designation_id THEN e.designation_id ELSE NULL END,
    CASE WHEN e.job_profile_id IS DISTINCT FROM chk.job_profile_id THEN e.job_profile_id ELSE NULL END,
    CASE WHEN e.job_position_id IS DISTINCT FROM chk.job_position_id THEN e.job_position_id ELSE NULL END,
    CASE WHEN e.empl_grade_id IS DISTINCT FROM chk.empl_grade_id THEN e.empl_grade_id ELSE NULL END,
    CASE WHEN e.empl_grade_sub_id IS DISTINCT FROM chk.empl_grade_sub_id THEN e.empl_grade_sub_id ELSE NULL END,
    CASE WHEN e.pay_period IS DISTINCT FROM chk.pay_period THEN e.pay_period ELSE NULL END,
    CASE WHEN e.salary_amt_period IS DISTINCT FROM chk.salary_amt_period THEN e.salary_amt_period ELSE NULL END,
    CASE WHEN e.pay_overtime IS DISTINCT FROM chk.pay_overtime THEN e.pay_overtime ELSE NULL END,
    CASE WHEN e.total_salary_amount IS DISTINCT FROM chk.total_salary_amount THEN e.total_salary_amount ELSE NULL END,
    CASE WHEN e.allowance_second_pmt_id IS DISTINCT FROM chk.allowance_second_pmt_id THEN e.allowance_second_pmt_id ELSE NULL END,
    CASE WHEN e.second_pmt_mehod_percent IS DISTINCT FROM chk.second_pmt_mehod_percent THEN e.second_pmt_mehod_percent ELSE NULL END,
    CASE WHEN e.salary_amt_second_pmt IS DISTINCT FROM chk.salary_amt_second_pmt THEN e.salary_amt_second_pmt ELSE NULL END,
    CASE WHEN e.salary_amount IS DISTINCT FROM chk.salary_amount THEN e.salary_amount ELSE NULL END,
    CASE WHEN e.with_hold_salary IS DISTINCT FROM chk.with_hold_salary THEN e.with_hold_salary ELSE NULL END,
    CASE WHEN e.empl_category_id IS DISTINCT FROM chk.empl_category_id THEN e.empl_category_id ELSE NULL END,
    CASE WHEN e.section_id IS DISTINCT FROM chk.section_id THEN e.section_id ELSE NULL END,
    CASE WHEN e.employee_group_id IS DISTINCT FROM chk.employee_group_id THEN e.employee_group_id ELSE NULL END,
    CASE WHEN e.bank_branch_id IS DISTINCT FROM chk.bank_branch_id THEN e.bank_branch_id ELSE NULL END,
    CASE WHEN e.bank_branch_name IS DISTINCT FROM chk.bank_branch_name THEN e.bank_branch_name ELSE NULL END,
    CASE WHEN e.bank_account IS DISTINCT FROM chk.bank_account THEN e.bank_account ELSE NULL END,
    CASE WHEN e.current_address IS DISTINCT FROM chk.current_address THEN e.current_address ELSE NULL END,
    CASE WHEN e.current_district_id IS DISTINCT FROM chk.current_district_id THEN e.current_district_id ELSE NULL END,
    CASE WHEN e.current_country_id IS DISTINCT FROM chk.current_country_id THEN e.current_country_id ELSE NULL END,
    CASE WHEN e.permanent_address IS DISTINCT FROM chk.permanent_address THEN e.permanent_address ELSE NULL END,
    CASE WHEN e.permanent_district_id IS DISTINCT FROM chk.permanent_district_id THEN e.permanent_district_id ELSE NULL END,
    CASE WHEN e.permanent_country_id IS DISTINCT FROM chk.permanent_country_id THEN e.permanent_country_id ELSE NULL END,
    CASE WHEN e.holiday_calendar_id IS DISTINCT FROM chk.holiday_calendar_id THEN e.holiday_calendar_id ELSE NULL END,
    CASE WHEN e.leave_profile_id IS DISTINCT FROM chk.leave_profile_id THEN e.leave_profile_id ELSE NULL END,
    CASE WHEN e.ot_hourly_rate IS DISTINCT FROM chk.ot_hourly_rate THEN e.ot_hourly_rate ELSE NULL END,
    CASE WHEN e.work_shift_id IS DISTINCT FROM chk.work_shift_id THEN e.work_shift_id ELSE NULL END,
    CASE WHEN e.work_shift_rotated IS DISTINCT FROM chk.work_shift_rotated THEN e.work_shift_rotated ELSE NULL END,
    CASE WHEN e.work_shift_rotate_rule_id IS DISTINCT FROM chk.work_shift_rotate_rule_id THEN e.work_shift_rotate_rule_id ELSE NULL END,
    CASE WHEN e.work_shift_effect_date IS DISTINCT FROM chk.work_shift_effect_date THEN e.work_shift_effect_date ELSE NULL END,
    CASE WHEN e.job_offered IS DISTINCT FROM chk.job_offered THEN e.job_offered ELSE NULL END,
    CASE WHEN e.job_offer_no IS DISTINCT FROM chk.job_offer_no THEN e.job_offer_no ELSE NULL END,
    CASE WHEN e.job_appointment_issued IS DISTINCT FROM chk.job_appointment_issued THEN e.job_appointment_issued ELSE NULL END,
    CASE WHEN e.salary_ready_for_app IS DISTINCT FROM chk.salary_ready_for_app THEN e.salary_ready_for_app ELSE NULL END,
    CASE WHEN e.salary_approved IS DISTINCT FROM chk.salary_approved THEN e.salary_approved ELSE NULL END,
    CASE WHEN e.salary_approve_date IS DISTINCT FROM chk.salary_approve_date THEN e.salary_approve_date ELSE NULL END,
    CASE WHEN e.salary_approved_user IS DISTINCT FROM chk.salary_approved_user THEN e.salary_approved_user ELSE NULL END,
    CASE WHEN e.empl_separation_id IS DISTINCT FROM chk.empl_separation_id THEN e.empl_separation_id ELSE NULL END,
    CASE WHEN e.payscale_or_paystructure IS DISTINCT FROM chk.payscale_or_paystructure THEN e.payscale_or_paystructure ELSE NULL END,
    CASE WHEN e.payscale_structure_id IS DISTINCT FROM chk.payscale_structure_id THEN e.payscale_structure_id ELSE NULL END,
    CASE WHEN e.payscale_id IS DISTINCT FROM chk.payscale_id THEN e.payscale_id ELSE NULL END,
    CASE WHEN e.payscale_cmp_id IS DISTINCT FROM chk.payscale_cmp_id THEN e.payscale_cmp_id ELSE NULL END,
    CASE WHEN e.basic_salary_cmp IS DISTINCT FROM chk.basic_salary_cmp THEN e.basic_salary_cmp ELSE NULL END,
    CASE WHEN e.update_date IS DISTINCT FROM chk.update_date THEN e.update_date ELSE NULL END,
    CASE WHEN e.religion_id IS DISTINCT FROM chk.religion_id THEN e.religion_id ELSE NULL END,
    CASE WHEN e.birth_certificate_no IS DISTINCT FROM chk.birth_certificate_no THEN e.birth_certificate_no ELSE NULL END,
    CASE WHEN e.signature_speciman IS DISTINCT FROM chk.signature_speciman THEN e.signature_speciman ELSE NULL END,
    CASE WHEN e.signature_update_date IS DISTINCT FROM chk.signature_update_date THEN e.signature_update_date ELSE NULL END,
    CASE WHEN e.schedule_work_calendar IS DISTINCT FROM chk.schedule_work_calendar THEN e.schedule_work_calendar ELSE NULL END,
    CASE WHEN e.hr_business_partner_id IS DISTINCT FROM chk.hr_business_partner_id THEN e.hr_business_partner_id ELSE NULL END,
    CASE WHEN e.temp_separated IS DISTINCT FROM chk.temp_separated THEN e.temp_separated ELSE NULL END,
    CASE WHEN e.attend_location_id IS DISTINCT FROM chk.attend_location_id THEN e.attend_location_id ELSE NULL END,
    CASE WHEN e.attend_latitude IS DISTINCT FROM chk.attend_latitude THEN e.attend_latitude ELSE NULL END,
    CASE WHEN e.attend_longitude IS DISTINCT FROM chk.attend_longitude THEN e.attend_longitude ELSE NULL END,
    CASE WHEN e.cost_alloc_many_cost_cent IS DISTINCT FROM chk.cost_alloc_many_cost_cent THEN e.cost_alloc_many_cost_cent ELSE NULL END,
    CASE WHEN e.deleted_by IS DISTINCT FROM chk.deleted_by THEN e.deleted_by ELSE NULL END,
    CASE WHEN e.deleted_date IS DISTINCT FROM chk.deleted_date THEN e.deleted_date ELSE NULL END,
    CASE WHEN e.pr_payment_method_id IS DISTINCT FROM chk.pr_payment_method_id THEN e.pr_payment_method_id ELSE NULL END,
    CASE WHEN e.pr_payment_method_sec_id IS DISTINCT FROM chk.pr_payment_method_sec_id THEN e.pr_payment_method_sec_id ELSE NULL END,
    CASE WHEN e.separation_date IS DISTINCT FROM chk.separation_date THEN e.separation_date ELSE NULL END,
    CASE WHEN e.attend_tracking_type IS DISTINCT FROM chk.attend_tracking_type THEN e.attend_tracking_type ELSE NULL END,
    CASE WHEN e.attend_track_type_effect_date IS DISTINCT FROM chk.attend_track_type_effect_date THEN e.attend_track_type_effect_date ELSE NULL END,
    CASE WHEN e.holiday_cal_effective_date IS DISTINCT FROM chk.holiday_cal_effective_date THEN e.holiday_cal_effective_date ELSE NULL END,
    CASE WHEN e.route_no IS DISTINCT FROM chk.route_no THEN e.route_no ELSE NULL END,
    'Update' AS operation_type,         -- fixed value
    FALSE AS is_done,                   -- boolean default
    NOW() AS last_updated_at,           -- timestamp
    NOW() AS updated_at                 -- default timestamp
FROM mdg_empl_profile e
JOIN mdg_empl_prof_old chk ON e.id = chk.id
WHERE
    e.dtype IS DISTINCT FROM chk.dtype OR
    e.version IS DISTINCT FROM chk.version OR
    e.created_by IS DISTINCT FROM chk.created_by OR
    e.created_date IS DISTINCT FROM chk.created_date OR
    e.last_modified_by IS DISTINCT FROM chk.last_modified_by OR
    e.last_modified_date IS DISTINCT FROM chk.last_modified_date OR
    e.empl_number IS DISTINCT FROM chk.empl_number OR
    e.employee_code IS DISTINCT FROM chk.employee_code OR
    e.first_name IS DISTINCT FROM chk.first_name OR
    e.middle_name IS DISTINCT FROM chk.middle_name OR
    e.last_name IS DISTINCT FROM chk.last_name OR
    e.name IS DISTINCT FROM chk.name OR
    e.father_name IS DISTINCT FROM chk.father_name OR
    e.mother_name IS DISTINCT FROM chk.mother_name OR
    e.empl_photo IS DISTINCT FROM chk.empl_photo OR
    e.market_hierarchy_id IS DISTINCT FROM chk.market_hierarchy_id OR
    e.manager_id IS DISTINCT FROM chk.manager_id OR
    e.manager_matrix_id IS DISTINCT FROM chk.manager_matrix_id OR
    e.company_id IS DISTINCT FROM chk.company_id OR
    e.department_id IS DISTINCT FROM chk.department_id OR
    e.operating_location_id IS DISTINCT FROM chk.operating_location_id OR
    e.functional_area_id IS DISTINCT FROM chk.functional_area_id OR
    e.job_family_id IS DISTINCT FROM chk.job_family_id OR
    e.hr_business_part_prof_id IS DISTINCT FROM chk.hr_business_part_prof_id OR
    e.birth_date IS DISTINCT FROM chk.birth_date OR
    e.join_date_actual IS DISTINCT FROM chk.join_date_actual OR
    e.employment_status IS DISTINCT FROM chk.employment_status OR
    e.confirmation_date IS DISTINCT FROM chk.confirmation_date OR
    e.contract_end_date IS DISTINCT FROM chk.contract_end_date OR
    e.workflow_group_id IS DISTINCT FROM chk.workflow_group_id OR
    e.pf_member_id IS DISTINCT FROM chk.pf_member_id OR
    e.gratuity_member_id IS DISTINCT FROM chk.gratuity_member_id OR
    e.dps_member_id IS DISTINCT FROM chk.dps_member_id OR
    e.gross_salary IS DISTINCT FROM chk.gross_salary OR
    e.basic_salary IS DISTINCT FROM chk.basic_salary OR
    e.empl_type IS DISTINCT FROM chk.empl_type OR
    e.gratuity_effective_date IS DISTINCT FROM chk.gratuity_effective_date OR
    e.bonus_entitlement_status IS DISTINCT FROM chk.bonus_entitlement_status OR
    e.attend_card_id IS DISTINCT FROM chk.attend_card_id OR
    e.spouse IS DISTINCT FROM chk.spouse OR
    e.number_of_child IS DISTINCT FROM chk.number_of_child OR
    e.empl_date IS DISTINCT FROM chk.empl_date OR
    e.join_date_planned IS DISTINCT FROM chk.join_date_planned OR
    e.curr_position_since IS DISTINCT FROM chk.curr_position_since OR
    e.marriage_date IS DISTINCT FROM chk.marriage_date OR
    e.job_description IS DISTINCT FROM chk.job_description OR
    e.national_id IS DISTINCT FROM chk.national_id OR
    e.gender IS DISTINCT FROM chk.gender OR
    e.phone_home IS DISTINCT FROM chk.phone_home OR
    e.phone_work_direct IS DISTINCT FROM chk.phone_work_direct OR
    e.phone_work_pabx IS DISTINCT FROM chk.phone_work_pabx OR
    e.phone_work_pabx_ext IS DISTINCT FROM chk.phone_work_pabx_ext OR
    e.phone_mobile IS DISTINCT FROM chk.phone_mobile OR
    e.emergency_contact IS DISTINCT FROM chk.emergency_contact OR
    e.probation_period_months IS DISTINCT FROM chk.probation_period_months OR
    e.confirmation_due_date IS DISTINCT FROM chk.confirmation_due_date OR
    e.tax_identification_no IS DISTINCT FROM chk.tax_identification_no OR
    e.tax_salary_circle IS DISTINCT FROM chk.tax_salary_circle OR
    e.tax_zone IS DISTINCT FROM chk.tax_zone OR
    e.tax_resident IS DISTINCT FROM chk.tax_resident OR
    e.passport_no IS DISTINCT FROM chk.passport_no OR
    e.passport_issue_date IS DISTINCT FROM chk.passport_issue_date OR
    e.passport_expiry_date IS DISTINCT FROM chk.passport_expiry_date OR
    e.passport_issued_by IS DISTINCT FROM chk.passport_issued_by OR
    e.driving_license_no IS DISTINCT FROM chk.driving_license_no OR
    e.driving_license_issued_by IS DISTINCT FROM chk.driving_license_issued_by OR
    e.blood_group IS DISTINCT FROM chk.blood_group OR
    e.pay_type IS DISTINCT FROM chk.pay_type OR
    e.nationality_id IS DISTINCT FROM chk.nationality_id OR
    e.marital_status IS DISTINCT FROM chk.marital_status OR
    e.email_company IS DISTINCT FROM chk.email_company OR
    e.email_personal IS DISTINCT FROM chk.email_personal OR
    e.job_title IS DISTINCT FROM chk.job_title OR
    e.designation_id IS DISTINCT FROM chk.designation_id OR
    e.job_profile_id IS DISTINCT FROM chk.job_profile_id OR
    e.job_position_id IS DISTINCT FROM chk.job_position_id OR
    e.empl_grade_id IS DISTINCT FROM chk.empl_grade_id OR
    e.empl_grade_sub_id IS DISTINCT FROM chk.empl_grade_sub_id OR
    e.pay_period IS DISTINCT FROM chk.pay_period OR
    e.salary_amt_period IS DISTINCT FROM chk.salary_amt_period OR
    e.pay_overtime IS DISTINCT FROM chk.pay_overtime OR
    e.total_salary_amount IS DISTINCT FROM chk.total_salary_amount OR
    e.allowance_second_pmt_id IS DISTINCT FROM chk.allowance_second_pmt_id OR
    e.second_pmt_mehod_percent IS DISTINCT FROM chk.second_pmt_mehod_percent OR
    e.salary_amt_second_pmt IS DISTINCT FROM chk.salary_amt_second_pmt OR
    e.salary_amount IS DISTINCT FROM chk.salary_amount OR
    e.with_hold_salary IS DISTINCT FROM chk.with_hold_salary OR
    e.empl_category_id IS DISTINCT FROM chk.empl_category_id OR
    e.section_id IS DISTINCT FROM chk.section_id OR
    e.employee_group_id IS DISTINCT FROM chk.employee_group_id OR
    e.bank_branch_id IS DISTINCT FROM chk.bank_branch_id OR
    e.bank_branch_name IS DISTINCT FROM chk.bank_branch_name OR
    e.bank_account IS DISTINCT FROM chk.bank_account OR
    e.current_address IS DISTINCT FROM chk.current_address OR
    e.current_district_id IS DISTINCT FROM chk.current_district_id OR
    e.current_country_id IS DISTINCT FROM chk.current_country_id OR
    e.permanent_address IS DISTINCT FROM chk.permanent_address OR
    e.permanent_district_id IS DISTINCT FROM chk.permanent_district_id OR
    e.permanent_country_id IS DISTINCT FROM chk.permanent_country_id OR
    e.holiday_calendar_id IS DISTINCT FROM chk.holiday_calendar_id OR
    e.leave_profile_id IS DISTINCT FROM chk.leave_profile_id OR
    e.ot_hourly_rate IS DISTINCT FROM chk.ot_hourly_rate OR
    e.work_shift_id IS DISTINCT FROM chk.work_shift_id OR
    e.work_shift_rotated IS DISTINCT FROM chk.work_shift_rotated OR
    e.work_shift_rotate_rule_id IS DISTINCT FROM chk.work_shift_rotate_rule_id OR
    e.work_shift_effect_date IS DISTINCT FROM chk.work_shift_effect_date OR
    e.job_offered IS DISTINCT FROM chk.job_offered OR
    e.job_offer_no IS DISTINCT FROM chk.job_offer_no OR
    e.job_appointment_issued IS DISTINCT FROM chk.job_appointment_issued OR
    e.salary_ready_for_app IS DISTINCT FROM chk.salary_ready_for_app OR
    e.salary_approved IS DISTINCT FROM chk.salary_approved OR
    e.salary_approve_date IS DISTINCT FROM chk.salary_approve_date OR
    e.salary_approved_user IS DISTINCT FROM chk.salary_approved_user OR
    e.empl_separation_id IS DISTINCT FROM chk.empl_separation_id OR
    e.payscale_or_paystructure IS DISTINCT FROM chk.payscale_or_paystructure OR
    e.payscale_structure_id IS DISTINCT FROM chk.payscale_structure_id OR
    e.payscale_id IS DISTINCT FROM chk.payscale_id OR
    e.payscale_cmp_id IS DISTINCT FROM chk.payscale_cmp_id OR
    e.basic_salary_cmp IS DISTINCT FROM chk.basic_salary_cmp OR
    e.update_date IS DISTINCT FROM chk.update_date OR
    e.religion_id IS DISTINCT FROM chk.religion_id OR
    e.birth_certificate_no IS DISTINCT FROM chk.birth_certificate_no OR
    e.signature_speciman IS DISTINCT FROM chk.signature_speciman OR
    e.signature_update_date IS DISTINCT FROM chk.signature_update_date OR
    e.schedule_work_calendar IS DISTINCT FROM chk.schedule_work_calendar OR
    e.hr_business_partner_id IS DISTINCT FROM chk.hr_business_partner_id OR
    e.temp_separated IS DISTINCT FROM chk.temp_separated OR
    e.attend_location_id IS DISTINCT FROM chk.attend_location_id OR
    e.attend_latitude IS DISTINCT FROM chk.attend_latitude OR
    e.attend_longitude IS DISTINCT FROM chk.attend_longitude OR
    e.cost_alloc_many_cost_cent IS DISTINCT FROM chk.cost_alloc_many_cost_cent OR
    e.deleted_by IS DISTINCT FROM chk.deleted_by OR
    e.deleted_date IS DISTINCT FROM chk.deleted_date OR
    e.pr_payment_method_id IS DISTINCT FROM chk.pr_payment_method_id OR
    e.pr_payment_method_sec_id IS DISTINCT FROM chk.pr_payment_method_sec_id OR
    e.separation_date IS DISTINCT FROM chk.separation_date OR
    e.attend_tracking_type IS DISTINCT FROM chk.attend_tracking_type OR
    e.attend_track_type_effect_date IS DISTINCT FROM chk.attend_track_type_effect_date OR
    e.holiday_cal_effective_date IS DISTINCT FROM chk.holiday_cal_effective_date OR
    e.route_no IS DISTINCT FROM chk.route_no;

--delete from chk_for_updates_on_mdg_2;

INSERT INTO chk_for_updates_on_mdg_2 (
    id, dtype, version, created_by, created_date, last_modified_by, last_modified_date,
    empl_number, employee_code, first_name, middle_name, last_name, name, father_name,
    mother_name, empl_photo, market_hierarchy_id, manager_id, manager_matrix_id, company_id,
    department_id, operating_location_id, functional_area_id, job_family_id, hr_business_part_prof_id,
    birth_date, join_date_actual, employment_status, confirmation_date, contract_end_date,
    workflow_group_id, pf_member_id, gratuity_member_id, dps_member_id, gross_salary, basic_salary,
    empl_type, gratuity_effective_date, bonus_entitlement_status, attend_card_id, spouse, number_of_child,
    empl_date, join_date_planned, curr_position_since, marriage_date, job_description, national_id,
    gender, phone_home, phone_work_direct, phone_work_pabx, phone_work_pabx_ext, phone_mobile,
    emergency_contact, probation_period_months, confirmation_due_date, tax_identification_no, tax_salary_circle,
    tax_zone, tax_resident, passport_no, passport_issue_date, passport_expiry_date, passport_issued_by,
    driving_license_no, driving_license_issued_by, blood_group, pay_type, nationality_id, marital_status,
    email_company, email_personal, job_title, designation_id, job_profile_id, job_position_id, empl_grade_id,
    empl_grade_sub_id, pay_period, salary_amt_period, pay_overtime, total_salary_amount,
    allowance_second_pmt_id, second_pmt_mehod_percent, salary_amt_second_pmt, salary_amount, with_hold_salary,
    empl_category_id, section_id, employee_group_id, bank_branch_id, bank_branch_name, bank_account,
    current_address, current_district_id, current_country_id, permanent_address, permanent_district_id,
    permanent_country_id, holiday_calendar_id, leave_profile_id, ot_hourly_rate, work_shift_id, work_shift_rotated,
    work_shift_rotate_rule_id, work_shift_effect_date, job_offered, job_offer_no, job_appointment_issued,
    salary_ready_for_app, salary_approved, salary_approve_date, salary_approved_user, empl_separation_id,
    payscale_or_paystructure, payscale_structure_id, payscale_id, payscale_cmp_id, basic_salary_cmp, update_date,
    religion_id, birth_certificate_no, signature_speciman, signature_update_date, schedule_work_calendar,
    hr_business_partner_id, temp_separated, attend_location_id, attend_latitude, attend_longitude,
    cost_alloc_many_cost_cent, deleted_by, deleted_date, pr_payment_method_id, pr_payment_method_sec_id,
    separation_date, attend_tracking_type, attend_track_type_effect_date, holiday_cal_effective_date, route_no
)
SELECT
    e.id,
    CASE WHEN e.dtype IS DISTINCT FROM chk.dtype THEN chk.dtype ELSE NULL END,
    CASE WHEN e.version IS DISTINCT FROM chk.version THEN chk.version ELSE NULL END,
    CASE WHEN e.created_by IS DISTINCT FROM chk.created_by THEN chk.created_by ELSE NULL END,
    CASE WHEN e.created_date IS DISTINCT FROM chk.created_date THEN chk.created_date ELSE NULL END,
    CASE WHEN e.last_modified_by IS DISTINCT FROM chk.last_modified_by THEN chk.last_modified_by ELSE NULL END,
    coalesce(chk.last_modified_date,chk.created_date),
    chk.empl_number,
    CASE WHEN e.employee_code IS DISTINCT FROM chk.employee_code THEN chk.employee_code ELSE NULL END,
    CASE WHEN e.first_name IS DISTINCT FROM chk.first_name THEN chk.first_name ELSE NULL END,
    CASE WHEN e.middle_name IS DISTINCT FROM chk.middle_name THEN chk.middle_name ELSE NULL END,
    CASE WHEN e.last_name IS DISTINCT FROM chk.last_name THEN chk.last_name ELSE NULL END,
    CASE WHEN e.name IS DISTINCT FROM chk.name THEN chk.name ELSE NULL END,
    CASE WHEN e.father_name IS DISTINCT FROM chk.father_name THEN chk.father_name ELSE NULL END,
    CASE WHEN e.mother_name IS DISTINCT FROM chk.mother_name THEN chk.mother_name ELSE NULL END,
    CASE WHEN e.empl_photo IS DISTINCT FROM chk.empl_photo THEN chk.empl_photo ELSE NULL END,
    CASE WHEN e.market_hierarchy_id IS DISTINCT FROM chk.market_hierarchy_id THEN chk.market_hierarchy_id ELSE NULL END,
    CASE WHEN e.manager_id IS DISTINCT FROM chk.manager_id THEN chk.manager_id ELSE NULL END,
    CASE WHEN e.manager_matrix_id IS DISTINCT FROM chk.manager_matrix_id THEN chk.manager_matrix_id ELSE NULL END,
    CASE WHEN e.company_id IS DISTINCT FROM chk.company_id THEN chk.company_id ELSE NULL END,
    CASE WHEN e.department_id IS DISTINCT FROM chk.department_id THEN chk.department_id ELSE NULL END,
    CASE WHEN e.operating_location_id IS DISTINCT FROM chk.operating_location_id THEN chk.operating_location_id ELSE NULL END,
    CASE WHEN e.functional_area_id IS DISTINCT FROM chk.functional_area_id THEN chk.functional_area_id ELSE NULL END,
    CASE WHEN e.job_family_id IS DISTINCT FROM chk.job_family_id THEN chk.job_family_id ELSE NULL END,
    CASE WHEN e.hr_business_part_prof_id IS DISTINCT FROM chk.hr_business_part_prof_id THEN chk.hr_business_part_prof_id ELSE NULL END,
    CASE WHEN e.birth_date IS DISTINCT FROM chk.birth_date THEN chk.birth_date ELSE NULL END,
    CASE WHEN e.join_date_actual IS DISTINCT FROM chk.join_date_actual THEN chk.join_date_actual ELSE NULL END,
    CASE WHEN e.employment_status IS DISTINCT FROM chk.employment_status THEN chk.employment_status ELSE NULL END,
    CASE WHEN e.confirmation_date IS DISTINCT FROM chk.confirmation_date THEN chk.confirmation_date ELSE NULL END,
    CASE WHEN e.contract_end_date IS DISTINCT FROM chk.contract_end_date THEN chk.contract_end_date ELSE NULL END,
    CASE WHEN e.workflow_group_id IS DISTINCT FROM chk.workflow_group_id THEN chk.workflow_group_id ELSE NULL END,
    CASE WHEN e.pf_member_id IS DISTINCT FROM chk.pf_member_id THEN chk.pf_member_id ELSE NULL END,
    CASE WHEN e.gratuity_member_id IS DISTINCT FROM chk.gratuity_member_id THEN chk.gratuity_member_id ELSE NULL END,
    CASE WHEN e.dps_member_id IS DISTINCT FROM chk.dps_member_id THEN chk.dps_member_id ELSE NULL END,
    CASE WHEN e.gross_salary IS DISTINCT FROM chk.gross_salary THEN chk.gross_salary ELSE NULL END,
    CASE WHEN e.basic_salary IS DISTINCT FROM chk.basic_salary THEN chk.basic_salary ELSE NULL END,
    CASE WHEN e.empl_type IS DISTINCT FROM chk.empl_type THEN chk.empl_type ELSE NULL END,
    CASE WHEN e.gratuity_effective_date IS DISTINCT FROM chk.gratuity_effective_date THEN chk.gratuity_effective_date ELSE NULL END,
    CASE WHEN e.bonus_entitlement_status IS DISTINCT FROM chk.bonus_entitlement_status THEN chk.bonus_entitlement_status ELSE NULL END,
    CASE WHEN e.attend_card_id IS DISTINCT FROM chk.attend_card_id THEN chk.attend_card_id ELSE NULL END,
    CASE WHEN e.spouse IS DISTINCT FROM chk.spouse THEN chk.spouse ELSE NULL END,
    CASE WHEN e.number_of_child IS DISTINCT FROM chk.number_of_child THEN chk.number_of_child ELSE NULL END,
    CASE WHEN e.empl_date IS DISTINCT FROM chk.empl_date THEN chk.empl_date ELSE NULL END,
    CASE WHEN e.join_date_planned IS DISTINCT FROM chk.join_date_planned THEN chk.join_date_planned ELSE NULL END,
    CASE WHEN e.curr_position_since IS DISTINCT FROM chk.curr_position_since THEN chk.curr_position_since ELSE NULL END,
    CASE WHEN e.marriage_date IS DISTINCT FROM chk.marriage_date THEN chk.marriage_date ELSE NULL END,
    CASE WHEN e.job_description IS DISTINCT FROM chk.job_description THEN chk.job_description ELSE NULL END,
    CASE WHEN e.national_id IS DISTINCT FROM chk.national_id THEN chk.national_id ELSE NULL END,
    CASE WHEN e.gender IS DISTINCT FROM chk.gender THEN chk.gender ELSE NULL END,
    CASE WHEN e.phone_home IS DISTINCT FROM chk.phone_home THEN chk.phone_home ELSE NULL END,
    CASE WHEN e.phone_work_direct IS DISTINCT FROM chk.phone_work_direct THEN chk.phone_work_direct ELSE NULL END,
    CASE WHEN e.phone_work_pabx IS DISTINCT FROM chk.phone_work_pabx THEN chk.phone_work_pabx ELSE NULL END,
    CASE WHEN e.phone_work_pabx_ext IS DISTINCT FROM chk.phone_work_pabx_ext THEN chk.phone_work_pabx_ext ELSE NULL END,
    CASE WHEN e.phone_mobile IS DISTINCT FROM chk.phone_mobile THEN chk.phone_mobile ELSE NULL END,
    CASE WHEN e.emergency_contact IS DISTINCT FROM chk.emergency_contact THEN chk.emergency_contact ELSE NULL END,
    CASE WHEN e.probation_period_months IS DISTINCT FROM chk.probation_period_months THEN chk.probation_period_months ELSE NULL END,
    CASE WHEN e.confirmation_due_date IS DISTINCT FROM chk.confirmation_due_date THEN chk.confirmation_due_date ELSE NULL END,
    CASE WHEN e.tax_identification_no IS DISTINCT FROM chk.tax_identification_no THEN chk.tax_identification_no ELSE NULL END,
    CASE WHEN e.tax_salary_circle IS DISTINCT FROM chk.tax_salary_circle THEN chk.tax_salary_circle ELSE NULL END,
    CASE WHEN e.tax_zone IS DISTINCT FROM chk.tax_zone THEN chk.tax_zone ELSE NULL END,
    CASE WHEN e.tax_resident IS DISTINCT FROM chk.tax_resident THEN chk.tax_resident ELSE NULL END,
    CASE WHEN e.passport_no IS DISTINCT FROM chk.passport_no THEN chk.passport_no ELSE NULL END,
    CASE WHEN e.passport_issue_date IS DISTINCT FROM chk.passport_issue_date THEN chk.passport_issue_date ELSE NULL END,
    CASE WHEN e.passport_expiry_date IS DISTINCT FROM chk.passport_expiry_date THEN chk.passport_expiry_date ELSE NULL END,
    CASE WHEN e.passport_issued_by IS DISTINCT FROM chk.passport_issued_by THEN chk.passport_issued_by ELSE NULL END,
    CASE WHEN e.driving_license_no IS DISTINCT FROM chk.driving_license_no THEN chk.driving_license_no ELSE NULL END,
    CASE WHEN e.driving_license_issued_by IS DISTINCT FROM chk.driving_license_issued_by THEN chk.driving_license_issued_by ELSE NULL END,
    CASE WHEN e.blood_group IS DISTINCT FROM chk.blood_group THEN chk.blood_group ELSE NULL END,
    CASE WHEN e.pay_type IS DISTINCT FROM chk.pay_type THEN chk.pay_type ELSE NULL END,
    CASE WHEN e.nationality_id IS DISTINCT FROM chk.nationality_id THEN chk.nationality_id ELSE NULL END,
    CASE WHEN e.marital_status IS DISTINCT FROM chk.marital_status THEN chk.marital_status ELSE NULL END,
    CASE WHEN e.email_company IS DISTINCT FROM chk.email_company THEN chk.email_company ELSE NULL END,
    CASE WHEN e.email_personal IS DISTINCT FROM chk.email_personal THEN chk.email_personal ELSE NULL END,
    CASE WHEN e.job_title IS DISTINCT FROM chk.job_title THEN chk.job_title ELSE NULL END,
    CASE WHEN e.designation_id IS DISTINCT FROM chk.designation_id THEN chk.designation_id ELSE NULL END,
    CASE WHEN e.job_profile_id IS DISTINCT FROM chk.job_profile_id THEN chk.job_profile_id ELSE NULL END,
    CASE WHEN e.job_position_id IS DISTINCT FROM chk.job_position_id THEN chk.job_position_id ELSE NULL END,
    CASE WHEN e.empl_grade_id IS DISTINCT FROM chk.empl_grade_id THEN chk.empl_grade_id ELSE NULL END,
    CASE WHEN e.empl_grade_sub_id IS DISTINCT FROM chk.empl_grade_sub_id THEN chk.empl_grade_sub_id ELSE NULL END,
    CASE WHEN e.pay_period IS DISTINCT FROM chk.pay_period THEN chk.pay_period ELSE NULL END,
    CASE WHEN e.salary_amt_period IS DISTINCT FROM chk.salary_amt_period THEN chk.salary_amt_period ELSE NULL END,
    CASE WHEN e.pay_overtime IS DISTINCT FROM chk.pay_overtime THEN chk.pay_overtime ELSE NULL END,
    CASE WHEN e.total_salary_amount IS DISTINCT FROM chk.total_salary_amount THEN chk.total_salary_amount ELSE NULL END,
    CASE WHEN e.allowance_second_pmt_id IS DISTINCT FROM chk.allowance_second_pmt_id THEN chk.allowance_second_pmt_id ELSE NULL END,
    CASE WHEN e.second_pmt_mehod_percent IS DISTINCT FROM chk.second_pmt_mehod_percent THEN chk.second_pmt_mehod_percent ELSE NULL END,
    CASE WHEN e.salary_amt_second_pmt IS DISTINCT FROM chk.salary_amt_second_pmt THEN chk.salary_amt_second_pmt ELSE NULL END,
    CASE WHEN e.salary_amount IS DISTINCT FROM chk.salary_amount THEN chk.salary_amount ELSE NULL END,
    CASE WHEN e.with_hold_salary IS DISTINCT FROM chk.with_hold_salary THEN chk.with_hold_salary ELSE NULL END,
    CASE WHEN e.empl_category_id IS DISTINCT FROM chk.empl_category_id THEN chk.empl_category_id ELSE NULL END,
    CASE WHEN e.section_id IS DISTINCT FROM chk.section_id THEN chk.section_id ELSE NULL END,
    CASE WHEN e.employee_group_id IS DISTINCT FROM chk.employee_group_id THEN chk.employee_group_id ELSE NULL END,
    CASE WHEN e.bank_branch_id IS DISTINCT FROM chk.bank_branch_id THEN chk.bank_branch_id ELSE NULL END,
    CASE WHEN e.bank_branch_name IS DISTINCT FROM chk.bank_branch_name THEN chk.bank_branch_name ELSE NULL END,
    CASE WHEN e.bank_account IS DISTINCT FROM chk.bank_account THEN chk.bank_account ELSE NULL END,
    CASE WHEN e.current_address IS DISTINCT FROM chk.current_address THEN chk.current_address ELSE NULL END,
    CASE WHEN e.current_district_id IS DISTINCT FROM chk.current_district_id THEN chk.current_district_id ELSE NULL END,
    CASE WHEN e.current_country_id IS DISTINCT FROM chk.current_country_id THEN chk.current_country_id ELSE NULL END,
    CASE WHEN e.permanent_address IS DISTINCT FROM chk.permanent_address THEN chk.permanent_address ELSE NULL END,
    CASE WHEN e.permanent_district_id IS DISTINCT FROM chk.permanent_district_id THEN chk.permanent_district_id ELSE NULL END,
    CASE WHEN e.permanent_country_id IS DISTINCT FROM chk.permanent_country_id THEN chk.permanent_country_id ELSE NULL END,
    CASE WHEN e.holiday_calendar_id IS DISTINCT FROM chk.holiday_calendar_id THEN chk.holiday_calendar_id ELSE NULL END,
    CASE WHEN e.leave_profile_id IS DISTINCT FROM chk.leave_profile_id THEN chk.leave_profile_id ELSE NULL END,
    CASE WHEN e.ot_hourly_rate IS DISTINCT FROM chk.ot_hourly_rate THEN chk.ot_hourly_rate ELSE NULL END,
    CASE WHEN e.work_shift_id IS DISTINCT FROM chk.work_shift_id THEN chk.work_shift_id ELSE NULL END,
    CASE WHEN e.work_shift_rotated IS DISTINCT FROM chk.work_shift_rotated THEN chk.work_shift_rotated ELSE NULL END,
    CASE WHEN e.work_shift_rotate_rule_id IS DISTINCT FROM chk.work_shift_rotate_rule_id THEN chk.work_shift_rotate_rule_id ELSE NULL END,
    CASE WHEN e.work_shift_effect_date IS DISTINCT FROM chk.work_shift_effect_date THEN chk.work_shift_effect_date ELSE NULL END,
    CASE WHEN e.job_offered IS DISTINCT FROM chk.job_offered THEN chk.job_offered ELSE NULL END,
    CASE WHEN e.job_offer_no IS DISTINCT FROM chk.job_offer_no THEN chk.job_offer_no ELSE NULL END,
    CASE WHEN e.job_appointment_issued IS DISTINCT FROM chk.job_appointment_issued THEN chk.job_appointment_issued ELSE NULL END,
    CASE WHEN e.salary_ready_for_app IS DISTINCT FROM chk.salary_ready_for_app THEN chk.salary_ready_for_app ELSE NULL END,
    CASE WHEN e.salary_approved IS DISTINCT FROM chk.salary_approved THEN chk.salary_approved ELSE NULL END,
    CASE WHEN e.salary_approve_date IS DISTINCT FROM chk.salary_approve_date THEN chk.salary_approve_date ELSE NULL END,
    CASE WHEN e.salary_approved_user IS DISTINCT FROM chk.salary_approved_user THEN chk.salary_approved_user ELSE NULL END,
    CASE WHEN e.empl_separation_id IS DISTINCT FROM chk.empl_separation_id THEN chk.empl_separation_id ELSE NULL END,
    CASE WHEN e.payscale_or_paystructure IS DISTINCT FROM chk.payscale_or_paystructure THEN chk.payscale_or_paystructure ELSE NULL END,
    CASE WHEN e.payscale_structure_id IS DISTINCT FROM chk.payscale_structure_id THEN chk.payscale_structure_id ELSE NULL END,
    CASE WHEN e.payscale_id IS DISTINCT FROM chk.payscale_id THEN chk.payscale_id ELSE NULL END,
    CASE WHEN e.payscale_cmp_id IS DISTINCT FROM chk.payscale_cmp_id THEN chk.payscale_cmp_id ELSE NULL END,
    CASE WHEN e.basic_salary_cmp IS DISTINCT FROM chk.basic_salary_cmp THEN chk.basic_salary_cmp ELSE NULL END,
    CASE WHEN e.update_date IS DISTINCT FROM chk.update_date THEN chk.update_date ELSE NULL END,
    CASE WHEN e.religion_id IS DISTINCT FROM chk.religion_id THEN chk.religion_id ELSE NULL END,
    CASE WHEN e.birth_certificate_no IS DISTINCT FROM chk.birth_certificate_no THEN chk.birth_certificate_no ELSE NULL END,
    CASE WHEN e.signature_speciman IS DISTINCT FROM chk.signature_speciman THEN chk.signature_speciman ELSE NULL END,
    CASE WHEN e.signature_update_date IS DISTINCT FROM chk.signature_update_date THEN chk.signature_update_date ELSE NULL END,
    CASE WHEN e.schedule_work_calendar IS DISTINCT FROM chk.schedule_work_calendar THEN chk.schedule_work_calendar ELSE NULL END,
    CASE WHEN e.hr_business_partner_id IS DISTINCT FROM chk.hr_business_partner_id THEN chk.hr_business_partner_id ELSE NULL END,
    CASE WHEN e.temp_separated IS DISTINCT FROM chk.temp_separated THEN chk.temp_separated ELSE NULL END,
    CASE WHEN e.attend_location_id IS DISTINCT FROM chk.attend_location_id THEN chk.attend_location_id ELSE NULL END,
    CASE WHEN e.attend_latitude IS DISTINCT FROM chk.attend_latitude THEN chk.attend_latitude ELSE NULL END,
    CASE WHEN e.attend_longitude IS DISTINCT FROM chk.attend_longitude THEN chk.attend_longitude ELSE NULL END,
    CASE WHEN e.cost_alloc_many_cost_cent IS DISTINCT FROM chk.cost_alloc_many_cost_cent THEN chk.cost_alloc_many_cost_cent ELSE NULL END,
    CASE WHEN e.deleted_by IS DISTINCT FROM chk.deleted_by THEN chk.deleted_by ELSE NULL END,
    CASE WHEN e.deleted_date IS DISTINCT FROM chk.deleted_date THEN chk.deleted_date ELSE NULL END,
    CASE WHEN e.pr_payment_method_id IS DISTINCT FROM chk.pr_payment_method_id THEN chk.pr_payment_method_id ELSE NULL END,
    CASE WHEN e.pr_payment_method_sec_id IS DISTINCT FROM chk.pr_payment_method_sec_id THEN chk.pr_payment_method_sec_id ELSE NULL END,
    CASE WHEN e.separation_date IS DISTINCT FROM chk.separation_date THEN chk.separation_date ELSE NULL END,
    CASE WHEN e.attend_tracking_type IS DISTINCT FROM chk.attend_tracking_type THEN chk.attend_tracking_type ELSE NULL END,
    CASE WHEN e.attend_track_type_effect_date IS DISTINCT FROM chk.attend_track_type_effect_date THEN chk.attend_track_type_effect_date ELSE NULL END,
    CASE WHEN e.holiday_cal_effective_date IS DISTINCT FROM chk.holiday_cal_effective_date THEN chk.holiday_cal_effective_date ELSE NULL END,
    CASE WHEN e.route_no IS DISTINCT FROM chk.route_no THEN chk.route_no ELSE NULL END
FROM mdg_empl_profile e
JOIN mdg_empl_prof_old chk ON e.id = chk.id
WHERE
    e.dtype IS DISTINCT FROM chk.dtype OR
    e.version IS DISTINCT FROM chk.version OR
    e.created_by IS DISTINCT FROM chk.created_by OR
    e.created_date IS DISTINCT FROM chk.created_date OR
    e.last_modified_by IS DISTINCT FROM chk.last_modified_by OR
    e.last_modified_date IS DISTINCT FROM chk.last_modified_date OR
    e.empl_number IS DISTINCT FROM chk.empl_number OR
    e.employee_code IS DISTINCT FROM chk.employee_code OR
    e.first_name IS DISTINCT FROM chk.first_name OR
    e.middle_name IS DISTINCT FROM chk.middle_name OR
    e.last_name IS DISTINCT FROM chk.last_name OR
    e.name IS DISTINCT FROM chk.name OR
    e.father_name IS DISTINCT FROM chk.father_name OR
    e.mother_name IS DISTINCT FROM chk.mother_name OR
    e.empl_photo IS DISTINCT FROM chk.empl_photo OR
    e.market_hierarchy_id IS DISTINCT FROM chk.market_hierarchy_id OR
    e.manager_id IS DISTINCT FROM chk.manager_id OR
    e.manager_matrix_id IS DISTINCT FROM chk.manager_matrix_id OR
    e.company_id IS DISTINCT FROM chk.company_id OR
    e.department_id IS DISTINCT FROM chk.department_id OR
    e.operating_location_id IS DISTINCT FROM chk.operating_location_id OR
    e.functional_area_id IS DISTINCT FROM chk.functional_area_id OR
    e.job_family_id IS DISTINCT FROM chk.job_family_id OR
    e.hr_business_part_prof_id IS DISTINCT FROM chk.hr_business_part_prof_id OR
    e.birth_date IS DISTINCT FROM chk.birth_date OR
    e.join_date_actual IS DISTINCT FROM chk.join_date_actual OR
    e.employment_status IS DISTINCT FROM chk.employment_status OR
    e.confirmation_date IS DISTINCT FROM chk.confirmation_date OR
    e.contract_end_date IS DISTINCT FROM chk.contract_end_date OR
    e.workflow_group_id IS DISTINCT FROM chk.workflow_group_id OR
    e.pf_member_id IS DISTINCT FROM chk.pf_member_id OR
    e.gratuity_member_id IS DISTINCT FROM chk.gratuity_member_id OR
    e.dps_member_id IS DISTINCT FROM chk.dps_member_id OR
    e.gross_salary IS DISTINCT FROM chk.gross_salary OR
    e.basic_salary IS DISTINCT FROM chk.basic_salary OR
    e.empl_type IS DISTINCT FROM chk.empl_type OR
    e.gratuity_effective_date IS DISTINCT FROM chk.gratuity_effective_date OR
    e.bonus_entitlement_status IS DISTINCT FROM chk.bonus_entitlement_status OR
    e.attend_card_id IS DISTINCT FROM chk.attend_card_id OR
    e.spouse IS DISTINCT FROM chk.spouse OR
    e.number_of_child IS DISTINCT FROM chk.number_of_child OR
    e.empl_date IS DISTINCT FROM chk.empl_date OR
    e.join_date_planned IS DISTINCT FROM chk.join_date_planned OR
    e.curr_position_since IS DISTINCT FROM chk.curr_position_since OR
    e.marriage_date IS DISTINCT FROM chk.marriage_date OR
    e.job_description IS DISTINCT FROM chk.job_description OR
    e.national_id IS DISTINCT FROM chk.national_id OR
    e.gender IS DISTINCT FROM chk.gender OR
    e.phone_home IS DISTINCT FROM chk.phone_home OR
    e.phone_work_direct IS DISTINCT FROM chk.phone_work_direct OR
    e.phone_work_pabx IS DISTINCT FROM chk.phone_work_pabx OR
    e.phone_work_pabx_ext IS DISTINCT FROM chk.phone_work_pabx_ext OR
    e.phone_mobile IS DISTINCT FROM chk.phone_mobile OR
    e.emergency_contact IS DISTINCT FROM chk.emergency_contact OR
    e.probation_period_months IS DISTINCT FROM chk.probation_period_months OR
    e.confirmation_due_date IS DISTINCT FROM chk.confirmation_due_date OR
    e.tax_identification_no IS DISTINCT FROM chk.tax_identification_no OR
    e.tax_salary_circle IS DISTINCT FROM chk.tax_salary_circle OR
    e.tax_zone IS DISTINCT FROM chk.tax_zone OR
    e.tax_resident IS DISTINCT FROM chk.tax_resident OR
    e.passport_no IS DISTINCT FROM chk.passport_no OR
    e.passport_issue_date IS DISTINCT FROM chk.passport_issue_date OR
    e.passport_expiry_date IS DISTINCT FROM chk.passport_expiry_date OR
    e.passport_issued_by IS DISTINCT FROM chk.passport_issued_by OR
    e.driving_license_no IS DISTINCT FROM chk.driving_license_no OR
    e.driving_license_issued_by IS DISTINCT FROM chk.driving_license_issued_by OR
    e.blood_group IS DISTINCT FROM chk.blood_group OR
    e.pay_type IS DISTINCT FROM chk.pay_type OR
    e.nationality_id IS DISTINCT FROM chk.nationality_id OR
    e.marital_status IS DISTINCT FROM chk.marital_status OR
    e.email_company IS DISTINCT FROM chk.email_company OR
    e.email_personal IS DISTINCT FROM chk.email_personal OR
    e.job_title IS DISTINCT FROM chk.job_title OR
    e.designation_id IS DISTINCT FROM chk.designation_id OR
    e.job_profile_id IS DISTINCT FROM chk.job_profile_id OR
    e.job_position_id IS DISTINCT FROM chk.job_position_id OR
    e.empl_grade_id IS DISTINCT FROM chk.empl_grade_id OR
    e.empl_grade_sub_id IS DISTINCT FROM chk.empl_grade_sub_id OR
    e.pay_period IS DISTINCT FROM chk.pay_period OR
    e.salary_amt_period IS DISTINCT FROM chk.salary_amt_period OR
    e.pay_overtime IS DISTINCT FROM chk.pay_overtime OR
    e.total_salary_amount IS DISTINCT FROM chk.total_salary_amount OR
    e.allowance_second_pmt_id IS DISTINCT FROM chk.allowance_second_pmt_id OR
    e.second_pmt_mehod_percent IS DISTINCT FROM chk.second_pmt_mehod_percent OR
    e.salary_amt_second_pmt IS DISTINCT FROM chk.salary_amt_second_pmt OR
    e.salary_amount IS DISTINCT FROM chk.salary_amount OR
    e.with_hold_salary IS DISTINCT FROM chk.with_hold_salary OR
    e.empl_category_id IS DISTINCT FROM chk.empl_category_id OR
    e.section_id IS DISTINCT FROM chk.section_id OR
    e.employee_group_id IS DISTINCT FROM chk.employee_group_id OR
    e.bank_branch_id IS DISTINCT FROM chk.bank_branch_id OR
    e.bank_branch_name IS DISTINCT FROM chk.bank_branch_name OR
    e.bank_account IS DISTINCT FROM chk.bank_account OR
    e.current_address IS DISTINCT FROM chk.current_address OR
    e.current_district_id IS DISTINCT FROM chk.current_district_id OR
    e.current_country_id IS DISTINCT FROM chk.current_country_id OR
    e.permanent_address IS DISTINCT FROM chk.permanent_address OR
    e.permanent_district_id IS DISTINCT FROM chk.permanent_district_id OR
    e.permanent_country_id IS DISTINCT FROM chk.permanent_country_id OR
    e.holiday_calendar_id IS DISTINCT FROM chk.holiday_calendar_id OR
    e.leave_profile_id IS DISTINCT FROM chk.leave_profile_id OR
    e.ot_hourly_rate IS DISTINCT FROM chk.ot_hourly_rate OR
    e.work_shift_id IS DISTINCT FROM chk.work_shift_id OR
    e.work_shift_rotated IS DISTINCT FROM chk.work_shift_rotated OR
    e.work_shift_rotate_rule_id IS DISTINCT FROM chk.work_shift_rotate_rule_id OR
    e.work_shift_effect_date IS DISTINCT FROM chk.work_shift_effect_date OR
    e.job_offered IS DISTINCT FROM chk.job_offered OR
    e.job_offer_no IS DISTINCT FROM chk.job_offer_no OR
    e.job_appointment_issued IS DISTINCT FROM chk.job_appointment_issued OR
    e.salary_ready_for_app IS DISTINCT FROM chk.salary_ready_for_app OR
    e.salary_approved IS DISTINCT FROM chk.salary_approved OR
    e.salary_approve_date IS DISTINCT FROM chk.salary_approve_date OR
    e.salary_approved_user IS DISTINCT FROM chk.salary_approved_user OR
    e.empl_separation_id IS DISTINCT FROM chk.empl_separation_id OR
    e.payscale_or_paystructure IS DISTINCT FROM chk.payscale_or_paystructure OR
    e.payscale_structure_id IS DISTINCT FROM chk.payscale_structure_id OR
    e.payscale_id IS DISTINCT FROM chk.payscale_id OR
    e.payscale_cmp_id IS DISTINCT FROM chk.payscale_cmp_id OR
    e.basic_salary_cmp IS DISTINCT FROM chk.basic_salary_cmp OR
    e.update_date IS DISTINCT FROM chk.update_date OR
    e.religion_id IS DISTINCT FROM chk.religion_id OR
    e.birth_certificate_no IS DISTINCT FROM chk.birth_certificate_no OR
    e.signature_speciman IS DISTINCT FROM chk.signature_speciman OR
    e.signature_update_date IS DISTINCT FROM chk.signature_update_date OR
    e.schedule_work_calendar IS DISTINCT FROM chk.schedule_work_calendar OR
    e.hr_business_partner_id IS DISTINCT FROM chk.hr_business_partner_id OR
    e.temp_separated IS DISTINCT FROM chk.temp_separated OR
    e.attend_location_id IS DISTINCT FROM chk.attend_location_id OR
    e.attend_latitude IS DISTINCT FROM chk.attend_latitude OR
    e.attend_longitude IS DISTINCT FROM chk.attend_longitude OR
    e.cost_alloc_many_cost_cent IS DISTINCT FROM chk.cost_alloc_many_cost_cent OR
    e.deleted_by IS DISTINCT FROM chk.deleted_by OR
    e.deleted_date IS DISTINCT FROM chk.deleted_date OR
    e.pr_payment_method_id IS DISTINCT FROM chk.pr_payment_method_id OR
    e.pr_payment_method_sec_id IS DISTINCT FROM chk.pr_payment_method_sec_id OR
    e.separation_date IS DISTINCT FROM chk.separation_date OR
    e.attend_tracking_type IS DISTINCT FROM chk.attend_tracking_type OR
    e.attend_track_type_effect_date IS DISTINCT FROM chk.attend_track_type_effect_date OR
    e.holiday_cal_effective_date IS DISTINCT FROM chk.holiday_cal_effective_date OR
    e.route_no IS DISTINCT FROM chk.route_no;


CREATE TABLE Change_data_capture_snapshot (
id uuid,
employee_code VARCHAR(255),
empl_number_old varchar(255), empl_number_new varchar(255),
first_name_old varchar(255), first_name_new varchar(255),
middle_name_old varchar(255), middle_name_new varchar(255),
last_name_old varchar(255), last_name_new varchar(255),
name_old varchar(255), name_new varchar(255),
father_name_old varchar(255), father_name_new varchar(255),
mother_name_old varchar(255), mother_name_new varchar(255),
empl_photo_old bytea, empl_photo_new bytea,
market_hierarchy_id_old uuid, market_hierarchy_id_new uuid,
manager_id_old uuid, manager_id_new uuid,
manager_matrix_id_old uuid, manager_matrix_id_new uuid,
company_id_old uuid, company_id_new uuid,
department_id_old uuid, department_id_new uuid,
operating_location_id_old uuid, operating_location_id_new uuid,
functional_area_id_old uuid, functional_area_id_new uuid,
job_family_id_old uuid, job_family_id_new uuid,
hr_business_part_prof_id_old uuid, hr_business_part_prof_id_new uuid,
birth_date_old date, birth_date_new date,
join_date_actual_old date, join_date_actual_new date,
employment_status_old integer, employment_status_new integer,
confirmation_date_old date, confirmation_date_new date,
contract_end_date_old date, contract_end_date_new date,
workflow_group_id_old uuid, workflow_group_id_new uuid,
pf_member_id_old uuid, pf_member_id_new uuid,
gratuity_member_id_old uuid, gratuity_member_id_new uuid,
dps_member_id_old uuid, dps_member_id_new uuid,
gross_salary_old double precision, gross_salary_new double precision,
basic_salary_old double precision, basic_salary_new double precision,
empl_type_old integer, empl_type_new integer,
gratuity_effective_date_old date, gratuity_effective_date_new date,
bonus_entitlement_status_old integer, bonus_entitlement_status_new integer,
attend_card_id_old varchar(255), attend_card_id_new varchar(255),
spouse_old varchar(255), spouse_new varchar(255),
number_of_child_old integer, number_of_child_new integer,
empl_date_old date, empl_date_new date,
join_date_planned_old date, join_date_planned_new date,
curr_position_since_old date, curr_position_since_new date,
marriage_date_old date, marriage_date_new date,
job_description_old text, job_description_new text,
national_id_old varchar(255), national_id_new varchar(255),
gender_old varchar(255), gender_new varchar(255),
phone_home_old varchar(255), phone_home_new varchar(255),
phone_work_direct_old varchar(255), phone_work_direct_new varchar(255),
phone_work_pabx_old varchar(255), phone_work_pabx_new varchar(255),
phone_work_pabx_ext_old varchar(255), phone_work_pabx_ext_new varchar(255),
phone_mobile_old varchar(255), phone_mobile_new varchar(255),
emergency_contact_old varchar(255), emergency_contact_new varchar(255),
probation_period_months_old double precision, probation_period_months_new double precision,
confirmation_due_date_old date, confirmation_due_date_new date,
tax_identification_no_old varchar(255), tax_identification_no_new varchar(255),
tax_salary_circle_old varchar(255), tax_salary_circle_new varchar(255),
tax_zone_old varchar(255), tax_zone_new varchar(255),
tax_resident_old boolean, tax_resident_new boolean,
passport_no_old varchar(255), passport_no_new varchar(255),
passport_issue_date_old date, passport_issue_date_new date,
passport_expiry_date_old date, passport_expiry_date_new date,
passport_issued_by_old varchar(255), passport_issued_by_new varchar(255),
driving_license_no_old varchar(255), driving_license_no_new varchar(255),
driving_license_issued_by_old varchar(255), driving_license_issued_by_new varchar(255),
blood_group_old integer, blood_group_new integer,
pay_type_old integer, pay_type_new integer,
nationality_id_old uuid, nationality_id_new uuid,
marital_status_old varchar(255), marital_status_new varchar(255),
email_company_old varchar(255), email_company_new varchar(255),
email_personal_old varchar(255), email_personal_new varchar(255),
job_title_old varchar(255), job_title_new varchar(255),
designation_id_old uuid, designation_id_new uuid,
job_profile_id_old uuid, job_profile_id_new uuid,
job_position_id_old uuid, job_position_id_new uuid,
empl_grade_id_old uuid, empl_grade_id_new uuid,
empl_grade_sub_id_old uuid, empl_grade_sub_id_new uuid,
pay_period_old integer, pay_period_new integer,
salary_amt_period_old integer, salary_amt_period_new integer,
pay_overtime_old boolean, pay_overtime_new boolean,
total_salary_amount_old double precision, total_salary_amount_new double precision,
allowance_second_pmt_id_old uuid, allowance_second_pmt_id_new uuid,
second_pmt_mehod_percent_old double precision, second_pmt_mehod_percent_new double precision,
salary_amt_second_pmt_old double precision, salary_amt_second_pmt_new double precision,
salary_amount_old double precision, salary_amount_new double precision,
with_hold_salary_old boolean, with_hold_salary_new boolean,
empl_category_id_old uuid, empl_category_id_new uuid,
section_id_old uuid, section_id_new uuid,
employee_group_id_old uuid, employee_group_id_new uuid,
bank_branch_id_old uuid, bank_branch_id_new uuid,
bank_branch_name_old varchar(255), bank_branch_name_new varchar(255),
bank_account_old varchar(255), bank_account_new varchar(255),
current_address_old text, current_address_new text,
current_district_id_old uuid, current_district_id_new uuid,
current_country_id_old uuid, current_country_id_new uuid,
permanent_address_old text, permanent_address_new text,
permanent_district_id_old uuid, permanent_district_id_new uuid,
permanent_country_id_old uuid, permanent_country_id_new uuid,
holiday_calendar_id_old uuid, holiday_calendar_id_new uuid,
leave_profile_id_old uuid, leave_profile_id_new uuid,
ot_hourly_rate_old double precision, ot_hourly_rate_new double precision,
work_shift_id_old uuid, work_shift_id_new uuid,
work_shift_rotated_old boolean, work_shift_rotated_new boolean,
work_shift_rotate_rule_id_old uuid, work_shift_rotate_rule_id_new uuid,
work_shift_effect_date_old date, work_shift_effect_date_new date,
job_offered_old boolean, job_offered_new boolean,
job_offer_no_old varchar(255), job_offer_no_new varchar(255),
job_appointment_issued_old boolean, job_appointment_issued_new boolean,
salary_ready_for_app_old boolean, salary_ready_for_app_new boolean,
salary_approved_old boolean, salary_approved_new boolean,
salary_approve_date_old timestamp, salary_approve_date_new timestamp,
salary_approved_user_old varchar(255), salary_approved_user_new varchar(255),
empl_separation_id_old uuid, empl_separation_id_new uuid,
payscale_or_paystructure_old integer, payscale_or_paystructure_new integer,
payscale_structure_id_old uuid, payscale_structure_id_new uuid,
payscale_id_old uuid, payscale_id_new uuid,
payscale_cmp_id_old uuid, payscale_cmp_id_new uuid,
basic_salary_cmp_old double precision, basic_salary_cmp_new double precision,
update_date_old timestamp, update_date_new timestamp,
religion_id_old uuid, religion_id_new uuid,
birth_certificate_no_old varchar(255), birth_certificate_no_new varchar(255),
signature_speciman_old bytea, signature_speciman_new bytea,
signature_update_date_old timestamp, signature_update_date_new timestamp,
schedule_work_calendar_old boolean, schedule_work_calendar_new boolean,
hr_business_partner_id_old uuid, hr_business_partner_id_new uuid,
temp_separated_old boolean, temp_separated_new boolean,
attend_location_id_old uuid, attend_location_id_new uuid,
attend_latitude_old double precision, attend_latitude_new double precision,
attend_longitude_old double precision, attend_longitude_new double precision,
cost_alloc_many_cost_cent_old boolean, cost_alloc_many_cost_cent_new boolean,
deleted_by_old varchar(255), deleted_by_new varchar(255),
deleted_date_old timestamptz, deleted_date_new timestamptz,
pr_payment_method_id_old uuid, pr_payment_method_id_new uuid,
pr_payment_method_sec_id_old uuid, pr_payment_method_sec_id_new uuid,
separation_date_old date, separation_date_new date,
attend_tracking_type_old integer, attend_tracking_type_new integer,
attend_track_type_effect_date_old date, attend_track_type_effect_date_new date,
holiday_cal_effective_date_old date, holiday_cal_effective_date_new date,
route_no_old varchar(255), route_no_new varchar(255),
operation_type VARCHAR(10),         -- 'Insert' or 'Update'
is_done BOOLEAN DEFAULT FALSE,      -- Processing status
last_updated_at TIMESTAMP,          -- From the source table
updated_at TIMESTAMP DEFAULT NOW()  -- Change detection timestamp
);

--delete from change_data_capture_snapshot;

INSERT INTO change_data_capture_snapshot (
    id,
    employee_code,
    empl_number_old, empl_number_new,
    first_name_old, first_name_new,
    middle_name_old, middle_name_new,
    last_name_old, last_name_new,
    name_old, name_new,
    father_name_old, father_name_new,
    mother_name_old, mother_name_new,
    empl_photo_old, empl_photo_new,
    market_hierarchy_id_old, market_hierarchy_id_new,
    manager_id_old, manager_id_new,
    manager_matrix_id_old, manager_matrix_id_new,
    company_id_old, company_id_new,
    department_id_old, department_id_new,
    operating_location_id_old, operating_location_id_new,
    functional_area_id_old, functional_area_id_new,
    job_family_id_old, job_family_id_new,
    hr_business_part_prof_id_old, hr_business_part_prof_id_new,
    birth_date_old, birth_date_new,
    join_date_actual_old, join_date_actual_new,
    employment_status_old, employment_status_new,
    confirmation_date_old, confirmation_date_new,
    contract_end_date_old, contract_end_date_new,
    workflow_group_id_old, workflow_group_id_new,
    pf_member_id_old, pf_member_id_new,
    gratuity_member_id_old, gratuity_member_id_new,
    dps_member_id_old, dps_member_id_new,
    gross_salary_old, gross_salary_new,
    basic_salary_old, basic_salary_new,
    empl_type_old, empl_type_new,
    gratuity_effective_date_old, gratuity_effective_date_new,
    bonus_entitlement_status_old, bonus_entitlement_status_new,
    attend_card_id_old, attend_card_id_new,
    spouse_old, spouse_new,
    number_of_child_old, number_of_child_new,
    empl_date_old, empl_date_new,
    join_date_planned_old, join_date_planned_new,
    curr_position_since_old, curr_position_since_new,
    marriage_date_old, marriage_date_new,
    job_description_old, job_description_new,
    national_id_old, national_id_new,
    gender_old, gender_new,
    phone_home_old, phone_home_new,
    phone_work_direct_old, phone_work_direct_new,
    phone_work_pabx_old, phone_work_pabx_new,
    phone_work_pabx_ext_old, phone_work_pabx_ext_new,
    phone_mobile_old, phone_mobile_new,
    emergency_contact_old, emergency_contact_new,
    probation_period_months_old, probation_period_months_new,
    confirmation_due_date_old, confirmation_due_date_new,
    tax_identification_no_old, tax_identification_no_new,
    tax_salary_circle_old, tax_salary_circle_new,
    tax_zone_old, tax_zone_new,
    tax_resident_old, tax_resident_new,
    passport_no_old, passport_no_new,
    passport_issue_date_old, passport_issue_date_new,
    passport_expiry_date_old, passport_expiry_date_new,
    passport_issued_by_old, passport_issued_by_new,
    driving_license_no_old, driving_license_no_new,
    driving_license_issued_by_old, driving_license_issued_by_new,
    blood_group_old, blood_group_new,
    pay_type_old, pay_type_new,
    nationality_id_old, nationality_id_new,
    marital_status_old, marital_status_new,
    email_company_old, email_company_new,
    email_personal_old, email_personal_new,
    job_title_old, job_title_new,
    designation_id_old, designation_id_new,
    job_profile_id_old, job_profile_id_new,
    job_position_id_old, job_position_id_new,
    empl_grade_id_old, empl_grade_id_new,
    empl_grade_sub_id_old, empl_grade_sub_id_new,
    pay_period_old, pay_period_new,
    salary_amt_period_old, salary_amt_period_new,
    pay_overtime_old, pay_overtime_new,
    total_salary_amount_old, total_salary_amount_new,
    allowance_second_pmt_id_old, allowance_second_pmt_id_new,
    second_pmt_mehod_percent_old, second_pmt_mehod_percent_new,
    salary_amt_second_pmt_old, salary_amt_second_pmt_new,
    salary_amount_old, salary_amount_new,
    with_hold_salary_old, with_hold_salary_new,
    empl_category_id_old, empl_category_id_new,
    section_id_old, section_id_new,
    employee_group_id_old, employee_group_id_new,
    bank_branch_id_old, bank_branch_id_new,
    bank_branch_name_old, bank_branch_name_new,
    bank_account_old, bank_account_new,
    current_address_old, current_address_new,
    current_district_id_old, current_district_id_new,
    current_country_id_old, current_country_id_new,
    permanent_address_old, permanent_address_new,
    permanent_district_id_old, permanent_district_id_new,
    permanent_country_id_old, permanent_country_id_new,
    holiday_calendar_id_old, holiday_calendar_id_new,
    leave_profile_id_old, leave_profile_id_new,
    ot_hourly_rate_old, ot_hourly_rate_new,
    work_shift_id_old, work_shift_id_new,
    work_shift_rotated_old, work_shift_rotated_new,
    work_shift_rotate_rule_id_old, work_shift_rotate_rule_id_new,
    work_shift_effect_date_old, work_shift_effect_date_new,
    job_offered_old, job_offered_new,
    job_offer_no_old, job_offer_no_new,
    job_appointment_issued_old, job_appointment_issued_new,
    salary_ready_for_app_old, salary_ready_for_app_new,
    salary_approved_old, salary_approved_new,
    salary_approve_date_old, salary_approve_date_new,
    salary_approved_user_old, salary_approved_user_new,
    empl_separation_id_old, empl_separation_id_new,
    payscale_or_paystructure_old, payscale_or_paystructure_new,
    payscale_structure_id_old, payscale_structure_id_new,
    payscale_id_old, payscale_id_new,
    payscale_cmp_id_old, payscale_cmp_id_new,
    basic_salary_cmp_old, basic_salary_cmp_new,
    update_date_old, update_date_new,
    religion_id_old, religion_id_new,
    birth_certificate_no_old, birth_certificate_no_new,
    signature_speciman_old, signature_speciman_new,
    signature_update_date_old, signature_update_date_new,
    schedule_work_calendar_old, schedule_work_calendar_new,
    hr_business_partner_id_old, hr_business_partner_id_new,
    temp_separated_old, temp_separated_new,
    attend_location_id_old, attend_location_id_new,
    attend_latitude_old, attend_latitude_new,
    attend_longitude_old, attend_longitude_new,
    cost_alloc_many_cost_cent_old, cost_alloc_many_cost_cent_new,
    deleted_by_old, deleted_by_new,
    deleted_date_old, deleted_date_new,
    pr_payment_method_id_old, pr_payment_method_id_new,
    pr_payment_method_sec_id_old, pr_payment_method_sec_id_new,
    separation_date_old, separation_date_new,
    attend_tracking_type_old, attend_tracking_type_new,
    attend_track_type_effect_date_old, attend_track_type_effect_date_new,
    holiday_cal_effective_date_old, holiday_cal_effective_date_new,
    route_no_old, route_no_new,
    operation_type,
    is_done,
    last_updated_at,
    updated_at
)
SELECT
    COALESCE(new_data.id, old_data.id) AS id,
    COALESCE(new_data.employee_code, old_data.employee_code) AS employee_code,

    -- All the old and new value pairs
    old_data.empl_number AS empl_number_old,    new_data.empl_number AS empl_number_new,
    old_data.first_name AS first_name_old,    new_data.first_name AS first_name_new,
    old_data.middle_name AS middle_name_old,    new_data.middle_name AS middle_name_new,
    old_data.last_name AS last_name_old,    new_data.last_name AS last_name_new,
    old_data.name AS name_old,    new_data.name AS name_new,
    old_data.father_name AS father_name_old,    new_data.father_name AS father_name_new,
    old_data.mother_name AS mother_name_old,    new_data.mother_name AS mother_name_new,
    old_data.empl_photo AS empl_photo_old,    new_data.empl_photo AS empl_photo_new,
    old_data.market_hierarchy_id AS market_hierarchy_id_old,    new_data.market_hierarchy_id AS market_hierarchy_id_new,
    old_data.manager_id AS manager_id_old,    new_data.manager_id AS manager_id_new,
    old_data.manager_matrix_id AS manager_matrix_id_old,    new_data.manager_matrix_id AS manager_matrix_id_new,
    old_data.company_id AS company_id_old,    new_data.company_id AS company_id_new,
    old_data.department_id AS department_id_old,    new_data.department_id AS department_id_new,
    old_data.operating_location_id AS operating_location_id_old,    new_data.operating_location_id AS operating_location_id_new,
    old_data.functional_area_id AS functional_area_id_old,    new_data.functional_area_id AS functional_area_id_new,
    old_data.job_family_id AS job_family_id_old,    new_data.job_family_id AS job_family_id_new,
    old_data.hr_business_part_prof_id AS hr_business_part_prof_id_old,    new_data.hr_business_part_prof_id AS hr_business_part_prof_id_new,
    old_data.birth_date AS birth_date_old,    new_data.birth_date AS birth_date_new,
    old_data.join_date_actual AS join_date_actual_old,    new_data.join_date_actual AS join_date_actual_new,
    old_data.employment_status AS employment_status_old,    new_data.employment_status AS employment_status_new,
    old_data.confirmation_date AS confirmation_date_old,    new_data.confirmation_date AS confirmation_date_new,
    old_data.contract_end_date AS contract_end_date_old,    new_data.contract_end_date AS contract_end_date_new,
    old_data.workflow_group_id AS workflow_group_id_old,    new_data.workflow_group_id AS workflow_group_id_new,
    old_data.pf_member_id AS pf_member_id_old,    new_data.pf_member_id AS pf_member_id_new,
    old_data.gratuity_member_id AS gratuity_member_id_old,    new_data.gratuity_member_id AS gratuity_member_id_new,
    old_data.dps_member_id AS dps_member_id_old,    new_data.dps_member_id AS dps_member_id_new,
    old_data.gross_salary AS gross_salary_old,    new_data.gross_salary AS gross_salary_new,
    old_data.basic_salary AS basic_salary_old,    new_data.basic_salary AS basic_salary_new,
    old_data.empl_type AS empl_type_old,    new_data.empl_type AS empl_type_new,
    old_data.gratuity_effective_date AS gratuity_effective_date_old,    new_data.gratuity_effective_date AS gratuity_effective_date_new,
    old_data.bonus_entitlement_status AS bonus_entitlement_status_old,    new_data.bonus_entitlement_status AS bonus_entitlement_status_new,
    old_data.attend_card_id AS attend_card_id_old,    new_data.attend_card_id AS attend_card_id_new,
    old_data.spouse AS spouse_old,    new_data.spouse AS spouse_new,
    old_data.number_of_child AS number_of_child_old,    new_data.number_of_child AS number_of_child_new,
    old_data.empl_date AS empl_date_old,    new_data.empl_date AS empl_date_new,
    old_data.join_date_planned AS join_date_planned_old,    new_data.join_date_planned AS join_date_planned_new,
    old_data.curr_position_since AS curr_position_since_old,    new_data.curr_position_since AS curr_position_since_new,
    old_data.marriage_date AS marriage_date_old,    new_data.marriage_date AS marriage_date_new,
    old_data.job_description AS job_description_old,    new_data.job_description AS job_description_new,
    old_data.national_id AS national_id_old,    new_data.national_id AS national_id_new,
    old_data.gender AS gender_old,    new_data.gender AS gender_new,
    old_data.phone_home AS phone_home_old,    new_data.phone_home AS phone_home_new,
    old_data.phone_work_direct AS phone_work_direct_old,    new_data.phone_work_direct AS phone_work_direct_new,
    old_data.phone_work_pabx AS phone_work_pabx_old,    new_data.phone_work_pabx AS phone_work_pabx_new,
    old_data.phone_work_pabx_ext AS phone_work_pabx_ext_old,    new_data.phone_work_pabx_ext AS phone_work_pabx_ext_new,
    old_data.phone_mobile AS phone_mobile_old,    new_data.phone_mobile AS phone_mobile_new,
    old_data.emergency_contact AS emergency_contact_old,    new_data.emergency_contact AS emergency_contact_new,
    old_data.probation_period_months AS probation_period_months_old,    new_data.probation_period_months AS probation_period_months_new,
    old_data.confirmation_due_date AS confirmation_due_date_old,    new_data.confirmation_due_date AS confirmation_due_date_new,
    old_data.tax_identification_no AS tax_identification_no_old,    new_data.tax_identification_no AS tax_identification_no_new,
    old_data.tax_salary_circle AS tax_salary_circle_old,    new_data.tax_salary_circle AS tax_salary_circle_new,
    old_data.tax_zone AS tax_zone_old,    new_data.tax_zone AS tax_zone_new,
    old_data.tax_resident AS tax_resident_old,    new_data.tax_resident AS tax_resident_new,
    old_data.passport_no AS passport_no_old,    new_data.passport_no AS passport_no_new,
    old_data.passport_issue_date AS passport_issue_date_old,    new_data.passport_issue_date AS passport_issue_date_new,
    old_data.passport_expiry_date AS passport_expiry_date_old,    new_data.passport_expiry_date AS passport_expiry_date_new,
    old_data.passport_issued_by AS passport_issued_by_old,    new_data.passport_issued_by AS passport_issued_by_new,
    old_data.driving_license_no AS driving_license_no_old,    new_data.driving_license_no AS driving_license_no_new,
    old_data.driving_license_issued_by AS driving_license_issued_by_old,    new_data.driving_license_issued_by AS driving_license_issued_by_new,
    old_data.blood_group AS blood_group_old,    new_data.blood_group AS blood_group_new,
    old_data.pay_type AS pay_type_old,    new_data.pay_type AS pay_type_new,
    old_data.nationality_id AS nationality_id_old,    new_data.nationality_id AS nationality_id_new,
    old_data.marital_status AS marital_status_old,    new_data.marital_status AS marital_status_new,
    old_data.email_company AS email_company_old,    new_data.email_company AS email_company_new,
    old_data.email_personal AS email_personal_old,    new_data.email_personal AS email_personal_new,
    old_data.job_title AS job_title_old,    new_data.job_title AS job_title_new,
    old_data.designation_id AS designation_id_old,    new_data.designation_id AS designation_id_new,
    old_data.job_profile_id AS job_profile_id_old,    new_data.job_profile_id AS job_profile_id_new,
    old_data.job_position_id AS job_position_id_old,    new_data.job_position_id AS job_position_id_new,
    old_data.empl_grade_id AS empl_grade_id_old,    new_data.empl_grade_id AS empl_grade_id_new,
    old_data.empl_grade_sub_id AS empl_grade_sub_id_old,    new_data.empl_grade_sub_id AS empl_grade_sub_id_new,
    old_data.pay_period AS pay_period_old,    new_data.pay_period AS pay_period_new,
    old_data.salary_amt_period AS salary_amt_period_old,    new_data.salary_amt_period AS salary_amt_period_new,
    old_data.pay_overtime AS pay_overtime_old,    new_data.pay_overtime AS pay_overtime_new,
    old_data.total_salary_amount AS total_salary_amount_old,    new_data.total_salary_amount AS total_salary_amount_new,
    old_data.allowance_second_pmt_id AS allowance_second_pmt_id_old,    new_data.allowance_second_pmt_id AS allowance_second_pmt_id_new,
    old_data.second_pmt_mehod_percent AS second_pmt_mehod_percent_old,    new_data.second_pmt_mehod_percent AS second_pmt_mehod_percent_new,
    old_data.salary_amt_second_pmt AS salary_amt_second_pmt_old,    new_data.salary_amt_second_pmt AS salary_amt_second_pmt_new,
    old_data.salary_amount AS salary_amount_old,    new_data.salary_amount AS salary_amount_new,
    old_data.with_hold_salary AS with_hold_salary_old,    new_data.with_hold_salary AS with_hold_salary_new,
    old_data.empl_category_id AS empl_category_id_old,    new_data.empl_category_id AS empl_category_id_new,
    old_data.section_id AS section_id_old,    new_data.section_id AS section_id_new,
    old_data.employee_group_id AS employee_group_id_old,    new_data.employee_group_id AS employee_group_id_new,
    old_data.bank_branch_id AS bank_branch_id_old,    new_data.bank_branch_id AS bank_branch_id_new,
    old_data.bank_branch_name AS bank_branch_name_old,    new_data.bank_branch_name AS bank_branch_name_new,
    old_data.bank_account AS bank_account_old,    new_data.bank_account AS bank_account_new,
    old_data.current_address AS current_address_old,    new_data.current_address AS current_address_new,
    old_data.current_district_id AS current_district_id_old,    new_data.current_district_id AS current_district_id_new,
    old_data.current_country_id AS current_country_id_old,    new_data.current_country_id AS current_country_id_new,
    old_data.permanent_address AS permanent_address_old,    new_data.permanent_address AS permanent_address_new,
    old_data.permanent_district_id AS permanent_district_id_old,    new_data.permanent_district_id AS permanent_district_id_new,
    old_data.permanent_country_id AS permanent_country_id_old,    new_data.permanent_country_id AS permanent_country_id_new,
    old_data.holiday_calendar_id AS holiday_calendar_id_old,    new_data.holiday_calendar_id AS holiday_calendar_id_new,
    old_data.leave_profile_id AS leave_profile_id_old,    new_data.leave_profile_id AS leave_profile_id_new,
    old_data.ot_hourly_rate AS ot_hourly_rate_old,    new_data.ot_hourly_rate AS ot_hourly_rate_new,
    old_data.work_shift_id AS work_shift_id_old,    new_data.work_shift_id AS work_shift_id_new,
    old_data.work_shift_rotated AS work_shift_rotated_old,    new_data.work_shift_rotated AS work_shift_rotated_new,
    old_data.work_shift_rotate_rule_id AS work_shift_rotate_rule_id_old,    new_data.work_shift_rotate_rule_id AS work_shift_rotate_rule_id_new,
    old_data.work_shift_effect_date AS work_shift_effect_date_old,    new_data.work_shift_effect_date AS work_shift_effect_date_new,
    old_data.job_offered AS job_offered_old,    new_data.job_offered AS job_offered_new,
    old_data.job_offer_no AS job_offer_no_old,    new_data.job_offer_no AS job_offer_no_new,
    old_data.job_appointment_issued AS job_appointment_issued_old,    new_data.job_appointment_issued AS job_appointment_issued_new,
    old_data.salary_ready_for_app AS salary_ready_for_app_old,    new_data.salary_ready_for_app AS salary_ready_for_app_new,
    old_data.salary_approved AS salary_approved_old,    new_data.salary_approved AS salary_approved_new,
    old_data.salary_approve_date AS salary_approve_date_old,    new_data.salary_approve_date AS salary_approve_date_new,
    old_data.salary_approved_user AS salary_approved_user_old,    new_data.salary_approved_user AS salary_approved_user_new,
    old_data.empl_separation_id AS empl_separation_id_old,    new_data.empl_separation_id AS empl_separation_id_new,
    old_data.payscale_or_paystructure AS payscale_or_paystructure_old,    new_data.payscale_or_paystructure AS payscale_or_paystructure_new,
    old_data.payscale_structure_id AS payscale_structure_id_old,    new_data.payscale_structure_id AS payscale_structure_id_new,
    old_data.payscale_id AS payscale_id_old,    new_data.payscale_id AS payscale_id_new,
    old_data.payscale_cmp_id AS payscale_cmp_id_old,    new_data.payscale_cmp_id AS payscale_cmp_id_new,
    old_data.basic_salary_cmp AS basic_salary_cmp_old,    new_data.basic_salary_cmp AS basic_salary_cmp_new,
    old_data.update_date AS update_date_old,    new_data.update_date AS update_date_new,
    old_data.religion_id AS religion_id_old,    new_data.religion_id AS religion_id_new,
    old_data.birth_certificate_no AS birth_certificate_no_old,    new_data.birth_certificate_no AS birth_certificate_no_new,
    old_data.signature_speciman AS signature_speciman_old,    new_data.signature_speciman AS signature_speciman_new,
    old_data.signature_update_date AS signature_update_date_old,    new_data.signature_update_date AS signature_update_date_new,
    old_data.schedule_work_calendar AS schedule_work_calendar_old,    new_data.schedule_work_calendar AS schedule_work_calendar_new,
    old_data.hr_business_partner_id AS hr_business_partner_id_old,    new_data.hr_business_partner_id AS hr_business_partner_id_new,
    old_data.temp_separated AS temp_separated_old,    new_data.temp_separated AS temp_separated_new,
    old_data.attend_location_id AS attend_location_id_old,    new_data.attend_location_id AS attend_location_id_new,
    old_data.attend_latitude AS attend_latitude_old,    new_data.attend_latitude AS attend_latitude_new,
    old_data.attend_longitude AS attend_longitude_old,    new_data.attend_longitude AS attend_longitude_new,
    old_data.cost_alloc_many_cost_cent AS cost_alloc_many_cost_cent_old,    new_data.cost_alloc_many_cost_cent AS cost_alloc_many_cost_cent_new,
    old_data.deleted_by AS deleted_by_old,    new_data.deleted_by AS deleted_by_new,
    old_data.deleted_date AS deleted_date_old,    new_data.deleted_date AS deleted_date_new,
    old_data.pr_payment_method_id AS pr_payment_method_id_old,    new_data.pr_payment_method_id AS pr_payment_method_id_new,
    old_data.pr_payment_method_sec_id AS pr_payment_method_sec_id_old,    new_data.pr_payment_method_sec_id AS pr_payment_method_sec_id_new,
    old_data.separation_date AS separation_date_old,    new_data.separation_date AS separation_date_new,
    old_data.attend_tracking_type AS attend_tracking_type_old,    new_data.attend_tracking_type AS attend_tracking_type_new,
    old_data.attend_track_type_effect_date AS attend_track_type_effect_date_old,    new_data.attend_track_type_effect_date AS attend_track_type_effect_date_new,
    old_data.holiday_cal_effective_date AS holiday_cal_effective_date_old,    new_data.holiday_cal_effective_date AS holiday_cal_effective_date_new,
    old_data.route_no AS route_no_old,    new_data.route_no AS route_no_new,

    -- The additional columns from the new table
    new_data.operation_type,
    true AS is_done,
    old_data.last_modified_date,
    now() AS updated_at
FROM
    chk_for_updates_on_mdg new_data
FULL OUTER JOIN
    chk_for_updates_on_mdg_2 old_data ON new_data.id = old_data.id;


