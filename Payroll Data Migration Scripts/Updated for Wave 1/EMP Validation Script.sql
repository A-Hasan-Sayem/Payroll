
-------------------------------------------------------------------NULL Value Check in Source-------------------------------------------------------------------
WITH Employee_CTE AS (
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.employee_information_update e
    INNER JOIN payroll_emp_data.employee_core_info eci ON e.employee_core_info_id=eci.id
    WHERE e.employee_information_update_change_type_id IN (11, 25)
        AND date(e.effective_date) > '2023-12-31'
        AND e.new_value != '3' AND e.domain_status_id = 1
    UNION
    SELECT e.employee_core_info_id::BIGINT
    FROM payroll_emp_data.emp_core_info_history e
    WHERE e.value_type = 'Employee Status Change'
        AND date(e.create_date) > '2023-12-31'
    UNION
    SELECT eci.id
    FROM payroll_emp_data.job_separation_proposal jsp
    INNER JOIN payroll_emp_data.employee_core_info eci ON jsp.employee_core_info_id=eci.id
    WHERE jsp.domain_status_id=1 AND eci.cur_job_status_id != 3
        AND date(jsp.date_created) > '2023-12-31'
    UNION
    SELECT id
    FROM payroll_emp_data.employee_core_info
    WHERE cur_job_status_id = 3 AND domain_status_id=1
),
CurrentAddr AS (
    SELECT employee_info_id, contact_address_line1
    FROM (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY employee_info_id, address_type_id ORDER BY id DESC) rn
        FROM payroll_emp_data.employee_address
        WHERE domain_status_id = 1 AND address_type_id = 2
    ) a WHERE rn = 1
),
PermanentAddr AS (
    SELECT employee_info_id, contact_address_line1
    FROM (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY employee_info_id, address_type_id ORDER BY id DESC) rn
        FROM payroll_emp_data.employee_address
        WHERE domain_status_id = 1 AND address_type_id = 1
    ) a WHERE rn = 1
)
SELECT
    -- employee_core_info
    COUNT(*) FILTER (WHERE eci.pin_no IS NULL) AS missing_employee_code,
    COUNT(*) FILTER (WHERE eci.first_name IS NULL) AS missing_full_name,
    COUNT(*) FILTER (WHERE eci.national_id_no IS NULL) AS missing_national_id,
    COUNT(*) FILTER (WHERE eci.joining_date IS NULL) AS missing_join_date_actual,
    COUNT(*) FILTER (WHERE eci.expiry_date IS NULL) AS missing_contract_end_date,
    COUNT(*) FILTER (WHERE eci.email_address IS NULL) AS missing_email_company,
    COUNT(*) FILTER (WHERE eci.employee_dob IS NULL) AS missing_birth_date,
    COUNT(*) FILTER (WHERE eci.tin_number IS NULL) AS missing_tin_no,
    COUNT(*) FILTER (WHERE eci.supervisor_id IS NULL) AS missing_supervisor_empl_code,
    COUNT(*) FILTER (WHERE eci.religion_id IS NULL) AS missing_religion,
    COUNT(*) FILTER (WHERE eci.employee_level_id IS NULL) AS missing_grade_code,
    COUNT(*) FILTER (WHERE eci.slab_id IS NULL) AS missing_grade_sub_code,
    COUNT(*) FILTER (WHERE eci.core_project_id IS NULL) AS missing_section_code,
    COUNT(*) FILTER (WHERE eci.emp_category_id IS NULL) AS missing_empl_category_code,
    COUNT(*) FILTER (WHERE eci.office_info_id IS NULL) AS missing_operating_location_code,
    COUNT(*) FILTER (WHERE eci.e_designation_id IS NULL) AS missing_designation_code,
    COUNT(*) FILTER (WHERE eci.gender_id IS NULL) AS missing_gender,
    -- employee_basic_info
    COUNT(*) FILTER (WHERE ebi.father_name IS NULL) AS missing_father_name,
    COUNT(*) FILTER (WHERE ebi.mother_name IS NULL) AS missing_mother_name,
    -- employee_contact_info
    COUNT(*) FILTER (WHERE eci2.mobile_no1 IS NULL) AS missing_phone_work_direct,
    COUNT(*) FILTER (WHERE eci2.mobile_no2 IS NULL) AS missing_phone_home,
    -- addresses
    COUNT(*) FILTER (WHERE ca.contact_address_line1 IS NULL) AS missing_current_address,
    COUNT(*) FILTER (WHERE pa.contact_address_line1 IS NULL) AS missing_permanent_address,
    -- users & leave group
    COUNT(*) FILTER (WHERE u.id IS NULL) AS missing_user_id,
    COUNT(*) FILTER (WHERE el.leavegroupid IS NULL) AS missing_leave_profile_code,
    -- attendance/holiday policy
    COUNT(*) FILTER (WHERE ap.policyid IS NULL) AS missing_work_shift_code,
    COUNT(*) FILTER (WHERE ap.policyid IS NULL) AS missing_holiday_calendar_code
