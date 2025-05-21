-- Data Quality and Summary Script

-- This script performs essential data quality checks and generates basic summary statistics
-- for the PurchasesDec, SalesDec, PricingPurchasesDec, and VendorInvoicesDec tables.
-- It's designed to help identify potential issues like missing or zero values,
-- inconsistencies between related tables, and provide an overview of the data's characteristics

---------------------------------------------------------------------------------------------------
-- SECTION 1: DATA VALIDATION - CHECKING FOR ZERO, MISSING, AND INCONSISTENT ENTRIES
---------------------------------------------------------------------------------------------------

-- This section identifies potential data quality issues such as zero or null values in key
-- financial columns and discrepancies between calculated and recorded dollar amounts.

-- SUB-SECTION 1.1: IDENTIFYING ZERO OR NULL ENTRIES

-- These queries highlight records where 'Dollars', 'SalesDollars', or 'Price' are zero or missing,
-- which can indicate incomplete or erroneous data.

/* a. Check for zero or missing entries */

SELECT *
FROM PurchasesDec
WHERE Dollars <= 0 OR Dollars IS NULL;

SELECT *
FROM SalesDec
WHERE SalesDollars <= 0 OR SalesDollars IS NULL;

SELECT *
FROM PricingPurchasesDec
WHERE Price <= 0 OR Price IS NULL;

/*  b. Identify sales records where the sales price is zero but a quantity was sold */
SELECT COUNT(*) AS Count
FROM SalesDec
WHERE SalesPrice = 0 AND SalesQuantity > 0;

-- SUB-SECTION 1.2: CALCULATING PERCENTAGE OF ZERO OR NULL ENTRIES

-- These queries provide a high-level overview of data completeness by calculating the percentage
-- of zero or null values in critical monetary columns.
SELECT
    CAST(SUM(CASE WHEN Dollars <= 0 OR Dollars IS NULL THEN 1 ELSE 0 END) AS REAL) * 100 / COUNT(*) AS PercentageZeroOrNullDollars,
    COUNT(*) AS TotalRecords
FROM PurchasesDec;

SELECT
    CAST(SUM(CASE WHEN SalesDollars <= 0 OR SalesDollars IS NULL THEN 1 ELSE 0 END) AS REAL) * 100 / COUNT(*) AS PercentageZeroOrNullSalesDollars,
    COUNT(*) AS TotalRecords
FROM SalesDec;

-- SUB-SECTION 1.3: INVESTIGATING SPECIFIC DATA INCONSISTENCIES

-- These queries delve deeper into specific data anomalies, such as zero dollar purchases with
-- non-zero quantities or discrepancies between calculated and recorded totals.

/* a. Breakdown of zero Dollars by PurchasePrice and Quantity */
-- This helps understand scenarios where Dollars are zero despite valid purchase details.
SELECT
    PurchasePrice,
    Quantity,
    COUNT(*) AS Count
FROM PurchasesDec
WHERE Dollars = 0
GROUP BY PurchasePrice, Quantity
ORDER BY Count DESC;

/* b. Records in PurchasesDec where 'Dollars' does not equal 'PurchasePrice * Quantity' */
-- A small tolerance (0.001) is used for floating-point comparisons to catch minor discrepancies.
SELECT
    InventoryId,
    PurchasePrice,
    Quantity,
    Dollars
FROM PurchasesDec
WHERE ABS(Dollars - (PurchasePrice * Quantity)) > 0.001; 

---------------------------------------------------------------------------------------------------
-- SECTION 2: BASIC SUMMARIES AND DATA OVERVIEWS
---------------------------------------------------------------------------------------------------

-- This section provides fundamental aggregate information and date range insights for the key tables,
-- offering a quick understanding of the data's scope and characteristics.

-- SUB-SECTION 2.1: "PURCHASESDEC" TABLE SUMMARIES

/* a. Total rows, distinct vendors, and distinct purchase orders in PurchasesDec */
SELECT 
  COUNT(*) AS TotalRows,
  COUNT(DISTINCT VendorNumber) AS DistinctVendors,
  COUNT(DISTINCT PONumber) AS DistinctPOs
FROM PurchasesDec;

/* b. Summary statistics (sum, average, min, max) for Quantity and Dollars */
SELECT
  SUM(Quantity) AS TotalQuantity,
  AVG(Quantity) AS AvgQuantity,
  MIN(Quantity) AS MinQuantity,
  MAX(Quantity) AS MaxQuantity,

  SUM(Dollars) AS TotalDollars,
  AVG(Dollars) AS AvgDollars,
  MIN(Dollars) AS MinDollars,
  MAX(Dollars) AS MaxDollars
