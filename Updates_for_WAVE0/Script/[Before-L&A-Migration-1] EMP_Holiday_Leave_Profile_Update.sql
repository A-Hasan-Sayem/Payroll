
----------------------------------------------------------------------------first 5 update ----------------------------------------------------------------------------


with cte as(select  e.pin,
                eg.id as employee_group_id,
    case when e.attendance_tracking_type = 'Not Monitored' then 10
        when e.attendance_tracking_type = 'Standard Monitor' then 20
        when e.attendance_tracking_type = 'Manual Entry Exception Only' then 30
    else null end  as attendance_tracking_type,
    ws.id as work_shift_id,
    e.is_shift_rotate as work_shift_rotated,
    e.is_ot_eligible as pay_overtime
from payroll_leave_attend_data.employee_records_beta_30 e inner join public.mdg_empl_profile ep on e.pin = ep.employee_code
    left join public.hmd_employee_group eg on e.employee_group = eg.name
    left join public.mdg_work_shift ws on e.work_shift = ws.name
)
update public.mdg_empl_profile ep
set employee_group_id = c.employee_group_id,
    attend_tracking_type = c.attendance_tracking_type,
    work_shift_id = c.work_shift_id,
    work_shift_rotated = c.work_shift_rotated,
    pay_overtime = c.pay_overtime
    from cte c
where ep.employee_code = c.pin ;

---------------------------------------------------------------------------- Last 2 Update ----------------------------------------------------------------------------

with cte as (select
    ep.pin AS employee_code,
    ecr.holiday_calendar_default_id,
	--holiday_calendar_id
  --leave_profile_id
  CASE
 WHEN e.gender = 'Male' OR e.gender IS NULL THEN ecr.leave_profile_male_id
 WHEN e.gender = 'Female' OR e.gender = '20' THEN ecr.leave_profile_female_id
ELSE ecr.leave_profile_male_id END as leave_profile_id

FROM public.mdg_empl_profile e inner join payroll_leave_attend_data.employee_records_beta_30 ep on ep.pin = e.employee_code
LEFT JOIN public.hmd_employee_group eg ON e.employee_group_id = eg.id
LEFT JOIN public.hmd_empl_category ec ON e.empl_category_id = ec.id
LEFT JOIN public.hmd_empl_category_comp_rule ecr ON ecr.empl_category_id = ec.id AND ecr.employee_group_id = eg.id
)
update public.mdg_empl_profile ep
    set holiday_calendar_id = c.holiday_calendar_default_id,
        leave_profile_id = c.leave_profile_id
from cte c
where ep.employee_code = c.employee_code;

----------------------------------------------------------------------- Effective date update ---------------------------------------------------------

UPDATE public.mdg_empl_profile
SET
    holiday_cal_effective_date = CASE
        WHEN join_date_actual >= '2025-01-01' THEN join_date_actual
        ELSE '2025-01-01'
    END,
    work_shift_effect_date = CASE
        WHEN join_date_actual >= '2025-01-01' THEN join_date_actual
        ELSE '2025-01-01'
    END,
    attend_track_type_effect_date = CASE
        WHEN join_date_actual >= '2025-01-01' THEN join_date_actual
        ELSE '2025-01-01'
    END;


---------------------------------------------------------------------  check all  ---------------------------------------------------------------------------

select
    holiday_calendar_id,
    leave_profile_id,
    employee_group_id ,
    attend_tracking_type ,
    work_shift_id ,
    work_shift_rotated ,
    pay_overtime,
    holiday_cal_effective_date,
    work_shift_effect_date,
    attend_track_type_effect_date
from public.mdg_empl_profile e inner join payroll_leave_attend_data.employee_records_beta_30 ep on ep.pin = e.employee_code