FROM Employee_CTE ec
LEFT JOIN payroll_emp_data.employee_core_info eci ON ec.Employee_ID = eci.id
LEFT JOIN payroll_emp_data.employee_basic_info ebi ON eci.id = ebi.employee_info_id AND ebi.domain_status_id = 1
LEFT JOIN payroll_emp_data.employee_contact_info eci2 ON eci.id = eci2.employee_info_id AND eci2.domain_status_id = 1
LEFT JOIN CurrentAddr ca ON eci.id = ca.employee_info_id
LEFT JOIN PermanentAddr pa ON eci.id = pa.employee_info_id
LEFT JOIN payroll_emp_data.users u ON eci.pin_no = u.pin
LEFT JOIN payroll_emp_data.employeeleavegroupmapping el ON u.id = el.employee_id
LEFT JOIN payroll_emp_data.employeewiseattendancepolicymapping ap ON u.id = ap.employee_id;

-------------------------------------------------------------------NULL Value Check in Destination-------------------------------------------------------------------
SELECT
    COUNT(*) FILTER (WHERE employee_code IS NULL) AS null_employee_code,
    COUNT(*) FILTER (WHERE first_name IS NULL) AS null_first_name,
    COUNT(*) FILTER (WHERE middle_name IS NULL) AS null_middle_name,
    COUNT(*) FILTER (WHERE last_name IS NULL) AS null_last_name,
    COUNT(*) FILTER (WHERE father_name IS NULL) AS null_father_name,
    COUNT(*) FILTER (WHERE mother_name IS NULL) AS null_mother_name,
    COUNT(*) FILTER (WHERE national_id IS NULL) AS null_national_id,
    COUNT(*) FILTER (WHERE join_date_actual IS NULL) AS null_join_date_actual,
    COUNT(*) FILTER (WHERE confirmation_date IS NULL) AS null_confirmation_date,
    COUNT(*) FILTER (WHERE contract_end_date IS NULL) AS null_contract_end_date,
    COUNT(*) FILTER (WHERE email_company IS NULL) AS null_email_company,
    COUNT(*) FILTER (WHERE current_address IS NULL) AS null_current_address,
    COUNT(*) FILTER (WHERE permanent_address IS NULL) AS null_permanent_address,
    COUNT(*) FILTER (WHERE birth_date IS NULL) AS null_birth_date,
    COUNT(*) FILTER (WHERE gender IS NULL) AS null_gender,
    COUNT(*) FILTER (WHERE tin_no IS NULL) AS null_tin_no,
    COUNT(*) FILTER (WHERE supervisor_empl_code IS NULL) AS null_supervisor_empl_code,
    COUNT(*) FILTER (WHERE holiday_calendar_code IS NULL) AS null_holiday_calendar_code,
    COUNT(*) FILTER (WHERE religion IS NULL) AS null_religion,
    COUNT(*) FILTER (WHERE grade_code IS NULL) AS null_grade_code,
    COUNT(*) FILTER (WHERE grade_sub_code IS NULL) AS null_grade_sub_code,
    COUNT(*) FILTER (WHERE section_code IS NULL) AS null_section_code,
    COUNT(*) FILTER (WHERE empl_category_code IS NULL) AS null_empl_category_code,
    COUNT(*) FILTER (WHERE work_shift_code IS NULL) AS null_work_shift_code,
    COUNT(*) FILTER (WHERE operating_location_code IS NULL) AS null_operating_location_code,
    COUNT(*) FILTER (WHERE designation_code IS NULL) AS null_designation_code,
    COUNT(*) FILTER (WHERE phone_home IS NULL) AS null_phone_home,
    COUNT(*) FILTER (WHERE phone_work_direct IS NULL) AS null_phone_work_direct,
    COUNT(*) FILTER (WHERE phone_mobile IS NULL) AS null_phone_mobile,
    COUNT(*) FILTER (WHERE leave_profile_code IS NULL) AS null_leave_profile_code,
    COUNT(*) FILTER (WHERE employee_job_status IS NULL) AS null_employee_job_status,
    COUNT(*) FILTER (WHERE last_working_day IS NULL) AS null_last_working_day
FROM public.integ_employee_imp;

-------------------------------------------------------------------emp supervisor analysis: DESTINATION-------------------------------------------------------------------

