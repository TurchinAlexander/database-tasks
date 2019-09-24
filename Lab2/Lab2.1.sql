use AdventureWorks2012
go

-- Task 2. Part 1
-- Variant 2

/*
	Show the history of an employee who is working on position 'Purchasing Manager'.
*/
declare
	@job_title varchar(50) = 'Purchasing Manager'

select
	e.BusinessEntityID
	,e.JobTitle
	,d.Name as [DepartmentName]
	,edh.StartDate
	,edh.EndDate
from
	HumanResources.Employee e
inner join
	HumanResources.EmployeeDepartmentHistory edh
		on
			edh.BusinessEntityID = e.BusinessEntityID
inner join
	HumanResources.Department d
		on
			d.DepartmentID = edh.DepartmentID
where
	e.JobTitle like '%' + @job_title + '%'

/*
	Show the history of an employee who rate has been changed more than one time.
*/
select
	e.BusinessEntityID
	,e.JobTitle
	,count(*) as [RateCount]
from
	HumanResources.Employee e
inner join
	HumanResources.EmployeePayHistory eph
		on
			eph.BusinessEntityID = e.BusinessEntityID
group by
	e.BusinessEntityID
	,e.JobTitle
having
	count(e.BusinessEntityID) > 1

/*
	Show max rate of each department
*/
select
	d.DepartmentID
	,d.Name
	,max(eph.Rate) as MaxRate
from
	HumanResources.Employee e
inner join
	HumanResources.EmployeePayHistory eph
		on
			eph.BusinessEntityID = e.BusinessEntityID
inner join
	HumanResources.EmployeeDepartmentHistory edh
		on
			edh.BusinessEntityID = e.BusinessEntityID
inner join
	HumanResources.Department d
	 on 
		d.DepartmentID = edh.DepartmentID
where
	edh.EndDate is null
group by
	d.DepartmentID
	,d.Name