-- https://stackoverflow.com/questions/1838276/cte-error-types-dont-match-between-the-anchor-and-the-recursive-part

USE [AdventureWorks2012]
GO

/****** Object:  StoredProcedure [dbo].[uspGetBillOfMaterials]    Script Date: 11/17/2018 10:51:44 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


alter PROCEDURE [dbo].[getBOM]
    @StartProductID [int],
    @CheckDate [datetime]
AS
BEGIN
    SET NOCOUNT ON;

    -- Use recursive query to generate a multi-level Bill of Material (i.e. all level 1 
    -- components of a level 0 assembly, all level 2 components of a level 1 assembly)
    -- The CheckDate eliminates any components that are no longer used in the product on this date.
    WITH [BOM_cte]([ProductAssemblyID], [ComponentID], [PerAssemblyQty], [BOMLevel]) -- CTE name and columns
    AS (
        SELECT b.[ProductAssemblyID], b.[ComponentID], b.[PerAssemblyQty], b.[BOMLevel] -- Get the initial list of components for the bike assembly
        FROM [Production].[BillOfMaterials] b
            INNER JOIN [Production].[Product] p 
            ON b.[ComponentID] = p.[ProductID] 
        WHERE b.[ProductAssemblyID] = @StartProductID 
            AND @CheckDate >= b.[StartDate] 
            AND @CheckDate <= ISNULL(b.[EndDate], @CheckDate)
        UNION ALL
        SELECT b.[ProductAssemblyID], b.[ComponentID], b.[PerAssemblyQty], b.[BOMLevel] -- Join recursive member to anchor
        FROM [BOM_cte] cte
            INNER JOIN [Production].[BillOfMaterials] b 
            ON b.[ProductAssemblyID] = cte.[ComponentID]
            INNER JOIN [Production].[Product] p 
            ON b.[ComponentID] = p.[ProductID] 
        WHERE @CheckDate >= b.[StartDate] 
            AND @CheckDate <= ISNULL(b.[EndDate], @CheckDate)
        )
    -- Outer select from the CTE
    SELECT b.[ProductAssemblyID] AS [PartID], b.[ComponentID], SUM(b.[PerAssemblyQty]) AS [Quantity] , b.[BOMLevel]
    FROM [BOM_cte] b
    GROUP BY b.[ComponentID], b.[ProductAssemblyID], b.[BOMLevel]
    ORDER BY b.[BOMLevel], b.[ProductAssemblyID], b.[ComponentID]
    OPTION (MAXRECURSION 25) 
END;
GO