WITH First_CTE AS(
SELECT DISTINCT supervisor_empl_code AS First_Sup,ECI.supervisor_id AS sup1
,ECI2.pin_no AS Second_Sup, ECI2.supervisor_id  AS sup2
,ECI3.pin_no AS Third_Sup, ECI3.supervisor_id AS sup3
,ECI4.pin_no AS Fourth_Sup, ECI4.supervisor_id AS sup4
,ECI5.pin_no AS Fifth_Sup, ECI5.supervisor_id AS sup5
,ECI6.pin_no AS Sixth_Sup, ECI6.supervisor_id AS sup6
,ECI7.pin_no AS Seventh_Sup, ECI7.supervisor_id AS sup7
,ECI8.pin_no AS Eighth_Sup, ECI8.supervisor_id AS sup8
,ECI9.pin_no AS Nineth_Sup, ECI9.supervisor_id AS sup9
,ECI10.pin_no AS Tenth_Sup, ECI10.supervisor_id AS sup10
,ECI11.pin_no AS Eleventh_Sup, ECI11.supervisor_id AS sup11
,ECI12.pin_no AS Twelveth_Sup, ECI12.supervisor_id AS sup12
FROM public.integ_employee_imp I
INNER JOIN payroll_emp_data.employee_core_info ECI ON I.supervisor_empl_code = ECI.pin_no
LEFT JOIN payroll_emp_data.employee_core_info ECI2 ON ECI.supervisor_id = ECI2.id
LEFT JOIN payroll_emp_data.employee_core_info ECI3 ON ECI2.supervisor_id = ECI3.id
LEFT JOIN payroll_emp_data.employee_core_info ECI4 ON ECI3.supervisor_id = ECI4.id
LEFT JOIN payroll_emp_data.employee_core_info ECI5 ON ECI4.supervisor_id = ECI5.id
LEFT JOIN payroll_emp_data.employee_core_info ECI6 ON ECI5.supervisor_id = ECI6.id
LEFT JOIN payroll_emp_data.employee_core_info ECI7 ON ECI6.supervisor_id = ECI7.id
LEFT JOIN payroll_emp_data.employee_core_info ECI8 ON ECI7.supervisor_id = ECI8.id
LEFT JOIN payroll_emp_data.employee_core_info ECI9 ON ECI8.supervisor_id = ECI9.id
LEFT JOIN payroll_emp_data.employee_core_info ECI10 ON ECI9.supervisor_id = ECI10.id
LEFT JOIN payroll_emp_data.employee_core_info ECI11 ON ECI10.supervisor_id = ECI11.id
LEFT JOIN payroll_emp_data.employee_core_info ECI12 ON ECI11.supervisor_id = ECI12.id
WHERE supervisor_empl_code NOT  IN
(SELECT DISTINCT employee_code FROM public.integ_employee_imp)
),Second_CTE AS(
SELECT First_Sup AS Pin
FROM First_CTE
UNION
SELECT Second_Sup AS Pin
FROM First_CTE
UNION
SELECT Third_Sup AS Pin
FROM First_CTE
UNION
SELECT Fourth_Sup AS Pin
FROM First_CTE
UNION
SELECT Fifth_Sup AS Pin
FROM First_CTE
UNION
SELECT Sixth_Sup AS Pin
FROM First_CTE
UNION
SELECT Seventh_Sup AS Pin
FROM First_CTE
UNION
SELECT Eighth_Sup AS Pin
FROM First_CTE
UNION
SELECT Nineth_Sup AS Pin
FROM First_CTE
UNION
SELECT Tenth_Sup AS Pin
FROM First_CTE
UNION
SELECT Eleventh_Sup AS Pin
FROM First_CTE
UNION
SELECT Twelveth_Sup AS Pin
FROM First_CTE
)
SELECT Pin FROM Second_CTE
WHERE PIN NOT IN(SELECT employee_code FROM public.integ_employee_imp);


-------------------------------------------------------------------emp supervisor analysis: Source-------------------------------------------------------------------

