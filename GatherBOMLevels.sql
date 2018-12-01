-- cursor through DemandCalc and calculate necessary BOM levels of sub-materials
-- everything where componentID is not a product assembly ID at some point


-- TODO: modify bom sproc to insert into table instead of selecting from CTE
-- TODO: modify sproc to count how many "base" parts are being used in total (multiply qty times how much its used - recursive)

-- https://stackoverflow.com/questions/4889584/is-it-possible-to-use-a-stored-procedure-as-a-subquery-in-sql-server-2008
-- https://www.ibm.com/support/knowledgecenter/en/SS6NHC/com.ibm.swg.im.dashdb.sql.ref.doc/doc/r0059242.html

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

	create table #temp (pID int, cID int, qty int, lvl int)

	-- loop through the demand calc table and determine BOM levels for all subparts of "top-level" parts
	while @@FETCH_STATUS = 0
	begin
		select @myID, @initialQty
		
		insert into #temp
		exec getBOM @myID, @startDate

		select * from #temp


		-- reference bottom URL for details
		-- have to figure out how to get this working...

		--with CTE (Part, Component, Quantity) as
		--	(
		--		select root.pID, root.cID, root.qty
		--		from #temp root
		--		where root.pID = 955)
		--select Part, Component, SUM(Quantity) as "Total Used"
		--from CTE
		--group by Part, Component
		--order by Part, Component;



		delete from #temp
		fetch next from my_cursor into @myID, @initialQty
	end
	close my_cursor
	deallocate my_cursor
go

exec BOMRecursion @days = 30
select * from BOMComponentneeds