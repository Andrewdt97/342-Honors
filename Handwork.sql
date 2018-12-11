-- Demand
SELECT ProductID, OrderQty, soh.OrderDate
FROM Sales.SalesOrderDetail sod JOIN Sales.SalesOrderHeader soh
ON sod.SalesOrderID = soh.SalesOrderID
WHERE ProductID = 1000

-- (10 + (10 + 20) / 2) = 25

-- Expected Inventory

SELECT ProductID, Sum(Quantity) FROM 

(SELECT ProductID, Quantity FROM Production.ProductInventory
WHERE ProductID >= 1000

UNION

SELECT ProductID, OrderQty
FROM Purchasing.PurchaseOrderDetail
WHERE ProductID >= 1000) AS u
GROUP BY ProductID
-- 1000: 10 1001:15 1002:10

-- Bill of Materials

SELECT * FROM Production.BillOfMaterials
WHERE ProductAssemblyID >= 1000

-- Hand calculated demand
-- 1000: 15 -> 1001: 0 1002: 20

-- Calculate for safety levels
-- 1000: 0 1001: 5 1002: 20