WITH Employee_CTE AS(
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.employee_information_update e
    INNER JOIN payroll_emp_data.employee_core_info eci ON e.employee_core_info_id=eci.id
    WHERE e.employee_information_update_change_type_id IN (11, 25) AND date(e.effective_date) > '2023-12-31' and e.new_value != '3' AND E.domain_status_id = 1
UNION
    SELECT e.employee_core_info_id::BIGINT AS Employee_ID
    FROM payroll_emp_data.emp_core_info_history e
    WHERE e.value_type = 'Employee Status Change' AND date(e.create_date) > '2023-12-31'
UNION
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.job_separation_proposal jsp
    INNER JOIN payroll_emp_data.employee_core_info eci ON jsp.employee_core_info_id=eci.id AND jsp.domain_status_id=1 AND eci.cur_job_status_id != 3 AND date(jsp.date_created) > '2023-12-31'
UNION
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.employee_core_info eci
    WHERE eci.cur_job_status_id = 3 AND eci.domain_status_id=1
),First_CTE AS(
SELECT DISTINCT
 ECI.pin_no  AS First_Sup,ECI.supervisor_id AS sup1
,ECI2.pin_no AS Second_Sup, ECI2.supervisor_id  AS sup2
,ECI3.pin_no AS Third_Sup, ECI3.supervisor_id AS sup3
,ECI4.pin_no AS Fourth_Sup, ECI4.supervisor_id AS sup4
,ECI5.pin_no AS Fifth_Sup, ECI5.supervisor_id AS sup5
,ECI6.pin_no AS Sixth_Sup, ECI6.supervisor_id AS sup6
,ECI7.pin_no AS Seventh_Sup, ECI7.supervisor_id AS sup7
,ECI8.pin_no AS Eighth_Sup, ECI8.supervisor_id AS sup8
,ECI9.pin_no AS Nineth_Sup, ECI9.supervisor_id AS sup9
,ECI10.pin_no AS Tenth_Sup, ECI10.supervisor_id AS sup10
,ECI11.pin_no AS Eleventh_Sup, ECI11.supervisor_id AS sup11
,ECI12.pin_no AS Twelveth_Sup, ECI12.supervisor_id AS sup12
FROM Employee_CTE E
INNER JOIN payroll_emp_data.employee_core_info I on E.Employee_ID = I.id
--INNER JOIN payroll_emp_data.employee_core_info EC ON I.supervisor_id = EC.id
INNER JOIN payroll_emp_data.employee_core_info ECI ON I.supervisor_id = ECI.id
LEFT JOIN payroll_emp_data.employee_core_info ECI2 ON ECI.supervisor_id = ECI2.id
LEFT JOIN payroll_emp_data.employee_core_info ECI3 ON ECI2.supervisor_id = ECI3.id
LEFT JOIN payroll_emp_data.employee_core_info ECI4 ON ECI3.supervisor_id = ECI4.id
LEFT JOIN payroll_emp_data.employee_core_info ECI5 ON ECI4.supervisor_id = ECI5.id
LEFT JOIN payroll_emp_data.employee_core_info ECI6 ON ECI5.supervisor_id = ECI6.id
LEFT JOIN payroll_emp_data.employee_core_info ECI7 ON ECI6.supervisor_id = ECI7.id
LEFT JOIN payroll_emp_data.employee_core_info ECI8 ON ECI7.supervisor_id = ECI8.id
LEFT JOIN payroll_emp_data.employee_core_info ECI9 ON ECI8.supervisor_id = ECI9.id
LEFT JOIN payroll_emp_data.employee_core_info ECI10 ON ECI9.supervisor_id = ECI10.id
LEFT JOIN payroll_emp_data.employee_core_info ECI11 ON ECI10.supervisor_id = ECI11.id
LEFT JOIN payroll_emp_data.employee_core_info ECI12 ON ECI11.supervisor_id = ECI12.id
WHERE ECI.id  NOT  IN (SELECT DISTINCT Employee_ID FROM Employee_CTE)
),
Second_CTE AS(
SELECT First_Sup AS Pin FROM First_CTE
UNION
SELECT Second_Sup AS Pin FROM First_CTE
UNION
SELECT Third_Sup AS Pin FROM First_CTE
UNION
SELECT Fourth_Sup AS Pin FROM First_CTE
UNION
SELECT Fifth_Sup AS Pin FROM First_CTE
UNION
SELECT Sixth_Sup AS Pin FROM First_CTE
UNION
SELECT Seventh_Sup AS Pin FROM First_CTE
UNION
SELECT Eighth_Sup AS Pin FROM First_CTE
UNION
SELECT Nineth_Sup AS Pin FROM First_CTE
UNION
SELECT Tenth_Sup AS Pin FROM First_CTE
UNION
SELECT Eleventh_Sup AS Pin FROM First_CTE
UNION
SELECT Twelveth_Sup AS Pin FROM First_CTE
)
SELECT Pin FROM Second_CTE S
INNER JOIN payroll_emp_data.employee_core_info ECI ON S.pin = ECI.pin_no
WHERE ECI.id NOT IN(SELECT DISTINCT Employee_ID FROM Employee_CTE);

-------------------------------------------------------------extensive religion analysis: source (total 13 records)-------------------------------------------------
--------------------------------------1 (7 records)

