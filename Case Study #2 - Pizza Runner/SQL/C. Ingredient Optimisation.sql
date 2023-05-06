--C. Ingredient Optimisation

-- 1. What are the standard ingredients for each pizza?
SELECT pizza_name, STRING_AGG(topping_name, ', ') AS toppings
FROM pizza_toppings AS t, pizza_recipes AS r 
JOIN pizza_names AS n
	ON n.pizza_id = r.pizza_id
GROUP BY pizza_name

-- 2. What was the most commonly added extra?
WITH extras_table AS 
(
	SELECT UNNEST(STRING_TO_ARRAY(extras, ',') :: int []) AS topping_id		
	FROM _customer_orders AS c
	WHERE extras != 'null'       
)
SELECT topping_name,COUNT(topping_name) AS nb_of_pizzas    
FROM extras_table AS et
JOIN pizza_toppings AS t 
  	ON et.topping_id = t.topping_id
GROUP BY topping_name
ORDER BY COUNT(topping_name) DESC
LIMIT 1

-- 3. What was the most common exclusion?
WITH exclusion_table AS 
(
	SELECT UNNEST(STRING_TO_ARRAY(exclusions, ',') :: int []) AS topping_id		
	FROM _customer_orders AS c
	WHERE exclusions != 'null'       
)
SELECT topping_name,COUNT(topping_name) AS nb_of_pizzas    
FROM exclusion_table AS et
JOIN pizza_toppings AS t 
  	ON et.topping_id = t.topping_id
GROUP BY topping_name
ORDER BY COUNT(topping_name) DESC
LIMIT 1

/* --------------------
4. Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
   --------------------*/
   
   
/* --------------------
5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
   --------------------*/
   
-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?