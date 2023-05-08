# 💵 Case Study #4 - Data Bank

## 🏦 Solution - B. Customer Transactions

**1. What is the unique count and total amount for each transaction type?**

````sql
SELECT 
  txn_type, 
  COUNT(*), 
  SUM(txn_amount) AS total_amount
FROM data_bank.customer_transactions
GROUP BY txn_type
````

**Answer:**

<img width="479" alt="image" src="https://user-images.githubusercontent.com/81607668/130349158-acb36028-df02-472a-bd34-15856f93b2b8.png">

***

**2. What is the average total historical deposit counts and amounts for all customers?**

````sql
WITH deposits AS 
(
  SELECT customer_id, txn_type, COUNT(*) AS txn_count,
    	AVG(txn_amount) AS avg_amount
  FROM customer_transactions
  GROUP BY customer_id, txn_type
)

SELECT ROUND(AVG(txn_count),0) AS avg_deposit, 
  ROUND(AVG(avg_amount),2) AS avg_amount
FROM deposits
WHERE txn_type = 'deposit'
````
**Answer:**

<img width="325" alt="image" src="https://user-images.githubusercontent.com/81607668/130349626-97309a3e-790b-47a9-b9bf-32e7f6f078e7.png">

- The average historical deposit count is 5 and average historical deposit amounts are 508.61.

***

**3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?**

````sql
WITH monthly_transactions AS 
(
  SELECT customer_id, DATE_PART('month', txn_date) AS month,
    SUM(CASE WHEN txn_type = 'deposit' THEN 0 ELSE 1 END) AS deposit_count,
    SUM(CASE WHEN txn_type = 'purchase' THEN 0 ELSE 1 END) AS purchase_count,
    SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
  FROM customer_transactions
  GROUP BY customer_id, month
)

SELECT month,
  COUNT(DISTINCT customer_id) AS customer_count
FROM monthly_transactions
WHERE deposit_count >= 2 
  AND (purchase_count > 1 OR withdrawal_count > 1)
GROUP BY month
ORDER BY month
````

**Answer:**

<img width="305" alt="image" src="https://user-images.githubusercontent.com/81607668/130412903-8b6686b4-c591-4154-be30-fa34e9e93e53.png">

***

**4. What is the closing balance for each customer at the end of the month? Also show the change in balance each month in the same table output.**


**5. Comparing the closing balance of a customer’s first month and the closing balance from their second nth, what percentage of customers:**
