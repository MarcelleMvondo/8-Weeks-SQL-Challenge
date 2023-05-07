/*-----------
	Data Exploration and Cleansing
-----------*/

/*-- 1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type 
with the start of the month --*/

ALTER TABLE fresh_segments.interest_metrics
ALTER month_year TYPE DATE USING month_year::DATE

/*-- 2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted 
in chronological order (earliest to latest) with the null values appearing first? --*/
SELECT 
  month_year, COUNT(*)
FROM fresh_segments.interest_metrics
GROUP BY month_year
ORDER BY month_year NULLS FIRST

-- 3. What do you think we should do with these null values in the fresh_segments.interest_metrics?
SELECT 
  ROUND(100 * (SUM(CASE WHEN interest_id IS NULL THEN 1 END) * 1.0 /
    COUNT(*)),2) AS null_perc
FROM fresh_segments.interest_metrics

/*-- 4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in 
the fresh_segments.interest_map table? What about the other way around? --*/
SELECT 
  COUNT(DISTINCT map.id) AS map_id_count,
  COUNT(DISTINCT metrics.interest_id) AS metrics_id_count,
  SUM(CASE WHEN map.id is NULL THEN 1 END) AS not_in_metric,
  SUM(CASE WHEN metrics.interest_id is NULL THEN 1 END) AS not_in_map
FROM fresh_segments.interest_map map
FULL OUTER JOIN fresh_segments.interest_metrics metrics
  ON metrics.interest_id = map.id
  
--5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table
SELECT 
  id, 
  interest_name, 
  COUNT(*)
FROM fresh_segments.interest_map map
JOIN fresh_segments.interest_metrics metrics
  ON map.id = metrics.interest_id
GROUP BY id, interest_name
ORDER BY count DESC, id

/*----------
6. What sort of table join should we perform for our analysis and why? Check your logic by checking 
the rows where 'interest_id = 21246' in your joined output and include all columns from 
fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.
------------*/
SELECT *
FROM fresh_segments.interest_map map
INNER JOIN fresh_segments.interest_metrics metrics
  ON map.id = metrics.interest_id
WHERE metrics.interest_id = 21246   
  AND metrics._month IS NOT NULL
  
/*--------------
7. Are there any records in your joined table where the month_year value is before the created_at value 
from the fresh_segments.interest_map table? Do you think these values are valid and why?
-------------*/



