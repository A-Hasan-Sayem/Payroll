
---------------------------------------------  NUll count checking START -------------------------------------------------------------------------

/*
    The purpose of this script is to identify key 
    columns in the destination tables that should not have such high null counts.

    By looking at the cols you can easily find out which ones have unusual nulls in them.

*/

drop table if exists redundant_table_cols;
create temporary table redundant_table_cols(table_name varchar, column_name varchar);

INSERT INTO redundant_table_cols (table_name, column_name) VALUES
-- hmd_designation
('hmd_designation', 'id'),
('hmd_designation', 'created_by'),
('hmd_designation', 'version'),
('hmd_designation', 'created_date'),
('hmd_designation', 'last_modified_by'),
('hmd_designation', 'last_modified_date'),

-- mdg_department
('mdg_department', 'id'),
('mdg_department', 'created_by'),
('mdg_department', 'created_date'),
('mdg_department', 'version'),
('mdg_department', 'last_modified_by'),
('mdg_department', 'last_modified_date'),

-- mdg_operating_location
('mdg_operating_location', 'id'),
('mdg_operating_location', 'name_local'),
('mdg_operating_location', 'address_local'),

-- hr_leave_application
('hr_leave_application', 'id'),
('hr_leave_application', 'version'),
('hr_leave_application', 'created_by'),
('hr_leave_application', 'created_date'),
('hr_leave_application', 'last_modified_by'),
('hr_leave_application', 'last_modified_date'),
('hr_leave_application', 'note'),
('hr_leave_application', 'deleted_by'),
('hr_leave_application', 'deleted_date'),
('hr_leave_application', 'leave_app_reversed_id'),
('hr_leave_application', 'exceeds_leave_entitlement'),
('hr_leave_application', 'doc_sent_to_hr_date'),
('hr_leave_application', 'doc_recvd_by_hr'),
('hr_leave_application', 'balance_days'),
('hr_leave_application', 'calendar_days'),
('hr_leave_application', 'working_days'),
('hr_leave_application', 'approver_username'),
('hr_leave_application', 'approver_date'),
('hr_leave_application', 'recall_date'),
('hr_leave_application', 'reference_application_id'),
('hr_leave_application', 'custom1'),

-- hr_leave_application_line
('hr_leave_application_line', 'id'),
('hr_leave_application_line', 'version'),
('hr_leave_application_line', 'created_by'),
('hr_leave_application_line', 'created_date'),
('hr_leave_application_line', 'last_modified_by'),
('hr_leave_application_line', 'last_modified_date'),
('hr_leave_application_line', 'remarks'),
('hr_leave_application_line', 'processed'),
('hr_leave_application_line', 'leave_app_line_reversed_id'),
('hr_leave_application_line', 'deleted_by'),
('hr_leave_application_line', 'deleted_date'),

-- hr_work_away_office
('hr_work_away_office', 'id'),
('hr_work_away_office', 'version'),
('hr_work_away_office', 'created_by'),
('hr_work_away_office', 'created_date'),
('hr_work_away_office', 'last_modified_by'),
('hr_work_away_office', 'last_modified_date'),
('hr_work_away_office', 'recall_date'),
('hr_work_away_office', 'file_ref_itinerary'),

-- hr_work_away_office_line
('hr_work_away_office_line', 'id'),
('hr_work_away_office_line', 'version'),
('hr_work_away_office_line', 'created_by'),
('hr_work_away_office_line', 'created_date'),
('hr_work_away_office_line', 'last_modified_by'),
('hr_work_away_office_line', 'last_modified_date'),

-- mdg_dept_section
('mdg_dept_section', 'id'),
('mdg_dept_section', 'version'),
('mdg_dept_section', 'created_by'),
('mdg_dept_section', 'created_date'),
('mdg_dept_section', 'last_modified_by'),
('mdg_dept_section', 'last_modified_date'),

-- hr_leave_opening_balance
('hr_leave_opening_balance', 'id'),
('hr_leave_opening_balance', 'version'),
('hr_leave_opening_balance', 'created_by'),
('hr_leave_opening_balance', 'created_date'),
('hr_leave_opening_balance', 'last_modified_by'),
('hr_leave_opening_balance', 'last_modified_date'),
('hr_leave_opening_balance', 'deleted_by'),
('hr_leave_opening_balance', 'deleted_date'),

-- hr_attend_missed_app
('hr_attend_missed_app', 'id'),
('hr_attend_missed_app', 'version'),
('hr_attend_missed_app', 'created_by'),
('hr_attend_missed_app', 'created_date'),
('hr_attend_missed_app', 'approver_username'),
('hr_attend_missed_app', 'approver_date'),
('hr_attend_missed_app', 'last_modified_by'),
('hr_attend_missed_app', 'last_modified_date'),
('hr_attend_missed_app', 'comments'),

