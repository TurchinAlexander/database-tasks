use AdventureWorks2012

-- Task 1. Part 2
-- Variant 2

/*
	Show departments sorted by name from third position.
*/
select top 5
	sd.DepartmentID
	,sd.Name
from (
	select
		d.DepartmentID
		,d.Name
		,row_number() over (order by d.[Name] desc) as [row]
	from
		HumanResources.Department d
) sd
where
	sd.row >= 3

/*
	Show distinct employee's job titles which organization node is 1
*/
select distinct
	e.JobTitle
from
	HumanResources.Employee e
where
	e.OrganizationLevel = 1

/*
	Show employees which have 18 years when they have been hired
*/

select
	e.BusinessEntityID
	,e.JobTitle
	,e.Gender
	,e.BirthDate
	,e.HireDate
from
	HumanResources.Employee e
where
	datediff(year, e.BirthDate, e.HireDate) = 18
