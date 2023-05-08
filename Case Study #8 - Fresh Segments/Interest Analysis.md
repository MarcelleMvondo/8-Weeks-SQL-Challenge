# 🍅 Case Study #8 - Fresh Segments

## 📚 Solution - Interest Analysis

### 1. Which interests have been present in all `month_year` dates in our dataset?

Find out how many unique `month_year` in dataset.

```sql
SELECT 
  COUNT(DISTINCT month_year) AS month_year_count, 
FROM fresh_segments.interest_metrics;
```

| month_year_count |
| ----- |
| 14    |

There are 14 distinct `month_year` dates and 1202 distinct `interest_id`s.

```sql
WITH interest AS 
(
SELECT interest_id, 
  COUNT(DISTINCT month_year) AS total_months
FROM fresh_segments.interest_metrics
WHERE month_year IS NOT NULL
GROUP BY interest_id
)
SELECT 
  c.total_months,
  COUNT(DISTINCT c.interest_id)
FROM interest_cte c
WHERE total_months = 14
GROUP BY c.total_months
ORDER BY count DESC
```

### 2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?

Find out the point in which interests present in a particular number of months are not performing well. For example, interest id 101 only appeared in 6 months due to non or lack of clicks and interactions, so we can consider to cut the interest off. 

```sql
WITH interest_months AS 
(
	SELECT
	  interest_id,
	  MAX(DISTINCT month_year) AS total_months
	FROM fresh_segments.interest_metrics
	WHERE interest_id IS NOT NULL
	GROUP BY interest_id
),
interest_counts AS 
(
  SELECT
    total_months,
    COUNT(DISTINCT interest_id) AS interest_count
  FROM cte_interest_months
  GROUP BY total_months
)
SELECT
  total_months,
  interest_count,
  ROUND(100 * SUM(interest_count) OVER (ORDER BY total_months DESC) / 
      (SUM(INTEREST_COUNT) OVER ()),2) AS cumulative_percentage
FROM cte_interest_counts
```

| total_months | number_of_interests | cum_top | cum_top_reversed |
| ------------ | ------------------- | ------- | ---------------- |
| 1            | 13                  | 1.08    | 98.92            |
| 2            | 12                  | 2.08    | 97.92            |
| 3            | 15                  | 3.33    | 96.67            |
| 4            | 32                  | 5.99    | 94.01            |
| 5            | 38                  | 9.15    | 90.85            |
| 6            | 33                  | 11.90   | 88.10            |
| 7            | 90                  | 19.38   | 80.62            |
| 8            | 67                  | 24.96   | 75.04            |
| 9            | 95                  | 32.86   | 67.14            |
| 10           | 85                  | 39.93   | 60.07            |
| 11           | 95                  | 47.84   | 52.16            |
| 12           | 65                  | 53.24   | 46.76            |
| 13           | 82                  | 60.07   | 39.93            |
| 14           | 480                 | 100.00  | 0.00             |


### 3. If we were to remove all `interest_id` values which are lower than the `total_months` value we found in the previous question - how many total data points would we be removing?
```sql
WITH interests AS 
(
    SELECT interest_id
    FROM interest_metrics AS im 
    GROUP BY 1 
    HAVING COUNT(interest_id) < 6
 )
SELECT
  COUNT(interest_id) AS number_of_interests
FROM interests
ORDER BY 1
```

| number_of_interests |
| ------------------- |
| 117                 |

### 4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective. 

### 5. If we include all of our interests regardless of their counts - how many unique interests are there for each month?
```sql
SELECT
  month_year,
  COUNT(interest_id) AS number_of_interests
FROM interest_metrics AS im
WHERE month_year IS NOT NULL
  AND interest_id :: int 
  	IN(SELECT interest_id :: int
    	FROM interest_metrics 
    	GROUP BY 1
    	HAVING COUNT(interest_id) > 5)
GROUP BY 1
ORDER BY 1
```

| month_year | number_of_included_interests | 
| ---------- | ---------------------------- | 
| 07-2018    | 709                          |
| 08-2018    | 752                          |
| 09-2018    | 774                          | 
| 10-2018    | 853                          | 
| 11-2018    | 925                          |
| 12-2018    | 986                          | 
| 01-2019    | 966                          | 
| 02-2019    | 1072                         |
| 03-2019    | 1078                         | 
| 04-2019    | 1035                         | 
| 05-2019    | 827                          |
| 06-2019    | 804                          | 
| 07-2019    | 836                          | 
| 08-2019    | 1062                         | 