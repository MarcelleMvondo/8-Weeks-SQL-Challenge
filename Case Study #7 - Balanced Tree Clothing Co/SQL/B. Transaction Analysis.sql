/* --------------------
Transaction Analysis
   --------------------*/

-- 1. How many unique transactions were there?
SELECT
  COUNT(distinct txn_id) AS number_of_transactions
FROM sales

-- 2. What is the average unique products purchased in each transaction?
SELECT
  COUNT(prod_id) / COUNT(distinct txn_id) AS avg_number_of_product
FROM sales

-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
WITH revenue AS
(
    SELECT txn_id,
      SUM(qty * price) AS revenue
    FROM sales
    GROUP BY txn_id   
)
SELECT
  PERCENTILE_CONT(0.25) WITHIN GROUP (
    ORDER BY revenue) AS percentile_25,
  PERCENTILE_CONT(0.50) WITHIN GROUP (
    ORDER BY revenue) AS percentile_50,
  PERCENTILE_CONT(0.75) WITHIN GROUP (
    ORDER BY revenue) AS percentile_75 
FROM revenue

-- 4. What is the average discount value per transaction?
WITH revenue AS
(
    SELECT txn_id,
      SUM(qty * price * discount :: numeric / 100) AS order_discount
    FROM sales
    GROUP BY txn_id 
 )
SELECT
  ROUND(AVG(order_discount), 2) AS avg_discount
FROM revenue

-- 5. What is the percentage split of all transactions for members vs non-members?
WITH members AS 
(
    SELECT DISTINCT sales.txn_id,
      	COUNT(distinct member) AS total_members,
      	CASE
        	WHEN member = TRUE THEN 1
        	ELSE 0
      	END AS number_of_members
    FROM sales
    GROUP BY txn_id, number_of_members      
)
SELECT distinct percentage_of_members,
  100 - percentage_of_members AS percentage_of_guests
FROM members,
  LATERAL(SELECT ROUND(100 *(SUM(number_of_members) / SUM(total_members)),1)
		  AS percentage_of_members
   			FROM members) pm

-- 6. What is the average revenue for member transactions and non-member transactions?
WITH members AS 
(
    SELECT sales.txn_id,
		  CASE
			WHEN member = TRUE THEN SUM(qty * price)
		  END AS members_revenue,
		  CASE
			WHEN member = FALSE THEN SUM(qty * price)
		  END AS guests_revenue
    FROM sales
      
    GROUP BY txn_id, member  
 )
SELECT
  ROUND(AVG(members_revenue), 2) AS avg_members_revenue,
  ROUND(AVG(guests_revenue), 2) AS avg_guests_revenue
FROM members
  
  