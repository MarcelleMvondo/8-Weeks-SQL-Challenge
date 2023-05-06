--B. Runner and Customer Experience

--1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT number_of_week,number_of_registrations
FROM
  (SELECT 'Week ' || RANK () 
	  	         OVER (ORDER BY date_trunc('week', registration_date)) number_of_week,
        date_trunc('week', registration_date) AS week,
        COUNT(*) AS number_of_registrations
    FROM runners
    GROUP BY week
  ) AS count_weeks
  
--2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT runner_id,
  	ROUND(AVG(DATE_PART
			  ('minute',
			   TO_TIMESTAMP(pickup_time, 'YYYY-MM-DD HH24:MI:SS') 
			   	- c.order_time)))AS average_pickup_time_in_minutes
FROM runner_orders AS r, customer_orders AS c
WHERE c.order_id = r.order_id
  AND pickup_time != 'null'
  AND distance != 'null'
GROUP BY runner_id  
ORDER BY runner_id
  
--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH prepare_time AS
(
SELECT c.order_id, COUNT(c.order_id) AS no_pizza_ordered, c.order_time, r.pickup_time, 
			DATE_PART('hour', c.order_time - r.pickup_time )  * 60 
	+ DATE_PART('minute', c.order_time - r.pickup_time ) AS time_taken_to_prepare 
FROM _customer_orders AS c
JOIN _runner_orders AS r
	ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY c.order_id, c.order_time, r.pickup_time
)
SELECT no_pizza_ordered, AVG(time_taken_to_prepare) AS avg_time_to_prepare
FROM prepare_time
WHERE time_taken_to_prepare > 1
GROUP BY no_pizza_ordered

--4. What was the average distance travelled for each customer?
SELECT c.customer_id, ROUND(AVG(r.distance)::numeric,1) AS avg_distance
FROM _customer_orders AS c
JOIN _runner_orders AS r
	ON c.order_id = r.order_id
WHERE cancellation is null
GROUP BY c.customer_id

--5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration::NUMERIC) - MIN(duration::NUMERIC) AS delivery_time_difference
FROM _runner_orders
where cancellation is null

--6. What was the average speed for each runner for each delivery and do you notice any trend for these values? 
SELECT r.runner_id, c.order_id, 
  	ROUND((r.distance/r.duration * 60)::numeric, 2) AS avg_speed
FROM _runner_orders AS r
JOIN _customer_orders AS c
  ON r.order_id = c.order_id
WHERE cancellation is null
GROUP BY r.runner_id, c.customer_id, c.order_id, r.distance, r.duration
ORDER BY c.order_id;

--7. What is the successful delivery percentage for each runner?
SELECT runner_id, 
	ROUND(100 * SUM(
  		CASE 
			WHEN distance is null THEN 0
    		ELSE 1 
		END) / COUNT(*), 0) AS success_percent
FROM _runner_orders
GROUP BY runner_id;