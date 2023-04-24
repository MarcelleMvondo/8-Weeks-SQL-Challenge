-- Solution - A. Customer Journey

/* Based off the 8 sample customers provided in the sample subscriptions table below, 
write a brief description about each customer’s onboarding journey.*/

SELECT s.customer_id, p.plan_id, p.plan_name, s.start_date
FROM plans AS p
JOIN subscriptions AS s
	ON p.plan_id = s.plan_id
WHERE customer_id IN (1,2,11,13,15,16,18,19)
