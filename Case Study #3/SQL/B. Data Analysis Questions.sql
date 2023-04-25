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

-- 6. What is the number and percentage of customer plans after their initial free trial?

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
SELECT plan_name, COUNT(DISTINCT customer_id) AS customer_count,
	ROUND(100 * COUNT(*)::NUMERIC / 
		(SELECT COUNT(DISTINCT customer_id)FROM subscriptions),1) AS percentage
FROM plans AS p
JOIN subscriptions AS s 
	ON s.plan_id = p.plan_id
WHERE start_date <= '2020-12-31'
GROUP BY plan_name

-- 8. How many customers have upgraded to an annual plan in 2020?
SELECT COUNT(DISTINCT customer_id) AS customers_number
FROM subscriptions
WHERE plan_id = 3
	AND DATE_PART('year',start_date) = 2020
	
-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?


