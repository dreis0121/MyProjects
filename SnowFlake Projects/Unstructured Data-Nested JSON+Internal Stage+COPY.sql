CREATE OR REPLACE database sales_data;
CREATE OR REPLACE SCHEMA raw_data;
CREATE OR replace schema flatten_data;

CREATE OR REPLACE TABLE sales_data.raw_data.sales_raw
(
json_data variant
);

CREATE OR REPLACE TABLE sales_data.flatten_data.sales_flatten
(
COMPANIES STRING,
SALES_PERIOD STRING,
TOTAL_REVENUE FLOAT,
TOTAL_UNITS_SOLD FLOAT,
REGIONS STRING,
TOTAL_SALES FLOAT,
PRODUCTS STRING,
UNITS_SOLD FLOAT,
REVENUE FLOAT
);

CREATE OR REPLACE STAGE sales_data.raw_data.sales_stage;

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE compute_wh;
USE DATABASE sales_data;
USE SCHEMA raw_data;

LIST @sales_stage;


COPY INTO sales_raw
FROM @sales_stage
FILE_FORMAT = (TYPE='json');

INSERT INTO sales_data.flatten_data.sales_flatten
SELECT
  companies.key::string as companies,
  companies.value:sales_period::string as sales_period,
  companies.value:total_revenue::float as total_revenue,
  companies.value:total_units_sold::float as total_units_sold,
  regions.key::string as regions,
  regions.value:total_sales::float as total_sales,
  products.key::string as products,
  products.value:revenue::float as revenue,
  products.value:units_sold::float as units_sold
  
FROM sales_raw,
lateral flatten(input=>json_data:companies) AS companies,
lateral flatten(input=>companies.value:regions) as regions,
lateral flatten(input=>regions.value:products) as products;

USE SCHEMA flatten_data;

SELECT * from sales_flatten;
  
  
