use AdventureWorks2012
go

-- Task 4. Part1
-- Variant 2

/*
	a) Create history table
*/
if object_id('Production.LocationHst', 'U') is not null
	drop table [Production].[LocationHst]

create table [Production].[LocationHst] (
	ID				int				identity(1, 1)
	,Action			nvarchar(10)	not null
	,ModifiedDate	datetime		not null
	,SourceID		int				not null
	,UserName		nvarchar(200)	not null
)
go
/*
	b) Create a trigger to INSERT, UPDATE and DELETE operations
*/

if object_id('[Production].[trg_location_action]') is not null
	drop trigger [Production].[trg_location_action]
go

create trigger [Production].[trg_location_action]
on	[Production].[Location]
after insert, update, delete
as
declare
	@activity	varchar(20)
	,@user		varchar(200)
	,@sourceId	int
begin
	if not exists(select * from inserted) and not exists(select * from deleted)
		return;

	if exists(select * from inserted) and exists(select * from deleted)
	begin
		set @activity = 'UPDATE'
		select @sourceId = LocationID from inserted;
	end

	if exists(select * from inserted) and not exists (select * from deleted)
	begin
		set @activity = 'INSERT'
		select @sourceId = LocationID from inserted
	end

	if not exists(select * from inserted) and exists(select * from deleted)
	begin
		set @activity = 'DELETE'
		select @sourceId = LocationID from deleted
	end

	set @user = SYSTEM_USER
	insert into [Production].[LocationHst] (
			Action,
			ModifiedDate,
			SourceID,
			UserName
		) 
		values (
			@activity, 
			GETDATE(), 
			@sourceId, 
			@user
		)
end
go

/*
	c) Create a view to show all columns of [Production].[Location]
*/

if object_id('show_all_production_location') is not null
	drop view show_all_production_location
go

create view show_all_production_location as
select
	l.Availability
	,l.CostRate
	,l.LocationID
	,l.ModifiedDate
	,l.Name
from
	[Production].[Location] l
go

/*
	d) Insert, update, delete a row in [Production].[Location] through VIEW
*/
insert into show_all_production_location (
	Availability,
	,CostRate
	,ModifiedDate
	,Name
) values (
	10
	,10
	,GETDATE()
	,'test insert'
)

declare @id int
select top 1 
	@id = LocationID 
from 
	show_all_production_location 
order by 
	LocationID desc 

update show_all_production_location
set
	Name = 'test update'
where
	LocationID = @id

delete show_all_production_location
where LocationID = @id

select * from Production.LocationHst