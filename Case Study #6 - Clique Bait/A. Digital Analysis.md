# 🐟 Case Study #6 - Clique Bait

## 👩🏻‍💻 Solution - A. Digital Analysis

**1. How many users are there?**

````sql
SELECT 
  COUNT(DISTINCT user_id) AS user_count
FROM clique_bait.users;
````

| user_count |
| --------------- |
| 500             |

**2. How many cookies does each user have on average?**

This was one of those tricky questions that seems easy, but the solution is not as clear as it seems. 

- Question is asking the number of cookies each user have on average. That's calling us to either use a `DISTINCT` or `GROUP BY` in order to ensure the count of cookies belonging to each user is unique.
- Next, round up the average cookie count with 0 decimal point as it will not make sense for the cookie to be in fractional form. 

````sql
WITH cookie AS (
  SELECT 
    user_id, 
    COUNT(cookie_id) AS cookie_id_count
  FROM clique_bait.users
  GROUP BY user_id)

SELECT 
  ROUND(AVG(cookie_id_count),0) AS avg_cookie_id
FROM cookie;
````

| avg_cookie_id |
| -------------------- |
| 3.56                 |

**3. What is the unique number of visits by all users per month?**
- First, extract numerical month from `event_time` so that we can group the data by month.
- Unique is a keyword to use `DISTINCT`.

````sql
SELECT 
  EXTRACT(MONTH FROM event_time) as month, 
  COUNT(DISTINCT visit_id) AS unique_visit_count
FROM clique_bait.events
GROUP BY EXTRACT(MONTH FROM event_time);
````

| month     | unique_visit_count |
| --------- | ---------------- |
| January   | 876              |
| February  | 1488             |
| March     | 916              |
| April     | 248              |
| May       | 36               |

**4. What is the number of events for each event type?**

````sql
SELECT 
  event_name, 
  COUNT(*) AS number_of_events
FROM clique_bait.events
GROUP BY event_type
ORDER BY event_type;
````

| event_name    | number_of_events |
| ------------- | ---------------- |
| Page View     | 20928            |
| Add to Cart   | 8451             |
| Purchase      | 1777             |
| Ad Impression | 876              |
| Ad Click      | 702              

**5. What is the percentage of visits which have a purchase event?**
- Join the events and events_identifier table and filter by `Purchase` event only. 
- As the data is now filtered to having `Purchase` events only, counting the distinct visit IDs would give you the number of purchase events.
- Then, divide the number of purchase events with a subquery of total number of distinct visits from the `events` table.

````sql
SELECT 
  100 * COUNT(DISTINCT e.visit_id)/
    (SELECT COUNT(DISTINCT visit_id) FROM clique_bait.events) AS percentage_purchase
FROM clique_bait.events AS e
JOIN clique_bait.event_identifier AS ei
  ON e.event_type = ei.event_type
WHERE ei.event_name = 'Purchase';
````

| percentage_purchase |
| -------------------------- |
| 49.9                       |

**6. What is the percentage of visits which view the checkout page but do not have a purchase event?**

````sql
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
````

| page_name | number_of_visits | percentage_from_checkout_page_visits | percentage_from_all_visits |
| --------- | ---------------- | ------------------------------------ | -------------------------- |
| Checkout  | 326              | 15.5                                 | 9.1                        |

**7. What are the top 3 pages by number of views?**

````sql
SELECT ph.page_name, 
  COUNT(*) AS number_of_views
FROM clique_bait.events AS e
JOIN clique_bait.page_hierarchy AS ph
  ON e.page_id = ph.page_id
WHERE e.event_type = 1 
GROUP BY ph.page_name
ORDER BY page_views DESC 
LIMIT 3
````
| page_name    | number_of_views |
| ------------ | --------------- |
| All Products | 3174            |
| Checkout     | 2103            |
| Home Page    | 1782            |

**8. What is the number of views and cart adds for each product category?**

````sql
SELECT ph.product_category, 
  SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_views,
  SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_adds
FROM clique_bait.events AS e
JOIN clique_bait.page_hierarchy AS ph
  ON e.page_id = ph.page_id
WHERE ph.product_category IS NOT NULL
GROUP BY ph.product_category
ORDER BY page_views DESC
````

| product_category | page_views | cart_adds |
| ---------------- | -------------------- | ---------------------------- |
| Fish             | 4633                 | 2789                         |
| Luxury           | 3032                 | 1870                         |
| Shellfish        | 6204                 | 3792                         |

**9. What are the top 3 products by purchases?**

````sql
SELECT ph.page_name, 
  COUNT(*) AS page_views
FROM clique_bait.events AS e
JOIN clique_bait.page_hierarchy AS ph
  ON e.page_id = ph.page_id
WHERE e.event_type = 1 
GROUP BY ph.page_name
ORDER BY page_views DESC 
LIMIT 3
````
| page_name | number_of_purchases |
| --------- | ------------------- |
| Lobster   | 754                 |
| Oyster    | 726                 |
| Crab      | 719                 |
***
