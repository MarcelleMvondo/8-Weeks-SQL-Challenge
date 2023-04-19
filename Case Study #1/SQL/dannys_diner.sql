SCHEMA: dannys_diner
 -- DROP SCHEMA dannys_diner ;

CREATE SCHEMA DANNYS_DINER
AUTHORIZATION POSTGRES;


CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
/* --------------------
   Case Study Questions
   --------------------*/
   
 -- 1. What is the total amount each customer spent at the restaurant?
 select customer_id, sum(price) as Total
 from sales as s
 join menu as m
 	on s.product_id = m.product_id
 group by customer_id
 
 -- 2. How many days has each customer visited the restaurant?
 select customer_id, count(distinct(order_date))
 from sales 
 group by customer_id
 
 -- 3. What was the first item from the menu purchased by each customer?
select s.customer_id, m.product_name
from sales as s
join menu as m
	on s.product_id = m.product_id
where s.order_date in (select min(order_date) from sales)
group by customer_id, product_name

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select m.product_name, count(m.product_name)
from menu as m
join sales as s
	on s.product_id = m.product_id
group by product_name
order by sum(price) desc limit 1

-- 5. Which item was the most popular for each customer?
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
where rank=1

-- 6. Which item was purchased first by the customer after they became a member?
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
where rank=1 

-- 7. Which item was purchased just before the customer became a member?
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
where rank=1 

-- 8. What is the total items and amount spent for each member before they became a member?
select s.customer_id, count(distinct(s.product_id)) as total_item, sum(price) as total_price
from sales as s
join members as m
	on m.customer_id=s.customer_id
join menu as m2
	on s.product_id=m2.product_id
where s.order_date < m.join_date
group by s.customer_id

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
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
group by customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
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

------------------------
--BONUS QUESTIONS-------
------------------------

-- Join All The Things
-- Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)

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
order by s.customer_id , s.order_date

-- Rank All The Things
-- Recreate the table with: customer_id, order_date, product_name, price, member (Y/N), ranking(null/123)
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
from ranking_cte
