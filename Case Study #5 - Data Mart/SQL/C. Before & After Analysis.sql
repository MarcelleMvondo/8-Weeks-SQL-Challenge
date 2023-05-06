-- C. Before & After Analysis

--1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
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
  
-- 2. What about the entire 12 weeks before and after?
WITH sales_before AS 
(
    SELECT SUM(sales) AS total_sales_before
    FROM clean_weekly_sales,
      LATERAL (SELECT EXTRACT(WEEK FROM '2020-06-15' :: date) AS base_week ) bw 
    WHERE calendar_year = 2020
      AND week_number between (base_week - 12)
      AND (base_week - 1)    
),
sales_after AS 
(
	SELECT SUM(sales) AS total_sales_after
	FROM clean_weekly_sales,
	  LATERAL (SELECT EXTRACT(WEEK FROM '2020-06-15' :: date) AS base_week ) bw 
	WHERE calendar_year = 2020
	  AND week_number between (base_week)
	  AND (base_week + 11)
)
SELECT total_sales_before, total_sales_after,
  total_sales_after - total_sales_before AS change_in_sales,
  ROUND(100 * (total_sales_after - total_sales_before) :: numeric 
		/ total_sales_before, 2) AS percentage_of_change 
FROM sales_before, sales_after

-- 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
  