-- mdg_empl_profile
('mdg_empl_profile', 'id'),
('mdg_empl_profile', 'version'),
('mdg_empl_profile', 'created_by'),
('mdg_empl_profile', 'created_date'),
('mdg_empl_profile', 'last_modified_by'),
('mdg_empl_profile', 'last_modified_date'),
('mdg_empl_profile', 'empl_photo'),
('mdg_empl_profile', 'market_hierarchy_id'),
('mdg_empl_profile', 'manager_matrix_id'),
('mdg_empl_profile', 'job_family_id'),
('mdg_empl_profile', 'hr_business_part_prof_id'),
('mdg_empl_profile', 'workflow_group_id'),
('mdg_empl_profile', 'job_title'),
('mdg_empl_profile', 'ot_hourly_rate'),
('mdg_empl_profile', 'job_offer_no'),
('mdg_empl_profile', 'job_appointment_issued'),
('mdg_empl_profile', 'salary_approve_date'),
('mdg_empl_profile', 'payscale_id'),
('mdg_empl_profile', 'payscale_cmp_id'),
('mdg_empl_profile', 'basic_salary_cmp'),
('mdg_empl_profile', 'update_date'),

('mdg_empl_profile', 'hr_business_partner_id'),
('mdg_empl_profile', 'attend_location_id'),
('mdg_empl_profile', 'attend_latitude'),
('mdg_empl_profile', 'attend_longitude'),

('mdg_empl_profile', 'total_salary_amount'),
('mdg_empl_profile', 'allowance_second_pmt_id'),
('mdg_empl_profile', 'second_pmt_mehod_percent'),
('mdg_empl_profile', 'salary_amt_second_pmt'),
('mdg_empl_profile', 'salary_amount'),

('mdg_empl_profile', 'pf_member_id'),
('mdg_empl_profile', 'gratuity_member_id'),
('mdg_empl_profile', 'dps_member_id'),
('mdg_empl_profile', 'gratuity_effective_date'),
('mdg_empl_profile', 'spouse'),
('mdg_empl_profile', 'number_of_child'),
('mdg_empl_profile', 'empl_date'),
('mdg_empl_profile', 'join_date_planned'),
('mdg_empl_profile', 'curr_position_since'),
('mdg_empl_profile', 'marriage_date'),
('mdg_empl_profile', 'job_description'),
('mdg_empl_profile', 'phone_work_pabx'),
('mdg_empl_profile', 'phone_work_pabx_ext'),
('mdg_empl_profile', 'tax_zone'),
('mdg_empl_profile', 'marital_status'),
('mdg_empl_profile', 'signature_speciman'),
('mdg_empl_profile', 'signature_update_date'),
('mdg_empl_profile', 'deleted_by'),
('mdg_empl_profile', 'deleted_date');

---------------------------------------------------------------------------------------------------

drop table if exists temp_null_counts ;
DO $$
DECLARE
    col RECORD;
    query TEXT;
BEGIN
    CREATE TEMP TABLE temp_null_counts (
        schema_name TEXT,
        table_name TEXT,
        column_name TEXT,
        null_count BIGINT
    );

    FOR col IN
        SELECT a.table_schema,
               a.table_name,
               a.column_name
        FROM information_schema.columns a
        LEFT JOIN redundant_table_cols b
            ON (a.table_name = b.table_name) and (a.column_name = b.column_name)
        WHERE a.table_schema NOT IN ('information_schema', 'pg_catalog')
          -- AND table_schema NOT LIKE 'pg_toast%'
            AND a.is_nullable = 'YES'
            and a.table_schema='public'
            and a.table_name in (select lower(a.original_table) from table_map_migration a)
--             and a.table_name = 'hmd_designation'
        and b.column_name is null
    LOOP
        IF col.table_schema = 'public' AND col.table_name = 'mdg_empl_profile' THEN
        query := FORMAT(
            'INSERT INTO temp_null_counts ' ||
            'SELECT %L, %L, %L, COUNT(*) FROM %I.%I WHERE %I IS NULL AND employee_code in (select pin from payroll_leave_attend_data.employee_records_beta_30)',
            col.table_schema, col.table_name, col.column_name,
            col.table_schema, col.table_name, col.column_name
        );
        else

            query := FORMAT(
            'INSERT INTO temp_null_counts ' ||
            'SELECT %L, %L, %L, COUNT(*) FROM %I.%I WHERE %I IS NULL',
            col.table_schema, col.table_name, col.column_name,
            col.table_schema, col.table_name, col.column_name
        );
            END IF;
        EXECUTE query;
    END LOOP;

    -- View the results
    RAISE NOTICE 'Column-wise null counts:';
    FOR col IN SELECT * FROM temp_null_counts ORDER BY null_count DESC
    LOOP
        RAISE NOTICE '%', col;
    END LOOP;
END $$;

select * from temp_null_counts a where a.null_count>0;


---------------------------------------------  NUll count checking END -------------------------------------------------------------------------
