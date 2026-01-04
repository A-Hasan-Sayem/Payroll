/*
Schemas: public, payroll_leave_attend_data
Table of wave0 users: payroll_leave_attend_data.employee_records_wave0

*/
-- wave beta
select count(1) from payroll_leave_attend_data.employee_records_beta;
-- wave30
select count(1) from payroll_leave_attend_data.employee_records_beta_30;

-------------------------------------------------------- Main Script Begins ---------------------------------------------------

----------------------------------------- Find out culprits ------------------------------------------------------------------

DROP TABLE IF EXISTS culprits;

CREATE TEMPORARY TABLE culprits AS
SELECT *
FROM mdg_user
WHERE username IN ( select
pr.employee_code
FROM mdg_empl_profile pr
INNER JOIN (
    SELECT DISTINCT a.employeepin
    FROM (
        SELECT b.pin AS employeepin -- employeepin
        FROM payroll_leave_attend_data.employee_records_beta_30 b
        UNION ALL
        SELECT aa.employee_code -- supervisor pin
        FROM mdg_empl_profile a
        INNER JOIN payroll_leave_attend_data.employee_records_beta_30 b
        ON a.employee_code = b.pin
        INNER JOIN mdg_empl_profile aa on aa.id = a.manager_id
        UNION ALL
        SELECT hr.hr_pin -- hr pin
        FROM payroll_leave_attend_data.employee_records_beta_30 hr
        UNION ALL
        SELECT bao.bao_pin -- bao pin
        FROM payroll_leave_attend_data.employee_records_beta_30 bao)
        a
    ) gu
        ON gu.employeepin = pr.employee_code
    WHERE not exists (
        SELECT 1 FROM
        public.mdg_user us
        WHERE us.empl_profile_id=pr.id
            -- this is important because due to us.empl_profile_id = pr.id
            -- this excluded only 1 user: Meherunnesa Moni as she was the only one that had employee profile id
            -- in this batch. The rest of the existing users only has first name, last name and email
        )
    )
AND empl_profile_id is null;

-- Culprits
SELECT * FROM culprits;

-- BEGIN;

-- DELETE EXISTING USERS
DELETE FROM mdg_user
WHERE username IN (
    SELECT username FROM culprits
    );

-- ROLLBACK;

-- check scripts
SELECT COUNT(1) from mdg_user;
SELECT * FROM mdg_user WHERE username in (SELECT username from culprits);

SELECT username, count(1)
from mdg_user
group by username
having count(1) > 1;


-------------------------------------- Inserting general user, supervisor, hr and bao info in the mdg_user table -------------------------------------

INSERT INTO public.mdg_user (id, version, username, first_name, last_name, password, email, active, time_zone_id, company_id, customer_id, employee_fund_id, empl_profile_id, mobile_no, tenant, user_category, vendor_id)
select
    gen_random_uuid(),
    1,
    pr.employee_code,
    pr.first_name,
    pr.last_name,
    '{bcrypt}$2a$10$a.t0rgOOLQQsXUBANoiQde41GQyulw4wVn/nZQYv0x.ZgMIy5lXPy',
    null,
    true,
    null,
    pr.company_id,
    null,
    null,
    pr.id,
    null,
    null,
    10,
    null
from mdg_empl_profile pr
inner join (
    select distinct a.employeepin from (
    select b.pin as employeepin -- employeepin
    from payroll_leave_attend_data.employee_records_beta_30 b
    Union All
    select aa.employee_code -- supervisor pin
    from mdg_empl_profile a
    inner join payroll_leave_attend_data.employee_records_beta_30 b on a.employee_code = b.pin
    inner join mdg_empl_profile aa on aa.id = a.manager_id
    union all
    select hr.hr_pin -- hr pin
    from payroll_leave_attend_data.employee_records_beta_30 hr
    union all
    select bao.bao_pin -- bao pin
    from payroll_leave_attend_data.employee_records_beta_30 bao
) a
) gu on gu.employeepin=pr.employee_code
where not exists (select 1 from public.mdg_user us where us.empl_profile_id=pr.id); -- done


-------------------------------- inserting general user, supervisor, bao and hr's corresponding company id into mdg_user_company -----------------------------

INSERT INTO public.mdg_user_company (id, version, created_by, created_date, last_modified_by, last_modified_date, company_id, access_granted, user_id)
select
    gen_random_uuid(),
    1,
    'support',
    now(),
    null,
    null,
    pr.company_id, -- inserting their corresponding company id
    true,
    us.id
from public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id
inner join (
    select distinct a.employeepin from (
    select b.pin as employeepin -- user pins
    from payroll_leave_attend_data.employee_records_beta_30 b
    Union All
    select aa.employee_code -- supervisor pins
    from mdg_empl_profile a
    inner join payroll_leave_attend_data.employee_records_beta_30 b on a.employee_code = b.pin
    inner join mdg_empl_profile aa on aa.id = a.manager_id
    union all
    select hr.hr_pin -- hr pins
    from payroll_leave_attend_data.employee_records_beta_30 hr
    union all
    select bao.bao_pin -- bao pins
    from payroll_leave_attend_data.employee_records_beta_30 bao
) a
) gu on gu.employeepin=pr.employee_code
where not exists (select 1 from public.mdg_user_company uc where us.id=uc.user_id); -- done

