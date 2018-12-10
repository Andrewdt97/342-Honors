USE [AdventureWorks2012]
GO

-- INSERT PRODUCTS


INSERT INTO [Production].[Product]
           ([Name]
           ,[ProductNumber]
           ,[MakeFlag]
           ,[FinishedGoodsFlag]
           ,[Color]
           ,[SafetyStockLevel]
           ,[ReorderPoint]
           ,[StandardCost]
           ,[ListPrice]
           ,[Size]
           ,[SizeUnitMeasureCode]
           ,[WeightUnitMeasureCode]
           ,[Weight]
           ,[DaysToManufacture]
           ,[ProductLine]
           ,[Class]
           ,[Style]
           ,[ProductSubcategoryID]
           ,[ProductModelID]
           ,[SellStartDate]
           ,[SellEndDate]
           ,[DiscontinuedDate]
           ,[ModifiedDate])
     VALUES
           ('Test1'
           , 200
           ,0
           ,1
           , 'Black'
           , 1
           , 1000
           , 0.00
           , 1.00
           , NULL
           , NULL
           , NULL
           , NULL
           , 1
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           , GETDATE() - 300
           ,NULL
           , NULL
           ,GETDATE())
GO


USE [AdventureWorks2012]
GO

INSERT INTO [Production].[Product]
           ([Name]
           ,[ProductNumber]
           ,[MakeFlag]
           ,[FinishedGoodsFlag]
           ,[Color]
           ,[SafetyStockLevel]
           ,[ReorderPoint]
           ,[StandardCost]
           ,[ListPrice]
           ,[Size]
           ,[SizeUnitMeasureCode]
           ,[WeightUnitMeasureCode]
           ,[Weight]
           ,[DaysToManufacture]
           ,[ProductLine]
           ,[Class]
           ,[Style]
           ,[ProductSubcategoryID]
           ,[ProductModelID]
           ,[SellStartDate]
           ,[SellEndDate]
           ,[DiscontinuedDate]
           ,[ModifiedDate])
     VALUES
           ('Test2'
           , 201
           ,0
           ,1
           , 'Black'
           , 20
           , 1000
           , 0.00
           , 1.00
           , NULL
           , NULL
           , NULL
           , NULL
           , 1
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           , GETDATE() - 300
           ,NULL
           , NULL
           ,GETDATE())
GO

INSERT INTO [Production].[Product]
           ([Name]
           ,[ProductNumber]
           ,[MakeFlag]
           ,[FinishedGoodsFlag]
           ,[Color]
           ,[SafetyStockLevel]
           ,[ReorderPoint]
           ,[StandardCost]
           ,[ListPrice]
           ,[Size]
           ,[SizeUnitMeasureCode]
           ,[WeightUnitMeasureCode]
           ,[Weight]
           ,[DaysToManufacture]
           ,[ProductLine]
           ,[Class]
           ,[Style]
           ,[ProductSubcategoryID]
           ,[ProductModelID]
           ,[SellStartDate]
           ,[SellEndDate]
           ,[DiscontinuedDate]
           ,[ModifiedDate])
     VALUES
           ('Test3'
           , 202
           , 0
           , 1
           , 'Black'
           , 1
           , 1000
           , 0.00
           , 1.00
           , NULL
           , NULL
           , NULL
           , NULL
           , 1
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           , GETDATE() - 300
           ,NULL
           , NULL
           ,GETDATE())
GO

-- INSERT Demand

USE [AdventureWorks2012]
GO

INSERT INTO [Sales].[SalesOrderHeader]
           ([RevisionNumber]
           ,[OrderDate]
           ,[DueDate]
           ,[ShipDate]
           ,[Status]
           ,[OnlineOrderFlag]
           ,[PurchaseOrderNumber]
           ,[AccountNumber]
           ,[CustomerID]
           ,[SalesPersonID]
           ,[TerritoryID]
           ,[BillToAddressID]
           ,[ShipToAddressID]
           ,[ShipMethodID]
           ,[CreditCardID]
           ,[CreditCardApprovalCode]
           ,[CurrencyRateID]
           ,[SubTotal]
           ,[TaxAmt]
           ,[Freight]
           ,[Comment]
           ,[rowguid]
           ,[ModifiedDate])
     VALUES
           (<RevisionNumber, tinyint,>
           ,<OrderDate, datetime,>
           ,<DueDate, datetime,>
           ,<ShipDate, datetime,>
           ,<Status, tinyint,>
           ,<OnlineOrderFlag, [dbo].[Flag],>
           ,<PurchaseOrderNumber, [dbo].[OrderNumber],>
           ,<AccountNumber, [dbo].[AccountNumber],>
           ,<CustomerID, int,>
           ,<SalesPersonID, int,>
           ,<TerritoryID, int,>
           ,<BillToAddressID, int,>
           ,<ShipToAddressID, int,>
           ,<ShipMethodID, int,>
           ,<CreditCardID, int,>
           ,<CreditCardApprovalCode, varchar(15),>
           ,<CurrencyRateID, int,>
           ,<SubTotal, money,>
           ,<TaxAmt, money,>
           ,<Freight, money,>
           ,<Comment, nvarchar(128),>
           ,<rowguid, uniqueidentifier,>
           ,<ModifiedDate, datetime,>)
GO


