-- cursor through DemandCalc and calculate necessary BOM levels of sub-materials
-- everything where componentID is not a product assembly ID at some point


-- TODO: modify bom sproc to insert into table instead of selecting from CTE
-- TODO: modify sproc to count how many "base" parts are being used in total (multiply qty times how much its used - recursive)

-- https://stackoverflow.com/questions/4889584/is-it-possible-to-use-a-stored-procedure-as-a-subquery-in-sql-server-2008

use AdventureWorks2012
go

alter proc BOMRecursion
	@days int
as 
	if object_id('BOMComponentNeeds') is not null
		drop table BOMComponentNeeds

	if object_id('BOMComponentNeeds') is null
		create table BOMComponentNeeds(
			ID int, 
			Qty int,
			StartDate datetime,
			EndDate datetime)

	declare @startDate datetime
	declare @endDate datetime
	set @startDate = GETDATE()
	set @endDate = @startDate + @days


	declare @myID int
	declare @initialQty int
	
	declare my_cursor cursor for
		select ID, Quantity
		from DemandCalc
	open my_cursor
	fetch next from my_cursor into @myID, @initialQty

	while @@FETCH_STATUS = 0
	begin
		select @myId, @initialQty
		fetch next from my_cursor into @myID, @initialQty
	end
	close my_cursor
	deallocate my_cursor
go

exec BOMRecursion @days = 30