use AdventureWorks2012
go

-- Task 2. Part 1
-- Variant 2

/*
	Create table like [Person].[PersonPhone]
*/
create table [dbo].[PersonPhone] (
	BusinessEntityID	[int]			not null
	,PhoneNumber		[nvarchar](25)	not null
	,PhoneNumberTypeID	[int]			not null
	,ModifiedDate		[datetime]		not null
)
go

/*
	Add new column ID
*/
alter table [dbo].[PersonPhone]
	add 
		ID bigint identity(2, 2)
go

/*
	Add constraint for words in PhoneNumber
*/
alter table [dbo].[PersonPhone]
	add constraint not_words_in_PhoneNumber check (PhoneNumber not like '%[a-z]%');
go

/*
	Add constraint DEFAULT to PhoneNumberTypeID
*/
alter table [dbo].[PersonPhone]
	add constraint default_PhoneNumberTypeID
	default 1 for PhoneNumberTypeID
go

/*
	Fill the date from [Person] schema to [dbo].
*/
insert into	
	[dbo].[PersonPhone]
select
	pp.*
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
go

/*
	Alter column to take NULL values.
*/
alter table [dbo].[PersonPhone]
	alter column PhoneNumber [nvarchar](25) null
go