WITH Employee_CTE AS(

SELECT eci.id AS Employee_ID

FROM payroll_emp_data.employee_information_update e

INNER JOIN payroll_emp_data.employee_core_info eci ON e.employee_core_info_id=eci.id

WHERE e.employee_information_update_change_type_id IN (11, 25) AND date(e.effective_date) > '2023-12-31' and e.new_value != '3' AND E.domain_status_id = 1

UNION

SELECT e.employee_core_info_id::BIGINT AS Employee_ID

FROM payroll_emp_data.emp_core_info_history e

WHERE e.value_type = 'Employee Status Change' AND date(e.create_date) > '2023-12-31'

UNION

SELECT eci.id AS Employee_ID

FROM payroll_emp_data.job_separation_proposal jsp

INNER JOIN payroll_emp_data.employee_core_info eci ON jsp.employee_core_info_id=eci.id AND jsp.domain_status_id=1 AND eci.cur_job_status_id != 3 AND date(jsp.date_created) > '2023-12-31'

UNION

SELECT eci.id AS Employee_ID

FROM payroll_emp_data.employee_core_info eci

WHERE eci.cur_job_status_id = 3 AND eci.domain_status_id=1

),bisshash as

(select a.id, a.religion_id, a.pin_no from payroll_emp_data.employee_core_info a

inner join Employee_CTE b on b.Employee_ID = a.id

where a.religion_id not in (2, 4, 5, 6, 7, 8) or a.religion_id is null

)

select * from bisshash d

--inner join integ_employee_imp i2 on i2.employee_code = d.pin_no

left join payroll_emp_data.updated_religion c on c.employee_id = d.id

where c.employee_id is null;

-------------------------------------2 (6 records)
WITH Employee_CTE AS(

    SELECT eci.id AS Employee_ID

    FROM payroll_emp_data.employee_information_update e

    INNER JOIN payroll_emp_data.employee_core_info eci ON e.employee_core_info_id=eci.id

    WHERE e.employee_information_update_change_type_id IN (11, 25) AND date(e.effective_date) > '2023-12-31' and e.new_value != '3' AND E.domain_status_id = 1

UNION

    SELECT e.employee_core_info_id::BIGINT AS Employee_ID

    FROM payroll_emp_data.emp_core_info_history e

    WHERE e.value_type = 'Employee Status Change' AND date(e.create_date) > '2023-12-31'

UNION

    SELECT eci.id AS Employee_ID

    FROM payroll_emp_data.job_separation_proposal jsp

    INNER JOIN payroll_emp_data.employee_core_info eci ON jsp.employee_core_info_id=eci.id AND jsp.domain_status_id=1 AND eci.cur_job_status_id != 3 AND date(jsp.date_created) > '2023-12-31'

UNION

    SELECT eci.id AS Employee_ID

    FROM payroll_emp_data.employee_core_info eci

    WHERE eci.cur_job_status_id = 3 AND eci.domain_status_id=1

),First_CTE AS(

SELECT DISTINCT

ECI.pin_no  AS First_Sup,ECI.supervisor_id AS sup1

,ECI2.pin_no AS Second_Sup, ECI2.supervisor_id  AS sup2

,ECI3.pin_no AS Third_Sup, ECI3.supervisor_id AS sup3

,ECI4.pin_no AS Fourth_Sup, ECI4.supervisor_id AS sup4

,ECI5.pin_no AS Fifth_Sup, ECI5.supervisor_id AS sup5

,ECI6.pin_no AS Sixth_Sup, ECI6.supervisor_id AS sup6

,ECI7.pin_no AS Seventh_Sup, ECI7.supervisor_id AS sup7

,ECI8.pin_no AS Eighth_Sup, ECI8.supervisor_id AS sup8

,ECI9.pin_no AS Nineth_Sup, ECI9.supervisor_id AS sup9

,ECI10.pin_no AS Tenth_Sup, ECI10.supervisor_id AS sup10

,ECI11.pin_no AS Eleventh_Sup, ECI11.supervisor_id AS sup11

,ECI12.pin_no AS Twelveth_Sup, ECI12.supervisor_id AS sup12

FROM Employee_CTE E

INNER JOIN payroll_emp_data.employee_core_info I on E.Employee_ID = I.id

--INNER JOIN payroll_emp_data.employee_core_info EC ON I.supervisor_id = EC.id

INNER JOIN payroll_emp_data.employee_core_info ECI ON I.supervisor_id = ECI.id

LEFT JOIN payroll_emp_data.employee_core_info ECI2 ON ECI.supervisor_id = ECI2.id

LEFT JOIN payroll_emp_data.employee_core_info ECI3 ON ECI2.supervisor_id = ECI3.id

LEFT JOIN payroll_emp_data.employee_core_info ECI4 ON ECI3.supervisor_id = ECI4.id

LEFT JOIN payroll_emp_data.employee_core_info ECI5 ON ECI4.supervisor_id = ECI5.id

LEFT JOIN payroll_emp_data.employee_core_info ECI6 ON ECI5.supervisor_id = ECI6.id

LEFT JOIN payroll_emp_data.employee_core_info ECI7 ON ECI6.supervisor_id = ECI7.id

LEFT JOIN payroll_emp_data.employee_core_info ECI8 ON ECI7.supervisor_id = ECI8.id

LEFT JOIN payroll_emp_data.employee_core_info ECI9 ON ECI8.supervisor_id = ECI9.id

LEFT JOIN payroll_emp_data.employee_core_info ECI10 ON ECI9.supervisor_id = ECI10.id

LEFT JOIN payroll_emp_data.employee_core_info ECI11 ON ECI10.supervisor_id = ECI11.id

LEFT JOIN payroll_emp_data.employee_core_info ECI12 ON ECI11.supervisor_id = ECI12.id

WHERE ECI.id  NOT  IN (SELECT DISTINCT Employee_ID FROM Employee_CTE)

),

