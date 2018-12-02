use AdventureWorks2012
go

exec CalculateDemand
exec BOMRecursion @days = 30

create table NeededOrders (
	ID int,
	qty int,
	startDate date,
	endDate date
);

SELECT * FROM NeededOrders
ORDER BY ID