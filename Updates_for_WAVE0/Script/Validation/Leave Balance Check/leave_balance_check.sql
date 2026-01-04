-- call sphr_leaveopeningandbalanceupdateallcompany();


DROP TABLE IF EXISTS data_migration_leave_check;
CREATE TEMPORARY TABLE data_migration_leave_check (
    employee_code VARCHAR,
    employment_status integer,
    empl_type integer,
    leave_type_code VARCHAR,
    leave_year_code VARCHAR,

    balance_days_integ NUMERIC,
    balance_days_destination NUMERIC,
    balance_days_match VARCHAR
);


TRUNCATE TABLE data_migration_leave_check;

DO $$
DECLARE
    rec RECORD;
    balance_days_val NUMERIC;
    balance_days_opening_val NUMERIC;
BEGIN
    FOR rec IN
        SELECT e.id AS employee_profile_id,
               c.id AS leave_type_id, mly.id AS leave_year_id,
               a.employee_code as employee_code,
               e.employment_status,
               e.empl_type,
               a.leave_type_code as leave_type_code,
               a.leave_year_code as leave_year_code
        FROM integ_leave_op_balance_imp a
        inner join payroll_leave_attend_data.employee_records_beta_30 bu
            on bu.pin=a.employee_code
        inner join mdg_empl_profile e on a.employee_code = e.employee_code
--         left join mdg_empl_profile b ON a.employee_code = b.employee_code
        left join hmd_leave_type c ON c.leave_type_code = a.leave_type_code
        left join public.mdg_leave_year mly on a.leave_year_code = trim(mly.name)
    LOOP
        EXECUTE format(
            'SELECT balance_days FROM hr_leave_balance WHERE employee_profile_id = %L AND leave_type_id = %L AND leave_year_id = %L',
            rec.employee_profile_id, rec.leave_type_id, rec.leave_year_id
        )
        INTO balance_days_val;
        EXECUTE format(
            'SELECT balance_days FROM integ_leave_op_balance_imp WHERE employee_code = %L AND leave_type_code = %L AND leave_year_code = %L',
            rec.employee_code, rec.leave_type_code, rec.leave_year_code
        )
        INTO balance_days_opening_val;

        INSERT INTO data_migration_leave_check (
            employee_code,
            employment_status,
            empl_type,
            leave_type_code,
            leave_year_code,
            balance_days_integ,
            balance_days_destination,
            balance_days_match
        )
        VALUES (
            rec.employee_code,
            rec.employment_status,
            rec.empl_type,
            rec.leave_type_code,
            rec.leave_year_code,
            balance_days_opening_val,
            balance_days_val,
            CASE WHEN balance_days_val = balance_days_opening_val THEN 'Yes' ELSE 'No' END
        );
    END LOOP;
END $$;

--
-- SELECT a.*, (a.balance_days_integ - a.balance_days_destination) difference,contr.contract_end_date,contr.join_date_actual
-- FROM data_migration_leave_check a
-- inner join (
--     select a.employee_code,a.contract_end_date,a.join_date_actual from mdg_empl_profile a
--     inner join hmd_empl_category b on a.empl_category_id=b.id
--     where a.employee_code in (select a.employeepin from payroll_leave_attend_data.employee_records_beta_30 a) and a.empl_type=60
--     and b.empl_category_code='C'
-- ) contr on contr.employee_code=a.employee_code
-- order by  a.leave_type_code
-- ;

SELECT a.employee_code,
       a.leave_type_code,
       a.leave_year_code,
       a.balance_days_integ,
       a.balance_days_destination,
       a.balance_days_match,
       Case when a.balance_days_integ>a.balance_days_destination then
    (a.balance_days_integ - a.balance_days_destination) else (a.balance_days_destination-a.balance_days_integ) end
    difference
FROM data_migration_leave_check a
left join (
    select a.employee_code,
           a.contract_end_date,
           a.join_date_actual
    from mdg_empl_profile a
    inner join hmd_empl_category b on a.empl_category_id=b.id
    where a.employee_code in (select a.pin from payroll_leave_attend_data.employee_records_beta_30 a)
--     and a.empl_type=60
--     and b.empl_category_code='C'
) contr on contr.employee_code=a.employee_code
where contr.employee_code is null
;


--------------------- Issue check -----------------------------------

select * from hr_leave_balance h
         where h.employee_profile_id in (select e.id
                                         from mdg_empl_profile e
                                         where e.employee_code = '00137408');



select * from integ_leave_op_balance_imp where employee_code = '00137408';



select * from hr_leave_opening_balance where employee_profile_id in (select e.id
                                         from mdg_empl_profile e
                                         where e.employee_code = '00137408');


select A.employee_code, e.employment_status, difference from (
select *, Case when a.balance_days_integ>a.balance_days_destination then
    (a.balance_days_integ - a.balance_days_destination) else (a.balance_days_destination-a.balance_days_integ) end
    difference
from data_migration_leave_check a ) A
INNER JOIN mdg_empl_profile e on A.employee_code = e.employee_code
where A.balance_days_match = 'No' and A.difference is null
;

select e.employee_code, e.name, e.employment_status, t.leave_type_code, l.leave_entitle_period from mdg_empl_profile e
    INNER JOIN hmd_leave_profile p ON p.id = e.leave_profile_id
    INNER JOIN hmd_leave_profile_line l ON l.leave_profile_id = p.id
    INNER JOIN hmd_leave_type t on l.leave_type_id = t.id
where e.employee_code = '00274456'
and t.leave_type_code = '00';

------------------------------------------- see what happens inside the functions ------------------------

SELECT
         lt.name,e.employment_status,
         ct.name,p.name,
        fnhr_getleavedaysentitlement(
			e.id,
			e.empl_category_id,
			e.join_date_actual,
			(select a.id from mdg_leave_year a where a.current_leave_year=true),
			l.id,
			l.number_of_days_per_period,
			l.limit_variation_type,
			l.min_job_length_month,
			l.entitle_calc_method,
			l.leave_entitle_calc_method_rule_id,
            l.special_rule,
			e.confirmation_date,
			e.contract_end_date
		),
    fnleave_calcofworkingdaysintheyearempl(e.join_date_actual,
                        '2025-01-01'::date,
            e.confirmation_date,'2025-12-31'::date
            ,
            e.id,
            (select a.id from mdg_leave_year a where a.current_leave_year=true),
             30),
    public.fnleave_leaveentitledremainingperiod(
									'2025-01-01'::date, '2025-08-30'::Date,
                                    365, 20),
    public.fnleave_calcofworkingdaysintheyearempl(
                            e.join_date_actual,'2025-01-01'::date ,
    e.confirmation_date, '2025-12-31'::date, e.id,
                            (select a.id from mdg_leave_year a where a.current_leave_year=true), 20)
  ,  l.entitle_calc_method
    FROM mdg_empl_profile e
    INNER JOIN hmd_leave_profile p ON p.id = e.leave_profile_id
    INNER JOIN hmd_leave_profile_line l ON l.leave_profile_id = p.id
    inner join hmd_leave_type lt on lt.id=l.leave_type_id
    inner join hmd_empl_category ct on ct.id=e.empl_category_id

	WHERE
-- 		l.leave_entitle_period IN (10, 20)
-- 		AND
-- 		e.employment_status IN (20,40)
-- and
	    e.employee_code='00257908'
;


----------------------------------------------------

select e.name, e.employee_code, e.employment_status, e.empl_type from mdg_empl_profile e
where e.employee_code = '00279856';

select e.last_working_day
from cdc.integ_employee_imp e
where employee_code = '00279856'


