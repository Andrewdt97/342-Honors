-- Gets all product orders between two dates regardless of year

SELECT pro.Name, SUM(sod.OrderQty) FROM 
Production.Product pro JOIN Sales.SalesOrderDetail sod
	ON pro.ProductID = sod.ProductID
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE DATEPART(DAYOFYEAR, OrderDate) > DATEPART(DAYOFYEAR, Convert(datetime, '2006-01-01' )) -- Will become GETDATE - numOfDays
	AND DATEPART(DAYOFYEAR, OrderDate) < DATEPART(DAYOFYEAR, Convert(datetime, '2006-03-01' )) -- Will become GETDATE
GROUP BY pro.Name