Second_CTE AS(

SELECT First_Sup AS Pin FROM First_CTE

UNION

SELECT Second_Sup AS Pin FROM First_CTE

UNION

SELECT Third_Sup AS Pin FROM First_CTE

UNION

SELECT Fourth_Sup AS Pin FROM First_CTE

UNION

SELECT Fifth_Sup AS Pin FROM First_CTE

UNION

SELECT Sixth_Sup AS Pin FROM First_CTE

UNION

SELECT Seventh_Sup AS Pin FROM First_CTE

UNION

SELECT Eighth_Sup AS Pin FROM First_CTE

UNION

SELECT Nineth_Sup AS Pin FROM First_CTE

UNION

SELECT Tenth_Sup AS Pin FROM First_CTE

UNION

SELECT Eleventh_Sup AS Pin FROM First_CTE

UNION

SELECT Twelveth_Sup AS Pin FROM First_CTE

)

SELECT Pin, ECI.religion_id FROM Second_CTE S

INNER JOIN payroll_emp_data.employee_core_info ECI ON S.pin = ECI.pin_no

WHERE ECI.id NOT IN(SELECT DISTINCT Employee_ID FROM Employee_CTE)

AND (ECI.religion_id NOT IN(2,4,5,6,7,8) OR ECI.religion_id IS NULL);

--------------------------------------------------------------------extensive religion analysis: Destination (total 13 records)-----------------------------------------------------------------
--1 (13 records)
select count(1) from integ_employee_imp where religion not in ('2', '4', '5', '6', '7', '8') or religion is null or religion = '';

--2_not_needed

------------------------------------------------------------------  Duplicate Employee code : Source  ----------------------------------------------------------------------
SELECT pin_no, COUNT(*) AS duplicate_count
FROM payroll_emp_data.employee_core_info
GROUP BY pin_no
HAVING COUNT(*) > 1;

------------------------------------------------------------------  Duplicate Employee code : Destination  ----------------------------------------------------------------------
SELECT employee_code, COUNT(*) AS duplicate_count
FROM public.integ_employee_imp
GROUP BY employee_code
HAVING COUNT(*) > 1;
------------------------------------------------------------------  name "null/ ./ missing" : Source  ----------------------------------------------------------------------
SELECT COUNT(*) AS invalid_first_name_count
FROM payroll_emp_data.employee_core_info
WHERE
    first_name IS NULL
    OR TRIM(first_name) = ''
    OR first_name = '.';
------------------------------------------------------------------ First name "null/ ./ missing" : Destination   ----------------------------------------------------------------------
SELECT COUNT(*) AS invalid_first_name_count
FROM public.integ_employee_imp
WHERE
    first_name IS NULL
    OR TRIM(first_name) = ''
    OR first_name = '.';
------------------------------------------------------------------  confirmation_date check : Source  ----------------------------------------------------------------------
WITH Employee_CTE AS(
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.employee_information_update e
    INNER JOIN payroll_emp_data.employee_core_info eci ON e.employee_core_info_id=eci.id
    WHERE e.employee_information_update_change_type_id IN (11, 25) AND date(e.effective_date) > '2023-12-31' and e.new_value != '3' AND E.domain_status_id = 1
UNION
    SELECT e.employee_core_info_id::BIGINT AS Employee_ID
    FROM payroll_emp_data.emp_core_info_history e
    WHERE e.value_type = 'Employee Status Change' AND date(e.create_date) > '2023-12-31'
UNION
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.job_separation_proposal jsp
    INNER JOIN payroll_emp_data.employee_core_info eci ON jsp.employee_core_info_id=eci.id AND jsp.domain_status_id=1 AND eci.cur_job_status_id != 3 AND date(jsp.date_created) > '2023-12-31'
UNION
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.employee_core_info eci
    WHERE eci.cur_job_status_id = 3 AND eci.domain_status_id=1
)
select count(*) from payroll_emp_data.employee_core_info eci inner join Employee_CTE ec on ec.Employee_ID = eci.id
          inner join payroll_emp_data.emp_confirmation_date cd on cd.staffpin = eci.pin_no
          where eci.emp_category_id != 2
