CREATE OR REPLACE DATABASE timetravel_db;
CREATE OR REPLACE SCHEMA timetravel_data;

USE DATABASE timetravel_db;
USE SCHEMA timetravel_data;

CREATE OR REPLACE TABLE EMPLOYEE
(
EMPLOYEE_ID STRING,
FIRST_NAME STRING,
LAST_NAME STRING,
DEPARTMENT STRING,
SALARY FLOAT,
HIRE_DATE DATE
);

INSERT INTO employee
VALUES
('E1', 'John', 'Doe', 'Finance', 75000.50, '2020-01-15'), 

('E2', 'Jane', 'Smith', 'HR', 68000.00, '2018-03-20'), 

('E3', 'Alice', 'Johnson', 'IT', 92000.75, '2019-07-10'),

 ('E4', 'Bob', 'Williams', 'Sales', 58000.25, '2021-06-01'), 

('E5', 'Charlie', 'Brown', 'Marketing', 72000.00, '2022-04-22'), 

('E6', 'Emily', 'Davis', 'IT', 89000.10, '2017-11-12'), 

('E7', 'Frank', 'Miller', 'Finance', 83000.30, '2016-09-05'), 

('E8', 'Grace', 'Taylor', 'Sales', 61000.45, '2023-02-11'),

 ('E9', 'Hannah', 'Moore', 'HR', 67000.80, '2020-05-18'), 

('E10', 'Jack', 'White', 'Marketing', 70000.90, '2019-12-25');

DELETE FROM employee WHERE employee_id = 'E7';

CREATE OR REPLACE TABLE employee_clone AS
--SELECT * FROM employee BEFORE(STATEMENT => '01c25399-0000-a1a6-0016-1d4f0006b256'),
SELECT * FROM employee BEFORE(STATEMENT => '01c25399-0000-a1a8-0016-1d4f0006a28e');

truncate table employee;

INSERT INTO employee
SELECT * FROM employee_clone;

select * from employee;

drop table employee_clone;