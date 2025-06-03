-- Vendor Analysis Script

-- This script provides various insights into vendor performance, including:
-- - List of all vendors
-- - Summarizing vendor activities (purchases, invoices, freight)
-- - Identifying top vendors by spending, sales, quantity, and freight cost
-- - Analyzing freight as a percentage of total purchase cost
-- - Tracking monthly purchase and sales trends
-- - Calculating gross margin by vendor to identify profitability.

---------------------------------------------------------------------------------------------------
-- SECTION 1: VENDOR OVERVIEWS
---------------------------------------------------------------------------------------------------

-- This section focuses on identifying all unique vendors and providing a comprehensive summary
-- of their combined activities across purchasing and invoicing.

-- SUB-SECTION 1.1: LIST ALL DISTINCT VENDORS

-- Retrieve a comprehensive list of all unique vendors from both PurchasesDec and VendorInvoicesDec.
-- This ensures all vendors, regardless of whether they have purchase or invoice records, are included.
SELECT DISTINCT VendorNumber, VendorName
FROM PurchasesDec
UNION
SELECT DISTINCT VendorNumber, VendorName
FROM VendorInvoicesDec;

-- SUB-SECTION 1.2: AGGREGATED VENDOR ACTIVITIES

-- Summarize total activities for each vendor by joining purchase and invoice data.
-- This query provides a holistic view of each vendor's engagement, including POs, quantities,
-- purchase dollars, invoices, invoice dollars, and freight.
SELECT
    p.VendorNumber,
    p.VendorName,
    COUNT(DISTINCT p.PONumber) AS TotalPurchaseOrders,
    SUM(p.Quantity) AS TotalQuantityPurchased,
    SUM(p.Dollars) AS TotalPurchaseDollars,
    COUNT(DISTINCT i.PONumber) AS TotalInvoices,
    SUM(i.Dollars) AS TotalInvoiceDollars,
    SUM(i.Freight) AS TotalFreight
FROM PurchasesDec p
LEFT JOIN VendorInvoicesDec i
    ON p.VendorNumber = i.VendorNumber AND p.PONumber = i.PONumber
GROUP BY 
    p.VendorNumber,
    p.VendorName
ORDER BY p.VendorNumber;

-- SUB-SECTION 1.3: AGGREGATED SALES BY VENDOR AND INVENTORY ITEM

-- Join sales and purchase data to aggregate key sales metrics for each inventory item,
-- categorized by its respective vendor.
-- It provides a clear overview of total units sold and total revenue generated per item from each vendor.
CREATE TABLE VendorItemsSold AS
SELECT
    p.VendorNumber,
    s.InventoryId,
    SUM(s.SalesQuantity) AS total_sold,
    SUM(s.SalesQuantity * s.SalesPrice) AS total_sales
FROM SalesDec s
JOIN PurchasesDec p
    ON s.InventoryId = p.InventoryId
GROUP BY
    p.VendorNumber,
    s.InventoryId;


---------------------------------------------------------------------------------------------------
-- SECTION 2: TOP VENDORS BY KEY METRICS
---------------------------------------------------------------------------------------------------

-- This section identifies the top-performing or most significant vendors based on different
-- financial and operational metrics such as total spending, sales generated, quantity purchased,
-- and freight costs.

-- SUB-SECTION 2.1: TOP VENDORS BY TOTAL PURCHASES ($)

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

-- SUB-SECTION 2.2: TOP VENDORS BY TOTAL SALES ($)

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

-- SUB-SECTION 2.3: TOP VENDORS BY QUANTITY PURCHASED

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

-- SUB-SECTION 2.4: TOP VENDORS BY FREIGHT COST

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

-- SUB-SECTION 2.5: TOP VENDORS BY FREIGHT AS PERCENTAGE OF TOTAL PURCHASE COST

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

-- SUB-SECTION 3.1: MONTHLY PURCHASES SUMMARY

-- Summarize total purchase dollars on a monthly basis from PurchasesDec using InvoiceDate.
SELECT
    strftime('%Y-%m', InvoiceDate) AS PurchaseMonth, -- Format date to YYYY-MM
    SUM(Dollars) AS MonthlyPurchasesDollars
FROM PurchasesDec
GROUP BY PurchaseMonth
ORDER BY PurchaseMonth;

-- SUB-SECTION 3.2: MONTHLY SALES SUMMARY

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
