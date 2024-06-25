-- grouping customers into either low, moderate, or high spenders; grouping by quarter to see any changes
WITH customerquarter AS (
  SELECT
    EXTRACT(quarter FROM order_date) AS quarter,
    customer_name,
    SUM(sales) AS totalspend
  FROM `superstore_dataset.Superstore Data`
  WHERE
    EXTRACT(year FROM order_date) = 2017
  GROUP BY
    customer_name,
    quarter
)
SELECT
  CONCAT('2017-Q', CAST(quarter AS STRING)) AS quarter,
  COUNT(CASE WHEN totalspend < 1000 THEN 1 END) AS lowspenders,
  COUNT(CASE WHEN totalspend BETWEEN 1000 AND 3000 THEN 1 END) AS moderatespenders,
  COUNT(CASE WHEN totalspend > 3000 THEN 1 END) AS highspenders
FROM customerquarter
GROUP BY
  quarter
ORDER BY
  quarter;

-- total sales, profit, and number of orders for different discount ranges
WITH discounttiers AS (
  SELECT
    CASE
      WHEN discount = 0 THEN '0%'
      WHEN discount <= 0.1 THEN '0% - 10%'
      WHEN discount <= 0.2 THEN '11% - 20%'
      ELSE '20%+'
    END AS discountrange,
    sales,
    profit
  FROM`superstore_dataset.Superstore Data`
  WHERE
    EXTRACT(year FROM order_date) = 2017
)
SELECT
  discountrange,
  ROUND(SUM(sales),2) AS totalsales,
  ROUND(SUM(profit),2) AS totalprofit,
  COUNT(*) AS numorders
FROM discounttiers
GROUP BY
  discountrange
ORDER BY
  discountrange;

-- 2017 KPI's for the superstore
SELECT
  ROUND(SUM(sales),2) AS totalsales,
  ROUND(SUM(profit),2) AS totalprofit,
  COUNT(DISTINCT order_id) AS totalorders
FROM `superstore_dataset.Superstore Data`
WHERE
  EXTRACT(year FROM order_date) = 2017;

-- sales growth over the years (looking at growth from 2016 - 2017)
SELECT
  year,
  ROUND((SUM(sales) - LAG(SUM(sales)) OVER (ORDER BY year))
  /(LAG(SUM(sales)) OVER (ORDER BY year)) * 100, 2) AS salesgrowth_pct
FROM (
SELECT
  sales,
  EXTRACT(year FROM order_date) AS year
FROM `superstore_dataset.Superstore Data`
)
GROUP BY
  year
ORDER BY
  year;

-- sales volume by month for each category, looking for seasonality for the categories of products
SELECT
  EXTRACT(month FROM order_date) AS month,
  category,
  COUNT(product_name) AS count
FROM `superstore_dataset.Superstore Data`
WHERE
  EXTRACT(year FROM order_date) = 2017
GROUP BY
  month,
  category
ORDER BY
  month;

-- total sales for each month
SELECT
  EXTRACT(month FROM order_date) AS month,
  ROUND(SUM(sales),2) AS totalsales
FROM `superstore_dataset.Superstore Data`
WHERE
  EXTRACT(year FROM order_date) = 2017
GROUP BY
  month
ORDER BY
  month;

-- finding out which discount range resulted in the best sales for each category
-- note, office supplies has a different discount range
WITH discountranges AS (
  SELECT
    category,
    FLOOR((discount * 100) / 20) * 20 AS discountrange,
    ROUND(SUM(sales), 2) AS totalsales
  FROM `superstore_dataset.Superstore Data`
  WHERE
    EXTRACT(year FROM order_date) = 2017
  GROUP BY
    category,
    discountrange
)
SELECT
  category,
  discountrange / 100.0 AS mindiscount,
  (discountrange + 20) / 100.0 AS maxdiscount,
  totalsales
FROM
  discountranges