---------------------------------- Inserting General User and Supervisor's operating location in mdg_user_operating_loc ----------------------------

INSERT INTO public.mdg_user_operating_loc (id, version, created_by, created_date, last_modified_by, last_modified_date, operating_location_id, access_granted, user_id)
select
    gen_random_uuid(),
    1,
    'support',
    now(),
    null,
    now(),
    pr.operating_location_id, -- corresponding operating location id
    true,
    us.id
from  public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id
inner join (
    select distinct a.employeepin from (
        select b.pin as employeepin -- user pin
        from payroll_leave_attend_data.employee_records_beta_30 b
        Union ALL
        select aa.employee_code -- supervisor pins
        from mdg_empl_profile a
        inner join payroll_leave_attend_data.employee_records_beta_30 b on a.employee_code = b.pin
        inner join mdg_empl_profile aa on aa.id = a.manager_id
) a
) gu on gu.employeepin=pr.employee_code
where not exists(select 1 from public.mdg_user_operating_loc ol
                          where us.id=ol.user_id and ol.operating_location_id=pr.operating_location_id); --DONE

----------------------- Inserting resource roles to general user, supervisor, bao and hr ---------------------

-- role code: 'EMPLOYEE_USER_DEFAULT_ROLE_CODE' type: 'resource'

INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
select gen_random_uuid(),
       1,
       now(),
       'support',
       null,
       null,
       null,
       null,
       us.username,
       'EMPLOYEE_USER_DEFAULT_ROLE_CODE',
       'resource'
from public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id -- profile id is used
inner join (
    select distinct a.employeepin from (
    select b.pin as employeepin -- user pin
    from payroll_leave_attend_data.employee_records_beta_30 b
    Union All
    select aa.employee_code -- supervisors
    from mdg_empl_profile a
    inner join payroll_leave_attend_data.employee_records_beta_30 b on a.employee_code = b.pin
    inner join mdg_empl_profile aa on aa.id = a.manager_id
    union all
    select hr.hr_pin -- hr pins
    from payroll_leave_attend_data.employee_records_beta_30 hr
    union all
    select bao.bao_pin -- bao pins
    from payroll_leave_attend_data.employee_records_beta_30 bao
) a
) gu on gu.employeepin=pr.employee_code
where not exists (select 1 from public.sec_role_assignment ra
                        where us.username=ra.username
                        and ra.role_code ='EMPLOYEE_USER_DEFAULT_ROLE_CODE'
                        and ra.delete_ts is null
                ); -- DONE

-- SELECT * from sec_role_assignment where username = '00098519' -- THIS PIN IS ALREADY IN THE TABLE, NEED TO REVISIT IT

-- always dup check:

SELECT username
     , count(role_code) as cnt
FROM sec_role_assignment
WHERE role_code = 'EMPLOYEE_USER_DEFAULT_ROLE_CODE'
and delete_ts is null
GROUP BY username
HAVING count(role_code) > 1;


------------------------------------------- Insert report role to GENERAL USERS and their SUPERVISORS

-- role_code: 'EMPLOYEE_USER_DEFAULT_REPORT_ROLE_CODE', type: 'resource'

INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
select
    gen_random_uuid(),
    1,
    now(),
    'support',
    null,
    null,
    null,
    null,
    us.username,
    'EMPLOYEE_USER_DEFAULT_REPORT_ROLE_CODE',
    'resource'
from public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id -- profile id used
inner join (
    select distinct a.employeepin from (
        select b.pin as employeepin -- user pins
        from payroll_leave_attend_data.employee_records_beta_30 b
        Union All
        select aa.employee_code -- supervisors
        from mdg_empl_profile a
        inner join payroll_leave_attend_data.employee_records_beta_30 b on a.employee_code = b.pin
        inner join mdg_empl_profile aa on aa.id = a.manager_id
) a
) gu on gu.employeepin=pr.employee_code
where not exists (select 1 from public.sec_role_assignment ra
                        where us.username=ra.username
                        and ra.role_code ='EMPLOYEE_USER_DEFAULT_REPORT_ROLE_CODE'
                        and ra.delete_ts is null
                        ); -- DONE

-- always dup check:

SELECT username
     , count(role_code) as cnt
FROM sec_role_assignment
WHERE role_code = 'EMPLOYEE_USER_DEFAULT_REPORT_ROLE_CODE'
and delete_ts is null
GROUP BY username
HAVING count(role_code) > 1;


-- SELECT * from sec_role_assignment where username = '00098519' -- THIS PIN IS ALREADY IN THE TABLE, NEED TO REVISIT IT
----------------------------------- INSERTING ROW LEVEL roles of USERS, SUPERVISORS, BAO, HR ------------------------------

-- role_code: 'EMPLOYEE_USER_DEFAULT_ROW_LEVEL_ROLE_CODE'
-- role_type: 'row_level'

INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
select
    gen_random_uuid(),
    1,
    now(),
    'support',
    null,
    null,
    null,
    null,
    us.username,
    'EMPLOYEE_USER_DEFAULT_ROW_LEVEL_ROLE_CODE',
    'row_level'
