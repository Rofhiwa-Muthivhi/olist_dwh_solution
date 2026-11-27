<div align="center">
  <img src="06_assets/banner.png" alt="Project Banner" width="100%">
</div>


## 📌 1. Project Overview

In this project, I take on the role of a Data Engineer at Olist, a Brazilian e-commerce marketplace. My assignment is to design and build an end-to-end data warehouse that brings the company's e-commerce data together into a centralised environment.

The project uses nine raw CSV datasets covering different areas of the business, including customers, sellers, products, orders, payments, order items, customer reviews, geographical locations and product category translations.

Using SQL Server and SQL Server Integration Services (SSIS), I build an ETL pipeline based on the Medallion Architecture (Bronze → Silver → Gold). The process involves loading the raw datasets into SQL Server, cleaning and transforming the data, and preparing it for analytical purposes through a Star Schema.

The overall goal is to create a reliable data warehouse that brings the different areas of the business together, improves data quality and makes it easier to analyse business performance and generate meaningful insights.

## 🏢 2. Business Context

Olist is a Brazilian online marketplace that connects small businesses with customers. Sellers list their products on the platform, customers place orders, and sellers fulfil those orders through delivery partners.

This business model is easy to relate to in South Africa. Platforms such as Takealot operate in a similar e-commerce environment where customers place orders, businesses fulfil them, deliveries take place and customers share feedback about their experiences.

Every transaction within this marketplace generates valuable information about customers, sellers, products, orders, payments, deliveries and customer satisfaction.

This information is important because it helps the business understand how different areas of its operations are performing. For example, management needs to understand which products generate the most revenue, how sellers are performing, whether orders are being delivered on time and how customers feel about their shopping experiences.

Bringing these different sources of information together creates an opportunity to get a better understanding of the business as a whole and support informed decision-making.

## ⚠️ 3. Business Problem

Olist generates a large amount of transactional data through its e-commerce operations between 2016 and 2018. However, turning this information into meaningful business insights presents several challenges.

The information is spread across nine different datasets, with each dataset representing a particular area of the business. Analysing these datasets independently makes it difficult to get a complete picture of what is happening across the marketplace.

There are also data quality challenges, including inconsistent formats, duplicate records and differences in how information is stored. These issues make it difficult to bring the data together and use it confidently for reporting and analysis.

As a result, management faces challenges in understanding important areas of business performance, such as:

- Revenue and overall sales performance.
- Customer purchasing behaviour and repeat purchases.
- Product and seller performance.
- Payment trends and customer payment preferences.
- Delivery performance and late deliveries.
- Customer satisfaction and product reviews.

The challenge, therefore, is to bring these different datasets together, address the data quality issues and develop a centralised data warehouse that can provide reliable information for business analysis and reporting.

## 🏗️ 4. Solution Architecture

My solution uses a Master Package to manage and control the execution of the entire Olist Data Warehouse ETL process. It starts by preparing the databases and schemas, setting up the audit tables and generating a batch ID to keep track of each ETL execution.

Once these steps are completed, the Master Package will execute the individual SSIS packages in sequence: Bronze, Silver, Gold Dimensions and finally Gold Facts. Each layer has its own package, which means I can run and test each stage independently while still having the ability to execute the entire ETL process from one central point.

The diagram below illustrates the overall ETL architecture and how data moves through the different layers.

