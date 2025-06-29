# Jupyter Notebooks for Data Analytics

This folder contains various Jupyter Notebooks focused on data analytics, spanning multiple domains like e-commerce, sales, customer behavior, etc. Each notebook performs analysis on different datasets, uncovering key insights that can help drive business decisions and understand patterns in the data.

## 📊 #01. E-Commerce Sales Analytics
**Dataset:** [E-Commerce Data - Kaggle](https://www.kaggle.com/datasets/carrie1/ecommerce-data/data)

This notebook performs an in-depth analysis of sales data from an online retailer. The analysis identifies trends in product sales, evaluates revenue across different periods, and analyzes customer behavior based on country and transaction history. Visualizations and charts highlight key insights like the top-selling products and monthly sales performance, providing a clear picture of the retailer's performance over time.

---

## 📊 #02. Amazon Sales Analytics
**Dataset:** [Amazon Sales Dataset - Kaggle](https://www.kaggle.com/datasets/karkavelrajaj/amazon-sales-dataset)

In this notebook, we analyze over 1,000 Amazon products, looking at how product pricing, ratings, and reviews affect overall sales performance. Key insights include understanding how product reviews and ratings impact consumer behavior and how discounts influence sales. The notebook provides a breakdown of product performance and explores customer behavior by analyzing rating counts and review content.

---

## 📊 #03. COVID-19 Global Cases Insights
**Dataset:** [Novel Corona Virus 2019 Dataset](https://www.kaggle.com/datasets/sudalairajkumar/novel-corona-virus-2019-dataset/data)

This notebook examines global COVID-19 data to explore trends in confirmed cases, deaths, and recoveries across different countries. The analysis includes time series visualizations, comparisons of country-specific statistics, and key metrics like mortality and recovery rates. Key findings help in understanding the global impact of COVID-19 and identifying the worst-affected regions.

---

## 📊 #04. COVID-19 Patient Analysis
**Dataset:** [COVID-19 Dataset](https://www.kaggle.com/datasets/meirnizri/covid19-dataset/data)

This notebook analyzes COVID-19 patient data, focusing on demographic, health condition, and treatment factors. It examines patient distribution across medical units, survival analysis based on various conditions, and the effects of treatments and comorbidities on survival rates. Visualizations include heatmaps, bar charts, and survival comparisons, providing insights into the impact of treatments, age, gender, and other factors on patient outcomes.

---

## 📊  #05. Mobile App Marketing & Conversion Analysis

**🔗 Dataset:** Internal App Usage & Campaign Data (2020 - 2025)  
**📈 Looker Studio Dashboards:** [View Here](https://lookerstudio.google.com/reporting/8959b791-5c18-4a12-8986-2f58b882b980)  
**📝 Case Study Blog:** [Read Here](https://dtbkhanh.github.io/2025/04/21/mobile-app-marketing-conversion-analysis.html)  

This notebook analyzes user behavior, marketing channel performance, and conversion trends for a mobile application targeting self-employed professionals. The dataset covers user acquisition, campaign types, regional engagement, and subscription patterns.

---

## 📊  #06. Business Type Classifier

This case study demonstrates an approach to **classifying and standardizing legal business form entries** using a combination of:
- Exact and fuzzy matching techniques
- Dictionary-based standardization
- Data validation and manual review support

### 🔗 Dataset:  
Sample data extracted from public business registries 

### 💡 Goal  
To clean and classify a column of messy "Legal Form" values from a business registry dataset, mapping them to standardized business types like `GmbH`, `UG`, or `AG`.

### 🛠️ Key Steps  
- ✅ **Standardization**: Normalized cases, whitespace, and known suffix/prefix patterns.
- 🔍 **Partial Matching**: Used a supplemental dictionary for typos and known variants.
- ❌ **Unmatched Entries**: Flagged for further review or enrichment (e.g., foreign or hybrid forms).
- 📊 **Summary Tables**: Outputs grouped by match status for quick review.

### 🧩 Notes  
- This version omits proprietary or company-specific content.
- The matching dictionary is designed to be extensible as new forms appear.
