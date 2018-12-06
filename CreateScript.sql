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

END
GO



CREATE PROC ExpectedInventory
AS
BEGIN

	DELETE FROM Production.ExpectedInventory
	INSERT INTO Production.ExpectedInventory
	SELECT incoming.ProductID
		, CurrentInv + OrderQty
	FROM (SELECT ProductID
			, Sum(Quantity) [CurrentInv]
		FROM Production.ProductInventory
		GROUP BY ProductID) AS currentInvTable
	JOIN (SELECT pod.ProductID
			, sum(pod.OrderQty) [OrderQty]
		FROM Purchasing.PurchaseOrderHeader poh
		JOIN Purchasing.PurchaseOrderDetail pod ON poh.PurchaseOrderID = pod.PurchaseOrderID
		WHERE poh.Status IN (1, 2)
		GROUP BY pod.ProductID) AS incoming
	ON currentInvTable.ProductID = incoming.ProductID
	ORDER BY incoming.ProductID
END
GO

CREATE PROC CalculateDemand
AS
BEGIN

	DELETE FROM DemandCalc
	INSERT INTO DemandCalc 

		SELECT [ProductID], sum([Quantity]) FROM (

		SELECT p.ProductID [ProductID], sum(sd.OrderQty) [Quantity] FROM Production.Product p
		INNER JOIN Sales.SalesOrderDetail sd ON sd.ProductID = p.ProductID
		INNER JOIN Sales.SalesOrderHeader sh ON sd.SalesOrderID = sh.SalesOrderID
		-- could be used in case the Status column isn't always reliable and we want to check by date instead
		--WHERE (sh.OrderDate <= convert(datetime, '2008-07-01') and convert(datetime, '2008-07-01') <= sh.DueDate)
		WHERE sh.Status = 1 OR sh.Status = 2 OR sh.Status = 3
		GROUP BY p.ProductID

	UNION

		SELECT "ID"
		, AVG("sum")
	FROM
		(SELECT pro.ProductID "ID", SUM(sod.OrderQty) "sum", DATEPART(YEAR, OrderDate) "year" FROM 
			Production.Product pro JOIN Sales.SalesOrderDetail sod
				ON pro.ProductID = sod.ProductID
			JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
			WHERE DATEPART(DAYOFYEAR, OrderDate) > DATEPART(DAYOFYEAR, CONvert(datetime, '2006-01-01' )) -- Will become GETDATE - numOfDays
				AND DATEPART(DAYOFYEAR, OrderDate) < DATEPART(DAYOFYEAR, CONvert(datetime, '2006-03-01' )) -- Will become GETDATE
				AND DATEPART(YEAR, OrderDate) < DATEPART(YEAR, cONvert(datetime, '2010-04-01'))
			GROUP BY pro.ProductID, DATEPART(YEAR, OrderDate)) HistoricalOrders
	GROUP BY "ID"

	) AS demcalc
	GROUP BY [ProductID]
END
GO

CREATE PROC BOMRecursion
AS
BEGIN

	DELETE FROM NeededOrders

	DECLARE @myID int
	DECLARE @qty int
	DECLARE @subpartID int
	DECLARE @subpartQty int
	
	DECLARE cursor1 CURSOR FOR
		SELECT ID, Quantity
		FROM DemandCalc
	OPEN cursor1
	FETCH NEXT FROM cursor1 INTO @myID, @qty

	-- loop through the demand calc TABLE and deterMINe BOM levels fOR all subparts of "top-level" parts
	WHILE @@FETCH_STATUS = 0
	BEGIN		
		
		IF EXISTS (SELECT ProductID FROM Production.ExpectedInventory WHERE ProductID = @myID)
		BEGIN
			UPDATE Production.ExpectedInventory
			SET Quantity = Quantity - @qty
			WHERE ProductID = @myID
		END

		ELSE
		BEGIN
			INSERT INTO Production.ExpectedInventory VALUES (@myID, @qty * -1)
		END

		FETCH NEXT FROM cursor1 INTO @myID, @qty
	END
	CLOSE cursor1
	DEALLOCATE cursor1

	WHILE (SELECT MIN(Quantity) FROM Production.ExpectedInventory) < 0
	BEGIN
	
		DECLARE cursor2 CURSOR fOR
			SELECT ProductID, Quantity
			FROM Production.ExpectedInventory
		OPEN cursor2
		FETCH NEXT FROM cursor2 INTO @myID, @qty

		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			IF @qty < 0
			BEGIN
				
				IF EXISTS (SELECT ComponentID FROM Production.BillOfMaterials WHERE ProductAssemblyID = @myID)
				BEGIN
					
					DECLARE cursor3 CURSOR fOR
						SELECT ComponentID, PerAssemblyQty
						FROM Production.BillOfMaterials
						WHERE ProductAssemblyID = @myID
					OPEN cursor3
					FETCH NEXT FROM cursor3 INTO @subpartID, @subpartQty

					WHILE @@FETCH_STATUS = 0
					BEGIN
							
						IF EXISTS (SELECT ProductID FROM Production.ExpectedInventory WHERE ProductID = @subpartID)
						BEGIN
							UPDATE Production.ExpectedInventory
							SET Quantity = Quantity + (@qty * @subpartQty)
							WHERE ProductID = @subpartID
						END

						ELSE
						BEGIN
							INSERT INTO Production.ExpectedInventory VALUES (@subpartID, @subpartQty * @qty)
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
						-- TODO: UPDATE secONd getdate to actually put END date
						INSERT INTO NeededOrders VALUES (@myID, abs(@qty), getdate(), getdate())
					END

				END

				UPDATE Production.ExpectedInventory
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