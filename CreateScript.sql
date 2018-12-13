--------------------------------------------------
-- Table and SP creation script                  |
-- By Andrew Thomas and Ty Vredeveld             |
-- CS 342 Honors                                 |
--------------------------------------------------

USE AdventureWorks2012
GO

-------------------------------
-- SP Creation                |
-------------------------------

CREATE PROC MakeTables
AS
BEGIN

	IF OBJECT_ID(N'Production.ExpectedInventory') IS NOT NULL
		DROP TABLE Production.ExpectedInventory

	IF OBJECT_ID(N'Production.ExpectedInventory') IS NULL
		CREATE TABLE Production.ExpectedInventory (
			ProductID int
			, Quantity int)

	IF OBJECT_ID('DemandCalc') IS NOT NULL
		DROP TABLE DemandCalc
	
	IF OBJECT_ID('DemandCalc') IS NULL
		CREATE TABLE DemandCalc(
			ID int,
			Quantity int)

	IF OBJECT_ID('NeededOrders') IS NOT NULL
		DROP TABLE NeededOrders

	IF OBJECT_ID('NeededOrders') IS NULL
		CREATE TABLE NeededOrders (
			ID int,
			qty int,
			startDate date,
			endDate date)
			
	IF OBJECT_ID('Production.BoMWorkingTable') IS NULL
		CREATE TABLE Production.BoMWorkingTable (
			ProductID int
			, Quantity int)

END
GO



CREATE PROC ExpectedInventory
AS
BEGIN

	DELETE FROM Production.ExpectedInventory
	INSERT INTO Production.ExpectedInventory
	SELECT ProductID
		, Sum(CurrentInv)
	FROM ((SELECT ProductID
			, Sum(Quantity) [CurrentInv]
		FROM Production.ProductInventory
		GROUP BY ProductID)
	UNION
	(SELECT pod.ProductID
			, sum(pod.OrderQty) [OrderQty]
		FROM Purchasing.PurchaseOrderHeader poh
		JOIN Purchasing.PurchaseOrderDetail pod ON poh.PurchaseOrderID = pod.PurchaseOrderID
		WHERE poh.Status IN (1, 2)
		GROUP BY pod.ProductID)) AS un
	GROUP BY ProductID
END
GO

CREATE PROC CalculateDemand
	@numDaysOut int
AS
BEGIN

	DELETE FROM DemandCalc
	INSERT INTO DemandCalc 

	SELECT [ProductID], sum([Quantity]) FROM (

		SELECT p.ProductID [ProductID], sum(sd.OrderQty) [Quantity] FROM Production.Product p
		INNER JOIN Sales.SalesOrderDetail sd ON sd.ProductID = p.ProductID
		INNER JOIN Sales.SalesOrderHeader sh ON sd.SalesOrderID = sh.SalesOrderID
		WHERE sh.Status < 4
		GROUP BY p.ProductID

	UNION

		SELECT "ID"
		, AVG("sum")
	FROM
		(SELECT sod.ProductID "ID", SUM(sod.OrderQty) "sum", DATEPART(YEAR, OrderDate) "year" FROM Sales.SalesOrderDetail sod
			JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
			WHERE ((DATEPART(DAYOFYEAR, OrderDate) > DATEPART(DAYOFYEAR, GETDATE())
				AND ( DATEPART(DAYOFYEAR, OrderDate) < DATEPART(DAYOFYEAR, GETDATE() + @numDaysOut))
					OR (DATEPART(DAYOFYEAR, GETDATE() + @numDaysOut) < DATEPART(DAYOFYEAR, GETDATE())
						AND (DATEPART(DAYOFYEAR, OrderDate) < 366)))
				OR (DATEPART(DAYOFYEAR, GETDATE() + @numDaysOut) < DATEPART(DAYOFYEAR, GETDATE()) 
						AND DATEPART(DAYOFYEAR, OrderDate) < DATEPART(DAYOFYEAR, GETDATE() + @numDaysOut)))
				AND DATEPART(YEAR, OrderDate) < DATEPART(YEAR, GETDATE())
			GROUP BY sod.ProductID, DATEPART(YEAR, OrderDate)) HistoricalOrders
	GROUP BY "ID"

	) AS demcalc
	GROUP BY [ProductID]
END
GO

CREATE PROC BOMRecursion
	@numDaysOut int
