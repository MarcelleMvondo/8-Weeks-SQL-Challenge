--A. Pizza Metrics

--1. How many pizzas were ordered?
select count(*) as nb_pizzas_ordered
from _customer_orders

--2. How many unique customer orders were made?
select count(distinct order_id) as unique_customer_orders
from _customer_orders

--3. How many successful orders were delivered by each runner?
select runner_id, count(distinct order_id) as nb_successful_delivery
from _runner_orders
where cancellation is null
group by runner_id

--4. How many of each type of pizza was delivered?
select pizza_name, count(pizza_name) as nb_pizza_delivered
from pizza_names as p
join _customer_orders as c
	on p.pizza_id = c.pizza_id
join _runner_orders as r 
	on c.order_id = r.order_id
where cancellation is null
group by pizza_name

--5. How many Vegetarian and Meatlovers were ordered by each customer?
select c.customer_id, p.pizza_name, count(pizza_name) as nb_pizza_ordered
from pizza_names as p
join _customer_orders as c
	on p.pizza_id = c.pizza_id
join _runner_orders as r 
	on c.order_id = r.order_id
group by pizza_name, customer_id
order by customer_id

--6. What was the maximum number of pizzas delivered in a single order?
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

--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
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

--8. How many pizzas were delivered that had both exclusions and extras?
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

--9. What was the total volume of pizzas ordered for each hour of the day?
select date_part('hour', order_time) as hour, count(order_id) as pizzas_ordered_per_hour
from _customer_orders
group by hour
order by hour

--10. What was the volume of orders for each day of the week?
with day_of_week as
(
	select *,
		case 
			when extract(isodow from order_time)=1 then 'Monday'
			when extract(isodow from order_time)=2 then 'Tuesday'
			when extract(isodow from order_time)=3 then 'Wednesday'
			when extract(isodow from order_time)=4 then 'Thursday '
			when extract(isodow from order_time)=5 then 'Friday'
			when extract(isodow from order_time)=6 then 'Saturday'
			when extract(isodow from order_time)=7 then 'Sunday'
		end as day
	from _customer_orders
)
select day, count(order_id)
from day_of_week
group by day