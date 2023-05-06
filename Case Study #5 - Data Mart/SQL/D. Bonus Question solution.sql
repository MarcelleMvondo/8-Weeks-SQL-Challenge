-- D. Bonus Question solution !

/* --------------------
Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?
   --------------------*/
-- region:
WITH sales_before AS 
(
    SELECT region, SUM(sales) AS total_sales_before
    FROM clean_weekly_sales,
      LATERAL (SELECT EXTRACT(WEEK FROM '2020-06-15' :: date) AS base_week ) bw 
    WHERE calendar_year = 2020
      AND week_number between (base_week - 12)
      AND (base_week - 1)
	GROUP BY 1
),
sales_after AS 
(
	SELECT region, SUM(sales) AS total_sales_after
	FROM clean_weekly_sales,
	  LATERAL (SELECT EXTRACT(WEEK FROM '2020-06-15' :: date) AS base_week ) bw 
	WHERE calendar_year = 2020
	  AND week_number between (base_week)
	  AND (base_week + 11)
	GROUP BY 1
)
SELECT sb.region, total_sales_before, total_sales_after,
  total_sales_after - total_sales_before AS change_in_sales,
  ROUND(100 * (total_sales_after - total_sales_before) :: numeric 
		/ total_sales_before, 2) AS percentage_of_change 
FROM sales_before AS sb
JOIN sales_after AS sa 
	ON sb.region = sa.region
GROUP BY 1,2,3,4
ORDER BY 5

-- platform:
WITH sales_before AS 
(
    SELECT platform, SUM(sales) AS total_sales_before
    FROM clean_weekly_sales,
      LATERAL (SELECT EXTRACT(WEEK FROM '2020-06-15' :: date) AS base_week ) bw 
    WHERE calendar_year = 2020
      AND week_number between (base_week - 12)
      AND (base_week - 1)
	GROUP BY 1
),
sales_after AS 
(
	SELECT platform, SUM(sales) AS total_sales_after
	FROM clean_weekly_sales,
	  LATERAL (SELECT EXTRACT(WEEK FROM '2020-06-15' :: date) AS base_week ) bw 
	WHERE calendar_year = 2020
	  AND week_number between (base_week)
	  AND (base_week + 11)
	GROUP BY 1
)
SELECT sb.platform, total_sales_before, total_sales_after,
  total_sales_after - total_sales_before AS change_in_sales,
  ROUND(100 * (total_sales_after - total_sales_before) :: numeric 
		/ total_sales_before, 2) AS percentage_of_change 
FROM sales_before AS sb
JOIN sales_after AS sa 
	ON sb.platform = sa.platform
GROUP BY 1,2,3,4
ORDER BY 5

-- age_band:
WITH sales_before AS 
(
    SELECT age_band, SUM(sales) AS total_sales_before
    FROM clean_weekly_sales,
      LATERAL (SELECT EXTRACT(WEEK FROM '2020-06-15' :: date) AS base_week ) bw 
    WHERE calendar_year = 2020
      AND week_number between (base_week - 12)
      AND (base_week - 1)
	GROUP BY 1
),
sales_after AS 
(
	SELECT age_band, SUM(sales) AS total_sales_after
	FROM clean_weekly_sales,
	  LATERAL (SELECT EXTRACT(WEEK FROM '2020-06-15' :: date) AS base_week ) bw 
	WHERE calendar_year = 2020
	  AND week_number between (base_week)
	  AND (base_week + 11)
	GROUP BY 1
)
SELECT sb.age_band, total_sales_before, total_sales_after,
  total_sales_after - total_sales_before AS change_in_sales,
  ROUND(100 * (total_sales_after - total_sales_before) :: numeric 
		/ total_sales_before, 2) AS percentage_of_change 
FROM sales_before AS sb
JOIN sales_after AS sa 
	ON sb.age_band = sa.age_band
GROUP BY 1,2,3,4
ORDER BY 5

-- demographic:
WITH sales_before AS 
(
    SELECT demographic, SUM(sales) AS total_sales_before
    FROM clean_weekly_sales,
      LATERAL (SELECT EXTRACT(WEEK FROM '2020-06-15' :: date) AS base_week ) bw 
    WHERE calendar_year = 2020
      AND week_number between (base_week - 12)
      AND (base_week - 1)
	GROUP BY 1
),
sales_after AS 
(
	SELECT demographic, SUM(sales) AS total_sales_after
	FROM clean_weekly_sales,
	  LATERAL (SELECT EXTRACT(WEEK FROM '2020-06-15' :: date) AS base_week ) bw 
	WHERE calendar_year = 2020
	  AND week_number between (base_week)
	  AND (base_week + 11)
	GROUP BY 1
)
SELECT sb.demographic, total_sales_before, total_sales_after,
  total_sales_after - total_sales_before AS change_in_sales,
  ROUND(100 * (total_sales_after - total_sales_before) :: numeric 
		/ total_sales_before, 2) AS percentage_of_change 
FROM sales_before AS sb
JOIN sales_after AS sa 
	ON sb.demographic = sa.demographic
GROUP BY 1,2,3,4
ORDER BY 5

-- customer_type:
WITH sales_before AS 
(
    SELECT customer_type, SUM(sales) AS total_sales_before
    FROM clean_weekly_sales,
      LATERAL (SELECT EXTRACT(WEEK FROM '2020-06-15' :: date) AS base_week ) bw 
    WHERE calendar_year = 2020
      AND week_number between (base_week - 12)
      AND (base_week - 1)
	GROUP BY 1
),
sales_after AS 
(
	SELECT customer_type, SUM(sales) AS total_sales_after
	FROM clean_weekly_sales,
	  LATERAL (SELECT EXTRACT(WEEK FROM '2020-06-15' :: date) AS base_week ) bw 
	WHERE calendar_year = 2020
	  AND week_number between (base_week)
	  AND (base_week + 11)
	GROUP BY 1
)
SELECT sb.customer_type, total_sales_before, total_sales_after,
  total_sales_after - total_sales_before AS change_in_sales,
  ROUND(100 * (total_sales_after - total_sales_before) :: numeric 
		/ total_sales_before, 2) AS percentage_of_change 
FROM sales_before AS sb
JOIN sales_after AS sa 
	ON sb.customer_type = sa.customer_type 
GROUP BY 1,2,3,4
ORDER BY 5

