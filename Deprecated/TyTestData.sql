USE [AdventureWorks2012]
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
           ,1004
           ,getdate()
           ,getdate() + 300
           ,'EA'
           ,1
           ,1
           ,getdate())
GO

select * from Production.BillOfMaterials where ProductAssemblyID = 1000

update Production.BillOfMaterials
set PerAssemblyQty = 3
where ComponentID = 1004

select * from Production.ProductInventory