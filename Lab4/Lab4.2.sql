use AdventureWorks2012
go

-- Task 4. Part 2
-- Variant 2

if exists(select * from sys.views where name = 'vShowProductData')
	drop view [Production].vShowProductData
go

if exists(SELECT * FROM sys.objects WHERE [name] = N'trg_insert_view')
	drop trigger dbo.[trg_insert_view]
go

if exists(SELECT * FROM sys.objects WHERE [name] = N'production.trg_update_view')
	drop trigger production.trg_update_view
go

if exists(SELECT * FROM sys.objects WHERE [name] = N'trg_delete_view')
	drop trigger [trg_delete_view]
go

/*
	a) Create view
*/

create view [Production].vShowProductData 
with encryption, schemabinding
as
select
	l.Availability
	,l.CostRate
	,l.LocationID
	,l.ModifiedDate
	,l.Name as [LocationName]
	,pi.Bin
	,pi.ProductID
	,pi.Quantity
	,pi.rowguid
	,pi.Shelf
	,p.Name
from
	[Production].[Location] l
inner join
	[Production].[ProductInventory] pi
		on
			pi.LocationID = l.LocationID
inner join
	[Production].[Product] p
		on
			p.ProductID = pi.ProductID
go

--select * from Production.vShowProductData

create unique clustered index
	ucidx_product_category_subcategory_id
on	[Production].vShowProductData(LocationID, ProductID)
go

/*
	b) Create triggers
*/
create trigger trg_insert_view
on [Production].[vShowProductData]
instead of insert
as 
declare
	@locationId int
	,@productId	int
begin

	select top 1
		@productId = p.ProductID
	from
		[Production].[Product] p 
	inner join
		inserted i
			on
				i.Name = p.Name

	insert into [Production].[Location] (
		Availability
		,Name
		,CostRate
		,ModifiedDate
	)
	select
		i.Availability
		,i.LocationName
		,i.CostRate
		,i.ModifiedDate
	from
		inserted i

	set @locationId = SCOPE_IDENTITY()

	insert into [Production].[ProductInventory] (
		LocationID
		,ProductID
		,Bin
		,Quantity
		,rowguid
		,Shelf
		,ModifiedDate
	)
	select
		@locationId
		,@productId
		,i.Bin
		,i.Quantity
		,i.rowguid
		,i.Shelf
		,i.ModifiedDate
	from
		inserted i

end
go

create trigger trg_update_view
on [Production].[vShowProductData]
instead of update
as
declare
	@productId int
begin
	update
		l
	set
		l.Availability = i.Availability
		,l.Name = i.LocationName
		,l.CostRate = i.CostRate
		,l.ModifiedDate = i.ModifiedDate
	from
		[Production].[Location] l
	inner join
		[Production].[ProductInventory] pp
			on
				pp.LocationID = l.LocationID
	inner join
		inserted i
			on
				i.LocationID = pp.LocationID
			and
				i.ProductID = pp.ProductID

	update
		pp
	set
		pp.Bin = i.Bin
		,pp.ModifiedDate = i.ModifiedDate
		,pp.Quantity  = i.Quantity
		,pp.rowguid = i.rowguid
		,pp.Shelf = i.Shelf
	from
		[Production].[ProductInventory] pp
	inner join
		inserted i
			on
				i.ProductID = pp.ProductID
			and
				i.LocationID = pp.LocationID
		
end
go

create trigger trg_delete_view
on [Production].[vShowProductData]
instead of delete
as 
declare
	@productId int
	,@locationId int
begin
	select
		@productId = p.ProductID
		,@locationID = l.LocationID
	from	
		deleted d
	inner join
		[Production].[Product] p
			on
				p.Name = d.Name
	inner join
		[Production].[Location] l
			on
				l.Name = d.LocationName

	delete
		[Production].[ProductInventory]
	where
		ProductID = @productId
	and
		LocationID = @locationId

	delete
		l
	from
		[Production].[Location] l
	where
		l.LocationID = @locationId

end
go

/*
	c) INSERT, UPDATE and DELETE in the view
*/

select * from [Production].[Location]		
select * from [Production].[ProductInventory]
select * from [Production].[Product]

insert into [Production].vShowProductData (
	Availability
	,rowguid
	,LocationName
	,CostRate
	,ModifiedDate
	,Bin
	,Quantity
	,Shelf
	,Name
) values (
	10,
	newid(),
	'test1',
	10
	,GETDATE()
	,1
	,10
	,'C'
	,'Adjustable Race'
)

update [Production].vShowProductData
set Availability = 99
where
	Name = 'Adjustable Race'
and
	LocationName = 'test1'

delete [Production].vShowProductData
where
	Name = 'Adjustable Race'
and
	LocationName = 'test1'

select * from [Production].vShowProductData