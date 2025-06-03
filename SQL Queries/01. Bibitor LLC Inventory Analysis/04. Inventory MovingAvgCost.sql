--=================================================================================================
-- Inventory Moving Average Cost Calculation Script

-- This script processes sales and purchase transactions to calculate a moving average cost (MAC)
-- for inventory items. It incorporates beginning inventory balances, adjusts quantities for sales,
-- and compares recalculated costs to ending inventory values.

-- The goal is to analyze inventory valuation changes by combining purchase and sales data with 
-- beginning and ending inventory snapshots.

-- Period: Starting from December 1, 2016
--=================================================================================================

---------------------------------------------------------------------------------------------------
-- STEP 1: PROCESS SALES DATA
---------------------------------------------------------------------------------------------------

-- Create a processing table for sales transactions occurring in December 2016 or later.
-- Sales quantities are converted to negative values to represent inventory outflow.
CREATE TABLE temp.SalesFLow AS
SELECT
    InventoryId,
    Store,
    Brand,
    (SalesQuantity * -1) AS Quantity,       -- Negative to represent sales (inventory reduction)
    SalesPrice AS Price,
    VendorNo
FROM SalesDec
WHERE SalesDate >= '2016-12-01';


---------------------------------------------------------------------------------------------------
-- STEP 2: PROCESS PURCHASE DATA
---------------------------------------------------------------------------------------------------

-- Create a processing table for purchase transactions received in December 2016 or later.
-- Purchase quantities remain positive representing inventory inflow.
CREATE TABLE temp.PurchasesFlow AS
SELECT
    InventoryId,
    Store,
    Brand,
    Quantity,                               -- Purchases increase inventory
    PurchasePrice AS Price,
    VendorNumber AS VendorNo
FROM PurchasesDec
WHERE ReceivingDate >= '2016-12-01';

---------------------------------------------------------------------------------------------------
-- STEP 3: COMBINE PURCHASES AND SALES TRANSACTIONS
---------------------------------------------------------------------------------------------------

-- This query aggregates purchase and sales transactions to create a combined view of inventory movement.
-- It sums quantities and prices by Inventory ID, Store, and Brand.
-- Each group of Inventory, Store, and Brand appears twice:
--  once for purchases (positive quantities),
--  and once for sales (negative quantities).

CREATE TABLE temp.All_Transactions AS
-- Aggregate purchases (quantities are positive, representing inventory *increases*)
SELECT
    InventoryId,
    Store,
    Brand,
    SUM(Quantity) AS Quantity,
    SUM(Price) AS Price
FROM
    temp.PurchasesFlow
GROUP BY
    InventoryId,
    Store,
    Brand

UNION ALL

-- Aggregate sales (quantities are negative, representing inventory *decreases*)
SELECT
    InventoryId,
    Store,
    Brand,
    SUM(Quantity) AS Quantity,
    SUM(Price) AS Price
FROM
    temp.SalesFLow
GROUP BY
    InventoryId,
    Store,
    Brand;

---------------------------------------------------------------------------------------------------
-- STEP 4: INCORPORATE BEGINNING INVENTORY BALANCES
---------------------------------------------------------------------------------------------------

-- Combine transaction aggregates with beginning inventory on hand and price.
-- Adjust Price aggregation conditionally: when Quantity < 0 (sales), set Price = 0 for summation.
CREATE TABLE temp.InvMovement AS

SELECT
    InventoryId,
    Store,
    Brand,
    Quantity,
    SUM(CASE WHEN Quantity < 0 THEN Price = 0 ELSE Price END) AS Price
FROM
    temp.All_Transactions
GROUP BY
    InventoryId,
    Store,
    Brand,
    Quantity

UNION ALL

-- Include beginning inventory quantities and prices
SELECT
    InventoryId,
    Store,
    Brand,
    onHand AS Quantity,
    Price
FROM
    BegInvDec;


---------------------------------------------------------------------------------------------------
-- STEP 5: CALCULATE MOVING AVERAGE COST
---------------------------------------------------------------------------------------------------

-- For each Inventory, Store, and Brand, sum quantities and prices from combined transactions
-- and beginning inventory, then compute the Moving Average Cost = Price / Quantity.
CREATE TABLE temp.InvCostCalc AS
SELECT
    InventoryId,
    Store,
    Brand,
    SUM(Quantity) AS Quantity,
    SUM(Price) AS Price,
    (SUM(Price) / NULLIF(SUM(Quantity), 0)) AS MAC
FROM
    temp.InvMovement
GROUP BY
    InventoryId,
    Store,
    Brand;


---------------------------------------------------------------------------------------------------
-- STEP 6: JOIN WITH ENDING INVENTORY AND CALCULATE COST DIFFERENCE
---------------------------------------------------------------------------------------------------

-- Join recalculated moving average cost with ending inventory data.
-- Calculate the difference between the recorded ending inventory price and the recalculated MAC.
CREATE TABLE Inv_AvgCost AS
SELECT
    a.*,
    b.MAC,
    (a.Price - b.MAC) AS Difference
FROM
    EndInvDec a
INNER JOIN
    temp.InvCostCalc b
ON
    a.InventoryId = b.InventoryId
    AND a.Store = b.Store
    AND a.Brand = b.Brand;

---------------------------------------------------------------------------------------------------
-- END OF SCRIPT
---------------------------------------------------------------------------------------------------
