-- cursor through DemandCalc and calculate necessary BOM levels of sub-materials
-- everything where componentID is not a product assembly ID at some point


-- TODO: modify bom sproc to insert into table instead of selecting from CTE
-- TODO: modify sproc to count how many "base" parts are being used in total (multiply qty times how much its used - recursive)

-- https://stackoverflow.com/questions/4889584/is-it-possible-to-use-a-stored-procedure-as-a-subquery-in-sql-server-2008
-- https://www.ibm.com/support/knowledgecenter/en/SS6NHC/com.ibm.swg.im.dashdb.sql.ref.doc/doc/r0059242.html

use AdventureWorks2012
go

alter proc BOMRecursion
as 


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
go

exec BOMRecursion