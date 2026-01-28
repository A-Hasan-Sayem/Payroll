INSERT INTO LM_LOAN_APP_DOC (
    ID,
    VERSION,
    CREATED_BY,
    CREATED_DATE,
    LAST_MODIFIED_BY,
    LAST_MODIFIED_DATE,
    DESCRIPTION,
    DOC_IMAGE,
    LOAN_APP_ID,
    FILE_REF
)
SELECT
    gen_random_uuid() AS ID,
    1 AS VERSION,
    1 AS CREATED_BY,
    NOW() AS CREATED_DATE,
    1 AS LAST_MODIFIED_BY,
    NOW() AS LAST_MODIFIED_DATE,
    la.attachment AS DESCRIPTION,
    NULL AS DOC_IMAGE,     -- YET TO BE MAPPED
    d_la.ID AS LOAN_APP_ID,
    NULL AS FILE_REF       -- YET TO BE MAPPED
FROM "Airbyte".loan_loanapplication la join public.LM_LOAN_ACCT d_le on la.loanno = d_le.loan_no
    JOIN public.LM_LOAN_APP d_la on d_la.LOAN_ACCT_ID = d_le.id;
