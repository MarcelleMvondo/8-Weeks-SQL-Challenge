-- A. Customer Nodes Exploration

-- 1. How many unique nodes are there on the Data Bank system?
SELECT COUNT(DISTINCT node_id)
FROM customer_nodes

--2. What is the number of nodes per region?
SELECT r.region_id, r.region_name, COUNT(*) AS node_count
FROM regions r
JOIN customer_nodes n
  ON r.region_id = n.region_id
GROUP BY r.region_id, r.region_name
ORDER BY region_id

--3. How many customers are allocated to each region?
SELECT region_id, COUNT(customer_id) AS nb_customer
FROM customer_nodes
GROUP BY region_id
ORDER BY region_id

--4. How many days on average are customers reallocated to a different node?
WITH node_diff AS 
(
  SELECT customer_id, node_id, start_date, end_date,
    end_date - start_date AS diff
  FROM customer_nodes
  WHERE end_date != '9999-12-31'
  GROUP BY customer_id, node_id, start_date, end_date
  ORDER BY customer_id, node_id
),
sum_diff_cte AS 
(
  SELECT customer_id, node_id, SUM(diff) AS sum_diff
  FROM node_diff
  GROUP BY customer_id, node_id
)
SELECT ROUND(AVG(sum_diff),2) AS avg_reallocation_days
FROM sum_diff_cte


