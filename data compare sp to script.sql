with altercte as (SELECT
    l.employeeid,
    l.loanno,
    l.rownumber,
    TO_CHAR(MAKE_DATE(l.fyear, l.fmonth, 1),'Mon - YYYY') AS legacy_period,
    TO_CHAR(MAKE_DATE(c.fyear, c.fmonth, 1),'Mon - YYYY') AS current_period,
    ( l.fyear = c.fyear AND l.fmonth = c.fmonth) AS period_match,
    l.openbalance   AS legacy_openbalance,
    c.openbalance   AS current_openbalance,
    l.openbalance = c.openbalance AS openbalance_match,
    l.installment   AS legacy_installment,
    c.installment   AS current_installment,
    l.installment = c.installment AS installment_match,
    l.intoutstanding AS legacy_intoutstanding,
    c.intoutstanding AS current_intoutstanding,
    l.intoutstanding = c.intoutstanding AS intoutstanding_match,
    l.interest      AS legacy_interest,
    c.interest      AS current_interest,
    l.interest = c.interest AS interest_match,
    l.principal     AS legacy_principal,
    c.principal     AS current_principal,
    l.principal = c.principal AS principal_match,
    l.closebalance  AS legacy_closebalance,
    c.closebalance  AS current_closebalance,
    l.closebalance = c.closebalance AS closebalance_match
FROM sp_employee_loanrealizationreport l JOIN sp_employee_loanrealizationreport2 c
  ON l.employeeid = c.employeeid
 AND l.loanno     = c.loanno
 AND l.rownumber  = c.rownumber)
select * from altercte
where period_match = False or openbalance_match = False or installment_match = False or intoutstanding_match  = False or
      interest_match = False or principal_match = False or closebalance_match = False


