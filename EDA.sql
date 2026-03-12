-- Database Exploration
SELECT * FROM INFORMATION_SCHEMA.TABLES

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='crm_cust_info'


-- Dimension Exploration
	-- Explore all the Countries our customers come from
		SELECT DISTINCT Country FROM gold.dim_customers
	-- Explore all the Categories available
		SELECT DISTINCT Category FROM gold.dim_products
	-- Explore all the Subcategories available
		SELECT DISTINCT Subcatgory FROM gold.dim_products
	-- Explore all the Product_Line available
		SELECT DISTINCT Product_Line FROM gold.dim_products

-- Date Exploration
	-- Find 1st and Last Order
		SELECT MIN(Order_Date) AS First_Order, MAX(Order_Date) AS Last_Order FROM gold.fact_sales
	-- Find the Tenure of Business
		SELECT DATEDIFF(year,MIN(Order_Date),MAX(Order_Date)) AS Tenure_in_years FROM gold.fact_sales
	-- Find Youngest and Oldest Customer age
		SELECT DATEDIFF(year,MIN(Birth_Date),GETDATE()) AS oldest_cust,
			   DATEDIFF(year,MAX(Birth_Date),GETDATE()) AS youngest_cust
		FROM gold.dim_customers

-- Measure Exploration
	-- Find the Total Sales
		SELECT 'Total_Sales' AS Measure_Name, SUM(Sales) AS Measure_Value FROM gold.fact_sales
		UNION ALL
	-- How many items were sold
		SELECT 'Total_Quantity', SUM(Quantity) AS Measure_Value FROM gold.fact_sales
		UNION ALL
	-- Average Selling Price
		SELECT 'Avg_Price', AVG(Price) AS Measure_Value FROM gold.fact_sales
		UNION ALL
	-- Total Number of Orders
		SELECT 'Total_Orders', COUNT(DISTINCT Order_Number) AS Measure_Value FROM gold.fact_sales
		UNION ALL
	-- Total Number of Products sold
		SELECT 'Total_Products_sold', COUNT(DISTINCT Product_Key) AS Measure_Value FROM gold.fact_sales
		UNION ALL
	-- Total Number of Customers
		SELECT 'Total_Customers', COUNT(Customer_id) AS Measure_Value FROM gold.dim_customers
		UNION ALL
	-- Total Number of Customers that has placed order
		SELECT 'Ordered_Customers', COUNT(DISTINCT Customer_Key) AS Measure_Value FROM gold.fact_sales

-- Magnitude Analysis
	-- No. of Cutomers in each Country
		SELECT Country,COUNT(Customer_id) as Total_Customers FROM gold.dim_customers
		GROUP BY Country
		ORDER BY Total_Customers DESC
	-- No. of Cutomers Gender wise
		SELECT Gender,COUNT(Customer_id) as Total_Customers FROM gold.dim_customers
		GROUP BY Gender
		ORDER BY Total_Customers DESC
	-- No. of Products Category wise
		SELECT Category,COUNT(Product_id) as Total_Products FROM gold.dim_products
		GROUP BY Category
		ORDER BY Total_Products DESC
	-- Average cost for each Category
		SELECT Category,AVG(Cost) AS Avg_Cost FROM gold.dim_products
		GROUP BY Category
		ORDER BY Avg_Cost DESC
	-- Total Revenue for each Category
		SELECT Category,SUM(Sales) AS Total_Revenue FROM gold.dim_products p
		LEFT JOIN gold.fact_sales s
		ON p.Product_Key=s.Product_Key
		GROUP BY Category
		ORDER BY Total_Revenue DESC
	-- Total Revenue by each Customer
		SELECT c.Customer_id, c.First_Name,c.Last_Name,SUM(s.Sales) AS Total_Revenue FROM gold.dim_customers c
		LEFT JOIN gold.fact_sales s
		ON c.Customer_id=s.Customer_Key
		GROUP BY c.Customer_id, c.First_Name,c.Last_Name
		ORDER BY Total_Revenue DESC
	-- Distribution of Sold items across country
		SELECT c.Country,COUNT(*) AS Tota_Orders FROM gold.fact_sales s
		LEFT JOIN gold.dim_customers c
		ON c.Customer_Key=s.Customer_Key
		GROUP BY c.Country
		ORDER BY Tota_Orders DESC


