# Bibitor, LLC – Liquor Sales & Inventory Analysis

This case study analyzes sales, purchases, inventory, and vendor invoice data for Bibitor, LLC — a fictional liquor store chain with ~80 locations and over $450M in annual sales. The goal is to perform due diligence on the wine and spirits business over a 12-month period, focusing on December 2016.

**Dataset Source:** HUB of Analytics Education – [www.hubae.org](https://www.hubae.org)
**Fictional Setting:** Lincoln, USA

---

## 📊 Datasets Overview

- **Inventory**
  - `BegInvDec`: Inventory at the start of December 2016.
  - `EndInvDec`: Inventory remaining at the end of December 2016.

- **Purchases**
  - `PurchasesDec`: What Bibitor bought from vendors (quantities, total cost, vendor info).
  - `PricingPurchasesDec`: Reference prices Bibitor expects from suppliers.

- **Vendor Invoices**
  - `VendorInvoicesDec`: The bills Bibitor received from their suppliers (vendors), include:
    - Who sent the bill (`VendorNumber`, `VendorName`).
    - When the bill was issued (`InvoiceDate`).
    - Details about the order (`PONumber`, `PODate`).
    - When they paid the bill (`PayDate`).
    - How many items were on the bill (`Quantity`).
    - The total amount of money on the bill (`Dollars`).
    - Any extra charges like `Freight` (shipping).
    - If the bill was approved (`Approval`).

- **Sales**
  - `SalesDec`: Item-level sales data including price, quantity, and total revenue.

---

## 🎯 Key Analysis Goals

- Identify top vendors by purchase volume and sales performance
- Analyze profit margins between purchase and sale prices
- Track inventory changes and movement across stores
- Evaluate vendor reliability and invoice patterns

---

## 📜 SQL Analysis Scripts

This repository contains the following SQL scripts designed to achieve the analysis goals:

### 1. `Initial Analysis.sql`
This script focuses on **data validation and basic summaries**. It's crucial for understanding the raw data and identifying potential quality issues. Key functions include:
* **Checking for Zero, Missing, and Inconsistent Entries**: Identifying records with zero or null values in critical financial columns (e.g., `Dollars`, `SalesDollars`, `Price`) and discrepancies where calculated totals don't match recorded ones (e.g., `Dollars` vs. `PurchasePrice * Quantity`).
* **Calculating Percentage of Zero or Null Entries**: Providing a high-level view of data completeness.
* **Generating Basic Summaries**: Offering aggregate statistics (sum, average, min, max) and date range insights for key tables (`PurchasesDec`, `SalesDec`, `VendorInvoicesDec`) to quickly grasp data scope and characteristics.
* **Performing Cross-Table Consistency Checks**: Verifying vendor consistency between `PurchasesDec` and `SalesDec` to ensure data integrity.

### 2. `Vendor Analysis.sql`
This script dives deep into **vendor performance and relationships**. It helps in strategic decision-making related to supplier management. Its capabilities include:
* **Listing All Vendors**: Providing a comprehensive list of unique vendors from both purchase and invoice records.
* **Aggregating Vendor Activities**: Summarizing total purchase orders, quantities, dollars, invoices, and freight costs for each vendor.
* **Identifying Top Vendors by Key Metrics**: Ranking vendors based on total spending, sales generated from their products, quantity purchased, and total freight costs.
* **Analyzing Freight as a Percentage of Purchase Cost**: Highlighting vendors with potentially high shipping overheads.
* **Tracking Monthly Trends**: Summarizing purchases and sales on a monthly basis to identify seasonality and trends.
* **Calculating Gross Margin by Vendor**: Determining the profitability contribution of each vendor by comparing total purchase costs to total sales revenue.

### 3. `Inventory Analysis.sql`
This script focuses on **inventory turnover and identifying slow-moving items**. It's essential for optimizing inventory levels and reducing carrying costs. This script:
* **Creates the `InventorySaleLag` Table**: A dedicated table is generated to store calculated inventory movement data. For each unique item at each store, it records the first received date, first sold date, average purchase and sales prices, and total quantities.
* **Calculates "Days to Sell"**: Determines the duration (in days) an inventory item sits from its first receipt to its first sale.
* **Identifies Slow-Moving Inventory**: Pinpoints items that exceed a predefined threshold (e.g., 60 days) between being received and sold, providing a clear list of potential problem areas for inventory management.

---

This case offers practical insights into retail operations, inventory control, and vendor performance — a comprehensive exercise in data-driven business decision-making.