from public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id -- profile id is used
inner join (
    select distinct a.employeepin from (
    select b.pin as employeepin -- employee pins
    from payroll_leave_attend_data.employee_records_beta_30 b
    Union All
    select aa.employee_code -- supervisors
    from mdg_empl_profile a
    inner join payroll_leave_attend_data.employee_records_beta_30 b on a.employee_code = b.pin
    inner join mdg_empl_profile aa on aa.id = a.manager_id
    union all
    select hr.hr_pin -- hr pins
    from payroll_leave_attend_data.employee_records_beta_30 hr
    union all
    select bao.bao_pin -- bao pins
    from payroll_leave_attend_data.employee_records_beta_30 bao
) a
) gu on gu.employeepin=pr.employee_code
where not exists (select * from public.sec_role_assignment ra
                    where us.username=ra.username
                    and ra.role_code ='EMPLOYEE_USER_DEFAULT_ROW_LEVEL_ROLE_CODE'
                    and ra.delete_ts is null
            ); -- DONE

-- SELECT * from sec_role_assignment where username = '00098519' -- THIS PIN IS ALREADY IN THE TABLE, NEED TO REVISIT IT

-- always dup check:

SELECT username
     , count(role_code) as cnt
FROM sec_role_assignment
WHERE role_code = 'EMPLOYEE_USER_DEFAULT_ROW_LEVEL_ROLE_CODE'
and delete_ts is null
GROUP BY username
HAVING count(role_code) > 1;


/*     Is not needed at this time

-- Delete supervisors who currently do not have any subordinates under them

-- DELETE FROM public.sec_role_assignment ra
-- USING public.mdg_user us
-- inner JOIN public.mdg_empl_profile pr ON pr.id = us.empl_profile_id
-- left JOIN public.mdg_empl_profile pr2 on pr2.manager_id=pr.id
-- WHERE ra.username = us.username
-- and ra.role_code  in ('ROLE_SUPERVISOR','SUPERVISOR_DATA_EMPLOYE_PROFILE_WS_OT_NT')
-- and pr2.id is null;

-- Assign supervisor roles who have now become new supervisors

-- INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
-- select
--     gen_random_uuid(),
--     1,
--     now(),
--     'support',
--     null,
--     null,
--     null,
--     null,
--     us2.username,
--     'ROLE_SUPERVISOR',
--     'resource'
-- from public.mdg_user us
-- inner join mdg_empl_profile pr on us.empl_profile_id=pr.id
-- inner JOIN public.mdg_empl_profile pr2 on pr2.manager_id=pr.id
-- inner JOIN public.mdg_user us2 on pr2.id=us2.empl_profile_id
-- inner join (
--     select distinct a.employeepin from (
--     select b.pin as employeepin
--     from payroll_leave_attend_data.employee_records_beta_30 b
--     Union All
--     select aa.employee_code
--     from mdg_empl_profile a
--     inner join payroll_leave_attend_data.employee_records_beta_30 b on a.employee_code = b.pin
--     inner join mdg_empl_profile aa on aa.id = a.manager_id
-- ) a
-- ) beta on beta.employeepin=pr.employee_code
-- where
--  not exists(select * from public.sec_role_assignment ra
--  where us2.username=ra.username and ra.role_code ='ROLE_SUPERVISOR'
-- );

*/

--- Inserting Row Level role for supervisors explicitly

-- INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
-- select gen_random_uuid(),
--        1,
--        now(),
--        'support',
--        null,
--        null,
--        null,
--        null,
--        us2.username,
--        'SUPERVISOR_DATA_EMPLOYE_PROFILE_WS_OT_NT',
--        'row_level'
-- -- select pr.employee_code,pr.manager_id,pr2.employee_code
-- from public.mdg_user us
-- inner join mdg_empl_profile pr on us.empl_profile_id=pr.id -- profile id is used
--     INNER JOIN public.mdg_empl_profile pr2 on pr2.manager_id=pr.id
--     INNER JOIN public.mdg_user us2 on pr2.id=us2.empl_profile_id
--     INNER JOIN (
--     select distinct a.employeepin from (
--         select distinct b.pin as employeepin -- USER PINS
--         from payroll_leave_attend_data.employee_records_beta_30 b
--         Union All
--         select distinct aa.employee_code as employeepin -- SUPERVISOR PINS
--         from mdg_empl_profile a
--         inner join payroll_leave_attend_data.employee_records_beta_30 b on a.employee_code = b.pin
--         inner join mdg_empl_profile aa on aa.id = a.manager_id
-- ) a
-- ) gu on gu.employeepin=pr2.employee_code
-- -- where pr2.employee_code = '00155717'
-- -- ;
-- where not exists(select 1 from public.sec_role_assignment ra
--                 where us2.username=ra.username and ra.role_code ='SUPERVISOR_DATA_EMPLOYE_PROFILE_WS_OT_NT'
--                     and ra.created_by = 'support'
--                     and ra.delete_ts is null
--                 );

-- select * from payroll_leave_attend_data.employee_records_beta_30;

-- SELECT * from mdg_empl_profile p
-- inner join mdg_empl_profile pp on p.manager_id=pp.id
-- where pp.employee_code='00155717';

-- I have some concern for the above code, UPDATE: This part is wrong

-------------------------------------------------- Assigning Supervisors --------------------------------------------------

---------------------------------------------------- ASSIGNING RESOURCE ROLE TO SUPERVISORS --------------------------------------

INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
select gen_random_uuid(),
       1,
       now(),
       'support',
       null,
       null,
       null,
       null,
       us.username,
       'ROLE_SUPERVISOR',
       'resource'
from public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id -- profile id is used
INNER JOIN (
    select distinct a.employeepin from (
        select aa.employee_code as employeepin -- SUPERVISOR PINS
        from mdg_empl_profile a
        inner join payroll_leave_attend_data.employee_records_beta_30 b on a.employee_code = b.pin
        inner join mdg_empl_profile aa on aa.id = a.manager_id
) a
) gu on gu.employeepin=pr.employee_code
where not exists(select 1 from public.sec_role_assignment ra
                where us.username=ra.username and ra.role_code ='ROLE_SUPERVISOR'
                    and ra.delete_ts is null
                );


--------------------------------------------------------------------------------------------------------------------------------



INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
select gen_random_uuid(),
       1,
       now(),
       'support',
       null,
       null,
       null,
       null,
       us.username,
       'SUPERVISOR_DATA_EMPLOYE_PROFILE_WS_OT_NT',
       'row_level'
from public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id -- profile id is used
INNER JOIN (
    select distinct a.employeepin from (
        select aa.employee_code as employeepin -- SUPERVISOR PINS
        from mdg_empl_profile a
        inner join payroll_leave_attend_data.employee_records_beta_30 b on a.employee_code = b.pin
        inner join mdg_empl_profile aa on aa.id = a.manager_id
) a
) gu on gu.employeepin=pr.employee_code
where not exists(select 1 from public.sec_role_assignment ra
                where us.username=ra.username and ra.role_code ='SUPERVISOR_DATA_EMPLOYE_PROFILE_WS_OT_NT'
                    and ra.delete_ts is null
                ); -- DONE

-- dup check:

SELECT username
     , count(role_code) as cnt
FROM sec_role_assignment
WHERE role_code = 'SUPERVISOR_DATA_EMPLOYE_PROFILE_WS_OT_NT'
and delete_ts is null
GROUP BY username
HAVING count(role_code) > 1;

-- select * from mdg_empl_profile where employee_code = '00010612'
-- SELECT * FROM sec_role_assignment where username = '00184785'; -- this user is also given in the user list as a gu but he is also a supervisor

------------------------------------------------------------------ BAO AND HR ----------------------------------------------------

----------------------------- INSERT OPERATING LOC FOR BAO

INSERT INTO public.mdg_user_operating_loc (id, version, created_by, created_date, last_modified_by, last_modified_date, operating_location_id, access_granted, user_id)
select gen_random_uuid(),
       1,
       'support',
       now(),
       null,
       now(),
       ol.id,
       true,
       us.id
from  public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id -- profile id used
inner join (
    select
        distinct bao_pin,
                 erp_office_code
    from payroll_leave_attend_data.employee_records_beta_30 w
) bao_hr
    on pr.employee_code = bao_hr.bao_pin -- TAKING BAO PIN
inner join public.mdg_operating_location ol on bao_hr.erp_office_code = ol.oper_loc_code
where not exists (select 1 from public.mdg_user_operating_loc uol where us.id=uol.user_id and uol.operating_location_id=ol.id); -- DONE

-- this users already exists in the mdg_user_operating_loc
-- 00137817 (Update: i found later that this guy is a supervisor, so his pin was early put in 2 days ago when i initially ran gu + sups and their oper locs)
-- 00098519 ( She was inserted long ago in the beta wave )


--------------------------------------------- INSERT OPERATING LOC FOR HR

INSERT INTO public.mdg_user_operating_loc (id, version, created_by, created_date, last_modified_by, last_modified_date, operating_location_id, access_granted, user_id)
select gen_random_uuid(),
       1,
       'support',
       now(),
       null,
       now(),
       ol.id,
       true,
       us.id
from  public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id -- user id is used
inner join (
    select
        distinct
                 hr_pin,
                 erp_office_code
    from payroll_leave_attend_data.employee_records_beta_30 w
) bao_hr
    on pr.employee_code = bao_hr.hr_pin -- TAKING HR PIN
inner join public.mdg_operating_location ol on bao_hr.erp_office_code = ol.oper_loc_code
where not exists (select 1 from public.mdg_user_operating_loc uol where us.id=uol.user_id and uol.operating_location_id=ol.id); -- DONE


---------------------------------------------- BAO ROLE ASSIGNMENTS START ------------------------------------------------------------------

-------------------------------------------------- BAO ROLE ASSIGNMENT RESOURCE LEVEL

INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
select gen_random_uuid(),
       1,
       now(),
       'support',
       null,
       null,
       null,
       null,
       us.username,
       'ROLE_BRANCH_ACCOUNT_OFFICER',
       'resource'
from mdg_user us
inner join public.mdg_empl_profile pr on us.empl_profile_id = pr.id
inner join (
    select
        distinct bao_pin,
                 erp_office_code
    from payroll_leave_attend_data.employee_records_beta_30 w
) bao_hr
    on pr.employee_code = bao_hr.bao_pin -- TAKING BAO PIN
where not exists (select 1 from public.sec_role_assignment ra where us.username=ra.username
                and ra.role_code ='ROLE_BRANCH_ACCOUNT_OFFICER'
                and ra.delete_ts is null
); -- DONE

