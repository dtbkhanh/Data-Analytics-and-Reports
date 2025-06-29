-- Vendor Analysis Script

-- This script provides various insights into vendor performance, including:
-- * List of all vendors
-- * Summarizing vendor activities (purchases, invoices, freight)
-- * Identifying top vendors by spending, sales, quantity, and freight cost
-- * Analyzing freight as a percentage of total purchase cost
-- * Tracking monthly purchase and sales trends
-- * Calculating gross margin by vendor to identify profitability.

---------------------------------------------------------------------------------------------------
-- SECTION 1: VENDOR OVERVIEWS
---------------------------------------------------------------------------------------------------

-- This section focuses on identifying all unique vendors and providing a comprehensive summary
-- of their combined activities across purchases, invoices, and sales.

-- # SUB-SECTION 1.1: LIST ALL DISTINCT VENDORS

-- Retrieve a comprehensive list of all unique vendors from both PurchasesDec and VendorInvoicesDec.
-- This ensures all vendors, regardless of whether they have purchase or invoice records, are included.
SELECT DISTINCT VendorNumber, VendorName
FROM PurchasesDec
UNION
SELECT DISTINCT VendorNumber, VendorName
FROM VendorInvoicesDec;

-- # SUB-SECTION 1.2: AGGREGATED VENDOR ACTIVITIES

-- Summarize total activities for each vendor by joining purchase, invoice, and sales data.
-- Provide a holistic view of each vendor's engagement across purchases, invoices, and sales.
WITH SalesAgg AS (
    SELECT
        VendorNo AS VendorNumber,
        SUM(SalesDollars) AS TotalSalesDollars
    FROM SalesDec
    GROUP BY VendorNo
)
SELECT
    p.VendorNumber,
    p.VendorName,
    COUNT(DISTINCT p.PONumber) AS TotalPurchaseOrders,
    SUM(p.Quantity) AS TotalQuantityPurchased,
    SUM(p.Dollars) AS TotalPurchaseDollars,
    COUNT(DISTINCT i.PONumber) AS TotalInvoices,
    SUM(i.Dollars) AS TotalInvoiceDollars,
    SUM(i.Freight) AS TotalFreight,
    -- ROUND(SUM(i.Freight) * 100.0 / NULLIF(SUM(i.Dollars), 0), 2) AS FreightPercentOfPurchase,
    sa.TotalSalesDollars
FROM PurchasesDec p
LEFT JOIN VendorInvoicesDec i
    ON p.VendorNumber = i.VendorNumber AND p.PONumber = i.PONumber
LEFT JOIN SalesAgg sa
    ON p.VendorNumber = sa.VendorNumber
GROUP BY
    p.VendorNumber,
    p.VendorName,
    sa.TotalSalesDollars
ORDER BY p.VendorNumber;

-- # SUB-SECTION 1.3: SALES PERFORMANCE OF VENDOR-SUPPLIED ITEMS

-- These queries analyze the sales data of inventory items, linking them back to their respective vendors.
-- The goal here is to understand which items, from which vendors, are performing best in terms of sales volume and revenue.

-- ## 1.3.1: Aggregate Sales data for Vendor Inventory
CREATE TABLE VendorItemsSold AS
SELECT
    p.VendorNumber,
	p.VendorName,
    s.InventoryId,
	s.Description,
    SUM(s.SalesQuantity) AS total_sold,
    SUM(s.SalesQuantity * s.SalesPrice) AS total_sales
FROM SalesDec s
JOIN PurchasesDec p
    ON s.InventoryId = p.InventoryId
GROUP BY
    p.VendorNumber,
    s.InventoryId;

-- ## 1.3.2: Identify the Top-Selling Product by Vendor
SELECT
    VendorNumber,
    VendorName,
    InventoryId,
    Description,
    total_sold,
    total_sales
FROM (
    SELECT
        VendorNumber,
        VendorName,
        InventoryId,
        Description,
        total_sold,
        total_sales,
        ROW_NUMBER() OVER (PARTITION BY VendorNumber ORDER BY total_sold DESC) as rn
    FROM
        VendorItemsSold
) AS RankedSales
WHERE rn = 1; -- Filters to include only the top-ranked (most sold) item for each vendor

-- ## 1.3.3: Calculate total Ending Inventory per Vendor
WITH InventoryVendorMap AS (
    SELECT
        InventoryId,
        VendorNumber,
        VendorName
    FROM (
        SELECT
            InventoryId,
            VendorNumber,
            VendorName,
            ROW_NUMBER() OVER (PARTITION BY InventoryId ORDER BY ReceivingDate DESC) AS rn
        FROM PurchasesDec
    ) t
    WHERE rn = 1  -- take the latest vendor info per InventoryId
)

SELECT
    v.VendorNumber,
    v.VendorName,
    COALESCE(SUM(e.onHand), 0) AS total_ending_inventory_units_by_vendor,
    COALESCE(SUM(e.onHand * e.Price), 0) AS total_ending_inventory_value_by_vendor
FROM InventoryVendorMap v
INNER JOIN EndInvDec e ON v.InventoryId = e.InventoryId
GROUP BY v.VendorNumber, v.VendorName
ORDER BY v.VendorName;


---------------------------------------------------------------------------------------------------
-- SECTION 2: TOP VENDORS BY KEY METRICS
---------------------------------------------------------------------------------------------------

-- This section identifies the top-performing or most significant vendors based on different
-- financial and operational metrics such as total spending, sales generated, quantity purchased,
-- and freight costs.

