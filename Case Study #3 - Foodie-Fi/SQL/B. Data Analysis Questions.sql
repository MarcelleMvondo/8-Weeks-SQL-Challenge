-- B. Data Analysis Questions

-- 1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) AS total_customer 
FROM subscriptions

-- 2. What is the monthly distribution of trial plan `start_date` values for our dataset
SELECT DATE_TRUNC('month',start_date)::date as start_month, COUNT(*)
FROM subscriptions AS s
JOIN plans AS p
	ON p.plan_id = s.plan_id
WHERE plan_name = 'trial'
GROUP BY start_month
ORDER BY start_month

-- 3. What plan `start_date` values occur after the year 2020 for our dataset? 
SELECT p.plan_id,plan_name, COUNT(*) AS events
FROM plans AS p
JOIN subscriptions AS s
	ON s.plan_id = p.plan_id
WHERE DATE_PART('year',start_date)>2020
GROUP BY plan_name,p.plan_id
ORDER BY plan_id

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT COUNT(*) AS churned_customers,
  ROUND(100 * COUNT(*)::NUMERIC / 
		(SELECT COUNT(DISTINCT customer_id)FROM subscriptions),1) AS churn_percentage
FROM subscriptions s
JOIN plans p
  ON s.plan_id = p.plan_id
WHERE s.plan_id = 4

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
WITH ranking AS 
(
	SELECT s.customer_id, s.plan_id, p.plan_name,
	  ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.plan_id) AS plan_rank     
	FROM subscriptions s
	JOIN plans p
	  ON s.plan_id = p.plan_id
) 
SELECT COUNT(*) AS churn_count, ROUND(100 * COUNT(*) / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM subscriptions),0) AS churn_percentage
FROM ranking
WHERE plan_id = 4
 AND plan_rank = 2

-- 6. What is the number and percentage of customer plans after their initial free trial?
WITH next_plan AS 
(
	SELECT customer_id, plan_id,
	  LEAD(plan_id, 1) OVER( PARTITION BY customer_id ORDER BY plan_id) as next_plan
	FROM subscriptions
)
SELECT next_plan, COUNT(*) AS conversions, 
	ROUND(100 * COUNT(*)::NUMERIC /
    (SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS percentage
FROM next_plan_cte
WHERE next_plan IS NOT NULL 
  AND plan_id = 0
GROUP BY next_plan

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH next_plan AS
(
	SELECT customer_id, plan_id, start_date,
	  LEAD(start_date, 1) OVER(PARTITION BY customer_id ORDER BY start_date) as next_date
	FROM subscriptions
	WHERE start_date <= '2020-12-31'
),
customer_breakdown AS
(
  SELECT plan_id, COUNT(DISTINCT customer_id) AS customers
  FROM next_plan
  WHERE (next_date IS NOT NULL AND (start_date < '2020-12-31'
		AND next_date > '2020-12-31'))
        OR (next_date IS NULL AND start_date < '2020-12-31')
  GROUP BY plan_id
)
SELECT plan_id, customers, 
  ROUND(100 * customers::NUMERIC / 
		(SELECT COUNT(DISTINCT customer_id) 
    FROM subscriptions),1) AS percentage
FROM customer_breakdown
GROUP BY plan_id, customers
ORDER BY plan_id

-- 8. How many customers have upgraded to an annual plan in 2020?
SELECT COUNT(DISTINCT customer_id) AS customers_number
FROM subscriptions
WHERE plan_id = 3
	AND DATE_PART('year',start_date) = 2020
	
-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
SELECT plan_name, ROUND(AVG(s.start_date - t.start_date)) AS average_days
FROM subscriptions AS s
JOIN plans AS p 
	ON s.plan_id = p.plan_id
JOIN (SELECT customer_id, start_date  
    	FROM subscriptions
    	WHERE plan_id = 0
      ) AS t 
	ON s.customer_id = t.customer_id
WHERE p.plan_id = 3
GROUP BY plan_name
  
-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)


-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH next_plan AS 
(
	SELECT customer_id, plan_id, start_date,
	  LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) as next_plan
	FROM subscriptions
)
SELECT COUNT(*) AS Customer_downgraded
FROM next_plan
WHERE start_date <= '2020-12-31'
  AND plan_id = 2 
  AND next_plan = 1


