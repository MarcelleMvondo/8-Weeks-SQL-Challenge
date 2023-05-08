-- B. Data Exploration

-- 1. What day of the week is used for each week_date value?
SELECT 
  DISTINCT(TO_CHAR(week_date, 'day')) AS week_day 
FROM clean_weekly_sales

-- 2. What range of week numbers are missing from the dataset?
WITH week_number AS 
(
  SELECT GENERATE_SERIES(1,52) AS week_number
)
SELECT DISTINCT w.week_number
FROM week_number_cte w
LEFT OUTER JOIN clean_weekly_sales s
  ON w.week_number = s.week_number
WHERE s.week_number IS NULL

-- 3. How many total transactions were there for each year in the dataset?
SELECT calendar_year, 
  SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year

-- 4. What is the total sales for each region for each month?
SELECT region, month_number, 
  SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number

-- 5. What is the total count of transactions for each platform?
SELECT platform, 
  SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform
ORDER BY platform

-- 6. What is the percentage of sales for Retail vs Shopify for each month?
WITH transactions_cte AS 
(
  SELECT calendar_year, month_number, platform, 
    SUM(sales) AS monthly_sales
  FROM clean_weekly_sales
  GROUP BY calendar_year, month_number, platform
)
SELECT calendar_year, month_number,
  ROUND(100 * MAX 
    (CASE WHEN platform = 'Retail' THEN monthly_sales ELSE NULL END) / 
      SUM(monthly_sales),2) AS retail_percentage,
  ROUND(100 * MAX 
    (CASE WHEN platform = 'Shopify' THEN monthly_sales ELSE NULL END) / 
      SUM(monthly_sales),2) AS shopify_percentage
FROM transactions_cte
GROUP BY calendar_year, month_number
ORDER BY calendar_year, month_number

-- 7. What is the percentage of sales by demographic for each year in the dataset?
WITH demographic_sales AS 
(
  SELECT calendar_year, demographic,
    SUM(sales) AS yearly_sales
  FROM clean_weekly_sales
  GROUP BY calendar_year, demographic
)

SELECT calendar_year,
  ROUND(100 * MAX 
    (CASE WHEN demographic = 'Couples' THEN yearly_sales ELSE NULL END) / 
      SUM(yearly_sales),2) AS couples_percentage,
  ROUND(100 * MAX 
    (CASE WHEN demographic = 'Families' THEN yearly_sales ELSE NULL END) / 
      SUM(yearly_sales),2) AS families_percentage,
  ROUND(100 * MAX 
    (CASE WHEN demographic = 'unknown' THEN yearly_sales ELSE NULL END) / 
      SUM(yearly_sales),2) AS unknown_percentage
FROM demographic_sales
GROUP BY calendar_year
ORDER BY calendar_year

-- 8. Which age_band and demographic values contribute the most to Retail sales?
SELECT age_band, demographic,
  SUM(sales) AS retail_sales,
  ROUND(100 * SUM(sales)::NUMERIC / SUM(SUM(sales)) OVER (),2) AS contribution_percentage
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY retail_sales DESC

-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT calendar_year, platform,
  ROUND(AVG(avg_transaction),0) AS avg_transaction_row, 
  SUM(sales) / sum(transactions) AS avg_transaction_group
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform




