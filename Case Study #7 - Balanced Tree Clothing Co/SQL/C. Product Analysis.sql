/* --------------------
Product Analysis
   --------------------*/

-- 1. What are the top 3 products by total revenue before discount?

WITH revenue AS
(
    SELECT product_name, SUM(qty * s.price) AS total_revenue,
      ROW_NUMBER() OVER(ORDER BY SUM(qty * s.price) DESC) AS row
    FROM sales AS s
	JOIN product_details AS pd 
		ON s.prod_id = pd.product_id
    GROUP BY product_name  
 )
SELECT product_name, total_revenue
FROM revenue
WHERE row in (1, 2, 3)
  

-- 2. What is the total quantity, revenue and discount for each segment?
SELECT segment_name, SUM(qty) AS total_quantity,
  SUM(qty * s.price) AS total_revenue,
  round(SUM(qty * s.price * discount :: numeric / 100),2) AS total_discount
FROM sales AS s
JOIN product_details AS pd 
	ON s.prod_id = pd.product_id
GROUP BY segment_name 
ORDER BY 1

-- 3. What is the top selling product for each segment?
WITH revenue AS 
(
    SELECT segment_name, product_name,
      SUM(qty) AS total_quantity,
      SUM(qty * s.price) AS total_revenue,
      ROW_NUMBER() OVER(PARTITION BY segment_name
        	ORDER BY SUM(qty * s.price) DESC) AS revenue_rank,
	  ROW_NUMBER() OVER(PARTITION BY segment_name
        	ORDER BY  SUM(qty) DESC) AS qty_rank,
    FROM sales AS s
    JOIN product_details AS pd 
		ON s.prod_id = pd.product_id
    GROUP BY segment_name, product_name
)
SELECT segment_name, product_name,
  total_quantity, total_revenue
FROM revenue
  
WHERE revenue_rank = 1
  OR qty_rank = 1
  
-- 4. What is the total quantity, revenue and discount for each category?
SELECT category_name,
  SUM(qty) AS total_quantity,
  SUM(qty * s.price) AS total_revenue,
  round(SUM(qty * s.price * discount :: numeric / 100),2) AS total_discount
FROM sales AS s
JOIN product_details AS pd 
	ON s.prod_id = pd.product_id
GROUP BY category_name
ORDER BY 1

-- 5. What is the top selling product for each category?
WITH revenue AS 
(
    SELECT category_name, product_name,
      	SUM(qty) AS total_quantity,
      	SUM(qty * s.price) AS total_revenue,
      	ROW_NUMBER() OVER(PARTITION BY category_name 
       			ORDER BY SUM(qty * s.price) DESC) AS revenue_rank,
      	ROW_NUMBER() OVER(PARTITION BY category_nameORDER BY SUM(qty) DESC) AS qty_rank
    FROM sales AS s
    JOIN product_details AS pd 
		ON s.prod_id = pd.product_id
    GROUP BY category_name, product_name
)
SELECT category_name, product_name,
  total_quantity, total_revenue
FROM revenue
WHERE revenue_rank = 1
  OR qty_rank = 1

-- 6. What is the percentage split of revenue by product for each segment?
SELECT segment_name, product_name,
  ROUND(100 *(SUM(qty * s.price) :: numeric / SUM(SUM(qty * s.price)) OVER(PARTITION BY segment_name)),1)
		 AS percent_of_revenue
FROM sales AS s
JOIN product_details AS pd 
  	ON s.prod_id = pd.product_id
GROUP BY segment_name,product_name
ORDER BY  1, 3 DESC
 

-- 7. What is the percentage split of revenue by segment for each category?
SELECT segment_name, category_name,
  ROUND(100 *(SUM(qty * s.price) :: numeric / SUM(SUM(qty * s.price)) OVER(PARTITION BY category_name)),1)
 		AS percent_of_revenue
FROM  sales AS s
JOIN product_details AS pd 
  	ON s.prod_id = pd.product_id
GROUP BY segment_name, category_name
ORDER BY 1

-- 8. What is the percentage split of total revenue by category?
SELECT category_name,
  ROUND(100 *(SUM(qty * s.price) :: numeric / SUM(SUM(qty * s.price)) OVER()),1)
 		AS percent_of_revenue
FROM sales AS s
JOIN product_details AS pd 
  	ON s.prod_id = pd.product_id
GROUP BY category_name
  
ORDER BY 1

-- 9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
SELECT product_name,
  ROUND(100 *(COUNT(product_name) :: numeric / number_of_txn),2 ) AS percent_of_penetration
FROM sales AS s
JOIN product_details AS pd 
	ON s.prod_id = pd.product_id,
  LATERAL(SELECT COUNT(distinct txn_id) AS number_of_txn
		  FROM sales ) ss
GROUP BY product_name, number_of_txn
ORDER BY 2 DESC
  

-- 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
SELECT product_1, product_2, product_3,
  times_bought_together
FROM
  (
    with products AS
	  (
      SELECT txn_id, product_name  
      FROM sales AS s
      JOIN product_details AS pd 
		  ON s.prod_id = pd.product_id
    )
    SELECT p.product_name AS product_1,
      p1.product_name AS product_2,
      p2.product_name AS product_3,
      COUNT(*) AS times_bought_together,
      ROW_NUMBER() OVER(ORDER BY COUNT(*) DESC) AS rank
    FROM products AS p
    JOIN products AS p1 
	  	ON p.txn_id = p1.txn_id
      	AND p.product_name != p1.product_name
      	AND p.product_name < p1.product_name
    JOIN products AS p2 
	  	ON p.txn_id = p2.txn_id
        AND p.product_name != p2.product_name
        AND p1.product_name != p2.product_name
        AND p.product_name < p2.product_name
        AND p1.product_name < p2.product_name
    GROUP BY p.product_name,
      p1.product_name, p2.product_name    
  ) pp
WHERE rank = 1
  
