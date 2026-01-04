-----------------------------------CDC_Division--------------------------------------

SELECT
    n.id,
    n.name,
    n.div_code,
    CASE
        WHEN o.id IS NULL THEN 'Insert'
        WHEN
            n.name IS DISTINCT FROM o.name
            OR n.div_code IS DISTINCT FROM o.div_code
        THEN 'Update'
    END AS FLAG
FROM cdc.mdg_division n
LEFT JOIN public.mdg_division o
    ON n.id = o.id
WHERE
    o.id IS NULL
    OR n.name IS DISTINCT FROM o.name
    OR n.div_code IS DISTINCT FROM o.div_code;

-----------------------------------CDC_District --------------------------------------
SELECT
    n.dist_code,
    n.name,
    n.div_code,
    CASE
        WHEN o.dist_code IS NULL THEN 'Insert'
        WHEN
            n.name IS DISTINCT FROM o.name
            OR n.div_code IS DISTINCT FROM o.div_code
        THEN 'Update'
    END AS FLAG
FROM cdc.mdg_district n
LEFT JOIN public.mdg_district o
    ON n.dist_code = o.dist_code
WHERE
    o.dist_code IS NULL
    OR n.name IS DISTINCT FROM o.name
    OR n.div_code IS DISTINCT FROM o.div_code;


-----------------------------------CDC_Upazila --------------------------------------

SELECT
    n.upazila_code,
    n.name,
    n.dist_code,
    CASE
        WHEN o.upazila_code IS NULL THEN 'Insert'
        WHEN
            n.name IS DISTINCT FROM o.name
            OR n.dist_code IS DISTINCT FROM o.dist_code
        THEN 'Update'
    END AS FLAG
FROM cdc.mdg_upazila n
LEFT JOIN public.mdg_upazila o
    ON n.upazila_code = o.upazila_code and n.dist_code = o.dist_code
WHERE
    o.upazila_code IS NULL
    OR n.name IS DISTINCT FROM o.name
    OR n.dist_code IS DISTINCT FROM o.dist_code;

-----------------------------------CDC_oper_location --------------------------------------

SELECT
    n.oper_loc_code,
    n.name,
    n.address,
    n.upozila_code,
    n.district_code,
    n.division_code,
    CASE
        WHEN o.oper_loc_code IS NULL THEN 'Insert'
        WHEN
            n.name IS DISTINCT FROM o.name
            OR n.address IS DISTINCT FROM o.address
            OR n.upozila_code IS DISTINCT FROM o.upozila_code
            OR n.district_code IS DISTINCT FROM o.district_code
            OR n.division_code IS DISTINCT FROM o.division_code
        THEN 'Update'
    END AS FLAG
FROM cdc.integ_oper_location_imp n
LEFT JOIN public.integ_oper_location_imp o
    ON n.oper_loc_code = o.oper_loc_code
WHERE
    o.oper_loc_code IS NULL
    OR n.name IS DISTINCT FROM o.name
    OR n.address IS DISTINCT FROM o.address
    OR n.upozila_code IS DISTINCT FROM o.upozila_code
    OR n.district_code IS DISTINCT FROM o.district_code
    OR n.division_code IS DISTINCT FROM o.division_code;


-----------------------------------CDC_Section --------------------------------------
SELECT
    n.sec_code,
    n.name,
    n.dept_code,
    n.cost_cent_code,
    CASE
        WHEN o.sec_code IS NULL THEN 'Insert'
        WHEN
            n.name IS DISTINCT FROM o.name
            OR n.dept_code IS DISTINCT FROM o.dept_code
            OR n.cost_cent_code IS DISTINCT FROM o.cost_cent_code
        THEN 'Update'
    END AS FLAG
FROM cdc.integ_section_imp n
LEFT JOIN public.integ_section_imp o
    ON n.sec_code = o.sec_code
WHERE
    o.sec_code IS NULL
    OR n.name IS DISTINCT FROM o.name
    OR n.dept_code IS DISTINCT FROM o.dept_code
    OR n.cost_cent_code IS DISTINCT FROM o.cost_cent_code;

-- sec_code 114 was before, now it's 114-. in our process we capture it as insert

-----------------------------------CDC_Department --------------------------------------
SELECT
    n.dept_code,
    n.name,
    n.functional_area_code,
    CASE
        WHEN o.dept_code IS NULL THEN 'Insert'
        WHEN
            n.name IS DISTINCT FROM o.name
            OR n.functional_area_code IS DISTINCT FROM o.functional_area_code
        THEN 'Update'
    END AS FLAG
FROM cdc.integ_department_imp n
LEFT JOIN public.integ_department_imp o
    ON n.dept_code = o.dept_code
WHERE
    o.dept_code IS NULL
    OR n.name IS DISTINCT FROM o.name
    OR n.functional_area_code IS DISTINCT FROM o.functional_area_code;


-----------------------------------CDC_Designation --------------------------------------
SELECT
    n.code,
    n.name,
    CASE
        WHEN o.code IS NULL THEN 'Insert'
        WHEN
            n.name IS DISTINCT FROM o.name
        THEN 'Update'
    END AS FLAG
FROM cdc.integ_designation_imp n
LEFT JOIN public.integ_designation_imp o
    ON n.code = o.code
WHERE
    o.code IS NULL
    OR n.name IS DISTINCT FROM o.name;

-----------------------------------CDC_Cost_centre --------------------------------------

SELECT
    n.cc_code,
    n.name,
    CASE
        WHEN o.cc_code IS NULL THEN 'Insert'
        WHEN
            n.name IS DISTINCT FROM o.name
        THEN 'Update'
    END AS FLAG
FROM cdc.integ_cost_centre_imp n
LEFT JOIN public.integ_cost_centre_imp o
    ON n.cc_code = o.cc_code
WHERE
    o.cc_code IS NULL
    OR n.name IS DISTINCT FROM o.name;
