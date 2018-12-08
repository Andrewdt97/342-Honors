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
