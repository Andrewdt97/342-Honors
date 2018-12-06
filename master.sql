USE AdventureWorks2012
GO

EXEC MakeTables
EXEC ExpectedInventory
EXEC CalculateDemand
EXEC BOMRecursion

SELECT * FROM NeededOrders
ORDER BY ID