-- dup check
SELECT username
     , count(role_code) as cnt
FROM sec_role_assignment
WHERE role_code = 'ROLE_BRANCH_ACCOUNT_OFFICER'
and delete_ts is null
GROUP BY username
HAVING count(role_code) > 1;

--------------------------------------------------------------- BAO ROLE ASSIGNMENT ROW LEVEL

INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
select gen_random_uuid(),
       1,
       now(),
       'support',
       null,
       null,
       null,
       null,
       us.username,
       'ACCESS_BAO_DATA_MULTI_BRANCH',
       'row_level'
from mdg_user us
inner join public.mdg_empl_profile pr on us.empl_profile_id = pr.id
inner join (
    select
        distinct bao_pin,
                 erp_office_code
    from payroll_leave_attend_data.employee_records_beta_30 w
) bao_hr
    on pr.employee_code = bao_hr.bao_pin -- TAKING BAO PIN
where not exists (select * from public.sec_role_assignment ra where us.username=ra.username
                and ra.role_code ='ACCESS_BAO_DATA_MULTI_BRANCH'
                and ra.delete_ts is null); -- DONE
-- dup check
SELECT username
     , count(role_code) as cnt
FROM sec_role_assignment
WHERE role_code = 'ACCESS_BAO_DATA_MULTI_BRANCH'
and delete_ts is null
GROUP BY username
HAVING count(role_code) > 1;


------------------------------------------------------ BAO REPORT ROLE ASSIGNMENT
INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
select gen_random_uuid(),
       1,
       now(),
       'support',
       null,
       null,
       null,
       null,
       us.username,
       'EMPLOYEE_USER_DEFAULT_REPORT_ROLE_CODE',
       'resource'
from mdg_user us
inner join public.mdg_empl_profile pr on us.empl_profile_id = pr.id
inner join (
    select
        distinct bao_pin,
                 branch_name
    from payroll_leave_attend_data.employee_records_beta_30 w
) bao_hr
    on pr.employee_code = bao_hr.bao_pin -- TAKING BAO PIN
where not exists (select 1 from public.sec_role_assignment ra where us.username=ra.username
                and ra.role_code ='EMPLOYEE_USER_DEFAULT_REPORT_ROLE_CODE'
                and ra.delete_ts is null); -- DONE


-- this users already exists in the sec role assignment
-- 00137817 (Update: i found later that this guy is a supervisor, so his pin was early put in 2 days ago when i initially ran gu + sups and their oper locs)
-- 00098519 ( She was inserted long ago in the beta wave )

-- dup check
SELECT username
     , count(role_code) as cnt
FROM sec_role_assignment
WHERE role_code = 'EMPLOYEE_USER_DEFAULT_REPORT_ROLE_CODE'
and delete_ts is null
GROUP BY username
HAVING count(role_code) > 1;

---------------------------------------------- BAO ROLE ASSIGNMENTS END ------------------------------------------------------------------


---------------------------------------------- HR ROLE ASSIGNMENTS START ------------------------------------------------------------------


------------------------------------------------ HR ROLE ASSIGNMENT RESOURCE LEVEL
INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
select gen_random_uuid(),
       1,
       now(),
       'support',
       null,
       null,
       null,
       null,
       us.username,
       'HR_USER_ACCESS',
       'resource'
from mdg_user us
inner join public.mdg_empl_profile pr on us.empl_profile_id = pr.id
inner join (
    select
        distinct
                 hr_pin,
                 branch_name
    from payroll_leave_attend_data.employee_records_beta_30 w
) bao_hr
    on pr.employee_code = bao_hr.hr_pin -- TAKING HR PIN
where not exists (select 1 from public.sec_role_assignment ra where us.username=ra.username
                and ra.role_code ='HR_USER_ACCESS'
                and ra.delete_ts is null); -- DONE

-- dup check
SELECT username
     , count(role_code) as cnt
FROM sec_role_assignment
WHERE role_code = 'HR_USER_ACCESS'
and delete_ts is null
GROUP BY username
HAVING count(role_code) > 1;


------------------------------------------------------------ HR ROLE ASSIGNMENT ROW LEVEL
INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
select gen_random_uuid(),
       1,
       now(),
       'support',
       null,
       null,
       null,
       null,
       us.username,
       'ACCESS_BAO_DATA_MULTI_BRANCH',
       'row_level'
from mdg_user us
inner join public.mdg_empl_profile pr on us.empl_profile_id = pr.id
inner join (
    select
        distinct
                 hr_pin,
                 branch_name
    from payroll_leave_attend_data.employee_records_beta_30 w
) bao_hr
    on pr.employee_code = bao_hr.hr_pin -- taking hr pin
where not exists (select 1 from public.sec_role_assignment ra where us.username=ra.username
                and ra.role_code ='ACCESS_BAO_DATA_MULTI_BRANCH'
                and ra.delete_ts is null); -- DONE

--- dup check
SELECT username
     , count(role_code) as cnt
FROM sec_role_assignment
WHERE role_code = 'ACCESS_BAO_DATA_MULTI_BRANCH'
and delete_ts is null
GROUP BY username
HAVING count(role_code) > 1;


-------------------------------------------------------------- HR REPORT ROLE ASSIGNMENT
INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
select gen_random_uuid(),
       1,
       now(),
       'support',
       null,
       null,
       null,
       null,
       us.username,
       'EMPLOYEE_USER_DEFAULT_REPORT_ROLE_CODE',
       'resource'
