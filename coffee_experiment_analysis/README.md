Crafted SQL queries to answer multi-tiered questions. Visualized the insights in [Tableau](https://mavenanalytics.io/project/11661)   
Example code:   
```sql
-- Age and category of spender
SELECT
  age,
  ROUND(COUNT(CASE WHEN mthly_spend LIKE '%<20%' OR mthly_spend LIKE '%20-40%' THEN 1 END)/COUNT(*),2) low_spenders,
  ROUND(COUNT(CASE WHEN mthly_spend LIKE '%40-60%' OR mthly_spend LIKE '%60-80%' THEN 1 END)/COUNT(*),2) medium_spenders,
  ROUND(COUNT(CASE WHEN mthly_spend LIKE '%80-100%' OR mthly_spend LIKE '%>100%' THEN 1 END)/COUNT(*),2) high_spenders
FROM `coffeedata.CoffeeData`
GROUP BY
  age;
```

```sql
-- Addin combos (just black, both cream and sugar, just one of the addins)
WITH defined AS (
SELECT
  CASE WHEN addins LIKE '%Dairy%' OR addins LIKE '%Milk%' OR addins LIKE '%Creamer%' THEN 'Milk'
  WHEN addins LIKE '%Sugar%' OR addins LIKE '%Syrup%' THEN 'Sugar'
  WHEN addins LIKE '%Black%' THEN 'Black' END type,
  COUNT(*) as CNT
FROM `coffeedata.CoffeeData`
GROUP BY
  type
)
SELECT
  'just_black' AS category,
  CNT AS newcount
FROM defined
WHERE
  type = 'Black'

UNION ALL

SELECT
  'cream_sugar' AS category,
  SUM(CNT) newcount
FROM defined
WHERE
  type = 'Sugar' OR type = 'Milk'

UNION ALL

SELECT
  'just_milk',
  CNT AS newcount
FROM defined
WHERE
  (type LIKE  'Milk') AND NOT (type LIKE 'Sugar')  AND type NOT LIKE 'Black'

UNION ALL

SELECT
  'just_sugar',
  CNT AS newcount
FROM defined
WHERE
  (type LIKE  'Sugar') AND NOT (type LIKE 'Milk')  AND type NOT LIKE 'Black';
```