------------------------------------------------------------------  confirmation_date check : Destination ----------------------------------------------------------------------
SELECT COUNT(*)
FROM public.integ_employee_imp
where confirmation_date is not null and empl_category_code != 'R'

------------------------------------------------------------------  contract_end_date check : Source  ----------------------------------------------------------------------

WITH Employee_CTE AS(
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.employee_information_update e
    INNER JOIN payroll_emp_data.employee_core_info eci ON e.employee_core_info_id=eci.id
    WHERE e.employee_information_update_change_type_id IN (11, 25) AND date(e.effective_date) > '2023-12-31' and e.new_value != '3' AND E.domain_status_id = 1
UNION
    SELECT e.employee_core_info_id::BIGINT AS Employee_ID
    FROM payroll_emp_data.emp_core_info_history e
    WHERE e.value_type = 'Employee Status Change' AND date(e.create_date) > '2023-12-31'
UNION
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.job_separation_proposal jsp
    INNER JOIN payroll_emp_data.employee_core_info eci ON jsp.employee_core_info_id=eci.id AND jsp.domain_status_id=1 AND eci.cur_job_status_id != 3 AND date(jsp.date_created) > '2023-12-31'
UNION
    SELECT eci.id AS Employee_ID
    FROM payroll_emp_data.employee_core_info eci
    WHERE eci.cur_job_status_id = 3 AND eci.domain_status_id=1
)
select count(*) from payroll_emp_data.employee_core_info eci inner join Employee_CTE ec on ec.Employee_ID = eci.id
where eci.emp_category_id != 1 and eci.expiry_date is not null

------------------------------------------------------------------ contract_end_date check: Destination   ----------------------------------------------------------------------
SELECT count(*)
FROM public.integ_employee_imp
where contract_end_date is not null and empl_category_code != 'C'

------------------------------------------------------------------  Gender Align with mapping : Source ----------------------------------------------------------------------
WITH Employee_CTE AS(
SELECT eci.id AS Employee_ID
FROM payroll_emp_data.employee_information_update e
INNER JOIN payroll_emp_data.employee_core_info eci ON e.employee_core_info_id=eci.id
WHERE e.employee_information_update_change_type_id IN (11, 25) AND date(e.effective_date) > '2023-12-31' and e.new_value != '3' AND E.domain_status_id = 1
UNION
SELECT e.employee_core_info_id::BIGINT AS Employee_ID
FROM payroll_emp_data.emp_core_info_history e
WHERE e.value_type = 'Employee Status Change' AND date(e.create_date) > '2023-12-31'
UNION
SELECT eci.id AS Employee_ID
FROM payroll_emp_data.job_separation_proposal jsp
INNER JOIN payroll_emp_data.employee_core_info eci ON jsp.employee_core_info_id=eci.id AND jsp.domain_status_id=1 AND eci.cur_job_status_id != 3 AND date(jsp.date_created) > '2023-12-31'
UNION
SELECT eci.id AS Employee_ID
FROM payroll_emp_data.employee_core_info eci
WHERE eci.cur_job_status_id = 3 AND eci.domain_status_id=1
)
select count(*) from payroll_emp_data.employee_core_info eci inner join Employee_CTE on Employee_CTE.Employee_ID = eci.id
LEFT JOIN payroll_emp_data.gender G ON ECI.gender_id = G.id
where g.id is null


------------------------------------------------------------------  emp category same as mapping : Source ----------------------------------------------------------------------
WITH Employee_CTE AS(
SELECT eci.id AS Employee_ID
FROM payroll_emp_data.employee_information_update e
INNER JOIN payroll_emp_data.employee_core_info eci ON e.employee_core_info_id=eci.id
WHERE e.employee_information_update_change_type_id IN (11, 25) AND date(e.effective_date) > '2023-12-31' and e.new_value != '3' AND E.domain_status_id = 1
UNION
SELECT e.employee_core_info_id::BIGINT AS Employee_ID
FROM payroll_emp_data.emp_core_info_history e
WHERE e.value_type = 'Employee Status Change' AND date(e.create_date) > '2023-12-31'
UNION
SELECT eci.id AS Employee_ID
FROM payroll_emp_data.job_separation_proposal jsp
INNER JOIN payroll_emp_data.employee_core_info eci ON jsp.employee_core_info_id=eci.id AND jsp.domain_status_id=1 AND eci.cur_job_status_id != 3 AND date(jsp.date_created) > '2023-12-31'
UNION
SELECT eci.id AS Employee_ID
FROM payroll_emp_data.employee_core_info eci
WHERE eci.cur_job_status_id = 3 AND eci.domain_status_id=1
)
select count(*) from payroll_emp_data.employee_core_info eci inner join Employee_CTE on Employee_CTE.Employee_ID = eci.id
LEFT JOIN payroll_emp_data.employee_category ec on eci.emp_category_id = ec.id
where eci.emp_category_id is not null and ec.id is null
------------------------------------------------------------------  emp category same as mapping : Destination ----------------------------------------------------------------------
SELECT count(*)
FROM public.integ_employee_imp emp left join public.hmd_empl_category ec on emp.empl_category_code = ec.empl_category_code
where ec.empl_category_code is null

