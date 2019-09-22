use AdventureWorks2012
go

-- Task 3. Part 2
-- Variant 2

/*
	a) Create [dbo].[PersonPhone]
*/

if object_id('dbo.PersonPhone', 'U') is not null
	drop table [dbo].[PersonPhone]

create table [dbo].[PersonPhone] (
	BusinessEntityID	[int]			not null
	,PhoneNumber		[nvarchar](25)	not null
	,PhoneNumberTypeID	[int]			not null
	,ModifiedDate		[datetime]		not null
	,JobTitle			[nvarchar](50)	null
	,BirthDate			[date]			null
	,HireDate			[date]			null
	
	,HireAge as datediff(year, BirthDate, HireDate)
)
go

alter table [dbo].[PersonPhone]
	add 
		ID bigint identity(2, 2)

alter table [dbo].[PersonPhone]
	add constraint not_words_in_PhoneNumber check (PhoneNumber not like '%[a-z]%');

alter table [dbo].[PersonPhone]
	add constraint default_PhoneNumberTypeID
	default 1 for PhoneNumberTypeID

insert into	[dbo].[PersonPhone] (
	BusinessEntityID
	,PhoneNumber
	,PhoneNumberTypeID
	,ModifiedDate
)
select
	pp.BusinessEntityID
	,pp.PhoneNumber
	,pp.PhoneNumberTypeID
	,pp.ModifiedDate
from
	[HumanResources].[Employee] e
inner join
	[HumanResources].[EmployeeDepartmentHistory] edh
		on
			edh.BusinessEntityID = e.BusinessEntityID
inner join
	[Person].[PersonPhone] pp
		on
			pp.BusinessEntityID = e.BusinessEntityID
where
	edh.StartDate = e.HireDate
and
	pp.PhoneNumber not like '%(%)%'

alter table [dbo].[PersonPhone]
	alter column PhoneNumber [nvarchar](25) null
go

/*
	b) Create a temporary table
*/
if object_id('tempdb..#PersonPhone', 'U') is not null
	drop table #PersonPhone

create table #PersonPhone (
	BusinessEntityID	[int]			primary key
	,PhoneNumber		[nvarchar](25)	not null
	,PhoneNumberTypeID	[int]			not null
	,ModifiedDate		[datetime]		not null
	,ID					[bigint]		not null
	,JobTitle			[nvarchar](50)	not null
	,BirthDate			[date]			not null
	,HireDate			[date]			not null
);

/*
	c) Fill #PersonPhone
*/
with PersonPhoneCTE (
	BusinessEntityID
	,PhoneNumber
	,PhoneNumberTypeID
	,ModifiedDate
	,ID
	,JobTitle
	,BirthDate
	,HireDate
)
as 
(
	select
		pp.BusinessEntityID
		,pp.PhoneNumber
		,pp.PhoneNumberTypeID
		,pp.ModifiedDate
		,pp.ID
		,e.JobTitle
		,e.BirthDate
		,e.HireDate
	from
		[HumanResources].[Employee] e
	inner join
		[dbo].[PersonPhone] pp
			on
				pp.BusinessEntityID = e.BusinessEntityID
	where
		e.JobTitle like 'Sales Representative'
)

insert into #PersonPhone
select 
	cte.BusinessEntityID
	,cte.PhoneNumber
	,cte.PhoneNumberTypeID
	,cte.ModifiedDate
	,cte.ID
	,cte.JobTitle
	,cte.BirthDate
	,cte.HireDate
from 
	PersonPhoneCTE cte


/*
	d) Delete BusinessEntityID 275
*/
delete 
	[dbo].[PersonPhone]
where
	BusinessEntityID = 275

/*
	e) Write merge statement
*/
merge [dbo].[PersonPhone] as target
	using #PersonPhone  as source
	on target.BusinessEntityID = source.BusinessEntityID
	when matched then
		update set
			JobTitle = source.JobTitle
			,BirthDate = source.BirthDate
			,HireDate = source.HireDate
	when not matched by target then
		insert (
			BusinessEntityID
			,PhoneNumber
			,PhoneNumberTypeID	
			,ModifiedDate		
			,JobTitle			
			,BirthDate			
			,HireDate
		) values (
			source.BusinessEntityID
			,source.PhoneNumber
			,source.PhoneNumberTypeID
			,source.ModifiedDate
			,source.JobTitle
			,source.BirthDate
			,source.HireDate
		)
	when not matched by source then
		delete
;

select * from [dbo].[PersonPhone]