-- Determine current orders for products
-- Get final product demand first, then worry about recursion and BOM stuff

use AdventureWorks2012
go

alter proc CalculateDemand
as
	if object_id('DemandCalc') is not null
		drop table DemandCalc
	
	if object_id('DemandCalc') is null
		create table DemandCalc(
			Name varchar(128),
			Quantity int)

	insert into DemandCalc 

		select [Name], sum([Quantity]) from (

		select p.Name [Name], sum(sd.OrderQty) [Quantity] from Production.Product p
		inner join Sales.SalesOrderDetail sd on sd.ProductID = p.ProductID
		inner join Sales.SalesOrderHeader sh on sd.SalesOrderID = sh.SalesOrderID
		-- could be used in case the Status column isn't always reliable and we want to check by date instead
		--where (sh.OrderDate <= convert(datetime, '2008-07-01') and convert(datetime, '2008-07-01') <= sh.DueDate)
		where sh.Status = 1 or sh.Status = 2 or sh.Status = 3
		group by p.Name

	union

		SELECT pro.Name, SUM(sod.OrderQty) FROM 
		Production.Product pro JOIN Sales.SalesOrderDetail sod
			ON pro.ProductID = sod.ProductID
		JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
		WHERE DATEPART(DAYOFYEAR, OrderDate) > DATEPART(DAYOFYEAR, Convert(datetime, '2006-01-01' )) -- Will become GETDATE - numOfDays
			AND DATEPART(DAYOFYEAR, OrderDate) < DATEPART(DAYOFYEAR, Convert(datetime, '2006-03-01' )) -- Will become GETDATE
			AND DATEPART(YEAR, OrderDate) < DATEPART(YEAR, convert(datetime, '2010-04-01'))
		GROUP BY pro.Name

	) as demcalc
	group by [Name]
go

exec CalculateDemand
select * from DemandCalc