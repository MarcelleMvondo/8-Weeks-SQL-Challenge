# Case Study Questions
## Solution - A. Pizza Metrics

### 1. How many pizzas were ordered?

````sql
select count(*) as nb_pizzas_ordered
from _customer_orders
  ````
  
| nb_pizzas_ordered |
| ----------------------- |
| 14                      |


### 2. How many unique customer orders were made?

````sql
select count(distinct order_id) as unique_customer_orders
from _customer_orders

  ````

| unique_customer_orders |
| ---------------- |
| 10                |

### 3. How many successful orders were delivered by each runner?

````sql
select runner_id, count(distinct order_id) as nb_successful_delivery
from _runner_orders
where cancellation is null
group by runner_id
  ````
  
| runner_id | nb_successful_delivery |
| --------- | ---------------- |
| 1         | 4                |
| 2         | 3                |
| 3         | 1                |


### 4. How many of each type of pizza was delivered?

````sql
select pizza_name, count(pizza_name) as nb_pizza_delivered
from pizza_names as p
join _customer_orders as c
	on p.pizza_id = c.pizza_id
join _runner_orders as r 
	on c.order_id = r.order_id
where cancellation is null
group by pizza_name
  ````

| pizza_name | nb_pizza_delivered |
| ---------- | -------------------------- |
| Meatlovers | 9                          |
| Vegetarian | 3                          |


### 5. How many Vegetarian and Meatlovers were ordered by each customer?

````sql
select c.customer_id, p.pizza_name, count(pizza_name) as nb_pizza_ordered
from pizza_names as p
join _customer_orders as c
	on p.pizza_id = c.pizza_id
join _runner_orders as r 
	on c.order_id = r.order_id
group by pizza_name, customer_id
order by customer_id
  ````
  
| customer_id | pizza_name | nb_pizza_ordered |
| ----------- | ---------- | -------------------------- |
| 101         | Meatlovers | 2                          |
| 101         | Vegetarian | 1                          |
| 102         | Meatlovers | 2                          |
| 102         | Vegetarian | 1                          |
| 103         | Meatlovers | 3                          |
| 103         | Vegetarian | 1                          |
| 104         | Meatlovers | 3                          |
| 105         | Vegetarian | 1                          |

  
***Customer with ID 101 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza***

***Customer with ID 102 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza***

***Customer with ID 103 ordered 3 Meatlovers pizzas and 1 Vegetarian pizza***

***Customer with ID 104 ordered 3 Meatlovers pizzas***

***Customer with ID 105 ordered 1 Vegetarian pizza***

### 6. What was the maximum number of pizzas delivered in a single order?

````sql
with count_delivery as
(
	select c.order_id, count(c.pizza_id) as pizza_count
	from _customer_orders as c
	join _runner_orders as r
		on c.order_id = r.order_id
	where cancellation is null
	group by c.order_id
)
select max(pizza_count) as max_pizza_per_order
from count_delivery
  ````

| max_pizza_per_order |
| ------------------ |
| 3                  |


### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

````sql
select c.customer_id, 
	sum(case
			when c.exclusions is not null or c.extras is not null then 1
			else 0
		end
		) as at_least_1_change,
	sum(case
			when c.exclusions is null and c.extras is null then 1
			else 0
		end
		) as no_changes
from _customer_orders as c
join _runner_orders as r
	on c.order_id = r.order_id
where cancellation is null
group by c.customer_id
  ````
  
| order_id | customer_id | pizza_id | exclusions | extras | order_time               |
| -------- | ----------- | -------- | ---------- | ------ | ------------------------ |
| 4        | 103         | 1        | 4          |        | 2020-01-04T13:23:46.000Z |
| 4        | 103         | 1        | 4          |        | 2020-01-04T13:23:46.000Z |
| 4        | 103         | 2        | 4          |        | 2020-01-04T13:23:46.000Z |
| 5        | 104         | 1        | null       | 1      | 2020-01-08T21:00:29.000Z |
| 6        | 101         | 2        | null       | null   | 2020-01-08T21:03:13.000Z |
| 7        | 105         | 2        | null       | 1      | 2020-01-08T21:20:29.000Z |
| 8        | 102         | 1        | null       | null   | 2020-01-09T23:54:33.000Z |
| 9        | 103         | 1        | 4          | 1, 5   | 2020-01-10T11:22:59.000Z |
| 10       | 104         | 1        | null       | null   | 2020-01-11T18:34:49.000Z |
| 10       | 104         | 1        | 2, 6       | 1, 4   | 2020-01-11T18:34:49.000Z |


Data type in the extras and exclusions columns is `varchar`, and the values are in the form of NaN (empty values), 'null' - string values or numeric values: single values or separated by commas. I decided to use a regular expression to find numeric values in these columns (thanks, StackOverFlow).
Another tough thing is that order #4 has 2 duplicated rows - all 2 pizzas in the order have exclusions and these pizzas should be counted separately. But when we use a `GROUP BY` statement, it groups these 2 records into one. So we need to avoid that grouping in advance. We can use CTE and `row_number` window function in the inner query to add a pseudo auto increment which allows us to keep these records separated. 

And one more solution - pre clean extras and exclusions columns as recommended by Danny, remove NaN and 'null' values. I won't do it now. 

  
| customer_id | at_least_1_change      | no_changes |
| ----------- | ------------ | ---------------- |
| 101         | 0   | 2                |
| 102         | 0   | 3                |
| 105         | 1 | 0                |
| 104         | 2 | 1               |
| 103         | 3 | 0                |


***Customer with ID 101 ordered 2 pizzas without changes***

***Customer with ID 102 ordered 3 pizzas without changes***

***Customer with ID 103 ordered 3 pizzas with changes***

***Customer with ID 104 ordered 2 pizza with changes***

***Customer with ID 104 ordered 1 pizzas without changes***

***Customer with ID 105 ordered 1 pizza with changes***

***In total, 6 pizzas had changes and 6 pizzas had no changes***

### 8. How many pizzas were delivered that had both exclusions and extras?

````sql
select 
	sum(case
			when c.exclusions is not null and c.extras is not null then 1
			else 0
		end
		) as pizza_w_exclusions_extras
from _customer_orders as c
join _runner_orders as r
	on c.order_id = r.order_id
where cancellation is null
  ````
  
| pizza_w_exclusions_extras  |
| -------------------------- |
| 1 |


### 9. What was the total volume of pizzas ordered for each hour of the day?

````sql
select date_part('hour', order_time) as hour, count(order_id) as pizzas_ordered_per_hour
from _customer_orders
group by hour
order by hour
````

| hours | pizzas_ordered_per_hour |
| ----- | -------------- |
| 11    | 1              |
| 13    | 3              |
| 18    | 3              |
| 19    | 1              |
| 21    | 3              |
| 23    | 3              |

### 10. What was the volume of orders for each day of the week?

````sql
SELECT TO_CHAR(order_time, 'Day') AS day_name, count(order_id)
FROM _customer_orders
GROUP BY day_name
  ````
  
| day | pizzas_ordered_per_day |
| ----------- | -------------- |
| Wednesnday  | 5              |
| Saturday    | 5              |
| Thursday    | 3              |
| Friday      | 1              |