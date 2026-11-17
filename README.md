<div align="center">
  <img src="06_assets/banner.png" alt="Project Banner" width="100%">
</div>

### 📌 Project Overview

In this project, I take on the role of a Data Engineer at Olist, a Brazilian e-commerce marketplace. My assignment is to design and build an end-to-end data warehouse that consolidates the company's e-commerce data into a centralised environment.

The project uses nine raw CSV datasets covering different areas of the business, including customers, sellers, products, orders, payments, order items, customer reviews, geographical locations and product category translations.


### 🏢 Business Context

Olist is a Brazilian online marketplace that connects small businesses with customers. Sellers list their products on the platform, customers place orders, and sellers fulfil those orders through delivery partners.

This business model is easy to relate to in South Africa. Platforms such as Takealot operate in a similar e-commerce environment where customers place orders, businesses fulfil them, deliveries take place and customers share feedback about their experiences.

Every transaction generates valuable information about customer behaviour, seller performance, product sales, payments, delivery operations and customer satisfaction.

This information is important to the business because it helps management understand how different areas of the marketplace are performing. Bringing these different sources of information together creates an opportunity to generate meaningful business insights and support better decision-making.

### ⚠️ Business Problem

Olist sits on a large amount of transactional data generated between 2016 and 2018. However, turning this data into meaningful business information presents several challenges.

Business information is spread across different datasets, making it difficult to get a complete view of business performance. Data quality issues, inconsistent formats and the lack of a centralised analytical environment further complicate reporting and analysis.

As a result, management faces challenges in understanding revenue, customer behaviour, seller performance, product sales, delivery efficiency and customer satisfaction.


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


### 🧩 Architecture Overview

```mermaid
flowchart LR
    A["📁 Olist Source Data<br/>9 CSV Files"]:::source

    subgraph BR["🥉 BRONZE LAYER<br/>olist_stg.bronze"]
        direction TB
        B[("Raw Tables<br/>Original Source Data<br/>Load Metadata")]
    end

    subgraph SL["🥈 SILVER LAYER<br/>olist_dwh.silver"]
        direction TB
        S[("Cleansed & Standardised<br/>Tables")]
        E[("etl.error_rows<br/>Invalid Records")]
    end

    subgraph GL["🥇 GOLD LAYER<br/>olist_dwh.gold"]
        direction TB
        G[("Business-Ready Star Schema<br/>Fact Tables & Dimension Tables")]
    end

    P["📊 Power BI<br/>Reporting & Analysis"]:::powerbi

    A --> B
    B --> S
    S --> G
    S -.-> E
    G --> P

    classDef source fill:#263B5E,stroke:#6488B8,color:#FFFFFF,stroke-width:2px
    classDef bronze fill:#75451F,stroke:#C18A50,color:#FFFFFF,stroke-width:2px
    classDef silver fill:#465569,stroke:#91A3B8,color:#FFFFFF,stroke-width:2px
    classDef gold fill:#765B18,stroke:#D5AD46,color:#FFFFFF,stroke-width:2px
    classDef powerbi fill:#145B46,stroke:#36A77F,color:#FFFFFF,stroke-width:2px

    class A source
    class B bronze
    class S,E silver
    class G gold
    class P powerbi

    style BR fill:#75451F12,stroke:#B8793D,stroke-width:2px
    style SL fill:#46556912,stroke:#8293A8,stroke-width:2px
    style GL fill:#765B1812,stroke:#C49B38,stroke-width:2px
```


### 🥉 Bronze Data Ingestion (`01_bronze_load.dtsx`)

```mermaid
flowchart LR

    A["📁 9 Source CSV Files"]:::source

    B["Flat File Source<br/>Read CSV Records"]:::bronze

    C["Derived Column<br/>Add Load Metadata"]:::transform

    D[("OLE DB Destination<br/>olist_stg.bronze<br/>9 Bronze Tables")]:::destination

    A --> B --> C --> D

    classDef source fill:#263B5E,stroke:#6488B8,color:#FFFFFF,stroke-width:2px
    classDef bronze fill:#75451F,stroke:#C18A50,color:#FFFFFF,stroke-width:2px
    classDef transform fill:#465569,stroke:#91A3B8,color:#FFFFFF,stroke-width:2px
    classDef destination fill:#75451F,stroke:#C18A50,color:#FFFFFF,stroke-width:2px
```


### 🥈 Silver Data Transformation (`02_silver_transform.dtsx`)

```mermaid
flowchart LR

    A[("🥉 Bronze Tables<br/>olist_stg.bronze")]:::bronze

    B["Execute SQL Task<br/>Create or Update Prepared Views"]:::silver

    C["OLE DB Source<br/>Read Prepared Records"]:::silver

    D["Transformations<br/>Data Cleaning, Standardisation<br/>& Type Conversions"]:::transform

    E[("🥈 Silver Tables<br/>olist_dwh.silver")]:::destination

    F[("etl.error_rows<br/>Invalid Records")]:::error

    A --> B --> C --> D
    D -->|"Valid Records"| E
    D -.->|"Invalid Records"| F

    classDef bronze fill:#75451F,stroke:#C18A50,color:#FFFFFF,stroke-width:2px
    classDef silver fill:#465569,stroke:#91A3B8,color:#FFFFFF,stroke-width:2px
    classDef transform fill:#354B63,stroke:#6386A8,color:#FFFFFF,stroke-width:2px
    classDef destination fill:#465569,stroke:#91A3B8,color:#FFFFFF,stroke-width:2px
    classDef error fill:#762F35,stroke:#C65C64,color:#FFFFFF,stroke-width:2px
```