from mdg_user us
inner join public.mdg_empl_profile pr on us.empl_profile_id = pr.id
inner join (
    select
        distinct
                 hr_pin,
                 branch_name
    from payroll_leave_attend_data.employee_records_beta_30 w
) bao_hr
    on pr.employee_code = bao_hr.hr_pin -- TAKING HR PIN
where not exists (select 1 from public.sec_role_assignment ra where us.username=ra.username
                and ra.role_code ='EMPLOYEE_USER_DEFAULT_REPORT_ROLE_CODE'
                and ra.delete_ts is null); -- DONE
---- dup check
SELECT username
     , count(role_code) as cnt
FROM sec_role_assignment
WHERE role_code = 'EMPLOYEE_USER_DEFAULT_REPORT_ROLE_CODE'
and delete_ts is null
GROUP BY username
HAVING count(role_code) > 1;


---------------------------------------------- HR ROLE ASSIGNMENTS END ----------------------------------------------------------


--------------------------------------------- DYNAMIC SUPERVISOR USER GENERATION START ------------------------------------------------

  /* need employee pins
    second supervisor,
    ** grade 12
    ** grade 13
   */

-- Insert for user info for specific employee pins

/*
    Analysis: 5 already existing from these 19 users, 2 are completely new, 12 have been inserted by other means -> need to delete them
 */

-- First delete

-- BEGIN;

DELETE FROM mdg_user
WHERE username IN (
    '00134156',
    '00028508',
    '00004630',
    '00137300',
    '00175696',
    '00257974',
    '00138927',
    '00034214',
    '00155790',
    '00034380',
    '00171578',
    '00286998',
    '00274565',
    '00175300',
    '00155745',
    '00184785',
    '00176576',
    '00176575',
    '00176616'
)
and empl_profile_id is null; -- DONE

-- ROLLBACK;

-- 12 new inserts, 7 already existing
INSERT INTO public.mdg_user (id, version, username, first_name, last_name, password, email, active, time_zone_id, company_id, customer_id, employee_fund_id, empl_profile_id, mobile_no, tenant, user_category, vendor_id)
select
    gen_random_uuid(),
       1,
       pr.employee_code,
       pr.first_name,
       pr.last_name,
       '{bcrypt}$2a$10$a.t0rgOOLQQsXUBANoiQde41GQyulw4wVn/nZQYv0x.ZgMIy5lXPy',
       null,
       true,
       null,
       pr.company_id,
       null,
       null,
       pr.id,
       null,
       null,
       10,
       null
from mdg_empl_profile pr
where pr.employee_code IN (
    '00134156',
    '00028508',
    '00004630',
    '00137300',
    '00175696',
    '00257974',
    '00138927',
    '00034214',
    '00155790',
    '00034380',
    '00171578',
    '00286998',
    '00274565',
    '00175300',
    '00155745',
    '00184785',
    '00176576',
    '00176575',
    '00176616'
)
and not exists(select 1 from public.mdg_user us where us.empl_profile_id=pr.id); -- DONE

-- Insert  user's company

-- 12 new inserts, 7 already existing
INSERT INTO public.mdg_user_company (id, version, created_by, created_date, last_modified_by, last_modified_date, company_id, access_granted, user_id)
select gen_random_uuid(), 1, 'support', now(), null, null, pr.company_id, true, us.id
from public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id
where pr.employee_code IN (
    '00134156',
    '00028508',
    '00004630',
    '00137300',
    '00175696',
    '00257974',
    '00138927',
    '00034214',
    '00155790',
    '00034380',
    '00171578',
    '00286998',
    '00274565',
    '00175300',
    '00155745',
    '00184785',
    '00176576',
    '00176575',
    '00176616'
)
and
not exists(select 1 from public.mdg_user_company uc where us.id=uc.user_id); -- DONE

-- For  User operating role
-- 12 new inserts, 7 already existing
INSERT INTO public.mdg_user_operating_loc (id, version, created_by, created_date, last_modified_by, last_modified_date, operating_location_id, access_granted, user_id)
select
    gen_random_uuid(),
    1,
    'support',
    now(),
    null,
    now(),
    pr.operating_location_id,
    true,
    us.id
from  public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id
where pr.employee_code IN (
    '00134156',
    '00028508',
    '00004630',
    '00137300',
    '00175696',
    '00257974',
    '00138927',
    '00034214',
    '00155790',
    '00034380',
    '00171578',
    '00286998',
    '00274565',
    '00175300',
    '00155745',
    '00184785',
    '00176576',
    '00176575',
    '00176616'
)
and not exists(select 1 from public.mdg_user_operating_loc ol where us.id=ol.user_id and ol.operating_location_id=pr.operating_location_id); -- DONE

-- dup check

select user_id, count(operating_location_id) as countt
from mdg_user_operating_loc
group by user_id
having count(operating_location_id) > 1;

-- Insert User Role Assignment resource level

-- 4 existing, 15 new insert
INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
select gen_random_uuid(),
       1,
       now(),
       'support',
       null,
       null,
       null,
       null,
       us.username,
       'EMPLOYEE_USER_DEFAULT_ROLE_CODE',
       'resource'