ORDER BY
  category,
  discountrange;

-- total sales by category
SELECT
  category,
  ROUND(SUM(sales),2) AS totalsales
FROM `superstore_dataset.Superstore Data`
WHERE
  EXTRACT(year FROM order_date) = 2017
GROUP BY
  category;

-- total sales on a segment level
SELECT
  segment,
  ROUND(SUM(sales),2) AS totalsales,
  ROUND(SUM(profit),2) AS totalprofit
FROM `superstore_dataset.Superstore Data`
WHERE
  EXTRACT(year FROM order_date) = 2017
GROUP BY
  segment;

-- top 10 states by their total sales
SELECT
  state,
  ROUND(SUM(sales),2) AS totalsales
FROM `superstore_dataset.Superstore Data`
WHERE
  EXTRACT(year FROM order_date) = 2017
GROUP BY
  state
ORDER BY
  totalsales DESC
LIMIT 10;

-- total sales by the region
SELECT
  region,
  ROUND(SUM(sales),2) AS totalsales
FROM `superstore_dataset.Superstore Data`
WHERE
  EXTRACT(year FROM order_date) = 2017
GROUP BY
  region
ORDER BY
  totalsales DESC;

-- overall top 10 spending customers and number of orders
SELECT
  customer_name,
  ROUND(SUM(sales),2) AS totalspend,
  COUNT(DISTINCT(Order_ID)) AS numoforders
FROM `superstore_dataset.Superstore Data`
WHERE
  EXTRACT(year FROM order_date) = 2017
GROUP BY
  customer_name
ORDER BY
  totalspend DESC
LIMIT 10;

-- most profitable products and how many times they were bought
SELECT
  product_name,
  ROUND(SUM(profit),2) AS profits,
  COUNT(*) AS count
FROM `superstore_dataset.Superstore Data`
WHERE
  EXTRACT(year FROM order_date) = 2017
GROUP BY
  product_name
ORDER BY
  profits DESC
LIMIT 10;

-- sales top 5 products by category
WITH product_sales AS (
  SELECT
    category,
    product_name,
    ROUND(SUM(sales), 2) AS totalsales,
    ROW_NUMBER() OVER (PARTITION BY category
    ORDER BY SUM(sales) DESC) AS rn
  FROM `superstore_dataset.Superstore Data`
  WHERE 
    EXTRACT(year FROM order_date) = 2017
  GROUP BY
    category,
    product_name
)
SELECT
  category,
  product_name,
  totalsales
FROM product_sales
WHERE
  rn <= 5
ORDER BY 
  category,
  totalsales DESC;

-- evaluating the financial performance and health of the store over the year
SELECT
  EXTRACT(month FROM order_date) AS month,
  ROUND(SUM(Profit),2) AS profit,
  ROUND(SUM(profit)/(SUM(sales)),4) AS profitmargin
FROM `superstore_dataset.Superstore Data`
WHERE
  EXTRACT(year FROM order_date) = 2017
GROUP BY
  month
ORDER BY
  month;

-- profitability by each group of customers
SELECT
  segment,
  ROUND(SUM(profit)/(SUM(sales)),4) AS profitmargin
FROM `superstore_dataset.Superstore Data`
WHERE
  EXTRACT(year FROM order_date) = 2017
GROUP BY
  segment;

-- profits for each category of products
-- good to know for product expansion opportunity as well as pricing strategy
SELECT
  category,
  ROUND(SUM(profit)/(SUM(sales)),4) AS profitmargin
FROM `superstore_dataset.Superstore Data`
WHERE
  EXTRACT(year FROM order_date) = 2017
GROUP BY
  category;

-- seeing the average sale amount by category and how they compare to each other
SELECT
  category,
  ROUND(AVG(sales),2) AS avgsaleamount
FROM `superstore_dataset.Superstore Data`
WHERE
  EXTRACT(year FROM order_date) = 2017
GROUP BY
  category;