AS
BEGIN

	DELETE FROM NeededOrders
	DELETE FROM Production.BoMWorkingTable

	DECLARE @myID int
	DECLARE @qty int
	DECLARE @subpartID int
	DECLARE @subpartQty int
	
	INSERT INTO Production.BoMWorkingTable
	SELECT * FROM Production.ExpectedInventory
	
	DECLARE cursor1 CURSOR FOR
		SELECT ID, Quantity
		FROM DemandCalc
	OPEN cursor1
	FETCH NEXT FROM cursor1 INTO @myID, @qty

	-- loop through the demand calc TABLE and deterMINe BOM levels fOR all subparts of "top-level" parts
	WHILE @@FETCH_STATUS = 0
	BEGIN		
		
		IF EXISTS (SELECT ProductID FROM Production.BoMWorkingTable WHERE ProductID = @myID)
		BEGIN
			UPDATE Production.BoMWorkingTable
			SET Quantity = Quantity - @qty
			WHERE ProductID = @myID
		END

		ELSE
		BEGIN
			INSERT INTO Production.BoMWorkingTable VALUES (@myID, @qty * -1)
		END

		FETCH NEXT FROM cursor1 INTO @myID, @qty
	END
	CLOSE cursor1
	DEALLOCATE cursor1

	WHILE (SELECT MIN(Quantity) FROM Production.BoMWorkingTable) < 0
	BEGIN
	
		DECLARE cursor2 CURSOR fOR
			SELECT ProductID, Quantity
			FROM Production.BoMWorkingTable
		OPEN cursor2
		FETCH NEXT FROM cursor2 INTO @myID, @qty

		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			IF @qty < 0
			BEGIN
				IF EXISTS (SELECT ProductID from Purchasing.ProductVendor WHERE ProductID = @myID)
				BEGIN
					
					IF EXISTS (SELECT ID FROM NeededOrders WHERE ID = @myID)
					BEGIN
						UPDATE NeededOrders
						SET qty = qty + abs(@qty)
						WHERE ID = @myID
					END

					ELSE
					BEGIN
						INSERT INTO NeededOrders VALUES (@myID, abs(@qty), getdate(), getdate() + @numDaysOut)
					END

				END

				ELSE IF EXISTS (SELECT ComponentID FROM Production.BillOfMaterials WHERE ProductAssemblyID = @myID)
				BEGIN
					
					DECLARE cursor3 CURSOR fOR
						SELECT ComponentID, PerAssemblyQty
						FROM Production.BillOfMaterials
						WHERE ProductAssemblyID = @myID
					OPEN cursor3
					FETCH NEXT FROM cursor3 INTO @subpartID, @subpartQty

					WHILE @@FETCH_STATUS = 0
					BEGIN
							
						IF EXISTS (SELECT ProductID FROM Production.BoMWorkingTable WHERE ProductID = @subpartID)
						BEGIN
							UPDATE Production.BoMWorkingTable
							SET Quantity = Quantity + (@qty * @subpartQty)
							WHERE ProductID = @subpartID
						END

						ELSE
						BEGIN
							INSERT INTO Production.BoMWorkingTable VALUES (@subpartID, @subpartQty * @qty)
						END

						FETCH NEXT FROM cursor3 INTO @subpartID, @subpartQty
					END
					CLOSE cursor3
					DEALLOCATE cursor3

				END

				ELSE
				BEGIN
					
					IF EXISTS (SELECT ID FROM NeededOrders WHERE ID = @myID)
					BEGIN
						UPDATE NeededOrders
						SET qty = qty + abs(@qty)
						WHERE ID = @myID
					END

					ELSE
					BEGIN
						INSERT INTO NeededOrders VALUES (@myID, abs(@qty), getdate(), getdate() + @numDaysOut)
					END

				END

				UPDATE Production.BoMWorkingTable
				SET Quantity = 0
				WHERE ProductID = @myID

			END

			FETCH NEXT FROM cursor2 INTO @myID, @qty
		END
		CLOSE cursor2
		DEALLOCATE cursor2
	END
	
END
GO

CREATE PROC SafetyLevels
@numDaysOut int
AS
BEGIN

	DECLARE @id int;
	DECLARE @current int;
	DECLARE @demand int;
	DECLARE @safety int;

	DECLARE product_cursor CURSOR FOR 
	SELECT ProductID
	FROM Production.ProductInventory

	OPEN product_cursor  
	FETCH NEXT FROM product_cursor INTO @id

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		SET @current = (SELECT Quantity FROM Production.ExpectedInventory WHERE ProductID = @id);
		SET @demand = (SELECT Qty FROM NeededOrders WHERE ID = @id);
		IF @demand IS NULL
		BEGIN
			SET @demand = 0
		END
		SET @safety = (SELECT SafetyStockLevel FROM Production.Product WHERE ProductID = @id);
	
		IF (@demand + @current < @safety)
		BEGIN
			IF EXISTS (SELECT ID FROM NeededOrders WHERE ID = @id)
			BEGIN
				UPDATE NeededOrders
				SET qty = @safety - (@demand + @current)
				WHERE ID = @id
			END

			ELSE
			BEGIN
				INSERT INTO NeededOrders VALUES (@id, @safety - (@demand + @current), getdate(), getdate() + @numDaysOut)
			END
		END
		
		FETCH NEXT FROM product_cursor INTO @id 
	END 

	CLOSE product_cursor  
	DEALLOCATE product_cursor 

END
GO

CREATE PROC MRP_Calculate_Orders
	@numDays int
AS
BEGIN
	EXEC MakeTables
	EXEC ExpectedInventory
	EXEC CalculateDemand @numDays
	EXEC BOMRecursion @numDays
	EXEC SafetyLevels @numDays
END
GO