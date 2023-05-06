-- C. Challenge Payment Question
/* --------------------
The Foodie-Fi team wants you to create a new `payments` table for the year 2020 that includes amounts paid by each customer in the `subscriptions` table with the following requirements:
- monthly payments always occur on the same day of month as the original `start_date` of any monthly paid plan
- 
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- 
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- 
- once a customer churns they will no longer make payments
   --------------------*/

SELECT customer_id, plan_id, plan_name, payment_date ::date :: varchar,
  CASE
    WHEN LAG(plan_id) OVER (PARTITION BY customer_id ORDER BY plan_id ) != plan_id
		AND DATE_PART('day', payment_date - LAG(payment_date)
				OVER (PARTITION BY customer_id ORDER BY plan_id))
			< 30 THEN amount - LAG(amount) OVER (PARTITION BY customer_id ORDER BY plan_id)
    ELSE amount
  END AS amount,
  RANK() OVER(PARTITION BY customer_id ORDER BY payment_date ) AS payment_order 
  
INTO TEMP TABLE payments
FROM
  (
    SELECT customer_id, s.plan_id, plan_name, 
	  generate_series(start_date,
        CASE
          WHEN s.plan_id = 3 THEN start_date
          WHEN s.plan_id = 4 THEN NULL
          WHEN LEAD(start_date) 
			OVER (PARTITION BY customer_id ORDER BY start_date)
            	IS NOT NULL THEN LEAD(start_date)
            OVER (PARTITION BY customer_id ORDER BY start_date)
          ELSE '2020-12-31' :: date
        END,
        '1 month' + '1 second' :: interval
      ) AS payment_date,
      price AS amount
    FROM subscriptions AS s 
    JOIN plans AS p 
	  ON s.plan_id = p.plan_id
    WHERE s.plan_id != 0
      AND start_date < '2021-01-01' :: date
    GROUP BY customer_id, s.plan_id, plan_name, start_date, price    
  ) AS t
ORDER BY customer_id
  