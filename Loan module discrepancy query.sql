--1--

with emp as (
    select pin_no, employee_name as staffname, name as designation, program_name, project_name, office_code from payroll_loan_data.employee_scope
),
cte as (select employeeid, applicationno,loanno,loanid, applieddate, appliedamount, remarks, applicationstatus, noofinstallment, installmentamount
from loan_loanapplication
where applicationstatus = 'A'
UNION
SELECT lam.employeeid,applicationid, lam.slno AS loanno,lam.loanid,lam.applieddate,lam.appliedamt,lam.remarks,'A' AS applicationstatus,NULL AS noofinstallment,NULL AS installmentamount
FROM loan_loanapplication_manual lam left join loan_loanapplication la on lam.slno = la.loanno
WHERE applicationapprovedyn = 1 and la.loanno is null and lam.slno is not null)

select emp.*, ls.loanname, le.loanno, cte.noofinstallment, cte.installmentamount
from cte join loan_loanemployee le on cte.loanno = le.loanno
left join loan_loansetup ls on le.loanid = ls.loanid
join emp on Lpad(le.employeeid,8,0) = emp.pin_no
where le.loanstatusid = 1 and (cte.installmentamount <=0 or cte.noofinstallment <=0) and is_disbursed = 1;

--2--

with emp as (
    select pin_no, employee_name as staffname, name as designation, program_name, project_name, office_code from payroll_loan_data.employee_scope
),
cte as (select employeeid, applicationno,loanno,loanid, applieddate, appliedamount, remarks, applicationstatus, noofinstallment, installmentamount
from loan_loanapplication
where applicationstatus = 'A'
UNION
SELECT lam.employeeid,applicationid, lam.slno AS loanno,lam.loanid,lam.applieddate,lam.appliedamt,lam.remarks,'A' AS applicationstatus,NULL AS noofinstallment,NULL AS installmentamount
FROM loan_loanapplication_manual lam left join loan_loanapplication la on lam.slno = la.loanno
WHERE applicationapprovedyn = 1 and la.loanno is null and lam.slno is not null)

select emp.*, le.loanno, ls.loanname as loan_emp_loan_name, le.loanid loan_emp_loan_id, ls2.loanname as loan_app_loan_name, la.loanid loan_app_loan_id
from cte la join loan_loanemployee le on la.loanno = le.loanno
left join loan_loansetup ls on le.loanid = ls.loanid
left join loan_loansetup ls2 on la.loanid = ls2.loanid
join emp on le.employeeid = emp.pin_no
where le.loanstatusid = 1 and is_disbursed = 1 and la.loanid <> le.loanid and la.loanid not in ('0110','0111','0112','0113','0115','0116','0118','0119','0120','0121');

--3--
with emp as (
    select pin_no, employee_name as staffname, name as designation, program_name, project_name, office_code from payroll_loan_data.employee_scope
)
select emp.*, le.loanno, ls.loanname, le.principleamt, le.installmentamt,le.noinstallment, le.installmentamt * le.noinstallment  amount
from  loan_loanemployee le left join loan_loansetup ls on le.loanid = ls.loanid
join emp on le.employeeid = emp.pin_no
where le.loanstatusid = 1 and le.is_disbursed = 1 and le.principleamt > (le.installmentamt*le.noinstallment);

--4--
with emp as (
    select pin_no, employee_name as staffname, name as designation, program_name, project_name, office_code from payroll_loan_data.employee_scope
)
select emp.*, le.loanno, ls.loanname, le.principleamt, sum(disburseamount) disburseamount
from  loan_loanemployee le left join loan_loansetup ls on le.loanid = ls.loanid
join emp on le.employeeid = emp.pin_no
left join loan_loandisbursementdetails ld on ld.loanno = le.loanno
where le.loanstatusid = 1 and le.is_disbursed = 1
group by 1,2,3,4,5,6,7,8,9
having sum(disburseamount) <> principleamt;

--5--
with emp as (
    select pin_no, employee_name as staffname, name as designation, program_name, project_name, office_code from payroll_loan_data.employee_scope
)
select emp.*, le.loanno, ls.loanname, le.principleamt, le.sanctionamt
from  loan_loanemployee le left join loan_loansetup ls on le.loanid = ls.loanid
join emp on le.employeeid = emp.pin_no
where le.loanstatusid = 1 and le.is_disbursed = 1 and  le.sanctionamt < le.principleamt;


