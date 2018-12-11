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
           , 1
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

-- Insert Inventory
USE [AdventureWorks2012]
GO

INSERT INTO [Production].[ProductInventory]
           ([ProductID]
           ,[LocationID]
           ,[Shelf]
           ,[Bin]
           ,[Quantity]
           ,[ModifiedDate])
     VALUES
           (1000
           ,1
           ,'A'
           ,1
           ,10
           ,GETDATE())
GO

INSERT INTO [Production].[ProductInventory]
           ([ProductID]
           ,[LocationID]
           ,[Shelf]
           ,[Bin]
           ,[Quantity]
           ,[ModifiedDate])
     VALUES
           (1001
           ,1
           ,'A'
           ,1
           ,5
           ,GETDATE())
GO

INSERT INTO [Production].[ProductInventory]
           ([ProductID]
           ,[LocationID]
           ,[Shelf]
           ,[Bin]
           ,[Quantity]
           ,[ModifiedDate])
     VALUES
           (1002
           ,1
           ,'A'
           ,1
           ,10
           ,GETDATE())
GO



-- INSERT Demand

USE [AdventureWorks2012]
GO
-- Current Sale
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
           ,[ModifiedDate])
     VALUES
           (3 
           ,GETDATE() - 1
           ,GETDATE() + 5
           ,NULL
           ,3
           ,1
           ,'PO18850127500'
           ,'10-4020-000442'
           ,29672
           ,279
           ,5
           ,921
           ,921
           ,5
           ,5618
           ,'115213Vi29411'
           , NULL
           ,0.01
           ,0.01
           ,429.98
           ,NULL
           ,GETDATE())
GO
 -- Historical sale 1
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
           ,[ModifiedDate])
     VALUES
           (3 
           ,GETDATE() - 360
           ,GETDATE() - 355
           ,GETDATE() - 355
           ,5
           ,1
           ,'PO18850127500'
           ,'10-4020-000442'
           ,29672
           ,279
           ,5
           ,921
           ,921
           ,5
           ,5618
           ,'115213Vi29411'
           , NULL
           ,0.01
           ,0.01
           ,429.98
           ,NULL
           ,GETDATE() - 355)
GO

-- HIstorical 2
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
           ,[ModifiedDate])
     VALUES
           (3 
           ,GETDATE() - 725
           ,GETDATE() - 715
           ,GETDATE() - 715
           ,5
           ,1
           ,'PO18850127500'
           ,'10-4020-000442'
           ,29672
           ,279
           ,5
           ,921
           ,921
           ,5
           ,5618
           ,'115213Vi29411'
           , NULL
           ,0.01
           ,0.01
           ,429.98
           ,NULL
           ,GETDATE() - 715)
GO


-- Insert SaleOrderDetail (Expected demand 25)

USE [AdventureWorks2012]
GO

INSERT INTO [Sales].[SpecialOfferProduct]
           ([SpecialOfferID]
           ,[ProductID]
           ,[ModifiedDate])
     VALUES
           (1
           ,1000
           ,GETDATE())
GO



USE [AdventureWorks2012]
GO

-- CurrentOrder
INSERT INTO [Sales].[SalesOrderDetail]
           ([SalesOrderID]
           ,[CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
           ,[ModifiedDate])
     VALUES
           (75124
           ,NULL
           ,10 -- On current order
           ,1000
           ,1
           ,10.00
           ,0.00
           ,GETDATE())
GO

-- Historical 1
INSERT INTO [Sales].[SalesOrderDetail]
           ([SalesOrderID]
           ,[CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
           ,[ModifiedDate])
     VALUES
           (75125
           ,NULL
           ,20 -- (20...
           ,1000
           ,1
           ,10.00
           ,0.00
           ,GETDATE() - 355)
GO

--Historical 2
INSERT INTO [Sales].[SalesOrderDetail]
           ([SalesOrderID]
           ,[CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
           ,[ModifiedDate])
     VALUES
           (75126
           ,NULL
           ,10 -- ... + 10 = 30) / 2 = 15
           ,1000
           ,1
           ,10.00
           ,0.00
           ,GETDATE() - 715)
GO

-- Insert PurchaseOrder
USE [AdventureWorks2012]
GO

INSERT INTO [Purchasing].[PurchaseOrderHeader]
           ([RevisionNumber]
           ,[Status]
           ,[EmployeeID]
           ,[VendorID]
           ,[ShipMethodID]
           ,[OrderDate]
           ,[ShipDate]
           ,[SubTotal]
           ,[TaxAmt]
           ,[Freight]
           ,[ModifiedDate])
     VALUES
           (1
           ,2
           ,254
           ,1496
           ,5
           ,GETDATE() - 2
           ,GETDATE() - 2
           ,10.00
           ,2.55
           ,20000.00
           ,GETDATE())
GO

USE [AdventureWorks2012]
GO

INSERT INTO [Purchasing].[PurchaseOrderDetail]
           ([PurchaseOrderID]
           ,[DueDate]
           ,[OrderQty]
           ,[ProductID]
           ,[UnitPrice]
           ,[ReceivedQty]
           ,[RejectedQty]
           ,[ModifiedDate])
     VALUES
           (4013
           ,GETDATE()
           ,10
           ,1001
           ,0.05
           ,0
           ,0
           ,GETDATE())
GO

-- Create BoM
INSERT INTO [Production].[BillOfMaterials]
           ([ProductAssemblyID]
           ,[ComponentID]
           ,[StartDate]
           ,[EndDate]
           ,[UnitMeasureCode]
           ,[BOMLevel]
           ,[PerAssemblyQty]
           ,[ModifiedDate])
     VALUES
           (1000
           ,1001
           ,getdate()
           ,getdate() + 300
           ,'EA'
           ,1
           ,1
           ,getdate())
GO

INSERT INTO [Production].[BillOfMaterials]
           ([ProductAssemblyID]
           ,[ComponentID]
           ,[StartDate]
           ,[EndDate]
           ,[UnitMeasureCode]
           ,[BOMLevel]
           ,[PerAssemblyQty]
           ,[ModifiedDate])
     VALUES
           (1000
           ,1002
           ,getdate()
           ,getdate() + 300
           ,'EA'
           ,1
           ,2
           ,getdate())
GO
