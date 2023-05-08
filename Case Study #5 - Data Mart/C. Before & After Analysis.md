# 🛒 Case Study #5 - Data Mart

## 🧼 Solution - C. Before & After Analysis

**1. What is the total sales for the 4 weeks before and after `2020-06-15`? What is the growth or reduction rate in actual values and percentage of sales?**

````sql
WITH sales_before AS 
(
    SELECT SUM(sales) AS total_sales_before
    FROM clean_weekly_sales,
      LATERAL (SELECT EXTRACT(WEEK FROM '2020-06-15' :: date) AS base_week ) bw 
    WHERE calendar_year = 2020
      AND week_number between (base_week - 4)
      AND (base_week - 1)    
),
 sales_after AS 
  (
    SELECT SUM(sales) AS total_sales_after
    FROM clean_weekly_sales,
      LATERAL (SELECT EXTRACT(WEEK FROM '2020-06-15' :: date) AS base_week ) bw 
    WHERE calendar_year = 2020
      AND week_number between (base_week)
      AND (base_week + 3)
  )
SELECT total_sales_before, total_sales_after,
  total_sales_after - total_sales_before AS change_in_sales,
  ROUND(100 * (total_sales_after - total_sales_before) :: numeric 
		/ total_sales_before, 2) AS percentage_of_change 
FROM sales_before, sales_after
````

**Answer:**

| total_sales_before | total_sales_after | change_in_sales | percentage_of_change  |
|--------------------|-------------------|-----------------|-----------------------|
| 2345878357         | 2318994169        | -26884188       | -1.15                 |

Total sales for 4 weeks after week 25 decreased to 1.15% compared to 4 week sales before week 25

***

**2. What about the entire 12 weeks before and after?**

We can apply the same logic and solution to this question. 

````sql
WITH changes AS (
  SELECT 
    week_date, 
    week_number, 
    SUM(sales) AS total_sales
  FROM clean_weekly_sales
  WHERE (week_number BETWEEN 13 AND 37) 
    AND (calendar_year = 2020)
  GROUP BY week_date, week_number
),
changes_2 AS (
  SELECT 
    SUM(CASE WHEN week_number BETWEEN 13 AND 24 THEN total_sales END) AS before_change,
    SUM(CASE WHEN week_number BETWEEN 25 AND 37 THEN total_sales END) AS after_change
  FROM changes)

SELECT 
  before_change, 
  after_change, 
  after_change - before_change AS variance, 
  ROUND(100 * (after_change - before_change) / before_change,2) AS percentage
FROM changes_2
````

**Answer:**

| total_sales_before | total_sales_after | change_in_sales | percentage_of_change  |
|--------------------|-------------------|-----------------|-----------------------|
| 7126273147         | 6973947753        | -152325394      | -2.14                 |


***Total sales for 12 weeks after week 25 decreased to 2.14% compared to 12 week sales before week 25***

***

**3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?**
