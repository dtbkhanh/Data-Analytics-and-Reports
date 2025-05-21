# Bibitor, LLC – Liquor Sales & Inventory Analysis

This case study analyzes sales, purchases, inventory, and vendor invoice data for Bibitor, LLC — a fictional liquor store chain with ~80 locations and over $450M in annual sales. The goal is to perform due diligence on the wine and spirits business over a 12-month period, focusing on December 2016.

**Dataset Source:** HUB of Analytics Education – [www.hubae.org](https://www.hubae.org)  
**Fictional Setting:** Lincoln, USA

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

## 🎯 Key Analysis Goals

- Identify top vendors by purchase volume and sales performance  
- Analyze profit margins between purchase and sale prices  
- Track inventory changes and movement across stores  
- Evaluate vendor reliability and invoice patterns

---

This case offers practical insights into retail operations, inventory control, and vendor performance — a comprehensive exercise in data-driven business decision-making.