from public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id
where pr.employee_code
  IN (
    '00134156',
    '00028508',
    '00004630',
    '00137300',
    '00175696',
    '00257974',
    '00138927',
    '00034214',
    '00155790',
    '00034380',
    '00171578',
    '00286998',
    '00274565',
    '00175300',
    '00155745',
    '00184785',
    '00176576',
    '00176575',
    '00176616'
)
and not exists(select 1 from public.sec_role_assignment ra
                        where us.username=ra.username
                        and ra.role_code ='EMPLOYEE_USER_DEFAULT_ROLE_CODE'
                        and ra.delete_ts is null
                        )
  -- and pr.employee_code='00271877'
; -- DONE





-- dup check
SELECT username
     , count(role_code) as cnt
FROM sec_role_assignment
WHERE role_code = 'EMPLOYEE_USER_DEFAULT_ROLE_CODE'
and delete_ts is null
GROUP BY username
HAVING count(role_code) > 1;

-- Insert general users report role code

-- 15 new insert, 4 existing
INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
    select gen_random_uuid(),
           1,
           now(),
           'support',
           null,
           null,
           null,
           null,
           us.username,
           'EMPLOYEE_USER_DEFAULT_REPORT_ROLE_CODE',
           'resource'
from public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id
where pr.employee_code
IN (
    '00134156',
    '00028508',
    '00004630',
    '00137300',
    '00175696',
    '00257974',
    '00138927',
    '00034214',
    '00155790',
    '00034380',
    '00171578',
    '00286998',
    '00274565',
    '00175300',
    '00155745',
    '00184785',
    '00176576',
    '00176575',
    '00176616'
)
and not exists(select 1 from public.sec_role_assignment ra
                where us.username=ra.username
                and ra.role_code ='EMPLOYEE_USER_DEFAULT_REPORT_ROLE_CODE'
                and ra.delete_ts is null); -- DONE

-- dup check
SELECT username
     , count(role_code) as cnt
FROM sec_role_assignment
WHERE role_code = 'EMPLOYEE_USER_DEFAULT_REPORT_ROLE_CODE'
and delete_ts is null
GROUP BY username
HAVING count(role_code) > 1;

-- Insert User Row Level Code
-- 15 new inserts, 4 existing
INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
    select gen_random_uuid(),
           1,
           now(),
           'support',
           null,
           null,
           null,
           null,
           us.username,
           'EMPLOYEE_USER_DEFAULT_ROW_LEVEL_ROLE_CODE',
           'row_level'
from public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id
where pr.employee_code
  IN (
    '00134156',
    '00028508',
    '00004630',
    '00137300',
    '00175696',
    '00257974',
    '00138927',
    '00034214',
    '00155790',
    '00034380',
    '00171578',
    '00286998',
    '00274565',
    '00175300',
    '00155745',
    '00184785',
    '00176576',
    '00176575',
    '00176616'
)
  and not exists(select 1 from public.sec_role_assignment ra
                        where us.username=ra.username
                        and ra.role_code ='EMPLOYEE_USER_DEFAULT_ROW_LEVEL_ROLE_CODE'
                        and ra.delete_ts is null);

-- dup check
SELECT username
     , count(role_code) as cnt
FROM sec_role_assignment
WHERE role_code = 'EMPLOYEE_USER_DEFAULT_ROW_LEVEL_ROLE_CODE'
and delete_ts is null
GROUP BY username
HAVING count(role_code) > 1; -- DONE
--------------------------------------------- DYNAMIC SUPERVISOR USER GENERATION END ------------------------------------------------

------------------------------------------------------ Users who are supervisors but not in employee list of previous or current waves----------------------------------------------------------------------
-- will get approver role
INSERT INTO public.sec_role_assignment (id, version, create_ts, created_by, update_ts, updated_by, delete_ts, deleted_by, username, role_code, role_type)
select gen_random_uuid(),
       1,
       now(),
       'support',
       null,
       null,
       null,
       null,
       us.username,
       'Approver_User_Access',
       'resource'
from public.mdg_user us
inner join mdg_empl_profile pr on us.empl_profile_id=pr.id -- profile id is used
INNER JOIN (
    select distinct a.employeepin from (
        select aa.employee_code as employeepin -- ALL SUPERVISOR PINS
        from mdg_empl_profile a
--         inner join payroll_leave_attend_data.employee_records_beta_30 b on a.employee_code = b.pin
        inner join mdg_empl_profile aa on aa.id = a.manager_id
) a
) gu on gu.employeepin=pr.employee_code
where not exists(select 1 from public.sec_role_assignment ra
                where us.username=ra.username and ra.role_code ='Approver_User_Access'
                    and ra.delete_ts is null
                )
AND us.username not in (
    select distinct A.employeepin
    from (
            select pin as employeepin from payroll_leave_attend_data.employee_records_beta -- beta user
            union all
            select pin as employeepin from payroll_leave_attend_data.employee_records_beta_30 w -- wave 30 users
    ) A
);




-------------------------------------------------APPROVER USER ROLE ASSIGNMENT START -------------------------------------------------------------

-- possible duplicate issue may arise, here need to talk with razu bhai on this

-- Users who are not from 146 user group (116+30), and their bao and hr pins, will have approver_user_access

-- BEGIN;

