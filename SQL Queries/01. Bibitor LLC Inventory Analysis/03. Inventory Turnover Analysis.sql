-- SQL Inventory Turnover and Slow-Moving Analysis Script

-- This script is designed to analyze the efficiency of inventory movement, specifically
-- focusing on how long purchased inventory sits before it's sold.
-- It identifies slow-moving inventory items by calculating the "Days to Sell" and
-- stores this critical information in a dedicated table for further analysis.

---------------------------------------------------------------------------------------------------
-- SECTION 1: CREATE INVENTORY_SALE_LAG TABLE FOR DETAILED ANALYSIS
---------------------------------------------------------------------------------------------------

-- This section constructs a new table, 'InventorySaleLag', to house key metrics related
-- to inventory movement. This includes the calculated "Days to Sell" for every unique
-- inventory item and store combination that has both a purchase and a subsequent sale record.

-- Safety check: Drop the table if it already exists to ensure a clean run.
-- This is particularly useful during development or for script re-execution.
-- For production environments, consider adding conditional checks or alternative
-- handling to prevent accidental data loss.
DROP TABLE IF EXISTS InventorySaleLag;

-- Create the 'InventorySaleLag' table with calculated inventory movement data.
CREATE TABLE InventorySaleLag AS
WITH Purchases AS (
  SELECT
    InventoryId,
    Store,
    MIN(ReceivingDate) AS FirstReceived,
    AVG(PurchasePrice) AS AvgPurchasePrice,
    SUM(Quantity) AS TotalPurchased,
    VendorNumber,
    VendorName
  FROM PurchasesDec
  GROUP BY InventoryId, Store
),
Sales AS (
  SELECT
    InventoryId,
    Store,
    MIN(SalesDate) AS FirstSold,
    AVG(SalesPrice) AS AvgSalesPrice,
    SUM(SalesQuantity) AS TotalSold
  FROM SalesDec
  GROUP BY InventoryId, Store
)
SELECT
  p.InventoryId,
  p.Store,
  p.VendorName,
  ROUND(p.AvgPurchasePrice, 2) AS AvgPurchasePrice,
  ROUND(s.AvgSalesPrice, 2) AS AvgSalesPrice,
  p.TotalPurchased,
  s.TotalSold,
  p.FirstReceived,
  s.FirstSold,
  strftime('%m', p.FirstReceived) AS PurchaseMonth,
  strftime('%m', s.FirstSold) AS SaleMonth,
  CAST(julianday(s.FirstSold) - julianday(p.FirstReceived) AS INTEGER) AS DaysToSell
FROM Purchases p
JOIN Sales s 
  ON p.InventoryId = s.InventoryId AND p.Store = s.Store
WHERE s.FirstSold IS NOT NUL
ORDER BY DaysToSell DESC;

---------------------------------------------------------------------------------------------------
-- SECTION 2: IDENTIFY SLOW-MOVING INVENTORY
---------------------------------------------------------------------------------------------------

-- Following the creation of the 'InventorySaleLag' table, this section specifically queries
-- that table to pinpoint **slow-moving inventory** items. In this analysis, an item is
-- considered slow-moving if it took **longer than 60 days** to sell after being received.

-- Retrieve a list of inventory items classified as slow-moving.
-- This query directly utilizes the pre-calculated 'DaysToSell' from the 'InventorySaleLag' table
-- to efficiently identify items exceeding the defined threshold.
SELECT *
FROM InventorySaleLag
WHERE DaysToSell > 60 -- Filters for items that took more than 60 days to sell
ORDER BY DaysToSell DESC; -- Orders by DaysToSell to show the slowest items prominently