```mermaid
%%{init: {
    "theme": "base",
    "themeVariables": {
        "fontFamily": "Arial, sans-serif",
        "fontSize": "17px",
        "lineColor": "#455A4E",
        "lineWidth": "2px"
    },
    "flowchart": {
        "nodeSpacing": 65,
        "rankSpacing": 85,
        "curve": "basis",
        "padding": 20
    }
}}%%

flowchart LR

    SRC[("OLIST SOURCE DATA<br/>9 CSV DATASETS")]

    MASTER["00_master.dtsx<br/>MASTER PACKAGE<br/>CENTRAL ETL ORCHESTRATION"]

    subgraph INITIALISE["MASTER PACKAGE | INITIALISATION"]
        direction TB
        A["01 | Prepare Databases"]
        B["02 | Create Schemas"]
        C["03 | Create Audit Tables"]
        D["04 | Generate Batch ID"]
        A --> B --> C --> D
    end

    subgraph BRONZE["01 | BRONZE LAYER"]
        direction TB
        BP["01_bronze_load.dtsx<br/>BRONZE LOAD PACKAGE"]
        BDB[("olist_stg<br/>RAW DATA TABLES")]
        BP --> BDB
    end

    subgraph SILVER["02 | SILVER LAYER"]
        direction TB
        SP["02_silver_transform.dtsx<br/>SILVER TRANSFORMATION"]
        SDB[("olist_dwh<br/>CLEANSED DATA TABLES")]
        SP --> SDB
    end

    subgraph GOLD["03 | GOLD LAYER"]
        direction TB
        DP["03_gold_dimensions.dtsx<br/>DIMENSION PACKAGE"]
        FP["04_gold_facts.dtsx<br/>FACT PACKAGE"]
        GDB[("olist_dwh<br/>GOLD STAR SCHEMA")]
        DP --> FP --> GDB
    end

    AUDIT[("CENTRAL ETL AUDIT TABLES<br/>BATCH LOG | LOAD LOG | ERROR ROWS")]

    END["ANALYTICAL<br/>REPORTING"]

    MASTER --> INITIALISE
    D --> BP

    SRC --> BP
    BDB --> SP
    SDB --> DP
    GDB --> END

    MASTER -.-> AUDIT
    BP -.-> AUDIT
    SP -.-> AUDIT
    DP -.-> AUDIT
    FP -.-> AUDIT

    classDef master fill:#244638,stroke:#10271D,color:#FFFFFF,stroke-width:5px,font-size:19px,font-weight:bold;
    classDef setup fill:#536D60,stroke:#304A3B,color:#FFFFFF,stroke-width:3px,font-size:16px,font-weight:bold;
    classDef bronze fill:#B18459,stroke:#805B38,color:#FFFFFF,stroke-width:3px,font-size:16px,font-weight:bold;
    classDef bronzeDB fill:#795638,stroke:#563B26,color:#FFFFFF,stroke-width:4px,font-size:16px,font-weight:bold;
    classDef silver fill:#C2C7CC,stroke:#737D86,color:#263238,stroke-width:3px,font-size:16px,font-weight:bold;
    classDef silverDB fill:#7D8993,stroke:#59656E,color:#FFFFFF,stroke-width:4px,font-size:16px,font-weight:bold;
    classDef gold fill:#C6A85F,stroke:#947B3D,color:#302716,stroke-width:3px,font-size:16px,font-weight:bold;
    classDef goldDB fill:#92763C,stroke:#675126,color:#FFFFFF,stroke-width:4px,font-size:16px,font-weight:bold;
    classDef source fill:#344D40,stroke:#1D362A,color:#FFFFFF,stroke-width:4px,font-size:16px,font-weight:bold;
    classDef audit fill:#536D60,stroke:#304A3B,color:#FFFFFF,stroke-width:4px,font-size:16px,font-weight:bold;
    classDef finish fill:#244638,stroke:#142D24,color:#FFFFFF,stroke-width:4px,font-size:17px,font-weight:bold;

    class MASTER master;
    class A,B,C,D setup;
    class BP bronze;
    class BDB bronzeDB;
    class SP silver;
    class SDB silverDB;
    class DP,FP gold;
    class GDB goldDB;
    class SRC source;
    class AUDIT audit;
    class END finish;

    style INITIALISE fill:#DCE9DF,stroke:#536D60,stroke-width:3px,color:#244638
    style BRONZE fill:#F4EDE4,stroke:#B18459,stroke-width:3px,color:#694A2D
    style SILVER fill:#E4E8EB,stroke:#858D95,stroke-width:3px,color:#45515B
    style GOLD fill:#F5F0E1,stroke:#C6A85F,stroke-width:3px,color:#75602D

    linkStyle default stroke:#536D60,stroke-width:2.5px
```