FROM PurchasesDec;

/* c. Date range for key purchase-related dates */
SELECT
  MIN(PODate) AS EarliestPODate,
  MAX(PODate) AS LatestPODate,
  MIN(ReceivingDate) AS EarliestReceivingDate,
  MAX(ReceivingDate) AS LatestReceivingDate,
  MIN(InvoiceDate) AS EarliestInvoiceDate,
  MAX(InvoiceDate) AS LatestInvoiceDate,
  MIN(PayDate) AS EarliestPayDate,
  MAX(PayDate) AS LatestPayDate
FROM PurchasesDec;

/* d. Count of records per distinct PONumber in PurchasesDec */
-- This helps identify how many items are associated with each purchase order.
SELECT
    PONumber,
    COUNT(*) AS Count
FROM PurchasesDec
GROUP BY PONumber
ORDER BY Count DESC;

-- SUB-SECTION 2.2: "SALESDEC: TABLE SUMMARIES
/* Summary statistics (sum, average, min, max) for SalesDollars */
SELECT 
  SUM(SalesDollars) AS TotalSalesDollars, 
  AVG(SalesDollars) AS AverageSalesDollars, 
  MIN(SalesDollars) AS MinSalesDollars, 
  MAX(SalesDollars) AS MaxSalesDollars
FROM SalesDec;

-- SUB-SECTION 2.3: "VENDORINVOICESDEC" TABLE SUMMARIES
/* Date ranges and aggregate statistics */
SELECT
  MIN(PODate) AS EarliestPODate,
  MAX(PODate) AS LatestPODate,
  MIN(InvoiceDate) AS EarliestInvoiceDate,
  MAX(InvoiceDate) AS LatestInvoiceDate,
  MIN(PayDate) AS EarliestPayDate,
  MAX(PayDate) AS LatestPayDate,
  SUM(Quantity) AS TotalQuantity,
  AVG(Quantity) AS AvgQuantity,
  MIN(Quantity) AS MinQuantity,
  MAX(Quantity) AS MaxQuantity,
  SUM(Dollars) AS TotalDollars,
  AVG(Dollars) AS AvgDollars,
  MIN(Dollars) AS MinDollars,
  MAX(Dollars) AS MaxDollars,
  SUM(Freight) AS TotalFreight,
  AVG(Freight) AS AvgFreight,
  MIN(Freight) AS MinFreight,
  MAX(Freight) AS MaxFreight
FROM VendorInvoicesDec;

---------------------------------------------------------------------------------------------------
-- SECTION 3: CROSS-TABLE CONSISTENCY CHECKS
---------------------------------------------------------------------------------------------------

-- This section focuses on verifying the consistency of vendor data across different tables,
-- which is crucial for maintaining data integrity in a relational database.

/* a. Find Vendors in PurchasesDec but not in SalesDec */
SELECT VendorNumber
FROM PurchasesDec
WHERE VendorNumber NOT IN (SELECT VendorNo FROM SalesDec)
GROUP BY VendorNumber;

/* b. Find vendors present in SalesDec but not in PurchasesDec */
SELECT VendorNo
FROM SalesDec
WHERE VendorNo NOT IN (SELECT VendorNumber FROM PurchasesDec)
GROUP BY VendorNo;

---------------------------------------------------------------------------------------------------
-- SECTION 4: PURCHASE VS. INVOICE RECONCILIATION
---------------------------------------------------------------------------------------------------
-- This section is vital for financial auditing, comparing the recorded purchase dollars with
-- the corresponding invoice amounts to detect discrepancies.

/* Reconcile purchase dollars from PurchasesDec with invoice dollars from VendorInvoicesDec 
   based on VendorNumber and PONumber */
SELECT
  p.VendorNumber,
  p.PONumber,
  p.VendorName,
  SUM(p.Dollars) AS TotalPurchaseDollars,
  i.Dollars AS InvoiceDollars ,
  ROUND(SUM(p.Dollars) - i.Dollars, 2) AS Difference
FROM
  PurchasesDec p
JOIN
  VendorInvoicesDec i
ON
  p.VendorNumber = i.VendorNumber
  AND p.PONumber = i.PONumber
GROUP BY
  p.VendorNumber,
  p.PONumber,
  p.VendorName,
  i.Dollars
ORDER BY
  p.VendorNumber,
  p.PONumber;