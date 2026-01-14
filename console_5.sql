-- Select * from LM_LOAN_TYPE
Select * from LM_LOAN_APP;
Select * from LM_LOAN_APP_DOC;
Select * from LM_LOAN_ACCT;
Select * from LM_LOAN_ACCT_INST_SCHEDULE order by loan_acct_id desc, inst_number asc ;
Select * from LM_LOAN_ACCT_BALANCE;
Select * from LM_LOAN_TRAN order by empl_profile_id, loan_acct_id


select * from lm_loan_type_name

Select loan_type_code,
       name,
       loan_category,
       charge_interest,
       rate_of_interest,
       apply_eligibility_criteria,
       job_len_fund_bal_criteria,
       restrict_multiple_loan_same_type,
       restrict_new_loan_after_early_close,
       restrict_new_loan_after_months_regular_close,
       max_loan_amt,
       installment_no_rule,
       max_install_amt,
       limit_in_job_tenure,
       max_no_in_job_tenure,
       empl_category_specific,
       INCLUDE_TOTAL_LOAN_EXPOSURE,
       FIRST_INSTALL_DUE_MON,
LOAN_APPR_VALIDITY_DAYS ,
INACTIVE,
MERGE_ALLOWED,
MERGE_OPTION_IN_SELF_SERVICE,
GROSS_SALARY_MULTIPLIER
from LM_LOAN_TYPE left join lm_loan_type_name on LM_LOAN_TYPE.loan_type_name_id = lm_loan_type_name.id

select * from lm_loan_purpose

select * from mdg_employee_fund

kichu korte chai
