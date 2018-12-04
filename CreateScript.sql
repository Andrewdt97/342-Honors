--------------------------------------------------
-- Table and SP creation script                  |
-- By Andrew Thomas and Ty Vredeveld             |
-- CS 342 Honors                                 |
--------------------------------------------------

USE AdventureWorks2012
GO

-------------------------------
-- Table Creation             |
-------------------------------
CREATE TABLE Production.ExpectedInventory (
	ProductID int
	, Quantity int
) -- TODO: Clean up
GO

create table NeededOrders (
	ID int,
	qty int,
	startDate date,
	endDate date
);
GO


-------------------------------
-- SP Creation                |
-------------------------------
CREATE proc ExpectedInventory
as
begin
	DELETE FROM Production.ExpectedInventory
	INSERT INTO Production.ExpectedInventory
	SELECT incoming.ProductID
		, CurrentInv + OrderQty
	FROM (SELECT ProductID
			, Sum(Quantity) [CurrentInv]
		FROM Production.ProductInventory
		GROUP BY ProductID) as currentInvTable
	JOIN (SELECT pod.ProductID
			, sum(pod.OrderQty) [OrderQty]
		FROM Purchasing.PurchaseOrderHeader poh
		JOIN Purchasing.PurchaseOrderDetail pod ON poh.PurchaseOrderID = pod.PurchaseOrderID
		WHERE poh.Status IN (1, 2)
		GROUP BY pod.ProductID) as incoming
	ON currentInvTable.ProductID = incoming.ProductID
	ORDER BY incoming.ProductID
end
go

create proc CalculateDemand
as
begin
	if object_id('DemandCalc') is not null
		drop table DemandCalc
	
	if object_id('DemandCalc') is null
		create table DemandCalc(
			ID int,
			Quantity int)

	insert into DemandCalc 

		select [ProductID], sum([Quantity]) from (

		select p.ProductID [ProductID], sum(sd.OrderQty) [Quantity] from Production.Product p
		inner join Sales.SalesOrderDetail sd on sd.ProductID = p.ProductID
		inner join Sales.SalesOrderHeader sh on sd.SalesOrderID = sh.SalesOrderID
		-- could be used in case the Status column isn't always reliable and we want to check by date instead
		--where (sh.OrderDate <= convert(datetime, '2008-07-01') and convert(datetime, '2008-07-01') <= sh.DueDate)
		where sh.Status = 1 or sh.Status = 2 or sh.Status = 3
		group by p.ProductID

	union

		SELECT "ID"
		, AVG("sum")
	FROM
		(SELECT pro.ProductID "ID", SUM(sod.OrderQty) "sum", DATEPART(YEAR, OrderDate) "year" FROM 
			Production.Product pro JOIN Sales.SalesOrderDetail sod
				ON pro.ProductID = sod.ProductID
			JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
			WHERE DATEPART(DAYOFYEAR, OrderDate) > DATEPART(DAYOFYEAR, Convert(datetime, '2006-01-01' )) -- Will become GETDATE - numOfDays
				AND DATEPART(DAYOFYEAR, OrderDate) < DATEPART(DAYOFYEAR, Convert(datetime, '2006-03-01' )) -- Will become GETDATE
				AND DATEPART(YEAR, OrderDate) < DATEPART(YEAR, convert(datetime, '2010-04-01'))
			GROUP BY pro.ProductID, DATEPART(YEAR, OrderDate)) HistoricalOrders
	GROUP BY "ID"

	) as demcalc
	group by [ProductID]
end
go

create proc BOMRecursion
as
begin
	declare @myID int
	declare @qty int
	declare @subpartID int
	declare @subpartQty int
	
	declare cursor1 cursor for
		select ID, Quantity
		from DemandCalc
	open cursor1
	fetch next from cursor1 into @myID, @qty

	-- loop through the demand calc table and determine BOM levels for all subparts of "top-level" parts
	while @@FETCH_STATUS = 0
	begin		
		
		if exists (select ProductID from Production.ExpectedInventory where ProductID = @myID)
		begin
			update Production.ExpectedInventory
			set Quantity = Quantity - @qty
			where ProductID = @myID
		end

		else
		begin
			insert into Production.ExpectedInventory values (@myID, @qty * -1)
		end

		fetch next from cursor1 into @myID, @qty
	end
	close cursor1
	deallocate cursor1

	while (select min(Quantity) from Production.ExpectedInventory) < 0
	begin
	
		declare cursor2 cursor for
			select ProductID, Quantity
			from Production.ExpectedInventory
		open cursor2
		fetch next from cursor2 into @myID, @qty

		while @@FETCH_STATUS = 0
		begin
			
			if @qty < 0
			begin
				
				if exists (select ComponentID from Production.BillOfMaterials where ProductAssemblyID = @myID)
				begin
					
					declare cursor3 cursor for
						select ComponentID, PerAssemblyQty
						from Production.BillOfMaterials
						where ProductAssemblyID = @myID
					open cursor3
					fetch next from cursor3 into @subpartID, @subpartQty

					while @@FETCH_STATUS = 0
					begin
							
						if exists (select ProductID from Production.ExpectedInventory where ProductID = @subpartID)
						begin
							update Production.ExpectedInventory
							set Quantity = Quantity + (@qty * @subpartQty)
							where ProductID = @subpartID
						end

						else
						begin
							insert into Production.ExpectedInventory values (@subpartID, @subpartQty * @qty)
						end

						fetch next from cursor3 into @subpartID, @subpartQty
					end
					close cursor3
					deallocate cursor3

				end

				else
				begin
					
					if exists (select ID from NeededOrders where ID = @myID)
					begin
						update NeededOrders
						set qty = qty + abs(@qty)
						where ID = @myID
					end

					else
					begin
						-- TODO: update second getdate to actually put end date
						insert into NeededOrders values (@myID, abs(@qty), getdate(), getdate())
					end

				end

				update Production.ExpectedInventory
				set Quantity = 0
				where ProductID = @myID

			end

			fetch next from cursor2 into @myID, @qty
		end
		close cursor2
		deallocate cursor2
	end
	
end
go