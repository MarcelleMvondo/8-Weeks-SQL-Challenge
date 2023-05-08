# 🛒 Case Study #5 - Data Mart

## 🛍 Solution - B. Data Exploration

**1. What day of the week is used for each week_date value?**

````sql
SELECT 
  DISTINCT(TO_CHAR(week_date, 'day')) AS week_day 
FROM clean_weekly_sales;
````

**Answer:**

<img width="110" alt="image" src="https://user-images.githubusercontent.com/81607668/131616348-81580d0e-b919-439a-821d-7997d958f59e.png">

````sql
WITH week_number AS (
  SELECT GENERATE_SERIES(1,52) AS week_number)
  
SELECT 
  DISTINCT c.week_number
FROM week_number_cte c
LEFT OUTER JOIN clean_weekly_sales s
  ON c.week_number = s.week_number
WHERE s.week_number IS NULL; -- Filter for the missing week numbers whereby the values would be `null`
````

**Answer:**

<details><summary> Click to expand :arrow_down: </summary>
  
| week_number  |
|----------------|
| 1              | 
| 2              |
| 3              |
| 4              |
| 5              |
| 6              |
| 7              |
| 8              |
| 9              |
| 10             |
| 11             |
| 12             |
| 37             |
| 38             |
| 39             |
| 40             |
| 41             |
| 42             |
| 43             |
| 44             |
| 45             |
| 46             |
| 47             |
| 48             |
| 49             |
| 50             |
| 51             |
| 52             |
  
</details>

- 28 `week_number`s are missing from the dataset.

**3. How many total transactions were there for each year in the dataset?**

````sql
SELECT 
  calendar_year, 
  SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;
````

**Answer:**

| calendar_year | total_transactions  |
|---------------|-------------------------------|
| 2018          | 346406460                     |
| 2019          | 365639285                     |
| 2020          | 375813651                     |

**4. What is the total sales for each region for each month?**

````sql
SELECT 
  region, 
  month_number, 
  SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;
````

**Answer:**

<details><summary> Click to expand :arrow_down: </summary>
  
| region        | month_number | total_sales  |
|---------------|--------------|--------------|
| AFRICA        | 3            | 567767480    |
| AFRICA        | 4            | 1911783504   |
| AFRICA        | 5            | 1647244738   |
| AFRICA        | 6            | 1767559760   |
| AFRICA        | 7            | 1960219710   |
| AFRICA        | 8            | 1809596890   |
| AFRICA        | 9            | 276320987    |
| ASIA          | 3            | 529770793    |
| ASIA          | 4            | 1804628707   |
| ASIA          | 5            | 1526285399   |
| ASIA          | 6            | 1619482889   |
| ASIA          | 7            | 1768844756   |
| ASIA          | 8            | 1663320609   |
| ASIA          | 9            | 252836807    |
| CANADA        | 3            | 144634329    |
| CANADA        | 4            | 484552594    |
| CANADA        | 5            | 412378365    |
| CANADA        | 6            | 443846698    |
| CANADA        | 7            | 477134947    |
| CANADA        | 8            | 447073019    |
| CANADA        | 9            | 69067959     |
| EUROPE        | 3            | 35337093     |
| EUROPE        | 4            | 127334255    |
| EUROPE        | 5            | 109338389    |
| EUROPE        | 6            | 122813826    |
| EUROPE        | 7            | 136757466    |
| EUROPE        | 8            | 122102995    |
| EUROPE        | 9            | 18877433     |
| OCEANIA       | 3            | 783282888    |
| OCEANIA       | 4            | 2599767620   |
| OCEANIA       | 5            | 2215657304   |
| OCEANIA       | 6            | 2371884744   |
| OCEANIA       | 7            | 2563459400   |
| OCEANIA       | 8            | 2432313652   |
| OCEANIA       | 9            | 372465518    |
| SOUTH AMERICA | 3            | 71023109     |
| SOUTH AMERICA | 4            | 238451531    |
| SOUTH AMERICA | 5            | 201391809    |
| SOUTH AMERICA | 6            | 218247455    |
| SOUTH AMERICA | 7            | 235582776    |
| SOUTH AMERICA | 8            | 221166052    |
| SOUTH AMERICA | 9            | 34175583     |
| USA           | 3            | 225353043    |
| USA           | 4            | 759786323    |
| USA           | 5            | 655967121    |
| USA           | 6            | 703878990    |
| USA           | 7            | 760331754    |
| USA           | 8            | 712002790    |
| USA           | 9            | 110532368    |

</details>

