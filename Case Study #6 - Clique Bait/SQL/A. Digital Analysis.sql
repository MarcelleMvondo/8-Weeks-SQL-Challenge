-- A. Digital Analysis

-- 1. How many users are there?
SELECT 
  COUNT(DISTINCT user_id) AS number_user
FROM clique_bait.users

-- 2. How many cookies does each user have on average?
WITH cookie AS 
(
  SELECT user_id, 
    COUNT(cookie_id) AS nb_of_cookie
  FROM clique_bait.users
  GROUP BY user_id
)
SELECT 
  ROUND(AVG(cookie_id_count),0) AS avg_cookie_id
FROM cookie

-- 3. What is the unique number of visits by all users per month?
SELECT 
  EXTRACT(MONTH FROM event_time) as month, 
  COUNT(DISTINCT visit_id) AS number_of_visit
FROM clique_bait.events
GROUP BY EXTRACT(MONTH FROM event_time)

-- 4. What is the number of events for each event type?
SELECT event_type, 
  COUNT(*) AS number_event
FROM clique_bait.events
GROUP BY event_type
ORDER BY event_type

-- 5. What is the percentage of visits which have a purchase event?
SELECT 
  100 * COUNT(DISTINCT e.visit_id)/
    (SELECT COUNT(DISTINCT visit_id) FROM clique_bait.events) AS percentage
FROM clique_bait.events AS e
JOIN clique_bait.event_identifier AS ei
  ON e.event_type = ei.event_type
WHERE ei.event_name = 'Purchase'

-- 6. What is the percentage of visits which view the checkout page but do not have a purchase event?
WITH checkout_purchase AS 
(
	SELECT visit_id,
	  MAX(CASE WHEN event_type = 1 AND page_id = 12 THEN 1 ELSE 0 END) AS checkout,
	  MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase
	FROM clique_bait.events
	GROUP BY visit_id
)
SELECT 
  ROUND(100 * (1-(SUM(purchase)::numeric/SUM(checkout))),2) AS percentage_checkout_view_with_no_purchase
FROM checkout_purchase

-- 7. What are the top 3 pages by number of views?
SELECT ph.page_name, 
  COUNT(*) AS page_views
FROM clique_bait.events AS e
JOIN clique_bait.page_hierarchy AS ph
  ON e.page_id = ph.page_id
WHERE e.event_type = 1 
GROUP BY ph.page_name
ORDER BY page_views DESC 
LIMIT 3

-- 8. What is the number of views and cart adds for each product category?
SELECT ph.product_category, 
  SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_views,
  SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_adds
FROM clique_bait.events AS e
JOIN clique_bait.page_hierarchy AS ph
  ON e.page_id = ph.page_id
WHERE ph.product_category IS NOT NULL
GROUP BY ph.product_category
ORDER BY page_views DESC

-- 9. What are the top 3 products by purchases?
SELECT ph.page_name, 
  COUNT(*) AS page_views
FROM clique_bait.events AS e
JOIN clique_bait.page_hierarchy AS ph
  ON e.page_id = ph.page_id
WHERE e.event_type = 1 
GROUP BY ph.page_name
ORDER BY page_views DESC 
LIMIT 3