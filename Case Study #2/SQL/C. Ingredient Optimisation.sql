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