-- Ranking
	-- Top 5 Products with highest revenue
		SELECT Top 5 p.Product_Key,p.Product_Name,SUM(Sales) as Total_Revenue FROM gold.fact_sales s
		LEFT JOIN gold.dim_products p
		ON s.Product_Key=p.Product_Key
		GROUP BY p.Product_Key,p.Product_Name
		ORDER BY Total_Revenue DESC
	--Top 5 worst Products with least Revenue
		SELECT Top 5 p.Product_Key,p.Product_Name,SUM(Sales) as Total_Revenue FROM gold.fact_sales s
		LEFT JOIN gold.dim_products p
		ON s.Product_Key=p.Product_Key
		GROUP BY p.Product_Key,p.Product_Name
		ORDER BY Total_Revenue
	--Top 5 Product Subcategory with highest revenue
		SELECT Top 5 p.Subcatgory,SUM(Sales) as Total_Revenue FROM gold.fact_sales s
		LEFT JOIN gold.dim_products p
		ON s.Product_Key=p.Product_Key
		GROUP BY p.Subcatgory
		ORDER BY Total_Revenue DESC
	--Top 5 Product Subcategory with least revenue
		SELECT Top 5 p.Subcatgory,SUM(Sales) as Total_Revenue FROM gold.fact_sales s
		LEFT JOIN gold.dim_products p
		ON s.Product_Key=p.Product_Key
		GROUP BY p.Subcatgory
		ORDER BY Total_Revenue
	--Top 10 Customers with highest sales
		SELECT Top 5 c.Customer_id,c.First_Name,c.Last_name,SUM(s.Sales) AS Total_Sales FROM gold.fact_sales s
		LEFT JOIN gold.dim_customers c
		ON c.Customer_Key=s.Customer_Key
		GROUP BY c.Customer_id,c.First_Name,c.Last_name
		ORDER BY Total_Sales DESC
	--Top 10 Customers with lowest sales
		SELECT Top 5 c.Customer_id,c.First_Name,c.Last_name,SUM(s.Sales) AS Total_Sales FROM gold.fact_sales s
		LEFT JOIN gold.dim_customers c
		ON c.Customer_Key=s.Customer_Key
		GROUP BY c.Customer_id,c.First_Name,c.Last_name
		ORDER BY Total_Sales


-- Advance Analytics
-- Change over time
	-- Analyse sales performance over time (Year)
		SELECT 
			YEAR(order_date) AS Order_Year,
			COUNT(Customer_Key) AS Total_Customers,
			COUNT(Order_Number) AS Total_Orders,
			SUM(Quantity) AS Total_Quantity,
			SUM(Sales) AS Total_Sales 
		FROM gold.fact_sales
		WHERE Order_Date IS NOT NULL
		GROUP BY YEAR(order_date)
		ORDER BY Order_Year
	-- Analyse sales performance over time (Month)
		SELECT 
			MONTH(order_date) AS Order_Month,
			COUNT(Customer_Key) AS Total_Customers,
			COUNT(Order_Number) AS Total_Orders,
			SUM(Quantity) AS Total_Quantity,
			SUM(Sales) AS Total_Sales 
		FROM gold.fact_sales
		WHERE Order_Date IS NOT NULL
		GROUP BY MONTH(order_date)
		ORDER BY Order_Month
	-- Analyse sales performance over time (Year+Month)
		SELECT 
			DATETRUNC(MONTH,order_date) AS Order_Y_Month,
			COUNT(Customer_Key) AS Total_Customers,
			COUNT(Order_Number) AS Total_Orders,
			SUM(Quantity) AS Total_Quantity,
			SUM(Sales) AS Total_Sales 
		FROM gold.fact_sales
		WHERE Order_Date IS NOT NULL
		GROUP BY DATETRUNC(MONTH,order_date)
		ORDER BY Order_Y_Month

