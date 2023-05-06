# Case Study #1: Danny's Diner 🍜

## Solution

View the complete syntax [here](https://github.com/MarcelleMvondo/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231/SQL/dannys_diner.sql).

***

### 1. What is the total amount each customer spent at the restaurant?

````sql
 select customer_id, sum(price) as Total
 from sales as s
 join menu as m
 	on s.product_id = m.product_id
 group by customer_id; 
````

#### Steps:
- Use **SUM** and **GROUP BY** to find out ```total_sales``` contributed by each customer.
- Use **JOIN** to merge ```sales``` and ```menu``` tables as ```customer_id``` and ```price``` are from both tables.


#### Answer:
| customer_id | total_sales |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.

***

### 2. How many days has each customer visited the restaurant?

````sql
select customer_id, count(distinct(order_date))
from sales 
group by customer_id;
````

#### Steps:
- Use **DISTINCT** and wrap with **COUNT** to find out the ```visit_count``` for each customer.
- If we do not use **DISTINCT** on ```order_date```, the number of days may be repeated.

#### Answer:
| customer_id | visit_count |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

- Customer A visited 4 times.
- Customer B visited 6 times.
- Customer C visited 2 times.

***

### 3. What was the first item from the menu purchased by each customer?

````sql
select s.customer_id, m.product_name
from sales as s
join menu as m
	on s.product_id = m.product_id
where s.order_date in (select min(order_date) from sales)
group by customer_id, product_name;
````

#### Steps:
- Use **JOIN** to merge ```sales``` and ```menu``` tables as ```customer_id``` and ```product_name``` are from both tables.
- Create a **subqueries** to **select** the minimal date, use **MIN** as ```order_date```.

#### Answer:
| customer_id | product_name | 
| ----------- | ----------- |
| A           | curry        | 
| A           | sushi        | 
| B           | curry        | 
| C           | ramen        |

- Customer A's first orders are curry and sushi.
- Customer B's first order is curry.
- Customer C's first order is ramen.

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
select m.product_name, count(m.product_name)
from menu as m
join sales as s
   on s.product_id = m.product_id
group by product_name
order by sum(price) desc limit 1;
````

#### Steps:
- **COUNT** number of ```product_name``` and **ORDER BY** ```sum(price)``` by descending order. 
- Then, use **LIMIT** to get the highest number of purchased item.

#### Answer:
| most_purchased | product_name | 
| ----------- | ----------- |
| 8       | ramen |


- Most purchased item on the menu is ramen which is 8 times.

***

### 5. Which item was the most popular for each customer?

````sql
with fav_item_cte as
(
	select s.customer_id, m.product_name, count(m.product_name), 
		dense_rank() over(partition by s.customer_id 
						  order by count(product_name) desc) as rank
	from menu m
	join sales s
	on m.product_id=s.product_id
	group by s.customer_id, m.product_name
)
select customer_id, product_name
from fav_item_cte
where rank=1 ;
````

#### Steps:
- Create a ```fav_item_cte``` and use **DENSE_RANK** to ```rank``` the ```order_count``` for each product by descending order for each customer.
- Generate results where product ```rank = 1``` only as the most popular product for each customer.

#### Answer:
| customer_id | product_name | order_count |
| ----------- | ---------- |------------  |
| A           | ramen        |  3   |
| B           | sushi        |  2   |
| B           | curry        |  2   |
| B           | ramen        |  2   |
| C           | ramen        |  3   |

- Customer A and C's favourite item is ramen.
- Customer B enjoys all items on the menu. He/she is a true foodie, sounds like me!

***

### 6. Which item was purchased first by the customer after they became a member?

````sql
with member_1st_item as
(
	select s.customer_id, m.join_date, s.order_date,s.product_id,
		dense_rank() over(partition by s.customer_id 
						  order by s.order_date) as rank
	from sales as s
	join members as m
		on m.customer_id=s.customer_id
	where s.order_date >= m.join_date
)
select s.customer_id, s.order_date, m2.product_name
from member_1st_item as s
join menu as m2
	on s.product_id=m2.product_id
where rank=1 ;
````

#### Steps:
- Create ```member_1st_item``` by using **windows function** and partitioning ```customer_id``` by ascending ```order_date```. Then, filter ```order_date``` to be on or after ```join_date```.
- Then, filter table by ```rank = 1``` to show 1st item purchased by each customer.

#### Answer:
| customer_id | order_date  | product_name |
| ----------- | ---------- |----------  |
| A           | 2021-01-07 | curry        |
| B           | 2021-01-11 | sushi        |

- Customer A's first order as member is curry.
- Customer B's first order as member is sushi.

***

### 7. Which item was purchased just before the customer became a member?

````sql
with members_prior_item as
(
	select s.customer_id, m.join_date, s.order_date,s.product_id,
		dense_rank() over(partition by s.customer_id 
						  order by s.order_date desc) as rank
	from sales as s
	join members as m
		on m.customer_id=s.customer_id
	where s.order_date < m.join_date
)
select s.customer_id, s.order_date, m2.product_name
from members_prior_item as s
join menu as m2
	on s.product_id=m2.product_id
where rank=1 ;
````

#### Steps:
- Create a ```prior_member_purchased_cte``` to create new column ```rank``` by using **Windows function** and partitioning ```customer_id``` by descending ```order_date``` to find out the last ```order_date``` before customer becomes a member.
- Filter ```order_date``` before ```join_date```.

#### Answer:
| customer_id | order_date  | product_name |
| ----------- | ---------- |----------  |
| A           | 2021-01-01 |  sushi        |
| A           | 2021-01-01 |  curry        |
| B           | 2021-01-04 |  sushi        |

- Customer A’s last order before becoming a member is sushi and curry.
- Whereas for Customer B, it's sushi.

***

### 8. What is the total items and amount spent for each member before they became a member?

````sql
select s.customer_id, count(distinct(s.product_id)) as total_item, sum(price) as total_price
from sales as s
join members as m
	on m.customer_id=s.customer_id
join menu as m2
	on s.product_id=m2.product_id
where s.order_date < m.join_date
group by s.customer_id;

````

#### Steps:
- Filter ```order_date``` before ```join_date``` and perform a **COUNT** **DISTINCT** on ```product_id``` and **SUM** the ```total spent``` before becoming member.

#### Answer:
| customer_id | unique_menu_item | total_sales |
| ----------- | ---------- |----------  |
| A           | 2 |  25       |
| B           | 2 |  40       |

Before becoming members,
- Customer A spent $ 25 on 2 items.
- Customer B spent $40 on 2 items.

***

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

````sql
with count_points as 
(
	select *, 
		case 
			when product_name='sushi' then price*20
			else price*10
		end as points
	from menu
)
select s.customer_id,sum(points) as Total_points
from count_points as p
join sales as s
	on s.product_id=p.product_id
group by customer_id ;
````

#### Steps:
Let’s breakdown the question.
- Each $1 spent = 10 points.
- But, sushi (product_id 1) gets 2x points, meaning each $1 spent = 20 points
So, we use CASE WHEN to create conditional statements
- If product_id = 1, then every $1 price multiply by 20 points
- All other product_id that is not 1, multiply $1 by 10 points
Using ```count_points```, **SUM** the ```points```.

#### Answer:
| customer_id | total_points | 
| ----------- | ---------- |
| A           | 860 |
| B           | 940 |
| C           | 360 |

- Total points for Customer A is 860.
- Total points for Customer B is 940.
- Total points for Customer C is 360.

***

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

````sql
with count_points as 
(
    select s.customer_id, order_date, join_date, product_name, sum(point) as point
    from sales as s
    join(
		select product_id, product_name,
			case 
				when product_name='sushi' then m.price*20  
          		else m.price*10
			end as point
		 from menu as m
		) as p
		on s.product_id = p.product_id
    join members as m2 on s.customer_id = m2.customer_id
	group by s.customer_id, order_date, join_date, product_name, point
)
select customer_id,
	sum(
		case
			when order_date >= join_date
				and order_date < join_date + (7 * interval '1 day')
				and product_name != 'sushi' 
			then point * 2
		  	else point
    	end 		
	) as members_points
from count_points 
where DATE_PART('month', order_date) = 1
group by 1 
````

#### Answer:
| customer_id | total_points | 
| ----------- | ---------- |
| A           | 1370 |
| B           | 820 |

- Total points for Customer A is 1,370.
- Total points for Customer B is 820.

***

## BONUS QUESTIONS

### Join All The Things - Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)

````sql
select s.customer_id, s.order_date, m.product_name, m.price,
		case
			when join_date > order_date then 'N'
			when join_date <= order_date then 'Y'
			else 'N' 
		end as member
from sales as s
left join menu as m
	on  s.product_id = m.product_id
left join members  as m2
	on  s.customer_id = m2.customer_id
order by s.customer_id , s.order_date;
 ````
 
#### Answer: 
| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | -------------| ----- | ------ |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

***

### Rank All The Things - Danny also requires further information about the ```ranking``` of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ```ranking``` values for the records when customers are not yet part of the loyalty program.

````sql
with ranking_cte as
(
	select s.customer_id, s.order_date, m.product_name, m.price,
		case
			when join_date > order_date then 'N'
			when join_date <= order_date then 'Y'
			else 'N'
		end as member
	from sales as s
	left join menu as m
		on  s.product_id = m.product_id
	left join members  as m2
		on  s.customer_id = m2.customer_id
)
select *,
	case 
		when member='N' then NULL
		else rank() over(partition by customer_id, member order by order_date)
	end	
from ranking_cte;
````

#### Answer: 
| customer_id | order_date | product_name | price | member | ranking | 
| ----------- | ---------- | -------------| ----- | ------ |-------- |
| A           | 2021-01-01 | sushi        | 10    | N      | NULL
| A           | 2021-01-01 | curry        | 15    | N      | NULL
| A           | 2021-01-07 | curry        | 15    | Y      | 1
| A           | 2021-01-10 | ramen        | 12    | Y      | 2
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| B           | 2021-01-01 | curry        | 15    | N      | NULL
| B           | 2021-01-02 | curry        | 15    | N      | NULL
| B           | 2021-01-04 | sushi        | 10    | N      | NULL
| B           | 2021-01-11 | sushi        | 10    | Y      | 1
| B           | 2021-01-16 | ramen        | 12    | Y      | 2
| B           | 2021-02-01 | ramen        | 12    | Y      | 3
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-07 | ramen        | 12    | N      | NULL


***
