-- 1) addin combos (just black, both cream and sugar, just one of the addins)
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

-- 2) how many people's favorite drink typically contains no milk vs contains milk
WITH mlk AS (
SELECT
  COUNT(*) nomilk
FROM `coffeedata.CoffeeData`
WHERE
  fav_drink LIKE '%Americano%' 
  OR fav_drink LIKE '%Cold brew%'
  OR fav_drink LIKE '%Espresso%' 
  OR fav_drink LIKE '%Pourover%'
  OR fav_drink LIKE '%drip%'
)
SELECT
  nomilk,
  (SELECT COUNT(*) FROM `coffeedata.CoffeeData`) - nomilk AS hasmilk
FROM mlk;

-- 3) gender and caffeine preference
SELECT
  gender,
  CONCAT(ROUND(SUM(CASE WHEN caffeine LIKE '%Full%' THEN 1 END)/COUNT(*)*100,2),'%') full_caffeine,
  CONCAT(ROUND(SUM(CASE WHEN caffeine LIKE '%Half%' THEN 1 END)/COUNT(*)*100,2),'%') less_caffeine,
  CONCAT(ROUND(SUM(CASE WHEN caffeine LIKE '%Decaf%' THEN 1 END)/COUNT(*)*100,2),'%') no_caffeine
FROM (
  SELECT
    gender,
    caffeine
  FROM `coffeedata.CoffeeData`
  WHERE
    gender IN ('Male', 'Female') AND caffeine IS NOT NULL
) AS g
GROUP BY gender;

-- 4) do people who know where their coffee comes from rank their expertise higher?
SELECT
  bean_origin,
  ROUND(AVG(expertise),1) as AvgExpertise
FROM `coffeedata.CoffeeData`
GROUP BY
  bean_origin;

-- 5) which coffees have the highest bitterness and acidity
SELECT
  'A' AS coffee,
  ROUND(AVG(a_bitt),2) AS avg_bitterness,
  ROUND(AVG(a_acid),2) AS avg_acidity
FROM `coffeedata.CoffeeData`

UNION ALL

SELECT
  'B' AS coffee,
  ROUND(AVG(b_bitt),2) AS avg_bitterness,
  ROUND(AVG(b_acid),2) AS avg_acidity
FROM `coffeedata.CoffeeData`

UNION ALL

SELECT
  'C' AS coffee,
  ROUND(AVG(c_bitt),2) AS avg_bitterness,
  ROUND(AVG(c_acid),2) AS avg_acidity
FROM `coffeedata.CoffeeData`

UNION ALL

SELECT
  'D' AS coffee,
  ROUND(AVG(d_bitt),2) AS avg_bitterness,
  ROUND(AVG(d_acid),2) AS avg_acidity
FROM `coffeedata.CoffeeData`;

-- 6) percentage of people whose roast level preference corresponds to their overall favorite coffee taste
SELECT
  'bitter' AS taste,
  CONCAT(ROUND(SUM(CASE WHEN roast_level LIKE '%Dark%'
  OR roast_level LIKE '%Medium%' THEN 1 END)/COUNT(*) * 100,2),'%') pct
FROM `coffeedata.CoffeeData`
WHERE
  overall_fav LIKE '%C%' OR overall_fav LIKE '%B%'

UNION ALL

SELECT
  'acidic' AS taste,
  CONCAT(ROUND(SUM(CASE WHEN roast_level LIKE '%Light%'
  THEN 1 END)/COUNT(*) * 100,2),'%') pct
FROM `coffeedata.CoffeeData`
WHERE
  overall_fav LIKE '%D%' OR overall_fav LIKE '%A%';

-- 7) how many cups do most people drink per day?
SELECT
  cups_day,
  COUNT(*) CNT
FROM `coffeedata.CoffeeData`
GROUP BY
  cups_day
ORDER BY
  CNT DESC;

-- 8) # of cups drank per day grouped by age group
SELECT
  age,
  SUM(CASE WHEN cups_day LIKE '%<1%' THEN 1 END) AS less_one,
  SUM(CASE WHEN cups_day LIKE '%1%' THEN 1 END) AS one,
  SUM(CASE WHEN cups_day LIKE '%2%' THEN 1 END) AS two,
  SUM(CASE WHEN cups_day LIKE '%3%' THEN 1 END) AS three,
  SUM(CASE WHEN cups_day LIKE '%4%' THEN 1 END) AS four,
  SUM(CASE WHEN cups_day LIKE '%>4%' THEN 1 END) AS more_four,
FROM `coffeedata.CoffeeData`
GROUP BY
  age;

-- 9) age and category of spender
SELECT
  age,
  ROUND(COUNT(CASE WHEN mthly_spend LIKE '%<20%' OR mthly_spend LIKE '%20-40%' THEN 1 END)/COUNT(*),2) low_spenders,
  ROUND(COUNT(CASE WHEN mthly_spend LIKE '%40-60%' OR mthly_spend LIKE '%60-80%' THEN 1 END)/COUNT(*),2) medium_spenders,
  ROUND(COUNT(CASE WHEN mthly_spend LIKE '%80-100%' OR mthly_spend LIKE '%>100%' THEN 1 END)/COUNT(*),2) high_spenders
FROM `coffeedata.CoffeeData`
GROUP BY
  age;

-- 10) average spend by age group (ranges turned into integers)
SELECT
  age,
  ROUND(AVG(mthly_spend2),2) AS avg_mthly_spend
FROM `coffeedata.CoffeeData`
GROUP BY
  age;

-- 11) which coffee had the most votes for overall favorite coffee
SELECT
  overall_fav AS coffee,
  COUNT(*) AS total_votes
FROM `coffeedata.CoffeeData`
GROUP BY
  coffee;