--6--
with emp as (
    select pin_no, employee_name as staffname, name as designation, program_name, project_name, office_code from payroll_loan_data.employee_scope
)
select emp.*, le.loanno, ls.loanname, le.principleamt, le.sanctionamt
from  loan_loanemployee le left join loan_loansetup ls on le.loanid = ls.loanid
join emp on le.employeeid = emp.pin_no
where le.loanstatusid = 1 and le.is_disbursed = 1 and  le.sanctionamt > le.principleamt;

--7--
with emp as (
    select pin_no, employee_name as staffname, name as designation, program_name, project_name, office_code from payroll_loan_data.employee_scope
)
select emp.*, le.loanno, ls.loanname, le.collstartdate, le.paymentdate
from  loan_loanemployee le left join loan_loansetup ls on le.loanid = ls.loanid
join emp on le.employeeid = emp.pin_no
where le.loanstatusid = 1 and le.is_disbursed = 1 and  le.collstartdate < le.paymentdate;

--8--

with emp as (
    select pin_no, employee_name as staffname, name as designation, program_name, project_name, office_code from payroll_loan_data.employee_scope
)
select emp.*, le.loanno, ls.loanname, le.sanctiondate, ld.disbursedate
from  loan_loanemployee le left join loan_loansetup ls on le.loanid = ls.loanid
join emp on le.employeeid = emp.pin_no
left join loan_loandisbursementdetails ld on ld.loanno = le.loanno
where le.loanstatusid = 1 and le.is_disbursed = 1 and date(le.sanctiondate) > date(ld.disbursedate);


--9--

with emp as (
    select pin_no, employee_name as staffname, name as designation, program_name, project_name, office_code from payroll_loan_data.employee_scope
)
select emp.*, le.loanno, ls.loanname, date as collection_month, lc.openingbalance
from  loan_loanemployee le left join loan_loansetup ls on le.loanid = ls.loanid
join emp on le.employeeid = emp.pin_no
left join  payroll_loan_data.sp_dump lc on le.loanno = lc.loanno
left join loan_loandisbursementdetails ld on ld.loanno = le.loanno
where le.loanstatusid = 1 and le.is_disbursed = 1 and lc.openingbalance<0;

--16--

with emp as (
    select pin_no, employee_name as staffname, name as designation, program_name, project_name, office_code from payroll_loan_data.employee_scope
)
select emp.*, le.loanno, ls.loanname, count(distinct lc.lcsrealizationamt) No_of_distinct_installment
from  loan_loanemployee le left join loan_loansetup ls on le.loanid = ls.loanid
join emp on le.employeeid = emp.pin_no
left join  payroll_loan_data.sp_dump lc on le.loanno = lc.loanno
where le.loanstatusid = 1 and le.is_disbursed = 1
group by 1,2,3,4,5,6,7,8
having count(distinct lc.lcsrealizationamt) > 1
order by 9 desc;

--17--

with emp as (
    select pin_no, employee_name as staffname, name as designation, program_name, project_name, office_code from payroll_loan_data.employee_scope
)
select emp.*, le.loanno, ls.loanname, date as collection_month, lc.interest
from  loan_loanemployee le left join loan_loansetup ls on le.loanid = ls.loanid
join emp on le.employeeid = emp.pin_no
left join  payroll_loan_data.sp_dump lc on le.loanno = lc.loanno
left join loan_loandisbursementdetails ld on ld.loanno = le.loanno
where le.loanstatusid = 1 and le.is_disbursed = 1 and lc.interest<0 ;

--18--

with emp as (
    select pin_no, employee_name as staffname, name as designation, program_name, project_name, office_code from payroll_loan_data.employee_scope
)
select emp.*, le.loanno, ls.loanname, date as collection_month, lc.intoutstanding
from  loan_loanemployee le left join loan_loansetup ls on le.loanid = ls.loanid
join emp on le.employeeid = emp.pin_no
left join  payroll_loan_data.sp_dump lc on le.loanno = lc.loanno
left join loan_loandisbursementdetails ld on ld.loanno = le.loanno
where le.loanstatusid = 1 and le.is_disbursed = 1 and lc.intoutstanding<0 ;
