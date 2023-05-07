/*-----------
	Interest Analysis
-----------*/

-- 1. Which interests have been present in all month_year dates in our dataset?
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

/*---------
2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - 
which total_months value passes the 90% cumulative percentage value? 
---------*/
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

/*---------------
3. If we were to remove all interest_id values which are lower than 
the total_months value we found in the previous question - how many total data points would we be removing?
-------------*/
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

/*---------------
4. Does this decision make sense to remove these data points from a business perspective? 
Use an example where there are all 14 months present to a removed interest example for your arguments - 
think about what it means to have less months present from a segment perspective.
-------------*/


-- 5. After removing these interests - how many unique interests are there for each month?
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
