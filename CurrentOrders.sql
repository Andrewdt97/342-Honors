-- Determine current orders for products
-- Get final product demand first, then worry about recursion and BOM stuff

use AdventureWorks2012
go

alter proc dbo.GetCurrentOrders
as
	select p.Name, sum(sd.OrderQty) "Quantity" from Production.Product p
	inner join Sales.SalesOrderDetail sd on sd.ProductID = p.ProductID
	inner join Sales.SalesOrderHeader sh on sd.SalesOrderID = sh.SalesOrderID
	-- could be used in case the Status column isn't always reliable and we want to check by date instead
	--where (sh.OrderDate <= convert(datetime, '2008-07-01') and convert(datetime, '2008-07-01') <= sh.DueDate)
	where sh.Status = 1 or sh.Status = 2 or sh.Status = 3
	group by p.Name
go

exec dbo.GetCurrentOrders