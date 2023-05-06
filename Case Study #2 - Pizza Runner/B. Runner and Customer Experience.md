# Case Study #2 Pizza Runner 🍕

## Solution - B. Runner and Customer Experience

### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

````sql
SELECT number_of_week,number_of_registrations
FROM
  (SELECT 'Week ' || RANK () 
	  	         OVER (ORDER BY date_trunc('week', registration_date)) number_of_week,
        date_trunc('week', registration_date) AS week,
        COUNT(*) AS number_of_registrations
    FROM runners
    GROUP BY week
  ) AS count_weeks;
````

**Answer:**

| number_of_week | number_of_registrations |
| -------------- | ----------------------- |
| Week 1         | 2                       |
| Week 2         | 1                       |
| Week 3         | 1                       |

- On Week 1, 2 new runners signed up.
- On Week 2 and 3, 1 new runner signed up.

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

````sql
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
ORDER BY runner_id;
````

**Answer:**

| runner_id | average_pickup_time_in_minutes |
| --------- | ------------------------------ |
| 1         | 15                             |
| 2         | 23                             |
| 3         | 10                             |


### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql
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
GROUP BY no_pizza_ordered;
````

**Answer:**

| no_pizza_ordered| avg_time_to_prepare |
| -------------- | --------------------------------- |
| 3              | 10                                |
| 2              | 10                                |
| 2              | 8                                 |
| 1              | 10                                |
| 1              | 20                                |
| 1              | 10                                |
| 1              | 10                                |
| 1              | 10                                |  

- On average, a single pizza order takes 12 minutes to prepare.
- An order with 3 pizzas takes 30 minutes at an average of 10 minutes per pizza.
- It takes 16 minutes to prepare an order with 2 pizzas which is 8 minutes per pizza — making 2 pizzas in a single order the ultimate efficiency rate.

### 4. Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql
SELECT c.customer_id, ROUND(AVG(r.distance)::numeric,1) AS avg_distance
FROM _customer_orders AS c
JOIN _runner_orders AS r
	ON c.order_id = r.order_id
WHERE cancellation is null
GROUP BY c.customer_id;
````

**Answer:**

| customer_id | avg_distance |
| ----------- | ------------------- |
| 101         | 20.0                |
| 102         | 16.7                |
| 103         | 23.4                |
| 104         | 10.0                |
| 105         | 25.0                |  

_(Assuming that distance is calculated from Pizza Runner HQ to customer’s place)_

- Customer 104 stays the nearest to Pizza Runner HQ at average distance of 10km, whereas Customer 105 stays the furthest at 25km.

### 5. What was the difference between the longest and shortest delivery times for all orders?

````sql
SELECT MAX(duration::NUMERIC) - MIN(duration::NUMERIC) AS delivery_time_difference
FROM _runner_orders
where cancellation is null;
````

**Answer:**
| delivery_time_difference |
| ----------------------------------- |
| 30                                  |  

- The difference between longest (40 minutes) and shortest (10 minutes) delivery time for all orders is 30 minutes.

### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

````sql
SELECT c.order_id, r.runner_id,
  	ROUND((r.distance/r.duration * 60)::numeric, 2) AS avg_speed
FROM _runner_orders AS r
JOIN _customer_orders AS c
  ON r.order_id = c.order_id
WHERE cancellation is null
GROUP BY r.runner_id, c.customer_id, c.order_id, r.distance, r.duration
ORDER BY c.order_id;
````

**Answer:**

| order_id | runner_id | avg_speed |
| -------- | --------- | -------------------- |
| 1        | 1         | 37,5                   |
| 2        | 1         | 44,44                   |
| 3        | 1         | 40,2                   |
| 4        | 2         | 35,1                   |
| 5        | 3         | 40,0                   |
| 7        | 2         | 60,0                   |
| 8        | 2         | 93,6                   |
| 10       | 1         | 60,0                   | 

_(Average speed = Distance in km / Duration in hour)_
- Runner 1’s average speed runs from 37.5km/h to 60km/h.
- Runner 2’s average speed runs from 35.1km/h to 93.6km/h. Danny should investigate Runner 2 as the average speed has a 300% fluctuation rate!
- Runner 3’s average speed is 40km/h

### 7. What is the successful delivery percentage for each runner?

````sql
SELECT runner_id, 
	ROUND(100 * SUM(
  		CASE 
			WHEN distance is null THEN 0
    		ELSE 1 
		END) / COUNT(*), 0) AS success_percent
FROM _runner_orders
GROUP BY runner_id;
````

**Answer:**

| runner_id | success_percent |
| --------- | --------------------------- |
| 1         | 100                         |
| 2         | 75                          |
| 3         | 50                          |

- Runner 1 has 100% successful delivery.
- Runner 2 has 75% successful delivery.
- Runner 3 has 50% successful delivery

***