-- Cummulative Analysis
	-- Find Total Sales per month & Running Total Sales over time (Year)
		WITH sales_tab AS(
			SELECT DATETRUNC(MONTH,Order_Date) AS Order_Month,SUM(Sales) AS Total_Sales
			FROM gold.fact_sales
			WHERE Order_Date IS NOT NULL
			GROUP BY DATETRUNC(MONTH,Order_Date)
		)

		SELECT Order_Month, Total_Sales,
		SUM(Total_Sales) OVER (PARTITION BY YEAR(Order_Month) ORDER BY Order_Month) AS Running_Total_Sales
		FROM sales_tab
	-- Find Total Sales per year & Running Total Sales over time
		WITH sales_tab AS(
			SELECT DATETRUNC(YEAR,Order_Date) AS Order_Year,SUM(Sales) AS Total_Sales
			FROM gold.fact_sales
			WHERE Order_Date IS NOT NULL
			GROUP BY DATETRUNC(YEAR,Order_Date)
		)
		SELECT Order_Year, Total_Sales,
		SUM(Total_Sales) OVER (ORDER BY Order_Year) AS Running_Total_Sales
		FROM sales_tab
	-- Find Total number of orders per month & Running Average sale over time (Year)
		WITH sales_tab AS(
			SELECT DATETRUNC(MONTH,Order_Date) AS Order_Month,COUNT(Order_Number) AS Total_Orders,AVG(Sales) as Sales_Avg
			FROM gold.fact_sales
			WHERE Order_Date IS NOT NULL
			GROUP BY DATETRUNC(MONTH,Order_Date)
		)

		SELECT Order_Month,Total_Orders,
		SUM(Sales_Avg) OVER (PARTITION BY YEAR(Order_Month) ORDER BY Order_Month) AS Running_Avg_Sales
		FROM sales_tab

-- Performance Analysis
	-- Analyse the yearly perfomace of the product by comparing sales to avg & previous year sales
		WITH product_sales AS(
			SELECT p.Product_Name,YEAR(s.Order_Date) AS Order_Year,SUM(s.Sales) AS Current_Sales
			FROM gold.fact_sales s
			LEFT JOIN gold.dim_products p
			ON s.Product_Key=p.Product_Key
			WHERE Order_Date IS NOT NULL
			GROUP BY YEAR(s.Order_Date),p.Product_Name
		),Comparison_Table AS(
			SELECT 
				Product_Name,
				Order_Year,
				Current_Sales,
				AVG(Current_Sales) OVER (PARTITION BY Product_Name) AS Avg_Sales,
				Current_Sales-AVG(Current_Sales) OVER (PARTITION BY Product_Name) AS Sale_vs_Avg,
				LAG(Current_Sales) OVER (PARTITION BY Product_Name ORDER BY Order_Year) As Previous_Sales,
				Current_Sales-LAG(Current_Sales) OVER (PARTITION BY Product_Name ORDER BY Order_Year) AS CurrentvsPrevious
			FROM product_sales
			)

		SELECT
			Product_Name,
			Order_Year,
			Current_Sales,
			CASE WHEN Sale_vs_Avg>0 THEN 'Above Average'
				 WHEN Sale_vs_Avg<0 THEN 'Below Average'
				 ELSE 'No Change'
			END Sale_vs_Avg,
			CASE WHEN CurrentvsPrevious>0 THEN 'More Than PY'
				 WHEN CurrentvsPrevious<0 THEN 'Less Than PY'
				 ELSE 'Not Available'
			END CurrentvsPrevious
		FROM Comparison_Table
		-- Analyse the monthly perfomace of the product by comparing sales to avg & previous months sales
		WITH product_sales AS(
			SELECT p.Product_Name,MONTH(s.Order_Date) AS Order_Month,SUM(s.Sales) AS Current_Sales
			FROM gold.fact_sales s
			LEFT JOIN gold.dim_products p
			ON s.Product_Key=p.Product_Key
			WHERE Order_Date IS NOT NULL
			GROUP BY MONTH(s.Order_Date),p.Product_Name
		),Comparison_Table AS(
			SELECT 
				Product_Name,
				Order_Month,
				Current_Sales,
				AVG(Current_Sales) OVER (PARTITION BY Product_Name) AS Avg_Sales,
				Current_Sales-AVG(Current_Sales) OVER (PARTITION BY Product_Name) AS Sale_vs_Avg,
				LAG(Current_Sales) OVER (PARTITION BY Product_Name ORDER BY Order_Month) As Previous_Sales,
				Current_Sales-LAG(Current_Sales) OVER (PARTITION BY Product_Name ORDER BY Order_Month) AS CurrentvsPrevious
			FROM product_sales
			)

		SELECT
			Product_Name,
			Order_Month,
			Current_Sales,
			CASE WHEN Sale_vs_Avg>0 THEN 'Above Average'
				 WHEN Sale_vs_Avg<0 THEN 'Below Average'
				 ELSE 'No Change'
			END Sale_vs_Avg,
			CASE WHEN CurrentvsPrevious>0 THEN 'More Than PM'
				 WHEN CurrentvsPrevious<0 THEN 'Less Than PM'
				 ELSE 'Not Available'
			END CurrentvsPrevious
		FROM Comparison_Table

