use AdventureWorks2012
go

-- Task 6
-- Variant 2

if object_id('dbo.SubCategoriesByColor') is not null
begin
	drop procedure dbo.SubCategoriesByColor
end
go

create procedure dbo.SubCategoriesByColor (
	@colors nvarchar(max)
)
as
declare
	@sql nvarchar(max) = ''
	,@pivot_headers nvarchar(max) = ''
	,@pivot_rows nvarchar(max) = ''
begin
	select 
		@pivot_headers += ',[' + value + '] as ' + value,
		@pivot_rows += '[' + value + '],'
	from
		string_split(@colors, ',')
		
	set	@pivot_rows = LEFT(@pivot_rows, LEN(@pivot_rows) - 1)

	set @sql = '
	select
		SubcategoryName as Name' + @pivot_headers + '
	from (
		select
			p.Color
			,p.[Weight]
			,ps.Name as SubcategoryName
		from
			[Production].[Product] p
		inner join
			[Production].[ProductSubcategory] ps
				on
					ps.ProductSubcategoryID = p.ProductSubcategoryID
	) as SourceTable
	pivot(
		max([Weight])
		for Color in (' + @pivot_rows + ')
	
	) as PivotTable
'

	exec sp_executesql @sql
end
go

EXECUTE dbo.SubCategoriesByColor 'Black,Silver,Yellow'