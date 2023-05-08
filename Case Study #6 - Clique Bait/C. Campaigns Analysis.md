# Case Study #6 - Clique Bait

## 👩🏻‍💻 Solution - C. Campaigns Analysis

Generate a table that has 1 single row for every unique visit_id record and has the following columns:
- `user_id`
- `visit_id`
- `visit_start_time`: the earliest event_time for each visit
- `page_views`: count of page views for each visit
- `cart_adds`: count of product cart add events for each visit
- `purchase`: 1/0 flag if a purchase event exists for each visit
- `campaign_name`: map the visit to a campaign if the `visit_start_time` falls between the `start_date` and `end_date`
- `impression`: count of ad impressions for each visit
- `click`: count of ad clicks for each visit
- (Optional column) `cart_products`: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)

We will create this table using the approach that we have applied to create tables for product funnel analysis. We will use left joins to add new columns to the table because we need to keep all rows from the left table. The products added to cart, can be added to the table as a string using the `string_agg()` function, and sorted by the `sequence_number` column to follow the order they were added to the cart. 

```sql
WITH joined_table AS 
(
    SELECT user_id, visit_id, event_time AS visit_start_time,
      page_name, event_name, sequence_number,  product_id
    FROM users AS u
	JOIN events AS e 
		ON u.cookie_id = e.cookie_id
	JOIN event_identifier AS ei 
		ON e.event_type = ei.event_type
	JOIN page_hierarchy AS pe 
		ON e.page_id = pe.page_id
    GROUP BY user_id, visit_id, event_name, event_time,
      page_name, event_name, sequence_number,  product_id
 )
SELECT user_id,  jt.visit_id, visit_start_time, page_views,
   cart_adds, purchase, campaign_name, impression,  click,
   cart_products
FROM joined_table AS jt
LEFT JOIN( SELECT visit_id, COUNT(page_name) AS page_views 
    		FROM joined_table 
    		WHERE event_name = 'Page View'
      		GROUP BY 1
  		) AS jt1 
	ON jt.visit_id = jt1.visit_id
LEFT JOIN(SELECT visit_id, COUNT(page_name) AS cart_adds 
    		FROM joined_table 
    		WHERE event_name = 'Add to Cart'
   			GROUP BY 1
  		) AS jt2 
	ON jt.visit_id = jt2.visit_id
LEFT JOIN(SELECT visit_id, 
		  	CASE
        		WHEN visit_id IN(SELECT distinct visit_id
          							FROM events AS ee
								 WHERE event_type = 3
            					) THEN 1
        		ELSE 0
      		END AS purchase
    	FROM joined_table 
    	WHERE event_name = 'Add to Cart'
   		GROUP BY 1
  		) AS jt3 
	ON jt.visit_id = jt3.visit_id
LEFT JOIN( SELECT visit_id, COUNT(page_name) AS impression
    		FROM joined_table   
    		WHERE event_name = 'Ad Impression'
      		GROUP BY 1
  		) AS jt4 
	ON jt.visit_id = jt4.visit_id
LEFT JOIN( SELECT visit_id, COUNT(page_name) AS click
		  	FROM joined_table   
    		WHERE event_name = 'Ad Click'
      		GROUP BY 1
  		) AS jt5 
	ON jt.visit_id = jt5.visit_id
LEFT JOIN campaign_identifier AS ci 
	ON jt.visit_start_time 
	between ci.start_date AND ci.end_date  
LEFT JOIN( SELECT  visit_id, 
		  STRING_AGG(page_name,', ' ORDER BY sequence_number) AS cart_products
    		FROM joined_table
    		WHERE  product_id > 0
      			AND event_name = 'Add to Cart'
    		GROUP BY 1
  		) AS jt6 
	ON jt.visit_id = jt6.visit_id
WHERE
  sequence_number = 1
GROUP BY page_name, page_views, cart_adds,  user_id,
  jt.visit_id,  purchase, impression, click,
  visit_start_time, campaign_name, cart_products 
ORDER BY 1,3
```