-- Part to Whole Analysis
	-- Which category contributes more to the sales
		SELECT 
			Category,
			Total_sales,
			CONCAT(ROUND(CAST(Total_sales AS FLOAT)/SUM(Total_sales) OVER () *100,2),' %') AS Contribution
			FROM(
				SELECT 
					p.Category,
					SUM(s.Sales) as Total_sales
				FROM gold.fact_sales s
				LEFT JOIN gold.dim_products p
				ON s.Product_Key=p.Product_Key
				GROUP BY p.Category
				)t
				ORDER BY Total_sales DESC
	-- Which Country contributes more to the sales
		SELECT 
			Country,
			Total_sales,
			CONCAT(ROUND(CAST(Total_sales AS FLOAT)/SUM(Total_sales) OVER () *100,2),' %') AS Contribution
			FROM(
				SELECT 
					c.Country,
					SUM(s.Sales) as Total_sales
				FROM gold.fact_sales s
				LEFT JOIN gold.dim_customers c
				ON s.Customer_Key=c.Customer_Key
				GROUP BY c.Country
				)t
				ORDER BY Total_sales DESC


-- Data Segementation
	-- Segement Products into different cost range & count how many products in each segement
		SELECT 
			Cost_range,
			COUNT(*) as Counts
		FROM(
			SELECT 
				p.Product_Key,
				p.Product_Name,
				p.Cost,
				CASE WHEN p.Cost<100 THEN 'Below 100'
					 WHEN p.Cost BETWEEN 100 AND 500 THEN '100-500'
					 WHEN p.Cost BETWEEN 500 AND 1000 THEN '500-1000'
					 WHEN p.Cost BETWEEN 1000 AND 1500 THEN '1000-1500'
					 ELSE '1500+'
				END Cost_range
			FROM gold.dim_products p
		)t
		GROUP BY Cost_range
		ORDER BY Counts DESC
	-- Group Customers into 3 segement based on:
	-- VIP: at leat 12 months of history & spend >5000
	-- Regular: at leat 12 months of history & spend <5000
	-- New: less tha 12 months
		WITH customer_span AS(
			SELECT 
				c.Customer_Key,
				c.First_Name,
				c.Last_name,
				SUM(s.Sales) AS Total_sales,
				DATEDIFF(MONTH,MIN(Order_Date),MAX(Order_Date)) AS Lifespan,
				CASE WHEN DATEDIFF(MONTH,MIN(Order_Date),MAX(Order_Date)) > 12 AND SUM(s.Sales) > 5000 THEN 'VIP'
					 WHEN DATEDIFF(MONTH,MIN(Order_Date),MAX(Order_Date)) > 12 AND SUM(s.Sales) < 5000 THEN 'Regular'
					 ELSE 'New'
				END Segement
			FROM gold.fact_sales s
			LEFT JOIN gold.dim_customers c
			ON s.Customer_Key=c.Customer_Key
			GROUP BY c.Customer_Key,c.First_Name,c.Last_name)

		SELECT 
			Segement,
			COUNT(*) AS COUNTS
		FROM customer_span
		GROUP BY Segement
		ORDER BY Counts DESC

