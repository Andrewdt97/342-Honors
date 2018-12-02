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

	if object_id('BOM_setup') is null
		create table BOM_setup (pID int, cID int, qty int, lvl int)

	if object_id('BOM_final_qtys') is null
		create table BOM_final_qtys (pID int, cID int, qty int)

	create table #temp (ID int, qty int)

	-- loop through the demand calc table and determine BOM levels for all subparts of "top-level" parts
	while @@FETCH_STATUS = 0
	begin		
		insert into BOM_setup
		exec getBOM @myID, @startDate

		insert into BOM_final_qtys
		exec BOM_CTE @myID		

		if exists (select 1 from BOM_setup)
		begin
			insert into #temp
			select cID, qty * @initialQty from BOM_final_qtys
			where cID not in (select pID from BOM_setup)
		end

		else
		begin
			insert into #temp (ID, qty)
			values (@myID, @initialQty)
		end

		delete from BOM_setup
		delete from BOM_final_qtys
		fetch next from my_cursor into @myID, @initialQty
	end
	close my_cursor
	deallocate my_cursor

	insert into BOMComponentNeeds
	select ID, sum(qty), @StartDate, @endDate
	from #temp
	group by ID

go

exec BOMRecursion @days = 30

select * from BOMComponentneeds
order by ID