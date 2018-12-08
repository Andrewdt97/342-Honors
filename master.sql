USE AdventureWorks2012
GO

EXEC MRP_Calculate_Orders 30;

SELECT * FROM NeededOrders
ORDER BY ID