update public.sec_role_assignment
    set role_code='Approver_User_Access'
--     select * from sec_role_assignment a -- for checking purpose
    where username not in (
    select distinct A.employeepin
    from (
            select pin as employeepin from payroll_leave_attend_data.employee_records_beta -- beta user
            union all
                select distinct a.employeepin from (
                    select aa.employee_code as employeepin -- SUPERVISOR PINS
                    from mdg_empl_profile a
                    inner join payroll_leave_attend_data.employee_records_beta b on a.employee_code = b.pin -- beta supervisor
                    inner join mdg_empl_profile aa on aa.id = a.manager_id
                ) a
            union all
            select distinct hr_pin from payroll_leave_attend_data.employee_records_beta -- beta hr
            union all
            select distinct bao_pin from payroll_leave_attend_data.employee_records_beta -- beta bao
            union all
            select pin as employeepin from payroll_leave_attend_data.employee_records_beta_30 w -- wave 30 users
            union all
            select distinct a.employeepin from (
                    select aa.employee_code as employeepin -- SUPERVISOR PINS
                    from mdg_empl_profile a
                    inner join payroll_leave_attend_data.employee_records_beta_30 b on a.employee_code = b.pin -- wave 30 supervisor
                    inner join mdg_empl_profile aa on aa.id = a.manager_id
                ) a
            union all
            select distinct bao_pin as employeepin from payroll_leave_attend_data.employee_records_beta_30 w -- wave30 bao
            union all
            select distinct hr_pin as employeepin from payroll_leave_attend_data.employee_records_beta_30 w -- wave30 hr
    ) A
)
--     and not exists (SELECT 1 from sec_role_assignment ra
--                            WHERE a.username = ra.username
--                            and ra.role_code)
    and username not like '999%'
    and username not like 'api'
    and role_code not like 'system-full-access'
    and role_type = 'resource'
    and delete_ts is null; -- DONE

-- ROLLBACK;


-------------------------------------------------APPROVER USER ROLE ASSIGNMENT END -------------------------------------------------------------



-- check script so that no duplicates are there
select a.username,a.role_code,
count(*) from sec_role_assignment a
where delete_ts is null
group by a.username,a.role_code
having count(*)>1; -- 31 duplicates found of approver user access -- DONE

select count(1) from sec_role_assignment; -- DONE

-- =================================== DELETE BAO AND HR  ==========================================================

/*
    Any HR, BAO who are not in the 146 user list, should not have any GU user roles.
    They will only have their BAO ROLE AND HR ROLE.
    They will not have any GU role.
*/


DELETE FROM sec_role_assignment rl
USING
(SELECT A.employeepin, B.bao_hr_pin, ra.role_code
--      , ra.username, ra.role_code
 FROM (select pin as employeepin -- 116 user
       from payroll_leave_attend_data.employee_records_beta
       UNION
       select pin as employeepin -- 30 user
       from payroll_leave_attend_data.employee_records_beta_30) A
          RIGHT JOIN (select distinct hr_pin as bao_hr_pin
                      from payroll_leave_attend_data.employee_records_beta -- hr pin from 116
                      UNION
                      select distinct bao_pin as bao_hr_pin
                      from payroll_leave_attend_data.employee_records_beta -- bao pin from 116
                      UNION
                      select distinct bao_pin as bao_hr_pin
                      from payroll_leave_attend_data.employee_records_beta_30 -- bao pin from 30 user
                      union
                      select distinct hr_pin as bao_hr_pin
                      from payroll_leave_attend_data.employee_records_beta_30 -- hr pin from 30 user
 ) B
                     ON A.employeepin = B.bao_hr_pin
          INNER JOIN mdg_user u ON B.bao_hr_pin = u.username
          INNER JOIN sec_role_assignment ra ON u.username = ra.username
 WHERE A.employeepin is null
   AND ra.role_code IN ('EMPLOYEE_USER_DEFAULT_REPORT_ROLE_CODE', 'EMPLOYEE_USER_DEFAULT_ROLE_CODE',
                        'EMPLOYEE_USER_DEFAULT_ROW_LEVEL_ROLE_CODE')

) bao_hr
       WHERE rl.username = bao_hr.bao_hr_pin AND rl.role_code = bao_hr.role_code; -- DONE


-- Finally Check to see if the change is reflected
SELECT * FROM sec_role_assignment
WHERE username IN (
    '00026463',
    '00069509',
    '00033460',
    '00155153',
    '00189667',
    '00188571',
    '00252264',
    '00137817'
); -- DONE

-- ========================================================== delete ANY DUPLICATES ==================================================

BEGIN;

DELETE FROM sec_role_assignment a
USING sec_role_assignment b
WHERE a.username = b.username
  AND a.role_code = b.role_code
  AND a.role_type = b.role_type
  AND a.ctid > b.ctid;

ROLLBACK;


-- ========================================================== Done ==================================================


-------------------------------------- FINAL CHECK AGAIN --------------------------------------------------
-- 116
SELECT * FROM sec_role_assignment
WHERE username IN (
SELECT pin from payroll_leave_attend_data.employee_records_beta)
and delete_ts is null;

-- 30
SELECT * FROM sec_role_assignment
WHERE username IN (
SELECT bao_pin from payroll_leave_attend_data.employee_records_beta_30)
and delete_ts is null;