-- # SUB-SECTION 2.1: TOP VENDORS BY TOTAL PURCHASES ($)
-- Identify top suppliers by total spending (Dollars) from PurchasesDec.
SELECT
    VendorNumber,
    VendorName,
    SUM(Dollars) AS TotalPurchaseDollars
FROM PurchasesDec
GROUP BY
    VendorNumber,
    VendorName
ORDER BY TotalPurchaseDollars DESC
LIMIT 10; -- Display top 10 vendors by purchase spending


-- # SUB-SECTION 2.2: TOP VENDORS BY TOTAL SALES ($)
-- Identify top vendors based on the sales generated from their products (SalesDollars).
-- This helps compare purchase volume vs. sales revenue to identify profitable vendors.
SELECT
    VendorNo AS VendorNumber, -- Standardize column name for consistency if needed
    VendorName,
    SUM(SalesDollars) AS TotalSalesDollars
FROM SalesDec
GROUP BY
    VendorNumber,
    VendorName
ORDER BY TotalSalesDollars DESC
LIMIT 10; -- Display top 10 vendors by sales dollars


-- # SUB-SECTION 2.3: TOP VENDORS BY QUANTITY PURCHASED
-- Identify top vendors based on the total quantity of items purchased from them.
SELECT
    VendorNumber,
    VendorName,
    SUM(Quantity) AS TotalQuantityPurchased
FROM PurchasesDec
GROUP BY
    VendorNumber,
    VendorName
ORDER BY TotalQuantityPurchased DESC
LIMIT 10; -- Display top 10 vendors by quantity purchased


-- # SUB-SECTION 2.4: TOP VENDORS BY FREIGHT COST
-- Identify vendors that incur the most shipping costs (Freight) from VendorInvoicesDec.
SELECT
    VendorNumber,
    VendorName,
    SUM(Freight) AS TotalFreightCost
FROM VendorInvoicesDec
GROUP BY
    VendorNumber,
    VendorName
ORDER BY TotalFreightCost DESC
LIMIT 10; -- Display top 10 vendors by total freight cost


-- # SUB-SECTION 2.5: TOP VENDORS BY FREIGHT AS PERCENTAGE OF TOTAL PURCHASE COST
-- Calculate and rank vendors by freight cost as a percentage of their total purchase cost.
-- This helps identify vendors with potentially high shipping overheads.
SELECT
    VendorNumber,
    VendorName,
    SUM(Dollars) AS TotalPurchaseDollars,
    SUM(Freight) AS TotalFreightDollars,
    ROUND(SUM(Freight) * 100.0 / NULLIF(SUM(Dollars), 0), 2) AS FreightPercentOfPurchase -- Handle division by zero
FROM VendorInvoicesDec
GROUP BY
    VendorNumber,
    VendorName
ORDER BY FreightPercentOfPurchase DESC
LIMIT 10; -- Display top 10 vendors by freight percentage


---------------------------------------------------------------------------------------------------
-- SECTION 3: TREND ANALYSIS OVER TIME
---------------------------------------------------------------------------------------------------

-- This section analyzes purchasing and sales activities over time, typically aggregated by month,
-- to identify trends and seasonality.

-- # SUB-SECTION 3.1: MONTHLY PURCHASES SUMMARY
-- Summarize total purchase dollars on a monthly basis from PurchasesDec using InvoiceDate.
SELECT
    strftime('%Y-%m', InvoiceDate) AS PurchaseMonth, -- Format date to YYYY-MM
    SUM(Dollars) AS MonthlyPurchasesDollars
FROM PurchasesDec
GROUP BY PurchaseMonth
ORDER BY PurchaseMonth;


-- # SUB-SECTION 3.2: MONTHLY SALES SUMMARY
-- Summarize total sales dollars on a monthly basis from SalesDec using SalesDate.
SELECT
    strftime('%Y-%m', SalesDate) AS SalesMonth, -- Format date to YYYY-MM
    SUM(SalesDollars) AS MonthlySalesDollars
FROM SalesDec
GROUP BY SalesMonth
ORDER BY SalesMonth;


---------------------------------------------------------------------------------------------------
-- SECTION 4: PROFITABILITY ANALYSIS
---------------------------------------------------------------------------------------------------

-- This section focuses on calculating profitability metrics, specifically gross margin,
-- to identify vendors that contribute most to the company's profit.

-- Gross Margin by Vendor: Calculate the margin between total cost (purchases) and total revenue (sales)
-- for each vendor. This helps identify vendors with the highest profit contribution.

WITH Purchases AS (
    -- Aggregate total cost (Dollars) for each vendor from PurchasesDec.
    -- Exclude records with zero or negative dollars to ensure meaningful cost calculation.
    SELECT VendorNumber, SUM(Dollars) AS TotalCost
    FROM PurchasesDec
    WHERE Dollars > 0
    GROUP BY VendorNumber
),
Sales AS (
    -- Aggregate total revenue (SalesDollars) for each vendor from SalesDec.
    SELECT VendorNo AS VendorNumber, SUM(SalesDollars) AS TotalRevenue
    FROM SalesDec
    GROUP BY VendorNo
)
SELECT
    s.VendorNumber,
    s.TotalRevenue,
    p.TotalCost,
    (s.TotalRevenue - p.TotalCost) AS GrossProfit, -- Calculate Gross Profit
    ROUND((s.TotalRevenue - p.TotalCost) * 100.0 / NULLIF(s.TotalRevenue, 0), 2) AS GrossMarginPercent -- Handle division by zero
FROM Sales s
LEFT JOIN Purchases p
    ON s.VendorNumber = p.VendorNumber
ORDER BY GrossProfit DESC;
