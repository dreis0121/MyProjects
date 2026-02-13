
USE ROLE ACCOUNTADMIN;

USE WAREHOUSE compute_wh;

--USE SCHEMA employee_data.raw_data


-- Create table EMPLOYEE_RAW in RAW_DATA schema

CREATE OR REPLACE TABLE employee_data.raw_data.employee_raw
(
  EMPLOYEE_ID STRING,
  FIRST_NAME STRING,
  LAST_NAME STRING,
  DEPARTMENT STRING,
  SALARY DECIMAL(10,2),
  HIRE_DATE DATE,
  LOCATION STRING
);

-- Create Transformed Table in 'transformed_data schema'
CREATE OR REPLACE TABLE employee_data.transformed_data.employee_transformed
(
EMPLOYEE_ID STRING,
FULL_NAME STRING,
DEPARTMENT STRING,
ANNUAL_SALARY DECIMAL(10, 2),
HIRE_DATE DATE,
EXPERIENCE_LEVEL STRING,
TENURE_DAYS STRING,
STATE STRING,
COUNTRY STRING,
BONUS_ELIGIBILITY STRING,
HIGH_POTENTIAL_FLAG STRING
);

-- Create an internal stage

USE ROLE ACCOUNTADMIN;

USE WAREHOUSE compute_wh;

USE SCHEMA employee_data.raw_data;

CREATE OR REPLACE STAGE EMPLOYEE_STAGE;

LIST @EMPLOYEE_STAGE;

COPY INTO EMPLOYEE_RAW
FROM @EMPLOYEE_STAGE
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1);

-- SELECT * from employee_raw;

SELECT
  employee_id,
  CONCAT(first_name,' ',last_name) AS Full_name,
  department,
  SALARY*12 AS Anuual_Salary,
  hire_date,
  CASE WHEN TIMESTAMPDIFF(day,hire_date,'2025-01-01') < 365 THEN 'New Hire'
       WHEN TIMESTAMPDIFF(day,hire_date,'2025-01-01') < (365*5) OR TIMESTAMPDIFF(year,hire_date,'2025-01-01') >= 365 THEN 'Mid-level'
       WHEN TIMESTAMPDIFF(day,hire_date, '2025-01-01') > (365*5) THEN 'Senior'
      END AS Experience_Level,
  TIMESTAMPDIFF(day,hire_date,'2025-01-01') AS Tenure_Days,
  SUBSTR(location,1, POSITION('-', location) -1) AS state,
  SUBSTR(location, POSITION( '-', location) +1) AS country,
  CASE WHEN salary > 10000 THEN 'YES' ELSE 'NO' END AS bonus_eligibility,
  CASE WHEN TIMESTAMPDIFF(day, hire_date, '2025-01-01') > (365*3) THEN 'YES' ELSE 'NO' END AS High_potential_flag
FROM employee_raw;

  
USE ROLE ACCOUNTADMIN;

USE WAREHOUSE compute_wh;

USE SCHEMA employee_data.transformed_data;

CREATE OR REPLACE STAGE Employee_Stage_Transformed;

LIST @employee_stage_transformed;

COPY INTO EMPLOYEE_TRANSFORMED
FROM @employee_stage_transformed
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1);

SELECT * FROM employee_transformed;

-- employee count by department
SELECT 
  department,
  COUNT(employee_id) AS employee_count
FROM employee_transformed
GROUP BY department;

-- count of employees by country
SELECT
  country,
  COUNT(employee_id) AS employee_count
FROM employee_transformed
GROUP BY country;

-- employees who were hired within 12 months
SELECT
  full_name,
  hire_date
FROM employee_transformed
WHERE hire_date >= DATEADD(month, -12, '2025-01-01');

--extract top 10% of employees by salary
WITH PercentRank AS (
SELECT
  employee_id,
  full_name,
  annual_salary,
  PERCENT_RANK() OVER(ORDER BY annual_salary DESC) as pr
FROM employee_transformed
--GROUP BY employee_id
)


SELECT
  employee_id,
  full_name,
  annual_salary
FROM PercentRank
WHERE pr <=0.10
ORDER BY annual_salary DESC;

-- Calculate total salary expense per department for each year
SELECT
  department,
  YEAR(hire_date) AS year,
  SUM(annual_salary) as total_salary
FROM employee_transformed
GROUP BY department, YEAR(hire_date)
ORDER BY 3 DESC;

--Determine how many employees with 5+ years with company
SELECT
  COUNT(employee_id) AS employee_count
FROM employee_transformed
WHERE experience_level = 'Senior' ;
--GROUP BY full_name;