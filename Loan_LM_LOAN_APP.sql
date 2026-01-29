INSERT INTO LM_LOAN_APP (
    ID,
    VERSION,
    CREATED_BY,
    CREATED_DATE,
    LAST_MODIFIED_BY,
    LAST_MODIFIED_DATE,
    LOAN_APP_NO,
    LOAN_APP_DATE,
    COMPANY_ID,
    LOAN_ACCT_ID,
    EMPLOYEE_FUND_PROFILE_ID,
    EMPL_PROFILE_ID,
    LOAN_TYPE_ID,
    LOAN_PURPOSE,
    AMOUNT,
    NO_OF_INSTALLMENT,
    AMOUNT_INSTALLMENT,
    DOC_IMAGE,
    DOC_NAME,
    PROCESS_STATE,
    APPROVER_USERNAME,
    SPL_ALLOW_LEVEL_ID,
    APPROVER_DATE,
    CANCEL_DATE,
    LOAN_ACCT_MERGE_ID,
    FILE_REF,
    FILE_REF,
    SIGNED_AGREEMENT,
    PREVIOUS_APP_INFO,
    MERGE_WITH_EXISTING_LOAN_ACCT,
    PURPOSE_ID,
    LOAN_CATEGORY,
    CHILD_NAME,
    INSTITUTE_TYPE,
    OVERRIDE_FLAG,
    COMMENTS
)
with loan_app as (select employeeid, applicationno,loanno,loanid, applieddate, appliedamount, remarks, applicationstatus, noofinstallment, installmentamount, mcusagetype
from "Airbyte".loan_loanapplication
where applicationstatus = 'A'
UNION
SELECT lam.employeeid,applicationid, lam.slno AS loanno,lam.loanid,lam.applieddate,lam.appliedamt,lam.remarks,'A' AS applicationstatus,NULL AS noofinstallment,NULL AS installmentamount, NULL as mcusagetype
FROM "Airbyte".loan_loanapplication_manual lam left join "Airbyte".loan_loanapplication la on lam.slno = la.loanno
WHERE applicationapprovedyn = 1 and la.loanno is null and lam.slno is not null)
SELECT
    gen_random_uuid()::uuid AS ID,
    1::integer AS VERSION,
    '1'::varchar AS CREATED_BY,
    NOW()::timestamp with time zone AS CREATED_DATE,
    '1'::varchar AS LAST_MODIFIED_BY,
    NOW()::timestamp with time zone AS LAST_MODIFIED_DATE,
    NULL::varchar AS LOAN_APP_NO,
    la.APPLIEDDATE::date AS LOAN_APP_DATE,
    ep.company_id::uuid AS COMPANY_ID,
    d_le.id::uuid AS LOAN_ACCT_ID,
    'Hardcode Master Data'::uuid AS EMPLOYEE_FUND_PROFILE_ID, -- MASTER DATA pending
    ep.id::uuid AS EMPL_PROFILE_ID,
    d_lt.id::uuid AS LOAN_TYPE_ID, --make sure where will it come from la or le in join
    la.remarks::text AS LOAN_PURPOSE, --make sure where will it come from la or le
    la.APPLIEDAMOUNT::double precision AS AMOUNT, --make sure where will it come from la or le
    la.NOOFINSTALLMENT::integer AS NO_OF_INSTALLMENT, --make sure where will it come from la or le
    la.INSTALLMENTAMOUNT::double precision AS AMOUNT_INSTALLMENT, --make sure where will it come from la or le
    NULL::bytea AS DOC_IMAGE,
    NULL::varchar AS DOC_NAME,
    40::integer AS PROCESS_STATE, --APPROVED(40)
    NULL::varchar AS APPROVER_USERNAME,
    (CASE la.mcusagetype WHEN '01' THEN '0195ff5f-98b2-7954-94c0-884751582369'
    WHEN '02' THEN '0195ff5f-cc62-7988-aad4-b047a1f95480'
    WHEN '03' THEN '0195ff5f-f815-7e39-af9c-08ae7b74c137'
    WHEN '04' THEN '019bb734-fb56-7f99-a94a-f5ee3462d617' ELSE NULL END)::uuid AS SPL_ALLOW_LEVEL_ID, -- Change these 4 uuid with live table uuid, or join with spl.level_ then take id from that table
    NULL::timestamp with time zone AS APPROVER_DATE,
    NULL::timestamp with time zone AS CANCEL_DATE,
    NULL::uuid AS LOAN_ACCT_MERGE_ID,
    NULL::varchar AS FILE_REF,
    NULL::varchar AS FILE_REF,
    NULL::varchar AS SIGNED_AGREEMENT,
    NULL::text AS PREVIOUS_APP_INFO,
    FALSE::boolean AS MERGE_WITH_EXISTING_LOAN_ACCT,
    NULL::uuid AS PURPOSE_ID,
    NULL::integer AS LOAN_CATEGORY,
    NULL::varchar AS CHILD_NAME,
    NULL::integer AS INSTITUTE_TYPE,
    NULL::boolean AS OVERRIDE_FLAG,
    NULL::varchar as COMMENTS
FROM  "Airbyte".loan_loanemployee le left join  loan_app la on le.loanno = la.loanno
    JOIN payroll_leave_attend_data.employee_records_all ie ON ie.pin = la.employeeid -- will eventuall join with destination live table mdg_empl_profile
    JOIN public.mdg_empl_profile ep ON ep.employee_code = ie.pin
    LEFT JOIN "Airbyte".loan_loanemployee le ON le.loanno = la.loanno
    --LEFT JOIN public.HMD_SPL_ALLOW_LEVEL sal ON sal.level_ = la.mcusagetype
    LEFT JOIN public.LM_LOAN_ACCT d_le ON d_le.LOAN_NO = le.loanno
    LEFT JOIN "Airbyte".loan_loansetup ls on le.loanid = ls.loanid  -- make sure where will it come from la or le
    LEFT JOIN public.LM_LOAN_TYPE d_lt on ls.typeid = d_lt.loan_type_code
where le.loanstatusid = 1 and le.is_disbursed = 1;

