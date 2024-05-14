

-- Checking for duplicates for dim_customer
select 
      customer_code,
      count(customer_code) AS count
From dim_customer
Group By customer_code
Having count(customer_code)>1;
-- No Duplicates Found
--------------------------------------------------------------------
-- Checking Duplicates for dim_product
select
      product_code,
      count(product_code)
From dim_product
Group By product_code
Having count(product_code)>1;
-- No Duplicates Found

-----------------------------------------------------------------------

-- Checking Duplicates for fact_sales_monthly

Create table temporary_1 AS Select * From fact_sales_monthly;
select * from Temporary_1;

With CTE1 AS
(Select
      date,
      product_code,
      customer_code,
      sold_quantity,
      fiscal_year,
      Row_Number() Over (partition by date,product_code,customer_code,sold_quantity,fiscal_year) AS RN
From temporary_1)
Select * From CTE1
Where RN>1;
-- No Duplicates Found
Drop Table temporary_1;

-------------------------------------------------------------------------------------
-- checking Duplicates value in fact_manufacturing_cost
Create table temporary_2 AS Select * From fact_manufacturing_cost;
Select * from temporary_2;

With CTE1 AS	
(Select
      product_code,
      cost_year,
      manufacturing_cost,
      Row_Number() Over (Partition by product_code,cost_year,manufacturing_cost) AS RN
From temporary_2)
Select * from CTE1
Where RN >1;
-- No Duplicates Found
Drop Table temporary_2;

------------------------------------------------------------------------------------------

-- Checking Duplicates For fact_gross_price
Create table temporary_3 AS Select * From fact_gross_price;
Select * from temporary_3;

With CTE1 AS
(Select
      product_code,
      fiscal_year,
      gross_price,
      Row_Number() Over (Partition By product_code,fiscal_year,gross_price) AS RN
From temporary_3)
Select * From CTE1
Where RN > 1;
-- No Duplicates Found
Drop Table temporary_3;

---------------------------------------------------------------------------------------------

-- Checking Duplicates fact_pre_invoice_deductions
Create table temporary_4 AS Select * From fact_pre_invoice_deductions;
Select * from temporary_4;

With CTE1 AS
(Select
      customer_code,
      fiscal_year,
      pre_invoice_discount_pct,
      Row_Number() Over (partition By customer_code,fiscal_year,pre_invoice_discount_pct) AS RN
From temporary_4)
Select * from CTE1
Where RN > 1;
-- No Duplicates Found

Drop Table temporary_4;

--------------------------------------------------------------------------------------------------

select * from dim_customer;

Update dim_customer
Set market = "New Zealand"
Where market = "Newzealand";

Set Sql_safe_updates = 0;

Update dim_customer
Set market = "philippines"
Where market = "Philiphines";

Set Sql_safe_updates = 0;

