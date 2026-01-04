
INSERT INTO HR_EMPL_LEAVE_ATTEN_MD_CHANGE
SELECT
    gen_random_uuid() as id,1 as version,NULL as created_by,NULL as created_at,NULL as last_modified_by,NULL as last_modified_date,
    e.id as employee_profile_id,'mdg_WorkShift' as entity_name,e.work_shift_id as entity_id,null as attend_tracking_type,
    e.work_shift_effect_date
FROM mdg_empl_profile e join payroll_leave_attend_data.employee_records_beta_30 w0 on e.employee_code = w0.pin
where e.work_shift_id is not null   AND NOT EXISTS (
        SELECT 1
        FROM HR_EMPL_LEAVE_ATTEN_MD_CHANGE c
        WHERE c.employee_profile_id   = e.id
          AND c.entity_name           = 'mdg_WorkShift'
          AND c.entity_id             = e.work_shift_id
          AND c.effective_date = e.work_shift_effect_date);

-- leave profile id
INSERT INTO HR_EMPL_LEAVE_ATTEN_MD_CHANGE
SELECT
gen_random_uuid() as id,1 as version,NULL as created_by,NULL as created_at,NULL as last_modified_by,NULL as last_modified_date,
e.id as employee_profile_id,'hmd_LeaveProfile' as entity_name,e.leave_profile_id as entity_id,null as attend_tracking_type
,case
    when e.join_date_actual < '2025-01-01' then '2025-01-01'
    else e.join_date_actual
    end
as effective_date
FROM mdg_empl_profile e join payroll_leave_attend_data.employee_records_beta_30 w0 on e.employee_code = w0.pin
where e.leave_profile_id is not null AND NOT EXISTS (
        SELECT 1
        FROM HR_EMPL_LEAVE_ATTEN_MD_CHANGE c
        WHERE c.employee_profile_id   = e.id
          AND c.entity_name           = 'hmd_LeaveProfile'
          AND c.entity_id             = e.leave_profile_id
          AND c.effective_date = case when e.join_date_actual < '2025-01-01' then '2025-01-01' else e.join_date_actual end);

-- holyday calendar
INSERT INTO HR_EMPL_LEAVE_ATTEN_MD_CHANGE
SELECT
gen_random_uuid() as id,1 as version,NULL as created_by,NULL as created_at,NULL as last_modified_by,NULL as last_modified_date,
e.id as employee_profile_id,'mdg_HolidayCalendar' as entity_name,
e.holiday_calendar_id as entity_id,null as attend_tracking_type,e.holiday_cal_effective_date
FROM mdg_empl_profile e join payroll_leave_attend_data.employee_records_beta_30 w0 on e.employee_code = w0.pin
where e.holiday_calendar_id is not null AND NOT EXISTS (
        SELECT 1
        FROM HR_EMPL_LEAVE_ATTEN_MD_CHANGE c
        WHERE c.employee_profile_id   = e.id
          AND c.entity_name           = 'mdg_HolidayCalendar'
          AND c.entity_id             = e.holiday_calendar_id
          AND c.effective_date = e.holiday_cal_effective_date);

-- attend tracking type
INSERT INTO HR_EMPL_LEAVE_ATTEN_MD_CHANGE
SELECT
gen_random_uuid() as id,1 as version,NULL as created_by,NULL as created_at,NULL as last_modified_by,NULL as last_modified_date,
e.id as employee_profile_id,NULL as entity_name,NULL as entity_id,e.attend_tracking_type as attend_tracking_type
       ,e.attend_track_type_effect_date
FROM mdg_empl_profile e join payroll_leave_attend_data.employee_records_beta_30 w0 on e.employee_code = w0.pin
where e.attend_tracking_type is not null AND NOT EXISTS (
        SELECT 1
        FROM HR_EMPL_LEAVE_ATTEN_MD_CHANGE c
        WHERE c.employee_profile_id   = e.id
          AND c.attend_tracking_type             = e.attend_tracking_type
          AND c.effective_date = e.attend_track_type_effect_date);
;