-- Check expected inventory - demand for each product
SELECT ID, dc.Quantity, ei.Quantity, ei.Quantity - dc.Quantity
FROM DemandCalc dc LEFT JOIN Production.ExpectedInventory ei
ON dc.ID = ei.ProductID
ORDER BY ei.Quantity - dc.Quantity