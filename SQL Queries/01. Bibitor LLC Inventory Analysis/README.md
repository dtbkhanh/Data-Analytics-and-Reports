# Bibitor, LLC – Liquor Sales & Inventory Analysis

This case study analyzes sales, purchases, inventory, and vendor invoice data for Bibitor, LLC — a fictional liquor store chain with ~80 locations and over $450M in annual sales. The goal is to perform due diligence on the wine and spirits business over a 12-month period, focusing on December 2016.

- **Dataset Source:** HUB of Analytics Education – [www.hubae.org](https://www.hubae.org)  
- **Fictional Setting:** Lincoln, USA

---

## 📊 Datasets Overview

- **Inventory**
  - `BegInvDec`: Inventory at the start of December 2016.
  - `EndInvDec`: Inventory remaining at the end of December 2016.

- **Purchases**
  - `PurchasesDec`: What Bibitor bought from vendors (quantities, total cost, vendor info).
  - `PricingPurchasesDec`: Reference prices Bibitor expects from suppliers.

- **Vendor Invoices**
  - `VendorInvoicesDec`: The bills Bibitor received from their suppliers (vendors).

- **Sales**
  - `SalesDec`: Item-level sales data including price, quantity, and total revenue.

## 🧩 Data Model

![DataModel_Bibitor](https://github.com/user-attachments/assets/e6d86de2-2505-44a6-921b-5a1e1a37264e)

---

## 🎯 Key Analysis Goals

- Identify top vendors by purchase volume and sales performance
- Analyze profit margins between purchase and sale prices
- Track inventory changes and movement across stores
- Evaluate vendor reliability and invoice patterns

---

## 📜 SQL Analysis Scripts

This repository contains the following SQL scripts to support the analysis:

### 1. `Initial Analysis.sql`
This script performs **foundational data validation and basic summarization**. It identifies missing/zero values, checks for data inconsistencies, and provides high-level aggregate statistics across purchase, sales, and vendor invoice datasets.

### 2. `Vendor Analysis.sql`
This script focuses on **comprehensive vendor performance analysis**. It lists all vendors, summarizes their activities, identifies top vendors by spending, sales, quantity, and freight costs, and calculates gross margins to assess profitability.

### 3. `Inventory Turnover Analysis.sql`
This script analyzes **inventory turnover and identifies slow-moving inventory**. It calculates the "Days to Sell" for each item (time from receipt to sale) and flags items that exceed a specified sale lag threshold (e.g., over 60 days).

### 4. `Inventory MovingAvgCost.sql`
This script helps analyze inventory valuation by calculating the Moving Average Cost (MAC) of items, combining sales and purchase data with inventory balances. It supports better cost control and inventory management decisions.

---
## 📝 Case Study Blog
👉 [Read Here](https://dtbkhanh.github.io/2025/04/21/mobile-app-marketing-conversion-analysis.html)  

This case offers practical insights into retail operations, inventory control, and vendor performance — a comprehensive exercise in data-driven business decision-making.
