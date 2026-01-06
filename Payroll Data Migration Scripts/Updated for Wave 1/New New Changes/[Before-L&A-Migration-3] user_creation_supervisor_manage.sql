

select distinct a.employeepin from (
select b.employeepin
               from beta_user b
               Union All
               select aa.employee_code
               from mdg_empl_profile a
                        inner join beta_user b on a.employee_code = b.employeepin
                        inner join mdg_empl_profile aa on aa.id = a.manager_id
) a

;


select * from beta_user;


select * from public.sec_role_assignment;

INSERT INTO public.mdg_user (id, version, username, first_name, last_name, password, email, active, time_zone_id, company_id, customer_id, employee_fund_id, empl_profile_id, mobile_no, tenant, user_category, vendor_id)
select gen_random_uuid(), 1,pr.employee_code , pr.first_name, pr.last_name, '{bcrypt}$2a$10$a.t0rgOOLQQsXUBANoiQde41GQyulw4wVn/nZQYv0x.ZgMIy5lXPy', null, true, null, pr.company_id, null, null, pr.id, null, null, 10, null
from mdg_empl_profile pr
inner join (
    select distinct a.employeepin from (
select b.employeepin
               from beta_user b
               Union All
               select aa.employee_code
               from mdg_empl_profile a
                        inner join beta_user b on a.employee_code = b.employeepin
                        inner join mdg_empl_profile aa on aa.id = a.manager_id
) a
) gu on gu.employeepin=pr.employee_code
where not exists(select * from public.mdg_user us where us.empl_profile_id=pr.id)
  -- and pr.employee_code='00271877'
;


INSERT INTO public.mdg_user_company (id, version, created_by, created_date, last_modified_by, last_modified_date, company_id, access_granted, user_id)
select gen_random_uuid(), 1, 'support', now(), null, null, pr.company_id, true, us.id
from public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id
inner join (
    select distinct a.employeepin from (
select b.employeepin
               from beta_user b
               Union All
               select aa.employee_code
               from mdg_empl_profile a
                        inner join beta_user b on a.employee_code = b.employeepin
                        inner join mdg_empl_profile aa on aa.id = a.manager_id
) a
) gu on gu.employeepin=pr.employee_code
where not exists(select * from public.mdg_user_company uc where us.id=uc.user_id)
 -- and pr.employee_code='00271877'
;


INSERT INTO public.mdg_user_operating_loc (id, version, created_by, created_date, last_modified_by, last_modified_date, operating_location_id, access_granted, user_id)
select gen_random_uuid(), 1, 'support', now(), null, now(), pr.operating_location_id, true, us.id
from  public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id
inner join (
    select distinct a.employeepin from (
select b.employeepin
               from beta_user b
               Union All
               select aa.employee_code
               from mdg_empl_profile a
                        inner join beta_user b on a.employee_code = b.employeepin
                        inner join mdg_empl_profile aa on aa.id = a.manager_id
) a
) gu on gu.employeepin=pr.employee_code
where not exists(select * from public.mdg_user_operating_loc ol where us.id=ol.user_id and ol.operating_location_id=pr.operating_location_id)
  -- and pr.employee_code='00271877'
;


INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
select gen_random_uuid(), 1, now(), 'support', null, null, null, null, us.username, 'EMPLOYEE_USER_DEFAULT_ROLE_CODE', 'resource'
from public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id
inner join (
    select distinct a.employeepin from (
select b.employeepin
               from beta_user b
               Union All
               select aa.employee_code
               from mdg_empl_profile a
                        inner join beta_user b on a.employee_code = b.employeepin
                        inner join mdg_empl_profile aa on aa.id = a.manager_id
) a
) gu on gu.employeepin=pr.employee_code
where not exists(select * from public.sec_role_assignment ra where us.username=ra.username and ra.role_code ='EMPLOYEE_USER_DEFAULT_ROLE_CODE')
  -- and pr.employee_code='00271877'
;


INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
    select gen_random_uuid(), 1, now(), 'support', null, null, null, null, us.username, 'EMPLOYEE_USER_DEFAULT_REPORT_ROLE_CODE', 'resource'
from public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id
inner join (
    select distinct a.employeepin from (
select b.employeepin
               from beta_user b
               Union All
               select aa.employee_code
               from mdg_empl_profile a
                        inner join beta_user b on a.employee_code = b.employeepin
                        inner join mdg_empl_profile aa on aa.id = a.manager_id
) a
) gu on gu.employeepin=pr.employee_code
where not exists(select * from public.sec_role_assignment ra where us.username=ra.username and ra.role_code ='EMPLOYEE_USER_DEFAULT_REPORT_ROLE_CODE')
  -- and  pr.employee_code='00271877'
;

INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
    select gen_random_uuid(), 1, now(), 'support', null, null, null, null, us.username, 'EMPLOYEE_USER_DEFAULT_ROW_LEVEL_ROLE_CODE', 'row_level'
from public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id
inner join (
    select distinct a.employeepin from (
select b.employeepin
               from beta_user b
               Union All
               select aa.employee_code
               from mdg_empl_profile a
                        inner join beta_user b on a.employee_code = b.employeepin
                        inner join mdg_empl_profile aa on aa.id = a.manager_id
) a
) gu on gu.employeepin=pr.employee_code
where not exists(select * from public.sec_role_assignment ra where us.username=ra.username and ra.role_code ='EMPLOYEE_USER_DEFAULT_ROW_LEVEL_ROLE_CODE')
  -- and pr.employee_code='00271877'
;

------ Supervisor dynamic


-- delete from public.sec_role_assignment;
-- select * from public.sec_role_assignment;

DELETE FROM public.sec_role_assignment ra
USING public.mdg_user us
inner JOIN public.mdg_empl_profile pr ON pr.id = us.empl_profile_id
left JOIN public.mdg_empl_profile pr2 on pr2.manager_id=pr.id
WHERE ra.username = us.username
and ra.role_code  in ('ROLE_SUPERVISOR','SUPERVISOR_DATA_EMPLOYE_PROFILE_WS_OT_NT')
and pr2.id is null

;


INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
select gen_random_uuid(), 1, now(), 'support', null, null, null, null, us2.username,
 'ROLE_SUPERVISOR','resource'
from public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id
inner JOIN public.mdg_empl_profile pr2 on pr2.manager_id=pr.id
    inner JOIN public.mdg_user us2 on pr2.id=us2.empl_profile_id
inner join (
    select distinct a.employeepin from (
select b.employeepin
               from beta_user b
               Union All
               select aa.employee_code
               from mdg_empl_profile a
                        inner join beta_user b on a.employee_code = b.employeepin
                        inner join mdg_empl_profile aa on aa.id = a.manager_id
) a
) beta on beta.employeepin=pr.employee_code
where
 not exists(select * from public.sec_role_assignment ra
  where us2.username=ra.username and ra.role_code ='ROLE_SUPERVISOR'
)

;

INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
select gen_random_uuid(), 1, now(), 'support', null, null, null, null, us2.username,
'SUPERVISOR_DATA_EMPLOYE_PROFILE_WS_OT_NT', 'row_level'
from public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id
    inner JOIN public.mdg_empl_profile pr2 on pr2.manager_id=pr.id
    inner JOIN public.mdg_user us2 on pr2.id=us2.empl_profile_id
inner join (
    select distinct a.employeepin from (
select b.employeepin
               from beta_user b
               Union All
               select aa.employee_code
               from mdg_empl_profile a
                        inner join beta_user b on a.employee_code = b.employeepin
                        inner join mdg_empl_profile aa on aa.id = a.manager_id
) a
) beta on beta.employeepin=pr.employee_code

where
 not exists(select * from public.sec_role_assignment ra
  where us2.username=ra.username and ra.role_code ='SUPERVISOR_DATA_EMPLOYE_PROFILE_WS_OT_NT'
)

;