#### 4.1 Bronze Layer 

I use the Bronze layer to load the nine original Olist CSV datasets into SQL Server. The 01_bronze_load.dtsx package manages the ingestion process, adds loading metadata and stores the raw records in the olist_stg database.
```mermaid
flowchart LR

    subgraph SOURCE["SOURCE DATA"]
        direction TB
        CSV[("OLIST SOURCE DATA<br/>9 CSV DATASETS")]
    end

    subgraph BRONZE["01 | BRONZE LAYER"]
        direction TB

        PKG["01_bronze_load.dtsx<br/>BRONZE LOAD PACKAGE"]

        FLAT["Flat File Source"]

        DERIVED["Derived Column<br/>LOAD TIMESTAMP | SOURCE FILE | BATCH ID"]

        BDB[("olist_stg<br/>RAW DATA TABLES")]

        PKG --> FLAT --> DERIVED --> BDB
    end

    CSV --> PKG

    classDef bronze fill:#B18459,stroke:#805B38,color:#FFFFFF,stroke-width:2px;
    classDef bronzeDB fill:#795638,stroke:#563B26,color:#FFFFFF,stroke-width:2px;
    classDef source fill:#344D40,stroke:#1D362A,color:#FFFFFF,stroke-width:2px;

    class PKG,FLAT,DERIVED bronze;
    class BDB bronzeDB;
    class CSV source;

    style SOURCE fill:#E6EEE8,stroke:#536D60,stroke-width:2px,color:#244638
    style BRONZE fill:#F4EDE4,stroke:#B18459,stroke-width:2px,color:#694A2D
```


#### 4.2 Silver Layer 
I use the Silver layer to clean and standardise the data loaded into Bronze. The 02_silver_transform.dtsx package uses SQL preparation views and SSIS transformations to prepare the records before loading them into the silver schema in olist_dwh. Invalid records are handled through the configured error-handling process.
```mermaid
flowchart LR

    subgraph BRONZE["01 | BRONZE LAYER"]
        direction TB
        BDB[("olist_stg<br/>RAW DATA TABLES")]
    end

    subgraph SILVER["02 | SILVER LAYER"]
        direction TB

        SP["02_silver_transform.dtsx<br/>SILVER TRANSFORMATION PACKAGE"]

        VIEWS["SQL PREPARATION VIEWS"]

        TRANSFORM["SSIS TRANSFORMATIONS<br/>DATA CONVERSION | DERIVED COLUMN | CONDITIONAL SPLIT"]

        SDB[("olist_dwh<br/>CLEANSED DATA TABLES")]

        SP --> VIEWS --> TRANSFORM
        TRANSFORM -->|"VALID RECORDS"| SDB
    end

    ERROR[("etl.error_rows<br/>INVALID RECORDS")]

    BDB --> SP

    TRANSFORM -->|"INVALID RECORDS"| ERROR

    classDef bronze fill:#B18459,stroke:#805B38,color:#FFFFFF,stroke-width:2px;
    classDef bronzeDB fill:#795638,stroke:#563B26,color:#FFFFFF,stroke-width:2px;
    classDef silver fill:#C2C7CC,stroke:#858D95,color:#263238,stroke-width:2px;
    classDef silverDB fill:#7D8993,stroke:#59656E,color:#FFFFFF,stroke-width:2px;
    classDef audit fill:#536D60,stroke:#304A3B,color:#FFFFFF,stroke-width:2px;

    class BDB bronzeDB;
    class SP,VIEWS,TRANSFORM silver;
    class SDB silverDB;
    class ERROR audit;

    style BRONZE fill:#F4EDE4,stroke:#B18459,stroke-width:2px,color:#694A2D
    style SILVER fill:#EEF0F2,stroke:#A6ADB4,stroke-width:2px,color:#45515B
```