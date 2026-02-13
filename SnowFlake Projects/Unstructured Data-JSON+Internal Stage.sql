USE ROLE ACCOUNTADMIN;

USE WAREHOUSE compute_wh;

CREATE OR REPLACE DATABASE CUSTOMER_DATA;

CREATE OR REPLACE SCHEMA RAW_DATA;

USE DATABASE customer_data;
USE SCHEMA RAW_data;
CREATE OR REPLACE TABLE customer_data.raw_data.customer_raw
(
    json_data variant
);

CREATE OR REPLACE SCHEMA FLATTEN_DATA;

CREATE OR REPLACE TABLE customer_data.flatten_data.customer_flatten
(
CUSTOMERID INT,
NAME STRING,
EMAIL STRING,
REGION STRING,
COUNTRY STRING,
PRODUCTNAME STRING,
PRODUCTBRAND STRING,
CATEGORY STRING,
QUANTITY INT,
PRICEPERUNIT FLOAT,
TOTALSALES FLOAT,
PURCHASEMODE STRING,
MODEOFPAYMENT STRING,
PURCHASEDATE DATE
);

USE SCHEMA raw_data;

CREATE OR REPLACE STAGE customer_stage;

LIST @customer_stage;

COPY INTO customer_raw
FROM @customer_stage
FILE_FORMAT = (TYPE='json');

INSERT INTO customer_data.flatten_data.customer_flatten
SELECT
tmp.value:customerid::integer AS customerid,
tmp.value:name::string as name,
tmp.value:email::string as email,
tmp.value:region::string as region,
tmp.value:country::string as country,
tmp.value:productname::string as productname,
tmp.value:productbrand::string as productbrand,
tmp.value:category::string as category,
tmp.value:quantity::integer as quantity,
tmp.value:priceperunit::float as priceperunit,
tmp.value:totalsales::float as totalsales,
tmp.value:purchasemode::string as purchasemode,
tmp.value:modeofpayment::string as modeofpayment,
tmp.value:purchasedate::date as purchasedate
FROM customer_raw,
lateral flatten(input=>json_data) as tmp;

LIST @customer_stage;

USE schema flatten_data;

SELECT
  region,
  SUM(totalsales) as total_sales
FROM customer_flatten
GROUP BY region
ORDER BY 2 DESC
LIMIT 1;


SELECT
  productbrand,
  SUM(quantity) AS total_quantity_sold
FROM customer_flatten
GROUP BY 1
ORDER BY 2 
LIMIT 1


  

