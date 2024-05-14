Select * from dim_customer;
Select * from dim_product;
Select * from fact_gross_price;
Select * from fact_manufacturing_cost;
Select * from fact_pre_invoice_deductions;
Select * from fact_sales_monthly;


/* 1) Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region. */

Select
       Distinct market
From dim_customer
where customer = "Atliq Exclusive" And region = "APAC"; 

-----------------------------------------------------------------------------------------------------------------------------------------
/* 2) 2. What is the percentage of unique product increase in 2021 vs. 2020? The final output contains these fields, unique_products_2020 
unique_products_2021 percentage_chg */

With CTE1 AS
(select
       Count(distinct Case
             when fiscal_year = 2020 Then product_code End) AS unique_products_2020,
	   Count(distinct Case
             when fiscal_year = 2021 Then Product_code End) As unique_products_2021
From fact_sales_monthly)
Select
      unique_products_2020,
      unique_products_2021,
      Concat(Round((unique_products_2021-unique_products_2020)/unique_products_2020*100,2),"%") 
      AS percentage_chg
From CTE1; 

-----------------------------------------------------------------------------------------------------------------------------------------
/* 3. Provide a report with all the unique product counts for each segment and sort them in descending order of product counts. 
	  The final output contains 2 fields, segment product_count */

Select
      segment,
      count(distinct product_code) AS product_counts
From dim_product
Group by segment
Order by product_counts DESC; 

--------------------------------------------------------------------------------------------------------------------------------------
/* 4. Follow-up: Which segment had the most increase in unique products in2021 vs 2020? The final output contains these fields,
       segment product_count_2020 product_count_2021 difference */

With CTE1 AS
(Select
      p.segment,
      count(distinct case
			When s.fiscal_year = 2020 Then p.product_code End) AS product_count_2020,
	  count(distinct case 
            when s.fiscal_year = 2021 Then p.product_code End) AS product_count_2021
From dim_product p Join fact_sales_monthly s Using (product_code)
Group by p.segment)
Select 
       segment,
       product_count_2020,
       product_count_2021,
       (product_count_2021 - product_count_2020) AS difference
From CTE1
Order by difference DESC; 
 
----------------------------------------------------------------------------------------------------------------------------------------------

/* 5. Get the products that have the highest and lowest manufacturing costs. The final output should contain these fields, product_code product
      manufacturing_cost*/
 
select m.product_code, p.product, m.manufacturing_cost
from dim_product p
join fact_manufacturing_cost m
on p.product_code=m.product_code
where manufacturing_cost
in(
 select max(manufacturing_cost) from fact_manufacturing_cost
 union
 select min(manufacturing_cost) from fact_manufacturing_cost
 )
order by manufacturing_cost desc;

----------------------------------------------------------------------------------------------------

/* 6. Generate a report which contains the top 5 customers who received anaverage high pre_invoice_discount_pct for the fiscal year 2021 and in the
Indian market. The final output contains these fields,customer_code, customer, average_discount_percentage */

Select
      i.customer_code, c.customer,
      round(avg(i.pre_invoice_discount_pct)*100,2) AS Avg_discount_percent
From dim_customer c Join fact_pre_invoice_deductions i  Using (customer_code)
Where fiscal_year = 2021 and c.market = "India"
group by i.customer_code, c.customer
Order by Avg_discount_percent DESC
Limit 5;
      
--------------------------------------------------------------------------------------------------------------

/* 7. Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month. This analysis helps to get an idea of low and
high-performing months and take strategic decisions.The final report contains these columns: Month Year Gross sales Amount */

Select
      monthname(s.date) AS `Month`,
      Year(s.date) AS `Year`,
      Round(Sum(s.sold_quantity*g.gross_price)/1000000,2) AS Gross_sales_Amount_Million
From 
     fact_gross_price g
Join 
     fact_sales_monthly s ON  g.product_code  = s.product_code
Join 
      dim_customer c ON s.customer_code = c.customer_code
Where customer = "Atliq Exclusive"
Group by `Month`,`Year`
Order by `Year` ASC;

-----------------------------------------------------------------------------------------------------------------------------   

/* 8. In which quarter of 2020, got the maximum total_sold_quantity? The final output contains these fields sorted by the total_sold_quantity, Quarter
total_sold_quantity */

Select
      Case
      When Month(date) IN (9,10,11)  Then "Q1"
      When Month(date) IN (12,1,2) Then "Q2"
      When Month(date) IN (3,4,5) Then "Q3"
      Else "Q4"
      End AS `Quarter`,
      Sum(sold_quantity) AS total_sold_quantity
From fact_sales_monthly
Where fiscal_year = 2020
Group by `Quarter`
Order by total_sold_quantity DESC;

----------------------------------------------------------------------------------------------------------------
/* 9. Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution? The final output contains these fields,
channel gross_sales_mln percentage */


With CTE1 AS
(Select
      channel,
	  Round(sum(s.sold_quantity*g.gross_price)/100000,2) AS Gross_Sales_Million
From
     dim_customer c 
Join 
     fact_sales_monthly s ON c.customer_code = s.customer_code
Join 
     fact_gross_price g  ON s.product_code = g.product_code
Where g.fiscal_year = 2021
Group by channel)
Select
       channel,
       Gross_Sales_Million,
       concat(Round((Gross_Sales_Million/(select sum(Gross_Sales_Million) From CTE1)*100),2),"%")
       AS Percentage
From 
     CTE1
Order by Percentage DESC;

---------------------------------------------------------------------------------------------------------------------

/* 10. Get the Top 3 products in each division that have a high
total_sold_quantity in the fiscal_year 2021? The final output contains these fields, division product_code product total_sold_quantity rank_order */

With CTE1 AS
(Select
      Division,
      product_code,
      product,
      sum(sold_quantity) AS Total_sold_Quantity,
      Dense_Rank() Over (partition by Division Order by sum(sold_quantity) DESC) AS Rank_Order
From dim_product p Join fact_sales_monthly s Using(product_code)
Where s.fiscal_year = 2021
Group by Division, product_code, product)
Select * 
From CTE1 
where Rank_Order<=3;     

------------------------------------------------------------------------------------------------------------------------