/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/
CREATE VIEW gold.customer_report AS
	WITH base_table AS (
		SELECT
			c.Customer_Key,
			CONCAT(c.First_Name,' ',c.Last_Name) AS CName,
			DATEDIFF(YEAR,c.Birth_Date,GETDATE()) AS Age,
			c.Country,
			s.Order_Number,
			s.Product_Key,
			s.Order_Date,
			s.Quantity,
			s.Sales
		FROM gold.fact_sales s
		LEFT JOIN gold.dim_customers c
		ON s.Customer_Key=c.Customer_Key
		),
		customer_table AS(
		SELECT 
			Customer_Key,
			CName,
			Age,
			Country,
			COUNT(DISTINCT Order_Number) AS Total_Orders,
			SUM(Quantity) AS Total_Quantity,
			SUM(Sales) AS Total_Sales,
			COUNT(DISTINCT Product_Key) AS Total_Products,
			DATEDIFF(MONTH,MIN(Order_Date),MAX(Order_Date)) AS Lifespan,
			DATEDIFF(MONTH,MAX(Order_Date),GETDATE()) AS Recency
		FROM base_table
		GROUP BY 
			Customer_Key,
			CName,
			Age,
			Country)
		SELECT 
			Customer_Key,
			CName,
			CASE WHEN AGE<20 THEN 'Below 20'
				 WHEN AGE BETWEEN 20 AND 40 THEN '20-40'
				 WHEN AGE BETWEEN 40 AND 60 THEN '40-60'
				 WHEN AGE BETWEEN 60 AND 80 THEN '40-60'
				 ELSE 'Above 80'
			END Age_group,
			Country,
			Total_Orders,
			Total_Quantity,
			Total_Sales,
			Total_Products,
			Lifespan,
			Recency,
			Total_Sales/NULLIF(Total_Orders,0) AS avg_order_rev,
			Total_Sales/NULLIF(Lifespan,0) AS avg_month_rev,
			CASE WHEN Lifespan > 12 AND Total_Sales > 5000 THEN 'VIP'
				 WHEN Lifespan > 12 AND Total_Sales < 5000 THEN 'Regular'
				 ELSE 'New'
			END Segement
		FROM customer_table

SELECT * FROM gold.customer_report
		/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
CREATE VIEW gold.report_products AS
	WITH base_table AS (
		SELECT 
			p.Product_Key,
			p.Category,
			p.Subcatgory,
			p.Product_Name,
			p.Cost,
			s.Customer_Key,
			s.Order_Number,
			s.Order_Date,
			s.Quantity,
			s.Sales
		FROM gold.fact_sales s
		LEFT JOIN gold.dim_products p
		ON s.Product_Key=p.Product_Key
		)
		SELECT
			Product_Key,
			Category,
			Subcatgory,
			Product_Name,
			COUNT(DISTINCT Order_Number) AS Total_Orders,
			SUM(Sales) AS Total_Sales,
			SUM(Quantity) AS Total_Quantity,
			COUNT(DISTINCT Customer_Key) AS Total_Customers,
			DATEDIFF(MONTH,MIN(Order_Date),MAX(Order_Date)) AS Lifespan,
			DATEDIFF(MONTH,MAX(Order_Date),GETDATE()) AS Recency,
			SUM(Sales)/COUNT(DISTINCT Order_Number) AS avg_order_rev,
			SUM(Sales)/DATEDIFF(MONTH,MIN(Order_Date),MAX(Order_Date)) AS avg_month_rev,
			CASE WHEN SUM(Sales)>600000 THEN 'High-Performers'
				 WHEN SUM(Sales)>200000 THEN 'Mid-Performers'
				 ELSE 'Low-Performers'
			END Sales_Range
		FROM base_table
		GROUP BY 
			Product_Key,
			Category,
			Subcatgory,
			Product_Name

SELECT * FROM gold.report_products



-- =============================================================================
		select * from  gold.dim_products
		select * from  gold.fact_sales
		select * from gold.dim_customers
