use AdventureWorks2012
go

exec ExpectedInventory
exec CalculateDemand
exec BOMRecursion @days = 30

SELECT * FROM NeededOrders
ORDER BY ID