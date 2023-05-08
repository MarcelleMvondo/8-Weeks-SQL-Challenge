# 🐟 Case Study #6 - Clique Bait

## 👩🏻‍💻 Solution - B. Product Funnel Analysis

Using a single SQL query - create a new output table which has the following details:

1. How many times was each product viewed?
2. How many times was each product added to cart?
3. How many times was each product added to a cart but not purchased (abandoned)?
4. How many times was each product purchased?

## Planning Our Strategy

Let us visualize the output table.

| Column | Description | 
| ------- | ----------- |
| product | Name of the product |
| views | Number of views for each product |
| cart_adds | Number of cart adds for each product |
| abandoned | Number of times product was added to a cart, but not purchased |
| purchased | Number of times product was purchased |

These information would come from these 2 tables.
- `events` table - visit_id, page_id, event_type
- `page_hierarchy` table - page_id, product_category

**Solution**

```sql
WITH product_page_events AS ( 
  SELECT 
    e.visit_id,
    ph.product_id,
    ph.page_name AS product_name,
    ph.product_category,
    SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_view, 
    SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_add 
  FROM clique_bait.events AS e
  JOIN clique_bait.page_hierarchy AS ph
    ON e.page_id = ph.page_id
  WHERE product_id IS NOT NULL
  GROUP BY e.visit_id, ph.product_id, ph.page_name, ph.product_category
),
purchase_events AS ( 
  SELECT 
    DISTINCT visit_id
  FROM clique_bait.events
  WHERE event_type = 3 
),
combined_table AS ( 
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
```

<kbd><img width="845" alt="image" src="https://user-images.githubusercontent.com/81607668/136649917-ff1f7daa-9fb6-4077-9196-8596cd6eb424.png"></kbd>

***

Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

**Solution**

```sql
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
```

<kbd><img width="661" alt="image" src="https://user-images.githubusercontent.com/81607668/136650026-e6817dd2-ab30-4d5f-ab06-0b431f087dad.png"></kbd>

***

Use your 2 new output tables - answer the following questions:

**1. Which product had the most views, cart adds and purchases?**
```sql
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
```

**2. Which product was most likely to be abandoned?**
```sql
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
```

- Oyster has the most views.
- Lobster has the most cart adds and purchases.
- Russian Caviar is most likely to be abandoned.

**3. Which product had the highest view to purchase percentage?**

```sql
SELECT product_name,product_category, 
  ROUND(100 * purchases/views,2) AS purchase_per_view_percentage
FROM product_info
ORDER BY purchase_per_view_percentage DESC
```

| page_name | purchase_per_view_percentage |
| --------- | --------------------------- |
| Lobster   | 48.7                        |

- Lobster has the highest view to purchase percentage at 48.74%.

**4. What is the average conversion rate from view to cart add?**

```sql
SELECT
  ROUND(100 *(SUM(number_of_added_to_cart) / SUM(number_of_views)),1)
  AS avg_conversion
FROM
  product_category_stats
```

| avg_conversion |
| --------------------------- |
| 60.9                        |

**5. What is the average conversion rate from cart add to purchase?**

```sql
SELECT 
  ROUND(100*AVG(purchases/cart_adds),2) AS | avg_cart_to_purchase_conversion |

FROM product_info
```

| avg_cart_to_purchase_conversion |
| ------------------------------- |
| 75.9                            |

- Average views to cart adds rate is 60.95% and average cart adds to purchases rate is 75.93%.


***