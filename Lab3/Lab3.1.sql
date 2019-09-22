use AdventureWorks2012
go

/*
	a) Add new column to [dbo].[PersonPhone]
*/
alter table [dbo].[PersonPhone]
	add
		HireDate date null
go

/*
	b) Fill the data to temporary table variable
*/
declare @PersonPhone table(
	BusinessEntityID	[int]			not null
	,PhoneNumber		[nvarchar](25)	not null
	,PhoneNumberTypeID	[int]			not null
	,ModifiedDate		[datetime]		not null
	,ID					[int]			not null
	,HireDate			[date]			not null
)

insert into @PersonPhone
select
	dpp.BusinessEntityID
	,dpp.PhoneNumber
	,dpp.PhoneNumberTypeID
	,dpp.ModifiedDate
	,dpp.ID
	,e.HireDate
from
	[HumanResources].[Employee] e
inner join
	[dbo].[PersonPhone] dpp
		on
			dpp.BusinessEntityID = e.BusinessEntityID

/*
	c) Increate HireDate by one day and update data in [dbo].[PersonPhone]
*/
update
	dpp
set
	dpp.HireDate = dateadd(d, 1, pp.HireDate)
from
	@PersonPhone pp
inner join
	[dbo].[PersonPhone] dpp
		on dpp.ID = pp.ID

/*
	d) Delete data for employees whose rate by hour more than 50
*/

delete
	pp
from
	[dbo].[PersonPhone] pp
inner join
	[HumanResources].EmployeePayHistory eph
		on
			pp.BusinessEntityID = eph.BusinessEntityID
where
	eph.Rate / eph.PayFrequency > 50

/*
	e) Delete all constrains from [dbo].[PersonPhone]
*/

alter table [dbo].[PersonPhone]
	drop constraint not_words_in_PhoneNumber

/*
	d) Drop table [dbo].[PersonTable]
*/
drop table [dbo].[PersonPhone]