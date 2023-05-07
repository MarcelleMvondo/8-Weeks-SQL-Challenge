--  B. Product Funnel Analysis
/* --------------------
Using a single SQL query - create a new output table which has the following details:
    How many times was each product viewed?
    How many times was each product added to cart?
    How many times was each product added to a cart but not purchased (abandoned)?
    How many times was each product purchased?
   --------------------*/
   
WITH product_page_events AS ( -- Note 1
  SELECT 
    e.visit_id,
    ph.product_id,
    ph.page_name AS product_name,
    ph.product_category,
    SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_view, -- 1 for Page View
    SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_add -- 2 for Add Cart
  FROM clique_bait.events AS e
  JOIN clique_bait.page_hierarchy AS ph
    ON e.page_id = ph.page_id
  WHERE product_id IS NOT NULL
  GROUP BY e.visit_id, ph.product_id, ph.page_name, ph.product_category
),
purchase_events AS ( -- Note 2
  SELECT 
    DISTINCT visit_id
  FROM clique_bait.events
  WHERE event_type = 3 -- 3 for Purchase
),
combined_table AS ( -- Note 3
  SELECT 
    ppe.visit_id, 
    ppe.product_id, 
    ppe.product_name, 
    ppe.product_category, 
    ppe.page_view, 
    ppe.cart_add,
    CASE WHEN pe.visit_id IS NOT NULL THEN 1 ELSE 0 END AS purchase
  FROM product_page_events AS ppe
  LEFT JOIN purchase_events AS pe
    ON ppe.visit_id = pe.visit_id
),
product_info AS (
  SELECT 
    product_name, 
    product_category, 
    SUM(page_view) AS views,
    SUM(cart_add) AS cart_adds, 
    SUM(CASE WHEN cart_add = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
    SUM(CASE WHEN cart_add = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
  FROM combined_table
  GROUP BY product_id, product_name, product_category)

SELECT *
FROM product_info
ORDER BY product_id;

-- Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

WITH product_page_events AS ( -- Note 1
  SELECT 
    e.visit_id,
    ph.product_id,
    ph.page_name AS product_name,
    ph.product_category,
    SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_view, -- 1 for Page View
    SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_add -- 2 for Add Cart
  FROM clique_bait.events AS e
  JOIN clique_bait.page_hierarchy AS ph
    ON e.page_id = ph.page_id
  WHERE product_id IS NOT NULL
  GROUP BY e.visit_id, ph.product_id, ph.page_name, ph.product_category
),
purchase_events AS ( -- Note 2
  SELECT 
    DISTINCT visit_id
  FROM clique_bait.events
  WHERE event_type = 3 -- 3 for Purchase
),
combined_table AS ( -- Note 3
  SELECT 
    ppe.visit_id, 
    ppe.product_id, 
    ppe.product_name, 
    ppe.product_category, 
    ppe.page_view, 
    ppe.cart_add,
    CASE WHEN pe.visit_id IS NOT NULL THEN 1 ELSE 0 END AS purchase
  FROM product_page_events AS ppe
  LEFT JOIN purchase_events AS pe
    ON ppe.visit_id = pe.visit_id
),
product_category AS (
  SELECT 
    product_category, 
    SUM(page_view) AS views,
    SUM(cart_add) AS cart_adds, 
    SUM(CASE WHEN cart_add = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
    SUM(CASE WHEN cart_add = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
  FROM combined_table
  GROUP BY product_category)

SELECT *
FROM product_category

-- Use your 2 new output tables - answer the following questions:
-- 1. Which product had the most views, cart adds and purchases?
WITH ordered_rows AS 
(
    SELECT  *, ROW_NUMBER() OVER (ORDER BY number_of_views DESC) AS views, 
      ROW_NUMBER() OVER (ORDER BY number_of_added_to_cart DESC ) AS carts,
      ROW_NUMBER() OVER (ORDER BY number_of_purchases DESC ) AS purchases
    FROM
      product_stats
    GROUP BY 1,2,3,4,5
)
SELECT page_name, number_of_views, 
	number_of_added_to_cart,number_of_purchases
FROM
  ordered_rows
WHERE
  views = 1
  OR carts = 1
  OR purchases = 1;
  
-- 2. Which product was most likely to be abandoned?
WITH ordered_rows AS 
( 
	SELECT  *, ROW_NUMBER() OVER (ORDER BY number_of_abandoned_carts DESC) AS row,
  	FROM product_stats
  	GROUP BY 1,2,3,4,5
)
SELECT page_name, 
	number_of_abandoned_carts
FROM ordered_rows
WHERE row = 1;

--3. Which product had the highest view to purchase percentage?
SELECT product_name,product_category, 
  ROUND(100 * purchases/views,2) AS purchase_per_view_percentage
FROM product_info
ORDER BY purchase_per_view_percentage DESC

-- 4. What is the average conversion rate from view to cart add?
SELECT
  ROUND(100 *(SUM(number_of_added_to_cart) / SUM(number_of_views)),1)
  AS avg_conversion
FROM
  product_category_stats
  
--5. What is the average conversion rate from cart add to purchase?
SELECT 
  ROUND(100*AVG(cart_adds/views),2) AS avg_view_to_cart_add_conversion,
  ROUND(100*AVG(purchases/cart_adds),2) AS avg_cart_add_to_purchases_conversion_rate
FROM product_info
  
