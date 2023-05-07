/* --------------------
High Level Sales Analysis
   --------------------*/

-- 1. What was the total quantity sold for all products?
SELECT
  SUM(qty) AS total_qty_sold
FROM sales

-- 2. What is the total generated revenue for all products before discounts?
SELECT
  SUM(qty * price) AS total_sales
FROM sales

-- 3. What was the total discount amount for all products?
SELECT
  ROUND(SUM(qty * price * discount :: numeric / 100), 2) AS total_discount
FROM sales
