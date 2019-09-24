use AdventureWorks2012
go

-- Task 5
-- Variant 2

/*
	a) Create a function to take ID of the department and returns count of the employees in them.
*/

IF object_id('[HumanResources].[EmployeeCount]', 'FN') IS NOT NULL
BEGIN
    DROP FUNCTION [HumanResources].[EmployeeCount]
END
GO

IF object_id('[HumanResources].[EmployeesInDepartment]', 'FN') IS NOT NULL
BEGIN
    DROP FUNCTION [HumanResources].[EmployeesInDepartment]
END
GO

create function [HumanResources].EmployeeCount(
	@department_id int
)
returns int
as
begin
	declare
		@employee_count int

	select 
		@employee_count = count(*)
	from
		[HumanResources].[Department] d
	inner join
		[HumanResources].[EmployeeDepartmentHistory] edh
			on
				edh.DepartmentID = d.DepartmentID
	inner join
		[HumanResources].[Employee] e
			on
				e.BusinessEntityID = edh.BusinessEntityID
	where
		edh.EndDate is null
	and
		edh.DepartmentID = @department_id

	return @employee_count
end
go

/*
	b) Create a function to show employees who are working more than 11 years 
	in the department
*/

create function [HumanResources].EmployeesInDepartment(
	@department_id int
)
returns table
as 
return (
	select
		e.*
	from
		[HumanResources].[Employee] e
	inner join
		[HumanResources].[EmployeeDepartmentHistory] edh
			on
				edh.BusinessEntityID = e.BusinessEntityID
	inner join
		[HumanResources].[Department] d
			on
				d.DepartmentID = edh.DepartmentID
	where
		edh.EndDate is null
	and
		d.DepartmentID = @department_id
	and
		DATEDIFF(year, edh.StartDate, getdate()) >= 11
)
go

/*
	Call function to each deparment
*/

select
	d.DepartmentID,
	[HumanResources].EmployeeCount(d.DepartmentID) as EmployeesInDepartment
from
	[HumanResources].[Department] d
order by 
	d.DepartmentID asc

select
	*
from
	[HumanResources].[Department] d
cross apply
	[HumanResources].EmployeesInDepartment(DepartmentID)
order by
	d.DepartmentID

select
	*
from
	[HumanResources].[Department] d
outer apply
	[HumanResources].EmployeesInDepartment(DepartmentID)
order by
	d.DepartmentID
go

/*
	d) Multi-statement Table-Valued User-Defined Function
*/

create function [HumanResources].EmployeesInDepartment(
	@department_id int
)
returns @table_employee table (
	[BusinessEntityID] [int] NOT NULL,
	[NationalIDNumber] [nvarchar](15) NOT NULL,
	[LoginID] [nvarchar](256) NOT NULL,
	[OrganizationNode] [hierarchyid] NULL,
	[OrganizationLevel] smallint NULL,
	[JobTitle] [nvarchar](50) NOT NULL,
	[BirthDate] [date] NOT NULL,
	[MaritalStatus] [nchar](1) NOT NULL,
	[Gender] [nchar](1) NOT NULL,
	[HireDate] [date] NOT NULL,
	[SalariedFlag] [dbo].[Flag] NOT NULL,
	[VacationHours] [smallint] NOT NULL,
	[SickLeaveHours] [smallint] NOT NULL,
	[CurrentFlag] [dbo].[Flag] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
)
as 
begin
	insert into @table_employee (
		[BusinessEntityID]
		,[NationalIDNumber]
		,[LoginID]
		,[OrganizationNode]
		,[OrganizationLevel]
		,[JobTitle]
		,[BirthDate]
		,[MaritalStatus]
		,[Gender]
		,[HireDate]
		,[SalariedFlag]
		,[VacationHours]
		,[SickLeaveHours]
		,[CurrentFlag]
		,[rowguid]
		,[ModifiedDate]
	)
	select
		e.[BusinessEntityID]
		,e.[NationalIDNumber]
		,e.[LoginID]
		,e.[OrganizationNode]
		,e.[OrganizationLevel]
		,e.[JobTitle]
		,e.[BirthDate]
		,e.[MaritalStatus]
		,e.[Gender]
		,e.[HireDate]
		,e.[SalariedFlag]
		,e.[VacationHours]
		,e.[SickLeaveHours]
		,e.[CurrentFlag]
		,e.[rowguid]
		,e.[ModifiedDate]
	from
		[HumanResources].[Employee] e
	inner join
		[HumanResources].[EmployeeDepartmentHistory] edh
			on
				edh.BusinessEntityID = e.BusinessEntityID
	inner join
		[HumanResources].[Department] d
			on
				d.DepartmentID = edh.DepartmentID
	where
		edh.EndDate is null
	and
		d.DepartmentID = @department_id
	and
		DATEDIFF(year, edh.StartDate, getdate()) >= 11

	return;
end
go
