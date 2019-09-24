use AdventureWorks2012
go

if OBJECT_ID('dbo.ParseXML') is not null
begin
	drop procedure [dbo].[ParseXML]
end

create procedure [dbo].[ParseXML](
	@xml xml
)
as
begin

	select
		n.value('@ID', 'int') as ProductID,
		n.value('(./Name)[1]', 'varchar(50)') as ProductName
		,n.value('(./ProductNumber)[1]', 'varchar(50)') as ProductNumber
	from
		@xml.nodes('/Products/Product') as T(n)
end
go

declare @xml xml

set @xml = (
	select
		p.ProductID as '@ID'
		,p.Name
		,p.ProductNumber
	from
		[Production].[Product] p
	for
		xml path('Product'), root('Products')
)

exec dbo.ParseXML @xml