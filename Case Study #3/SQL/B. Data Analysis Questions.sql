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
WITH count_customer AS
(
	SELECT 
		CASE 
			WHEN plan_name = 'churn' THEN COUNT(DISTINCT customer_id)
		END AS churned_customers,
		CASE 
			WHEN plan_name = 'trial' THEN COUNT(DISTINCT customer_id)
		END AS total_customers
	FROM subscriptions AS s
	JOIN plans AS p
		ON p.plan_id = s.plan_id
	GROUP BY plan_name
)
SELECT SUM(churned_customers) AS churned_customers, 
	ROUND((SUM(churned_customers)/SUM(total_customers))*100,1) AS churn_percentage
FROM count_customer