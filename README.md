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

   