**5. What is the total count of transactions for each platform?**

````sql
SELECT 
  platform, 
  SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform
ORDER BY platform;
````

**Answer:**

| platform | total_transactions  |
|----------|---------------------|
| Retail   | 1081934227          |
| Shopify  | 5925169             |

**6. What is the percentage of sales for Retail vs Shopify for each month?**

````sql
WITH transactions AS (
  SELECT 
    calendar_year, 
    month_number, 
    platform, 
    SUM(sales) AS monthly_sales
  FROM clean_weekly_sales
  GROUP BY calendar_year, month_number, platform
)

SELECT 
  calendar_year, 
  month_number, 
  ROUND(100 * MAX 
    (CASE WHEN platform = 'Retail' THEN monthly_sales ELSE NULL END) / 
      SUM(monthly_sales),2) AS retail_percentage,
  ROUND(100 * MAX 
    (CASE WHEN platform = 'Shopify' THEN monthly_sales ELSE NULL END) / 
      SUM(monthly_sales),2) AS shopify_percentage
  FROM transactions
  GROUP BY calendar_year, month_number
  ORDER BY calendar_year, month_number;
````

**Answer:**

| month_number | calendar_year | percentage_of_sales_retail | percentage_of_sales_shopify  |
|--------------|---------------|----------------------------|------------------------------|
| 3            | 2018          | 97.9                       | 2.1                          |
| 4            | 2018          | 97.9                       | 2.1                          |
| 5            | 2018          | 97.7                       | 2.3                          |
| 6            | 2018          | 97.8                       | 2.2                          |
| 7            | 2018          | 97.8                       | 2.2                          |
| 8            | 2018          | 97.7                       | 2.3                          |
| 9            | 2018          | 97.7                       | 2.3                          |
| 3            | 2019          | 97.7                       | 2.3                          |
| 4            | 2019          | 97.8                       | 2.2                          |
| 5            | 2019          | 97.5                       | 2.5                          |
| 6            | 2019          | 97.4                       | 2.6                          |
| 7            | 2019          | 97.4                       | 2.6                          |
| 8            | 2019          | 97.2                       | 2.8                          |
| 9            | 2019          | 97.1                       | 2.9                          |
| 3            | 2020          | 97.3                       | 2.7                          |
| 4            | 2020          | 97.0                       | 3.0                          |
| 5            | 2020          | 96.7                       | 3.3                          |
| 6            | 2020          | 96.8                       | 3.2                          |
| 7            | 2020          | 96.7                       | 3.3                          |
| 8            | 2020          | 96.5                       | 3.5                          |

**7. What is the percentage of sales by demographic for each year in the dataset?**

````sql
WITH demographic_sales AS (
  SELECT 
    calendar_year, 
    demographic, 
    SUM(sales) AS yearly_sales
  FROM clean_weekly_sales
  GROUP BY calendar_year, demographic
)

SELECT 
  calendar_year, 
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
ORDER BY calendar_year;
````

**Answer:**

<img width="755" alt="image" src="https://user-images.githubusercontent.com/81607668/131632947-ba6d9444-73e2-4ecd-9ff2-5bd6ab78f66d.png">

**8. Which age_band and demographic values contribute the most to Retail sales?**

````sql
SELECT 
  age_band, 
  demographic, 
  SUM(sales) AS retail_sales,
  ROUND(100 * SUM(sales)::NUMERIC / SUM(SUM(sales)) OVER (),2) AS contribution_percentage
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY retail_sales DESC;
````

**Answer:**

<img width="650" alt="image" src="https://user-images.githubusercontent.com/81607668/131634091-bc09c295-f880-4ec1-ad2f-d503bb3b04b9.png">

The highest retail sales are contributed by unknown `age_band` and `demographic` at 42% followed by retired families at 16.73% and retired couples at 16.07%.

**9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?**

````sql
SELECT 
  calendar_year, 
  platform, 
  ROUND(AVG(avg_transaction),0) AS avg_transaction_row, 
  SUM(sales) / sum(transactions) AS avg_transaction_group
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;
````

**Answer:**

| calendar_year | platform | avg_transaction_row | avg_transaction_group  |
|---------------|----------|-------------|----------------|
| 2018          | Retail   | 36.6        | 42.9           |
| 2018          | Shopify  | 192.5       | 188.3          |
| 2019          | Retail   | 36.8        | 42.0           |
| 2019          | Shopify  | 183.4       | 177.6          |
| 2020          | Retail   | 36.6        | 40.6           |
| 2020          | Shopify  | 179.0       | 174.9          |

***