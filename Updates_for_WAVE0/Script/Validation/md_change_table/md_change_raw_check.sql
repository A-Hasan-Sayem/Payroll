select
    distinct
    gu.pin as employee_pin,
    e.name as employee_name,
    e.work_shift_id,
    ws.shift_code,
    ws.name as workshift_name,
    e.work_shift_effect_date,
    e.holiday_calendar_id,
    hc.calendar_code,
    hc.name as holiday_calendar_name,
    e.holiday_cal_effective_date,
    e.attend_tracking_type,
    e.attend_track_type_effect_date,
    e.leave_profile_id,
    p.leave_prof_code leave_profile_code,
    p.name leave_profile_name,
    (select max(mc.effective_date) from hr_empl_leave_atten_md_change mc
    join mdg_empl_profile emp on mc.employee_profile_id = emp.id
    where emp.id = e.id) as leave_effective_date
    from payroll_leave_attend_data.employee_records_beta_30 gu
        LEFT JOIN mdg_empl_profile e on gu.pin = e.employee_code
        LEFT JOIN mdg_work_shift ws on e.work_shift_id = ws.id
        LEFT JOIN mdg_holiday_calendar hc on e.holiday_calendar_id = hc.id
        LEFT JOIN HMD_LEAVE_PROFILE p ON p.ID = e.LEAVE_PROFILE_ID
        LEFT JOIN HMD_LEAVE_PROFILE_LINE l ON l.LEAVE_PROFILE_ID = p.ID
WHERE e.work_shift_id IS NULL
OR ws.shift_code IS NULL
OR ws.name IS NULL
OR e.work_shift_effect_date IS NULL
OR e.holiday_calendar_id IS NULL
OR hc.calendar_code IS NULL
OR hc.name IS NULL
OR e.holiday_cal_effective_date IS NULL
OR e.attend_tracking_type IS NULL
OR e.attend_track_type_effect_date IS NULL
OR e.leave_profile_id IS NULL
OR p.leave_prof_code IS NULL
OR p.name IS NULL;