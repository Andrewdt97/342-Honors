USE AdventureWorks2012
GO

DECLARE @days int
SET @days = 19
EXEC MRP_Calculate_Orders @days;

SELECT * FROM NeededOrders
ORDER BY ID