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
    SIGNED_AGREEMENT,
    PREVIOUS_APP_INFO,
    MERGE_WITH_EXISTING_LOAN_ACCT,
    PURPOSE_ID,
    LOAN_CATEGORY,
    CHILD_NAME,
    INSTITUTE_TYPE,
    OVERRIDE_FLAG
)
with loan_app as (select employeeid, applicationno,loanno,loanid, applieddate, appliedamount, remarks, applicationstatus, noofinstallment, installmentamount
from "Airbyte".loan_loanapplication
where applicationstatus = 'A'
UNION
SELECT lam.employeeid,applicationid, lam.slno AS loanno,lam.loanid,lam.applieddate,lam.appliedamt,lam.remarks,'A' AS applicationstatus,NULL AS noofinstallment,NULL AS installmentamount
FROM "Airbyte".loan_loanapplication_manual lam left join "Airbyte".loan_loanapplication la on lam.slno = la.loanno
WHERE applicationapprovedyn = 1 and la.loanno is null and lam.slno is not null)
SELECT
    gen_random_uuid() AS ID,
    0 AS VERSION,
    1 AS CREATED_BY,
    NOW() AS CREATED_DATE,
    1 AS LAST_MODIFIED_BY,
    NOW() AS LAST_MODIFIED_DATE,
    NULL AS LOAN_APP_NO,
    la.APPLIEDDATE AS LOAN_APP_DATE,
    ep.company_id AS COMPANY_ID,
    d_le.id AS LOAN_ACCT_ID,
    'Hardcode Master Data' AS EMPLOYEE_FUND_PROFILE_ID, -- MASTER DATA pending
    ep.id AS EMPL_PROFILE_ID,
    la.loanid AS LOAN_TYPE_ID, --make sure where will it come from la or le
    la.remarks AS LOAN_PURPOSE, --make sure where will it come from la or le
    la.APPLIEDAMOUNT AS AMOUNT, --make sure where will it come from la or le
    la.NOOFINSTALLMENT AS NO_OF_INSTALLMENT, --make sure where will it come from la or le
    la.INSTALLMENTAMOUNT AS AMOUNT_INSTALLMENT, --make sure where will it come from la or le
    NULL AS DOC_IMAGE,
    NULL AS DOC_NAME,
    '40' AS PROCESS_STATE, --APPROVED(40)
    NULL AS APPROVER_USERNAME,
    sal.id AS SPL_ALLOW_LEVEL_ID, -- only if applicable
    NULL AS APPROVER_DATE,
    NULL AS CANCEL_DATE,
    NULL AS LOAN_ACCT_MERGE_ID,
    NULL AS FILE_REF,
    NULL AS SIGNED_AGREEMENT,
    NULL AS PREVIOUS_APP_INFO,
    FALSE AS MERGE_WITH_EXISTING_LOAN_ACCT,
    NULL AS PURPOSE_ID,
    NULL AS LOAN_CATEGORY,
    NULL AS CHILD_NAME,
    NULL AS INSTITUTE_TYPE,
    NULL AS OVERRIDE_FLAG
FROM  "Airbyte".loan_loanemployee le left join  loan_app la on le.loanno = la.loanno
    JOIN payroll_leave_attend_data.employee_records_all ie ON ie.pin = la.employeeid
    JOIN public.mdg_empl_profile ep ON ep.employee_code = ie.pin
    LEFT JOIN "Airbyte".loan_loanemployee le ON le.loanno = la.loanno
    LEFT JOIN public.SPL_ALLOW_LEVEL sal ON sal.loan_type_id = la.loanid
    LEFT JOIN public.LM_LOAN_ACCT d_le ON d_le.LOAN_NO = le.loanno
where le.loanstatusid = 1 and le.is_disbursed = 1;