------------------------------------------------------------------  Phone number validation  : Source ----------------------------------------------------------------------
WITH Employee_CTE AS(
SELECT eci.id AS Employee_ID
FROM payroll_emp_data.employee_information_update e
INNER JOIN payroll_emp_data.employee_core_info eci ON e.employee_core_info_id=eci.id
WHERE e.employee_information_update_change_type_id IN (11, 25) AND date(e.effective_date) > '2023-12-31' and e.new_value != '3' AND E.domain_status_id = 1
UNION
SELECT e.employee_core_info_id::BIGINT AS Employee_ID
FROM payroll_emp_data.emp_core_info_history e
WHERE e.value_type = 'Employee Status Change' AND date(e.create_date) > '2023-12-31'
UNION
SELECT eci.id AS Employee_ID
FROM payroll_emp_data.job_separation_proposal jsp
INNER JOIN payroll_emp_data.employee_core_info eci ON jsp.employee_core_info_id=eci.id AND jsp.domain_status_id=1 AND eci.cur_job_status_id != 3 AND date(jsp.date_created) > '2023-12-31'
UNION
SELECT eci.id AS Employee_ID
FROM payroll_emp_data.employee_core_info eci
WHERE eci.cur_job_status_id = 3 AND eci.domain_status_id=1
)
SELECT count(*)
FROM payroll_emp_data.employee_core_info eci inner join Employee_CTE on Employee_CTE.Employee_ID = eci.id
LEFT JOIN payroll_emp_data.employee_contact_info ec ON ec.employee_info_id = eci.id
where     LENGTH(TRIM(ec.mobile_no1)) != 10 -- OR   -- phone_work_direct  LENGTH(TRIM(ec.mobile_no2)) != 10      -- phone_mobile

------------------------------------------------------------------  Phone number validation : Destination ----------------------------------------------------------------------
SELECT count(*)
FROM public.integ_employee_imp
WHERE LENGTH(TRIM(phone_work_direct)) != 10 --OR LENGTH(TRIM(phone_mobile)) != 10 LENGTH(TRIM(phone_home)) != 10 OR

----------------------------------------------------  grade_sub_code Mapping Within grade_code : Source ----------------------------------------------------------------------
WITH Employee_CTE AS(
SELECT eci.id AS Employee_ID
FROM payroll_emp_data.employee_information_update e
INNER JOIN payroll_emp_data.employee_core_info eci ON e.employee_core_info_id=eci.id
WHERE e.employee_information_update_change_type_id IN (11, 25) AND date(e.effective_date) > '2023-12-31' and e.new_value != '3' AND E.domain_status_id = 1
UNION
SELECT e.employee_core_info_id::BIGINT AS Employee_ID
FROM payroll_emp_data.emp_core_info_history e
WHERE e.value_type = 'Employee Status Change' AND date(e.create_date) > '2023-12-31'
UNION
SELECT eci.id AS Employee_ID
FROM payroll_emp_data.job_separation_proposal jsp
INNER JOIN payroll_emp_data.employee_core_info eci ON jsp.employee_core_info_id=eci.id AND jsp.domain_status_id=1 AND eci.cur_job_status_id != 3 AND date(jsp.date_created) > '2023-12-31'
UNION
SELECT eci.id AS Employee_ID
FROM payroll_emp_data.employee_core_info eci
WHERE eci.cur_job_status_id = 3 AND eci.domain_status_id=1
)
SELECT eci.employee_level_id, eci.slab_id, count(*)
FROM payroll_emp_data.employee_core_info eci inner join Employee_CTE on Employee_CTE.Employee_ID = eci.id
where slab_id is null
group by 1,2
order by 1,2

------------------------------------------------------------------  employee_job_status Mapping : Destination ----------------------------------------------------------------------
SELECT count(*)
FROM public.integ_employee_imp e left join public.integ_employment_status_map m on e.employee_job_status = m.status_code
where m.status_code is null


