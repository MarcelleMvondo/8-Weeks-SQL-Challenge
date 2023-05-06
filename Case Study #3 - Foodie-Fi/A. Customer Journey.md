# 🥑 Case Study #3 - Foodie-Fi

## 🎞 Solution - A. Customer Journey

**Answer:**

````sql
SELECT
  s.customer_id,f.plan_id, f.plan_name,  s.start_date
FROM foodie_fi.plans f
JOIN foodie_fi.subscriptions s
  ON f.plan_id = s.plan_id
WHERE s.customer_id IN (1,2,11,13,15,16,18,19)
````

| customer_id | plan_id |     plan_name     | start_date |
|-------------|---------|-------------------|------------|
| 1           | 0       |        trial      | 2020-08-01 |
| 1           | 1       |    basic montly   | 2020-08-08 |
| 2           | 0       |        trial      | 2020-09-20 |
| 2           | 3       |     pro annual    | 2020-09-27 |
| 11          | 0       |        trial      | 2020-11-19 |
| 11          | 4       |        churn      | 2020-11-26 |
| 13          | 0       |        trial      | 2020-12-15 |
| 13          | 1       |    basic montly   | 2020-12-22 |
| 13          | 2       |     pro montly    | 2021-03-29 |
| 15          | 0       |        trial      | 2020-03-17 |
| 15          | 2       |     pro montly    | 2020-03-24 |
| 15          | 4       |        churn      | 2020-04-29 |
| 16          | 0       |        trial      | 2020-05-31 |
| 16          | 1       |    basic montly   | 2020-06-07 |
| 16          | 3       |     pro annual    | 2020-10-21 |
| 18          | 0       |        trial      | 2020-07-06 |
| 18          | 2       |     pro montly    | 2020-07-13 |
| 19          | 0       |        trial      | 2020-06-22 |
| 19          | 2       |     pro montly    | 2020-06-29 |
| 19          | 3       |     pro annual    | 2020-08-29 |

###  Based off the 8 sample customers provided in the sample from the `subscriptions` table, write a brief description about each customer’s onboarding journey.
#### Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

The sample table has plan IDs, join the plan table to show plan names.

- Customer with ID 1 started with a trial subscription and continued with a basic monthly subscription in 7 days after sign-up

- Customer with ID 2 started with a trial subscription and continued with a pro annual subscription in 7 days after sign-up

- Customer with ID 11 started with a trial subscription and has churned in 7 days after sign-up

- Customer with ID 13 started with a trial subscription, then purchased a basic monthly subscription in 7 days after sign-up and in 7 days after that has upgraded to a pro monthly subscription

- Customer with ID 15 started with a trial subscription, purchased a basic monthly subscription in 7 days after sign-up and has churned in a month

- Customer with ID 16 started with a trial subscription, purchased a basic monthly subscription in 7 days after sign-up and in 4 months after that has ugraded to a pro annual subscription

- Customer with ID 18 started with a trial subscription and continued with a pro monthly subscription in 7 days after sign-up

- Customer with ID 19 started with a trial subscription, continued with a pro monthly subscription in 7 days after sign-up and has upgraded to pro annual subscpription in 2 months