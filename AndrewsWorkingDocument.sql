-----------------------------------------------------------------
-- Gets all product orders between two dates regardless of year |
-----------------------------------------------------------------
SELECT pro.Name, SUM(sod.OrderQty) FROM 
Production.Product pro JOIN Sales.SalesOrderDetail sod
	ON pro.ProductID = sod.ProductID
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE DATEPART(DAYOFYEAR, OrderDate) > DATEPART(DAYOFYEAR, Convert(datetime, '2006-01-01' )) -- Will become GETDATE - numOfDays
	AND DATEPART(DAYOFYEAR, OrderDate) < DATEPART(DAYOFYEAR, Convert(datetime, '2006-03-01' )) -- Will become GETDATE
GROUP BY pro.Name

-------------------------------
-- Subtract current inventory |
-------------------------------
CREATE TABLE Production.ExpectedInventory (
	ProductID int
	, Quantity int
) -- TODO: Clean up
GO

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

select ProductID, sum(Quantity) "Quantity" from Production.ExpectedInventory
group by ProductID
order by ProductID

select * from Production.ExpectedInventory
order by ProductID

CREATE TABLE Purchasing.NeedToOrder ( -- TODO: Clean up
	ProductID int PRIMARY KEY
	, Quantity int);
GO

SELECT ProductID
	demand.Quantity - ei.ExpectedQty as QtyNeeded
INTO Purchasing.NeedToOrder
FROM
-- other query
JOIN ExpectedInventory ei ON demand.ProductID = ei.ProductID
ORDER BY QtyNeeded

-------------------------------------
-- Make sure safety levels are met  |
-------------------------------------
DECLARE @id int;
DECLARE @current int;
DECLARE @demand int;
DECLARE @safety int;

DECLARE product_cursor CURSOR FOR 
SELECT ProductID
FROM Production.ProductInventory

OPEN product_curson  
FETCH NEXT FROM db_cursor INTO @id

WHILE @@FETCH_STATUS = 0  
BEGIN  
	SET @current = (SELECT ExpectedQty FROM Production.ExpectedInventory WHERE ProductID = @id);
	SET @demand = (SELECT Quantity FROM DEMANDTABLE WHERE ProductID = @id);
	SET @safety = (SELECT SafetyStockLevel FROM Production.Product WHERE ProductID = @id);
	
	IF (@demand < @safety AND @current < @safety)
		UPDATE NEEDTABLE
		SET Quantity = @safety
		WHERE ProductID = @id
		
    FETCH NEXT FROM db_cursor INTO @name 
END 

CLOSE product_cursor  
DEALLOCATE product_cursor 