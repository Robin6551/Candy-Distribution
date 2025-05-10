

SELECT * 
FROM candy_sales;

SELECT *
FROM data_dictionary;

SELECT *
FROM candy_factories;

SELECT *
FROM candy_products;

SELECT *
FROM candy_targets;



-- Monthly Sales Trend

SELECT 
  DATE_TRUNC('month', order_date) AS month,
  SUM(units) AS total_units_sold,
  SUM(sales) AS total_revenue,
  SUM(gross_profit) AS total_profit
FROM candy_sales
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- Top 3 Best-Selling Candies by Revenue

SELECT cp.division,
		sum(sales) as total_revenue
FROM candy_products cp
		LEFT join
		candy_sales cs
on cp.product_id = cs.product_id
GROUP BY 1
ORDER BY 2 DESC;

-- Sales Target vs Actual

SELECT ct.division,
		ct.target,
		sum(cs.sales) as total_sales
FROM candy_sales cs 
			left join
			candy_targets ct
on cs.division = ct.division
GROUP BY 1,2;

-- Factory-wise Production Revenue

SELECT cf.factory,
		sum(cs.sales) as revenue
FROM candy_sales cs 
			left join
			candy_products cp
ON cp.product_id = cs.product_id
 		LEFT join
 candy_factories cf
 ON cf.factory = cp.factory
 GROUP BY 1
 ORDER BY 2 DESC;


-- Most Profitable Factory
 
SELECT cf.factory,
		cs.product_name,
		sum(cs.sales) as revenue,
		Rank() over(partition BY cf.factory order by sum(cs.sales))
FROM candy_sales cs 
		left join 
		candy_products cp
ON cp.product_id = cs.product_id
 		LEFT join
 		candy_factories cf
 ON cf.factory = cp.factory
 GROUP BY 1,2
 ORDER BY 2 DESC;

-- Product Variety per Factory

SELECT cf.factory,
		count(cp.product_name) as unique_product
FROM candy_factories cf 
				left join 
				candy_products cp
		ON cf.factory = cp.factory
	GROUP BY 1;

-- Underperforming Products

SELECT 
  cp.product_id,
  cp.product_name,
  SUM(cs.sales) AS actual_sales,
  ct.target,
  ROUND((SUM(cs.sales)::decimal / ct.target) * 100, 2) AS performance_percent
FROM candy_sales cs
JOIN candy_targets ct ON cs.division = ct.division
JOIN candy_products cp ON cs.product_id = cp.product_id
GROUP BY cp.product_id, cp.product_name, ct.target
HAVING SUM(cs.sales) < 0.8 * ct.target
ORDER BY performance_percent ASC;

-- Top Products by Profit Margin

SELECT product_name, 
		Round((gross_profit/sales)*100) as profit_margin
FROM candy_sales
GROUP BY 1,2
ORDER BY 2 DESC;

-- Daily Average Sales per Product

SELECT 
EXTRACT(day	from order_date) as days,
EXTRACT(MONTH FROM ORDER_DATE) AS MONTHS,
EXTRACT(YEAR from order_date) AS YEARS,
ROUND(AVG(sales)) AS AVG_SALES
FROM candy_sales
GROUP BY 1,2,3
ORDER by DAYS;

-- Revenue and Profit per Factory per Month

SELECT cp.factory,
		TO_CHAR(order_date, 'YYYY-MM') as date,
		sum(cs.sales) as revenue,
		sum(cs.gross_profit) as profit
FROM Candy_sales cs LEFT JOIN candy_products cp
ON cs.product_id = cp.product_id
GROUP BY 1,2
ORDER BY 2 ASC;


-- Most Efficient Factory

SELECT 
		cf.factory,
		sum(cs.units) as total_units,
		sum(sales-cost) as total_profit,
		Round(sum(sales-cost)/sum(cs.units)) as profit_per_unit
FROM candy_sales cs LEFT JOIN candy_products cp
ON cs.product_id = cp.product_id
JOIN candy_factories cf ON cp.factory = cf.factory
GROUP BY 1;



-- Duplicate Records Check

SELECT 
  product_id,
  order_date,
  COUNT(*) AS occurrence_count
FROM candy_sales
GROUP BY product_id, order_date
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;


