Using SQL and [Tableau](https://mavenanalytics.io/project/11657) to uncover insights and discover trends about the sales data   
Example Code:
```sql
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
```

```sql
-- sales growth over the years
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
```
