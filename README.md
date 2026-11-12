<div align="center">
  <img src="06_assets/banner.png" alt="Project Banner" width="100%">
</div>

### 📌 Project Overview

In this project, I take on the role of a Data Engineer at Olist, a Brazilian e-commerce marketplace. My assignment is to design and build an end-to-end data warehouse that consolidates the company's e-commerce data into a centralised environment.

The project uses nine raw CSV datasets covering customers, sellers, products, orders, payments, deliveries and customer reviews. The objective is to create a reliable data foundation that enables consistent reporting, business analysis and informed decision-making.

### 🏢 Business Context

Olist is a Brazilian online marketplace that connects small businesses with customers. Sellers list their products on the platform, customers place orders, and sellers fulfil those orders through delivery partners.

This business model is easy to relate to in South Africa. Platforms such as Takealot and Mr D operate in familiar e-commerce spaces where customers place orders, businesses fulfil them, deliveries take place and customers share feedback about their experiences.

Every transaction generates valuable information about customer behaviour, seller performance, product sales, payments, delivery operations and customer satisfaction. Bringing this information together provides an opportunity to generate meaningful business insights.

### ⚠️ Business Problem

Olist has nine raw CSV extracts covering approximately 100,000 orders between 2016 and 2018, but no centralised data warehouse.

As a result, business information is distributed across multiple datasets, making it difficult to obtain a consistent view of revenue, product performance, delivery efficiency and customer satisfaction.

My responsibility is to address this challenge by developing a centralised data warehouse that integrates the datasets, improves data quality and provides a trusted foundation for business reporting and decision-making.

### 🎯 Project Requirements & Technical Approach

As the Data Engineer assigned to this project, I received technical guidance from my Senior Data Engineer outlining the architecture, technologies and requirements for delivering the solution.

The project follows the **Medallion Architecture (Bronze → Silver → Gold)** using SQL Server, SQL Server Management Studio (SSMS), SQL Server Integration Services (SSIS) and Power BI.

- **Infrastructure:** Establish databases, schemas, tables and ETL logging structures.
- **Bronze Layer – Raw:** Ingest the nine CSV datasets into SQL Server while preserving original source values and capturing ingestion metadata, batch information and load statistics.
- **Silver Layer – Cleansed:** Apply data type conversions, standardisation, deduplication, aggregations and data quality handling to produce reliable datasets.
- **Gold Layer – Business Ready:** Build a Star Schema with fact and dimension tables, surrogate keys and customer history tracking using Slowly Changing Dimension (SCD Type 2).
- **SSIS Orchestration:** Develop a master package to coordinate ETL execution, manage configurations and maintain batch logs, load audits and error records.
- **Data Quality & Analytics:** Implement SQL validation tests, develop business analytics queries using the Gold layer and build a Power BI dashboard to communicate business insights.

The objective is to deliver a reliable, auditable and business-ready data warehouse that transforms raw e-commerce data into meaningful business insights.

**📖 Detailed Technical Requirements:** [View Original Project Brief](https://github.com/KetroSithole/brightlearn_olist_dwh_2026/tree/main)


