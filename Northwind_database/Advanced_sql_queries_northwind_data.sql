

---
--Scripts by Prakash Jamar Kattel 
---

--Over Operator 

---Row number gives the index for the entries (row) based on the parameter provided in over operator
-- here the row are indexed based on product_id 
 
select row_number() over(Order by prod.product_id) rownum, cat.category_name, prod.product_name
from categories cat
Inner join products prod ON cat.Category_ID = prod.category_id

-- we can use same function to list the index based on categories; that is start the index with each category. 

select 
	row_number() over(Partition by cat.category_id order by prod.product_name) Product_wise_row_num, 
	row_number() over(order by cat.category_name) overall_row_num,
	cat.category_name,
	prod.product_name
FROM
	categories cat
Inner Join
	products prod
on 	
	cat.category_id = prod.category_id 
-- Now we want to get the unique value for each cagetories like for exmaple beverage the rank is 1, 
--for condiments the rank is 2 and so on. This can be done by using "dense Rank" function

select 
	dense_rank() over (order by cat.category_id) Cagegory_wise_row_num, 
	cat.category_name,
	row_number() over(partition by cat.category_id order by product_id) product_wise_row_num,
	prod.product_name
from 
	categories cat
inner join
	products prod
on 
	cat.category_id = prod.category_id


-- list the products and its total sales 
create view Total_sales as

select 
	prod.product_name, 
	sum(ord.quantity),
	Round ( AVG(ord.unit_price)::numeric,2) avg_unit_price,
	round(sum(ord.quantity * ord.unit_price)::numeric,2) as Total_sales
from 
	products prod
inner join 
	order_details ord
on 
	prod.product_id = ord.product_id
group by prod.product_name
order by prod.product_name


-- Create a vies for the list of products and its total sales so that we can use its later easily 
create view Total_sales as

select 
	prod.product_name, 
	sum(ord.quantity),
	Round ( AVG(ord.unit_price)::int,2) avg_unit_price,
	round(sum(ord.quantity * ord.unit_price)::numeric,2) as Total_sales
from 
	products prod
inner join 
	order_details ord
on 
	prod.product_id = ord.product_id
group by prod.product_name
order by prod.product_name


-- lets get the running total for the prducts based on alphabetical order using the view we created 

select 
	product_name,
	total_sales,
	sum(total_sales) over (order by product_name) as running_total
	from Total_sales



-- lets get running total for each category separately
 
select 
	category_name,
	product_name,
	total_sales,
	sum(total_sales) over (partition by category_name order by product_name) as running_total
	from 
(	
select 
	cat.category_name,
	prod.product_name,
	round(sum(ord.quantity*ord.unit_price)::numeric,2) as Total_sales --casting to integer to round the values 
from 
	order_details ord
inner join 
	products prod
on ord.product_id = prod.product_id 
inner join 
	categories cat
on 
	cat.category_id = prod.category_id
group by cat.category_name, prod.product_name
order by 1,2) as t


--Lead and lag function 
-- The lead function gives the value of leading row, and lag function gives the value of previous row
--this function is useful to get the frequency be which a particular customer places an order , 
-- we can get the difference between the current order and the previous or leading orders to get how frequently the customer places order \

--using Common table expression (CTE) 

--this is regular query that gives the leading and lagging dates 
select 
	cust.customer_id,
	cust.company_name,
	ord.Order_date,
	lead(ord.order_date) over(partition by cust.company_name order by ord.order_date) Next_order_date,
	lag(ord.order_date) over(partition by cust.company_name order by ord.order_date) previous_order_date
from 
	orders ord
inner join 
	customers cust 
on 
	ord.customer_id = cust.customer_id
	

-- Using above query as CTE we can ge the frequecy  
 with CTE as 
	(select 
		cust.customer_id,
		cust.company_name,
		ord.Order_date,
		lead(ord.order_date) over(partition by cust.company_name order by ord.order_date) Next_order_date,
		lag(ord.order_date) over(partition by cust.company_name order by ord.order_date) previous_order_date
	from 
		orders ord
	inner join 
		customers cust 
	on 
		ord.customer_id = cust.customer_id)
select 
	customer_id, 
	company_name,
	coalesce(abs(date_part('day',order_date::timestamp-coalesce(next_order_date,order_date)::timestamp)),0) as Next_order_diff,
	coalesce(date_part('day',order_date::timestamp-coalesce(previous_order_date,order_date)::timestamp),0) as previous_order_diff,
	next_order_date,
	previous_order_date
from 
	CTE

-- creating the view and get the avarage frequencies

create view  order_frequency	as
 with CTE as 
	(select 
		cust.customer_id,
		cust.company_name,
		ord.Order_date,
		lead(ord.order_date) over(partition by cust.company_name order by ord.order_date) Next_order_date,
		lag(ord.order_date) over(partition by cust.company_name order by ord.order_date) previous_order_date
	from 
		orders ord
	inner join 
		customers cust 
	on 
		ord.customer_id = cust.customer_id)
select 
	customer_id, 
	company_name,
	coalesce(abs(date_part('day',order_date::timestamp-coalesce(next_order_date,order_date)::timestamp)),0) as Next_order_diff,
	coalesce(date_part('day',order_date::timestamp-coalesce(previous_order_date,order_date)::timestamp),0) as previous_order_diff,
	next_order_date,
	previous_order_date
from 
	CTE

--now lets get the average frequency per order for each customer, for each company
select
	customer_id,
	company_name,
	round(avg(Next_order_diff)::numeric,2) as Average_order_frequency_days
from 
	order_frequency
group by 
	customer_id, company_name
order by 1


-- groupby by company name only
select
	company_name,
	round(avg(Next_order_diff)::int,2) as Average_order_frequency_days
from 
	order_frequency
group by 
	 company_name
order by 2


--paging using offset and fetch 
-- this will return the next n rows of entries after m rows of entries 
-- for example lets get the first 10 rows of data after the 20th rows 
-- or the data between 20th row and 30th row

select 
	row_number() over(order by order_id) row_num, 
	*
from 
	orders
order by 
	order_id
offset 20 rows 
fetch next 10 rows only


--first value and last value. 
-- this will return the first value or last value for a column 
-- used along with over operator and partition operator we can get the first value and last value for each cagetory with in the column

select 
	cust.customer_id,
	cust.company_name,
	ord.order_date,
	first_value(ord.order_date) over(partition by cust.customer_id order by cust.customer_id) first_order_date,
	last_value(ord.order_date) over(partition by cust.customer_id order by cust.customer_id) last_order_date
from 
	customers cust
inner join 
	orders ord
on 	
	cust.customer_id = ord.customer_id

--grouping and tagging the entries 
-- It is helpful if you want to group the entries into certain groups and tag them with respective name. 
--for exmaple, a customer who is buying frequently is more important..
-- we need to create a focus groups of customer who we need to focus more from advertising point of view 
-- using case function (if fucntion) 
-- Here the order_frequency is the view we created in previous statement 

with CTE as (
select
	customer_id,
	company_name,
	round(avg(Next_order_diff)::numeric,2) as avgfreq
from 
	order_frequency
group by 
	customer_id, company_name
)


select 
	customer_id, 
	company_name,
	avgfreq,
	case When avgfreq <= 30 then 'Premium_customer'
		when avgfreq >=30 and avgfreq <= 90 then 'Regular_customer'
		when avgfreq >= 90 and avgfreq <= 150 then 'Normal_customer'
		else 'Needs_Attention'  
	end as tag
from 
	CTE




-- Complex Match Join:
-- creating a pair of supply and demand cities. for example paring each cities with every other cities but only once
-- a altered pair between same cities are not allowed. 

--lets create a table of cities for this purpose
 --create table cities
-- ( 
 --id  serial,
-- city varchar(20))

 --inserting the data 
 --insert into cities (city) values ('New York')
 --insert into cities (city)values ('Chicago')
 --insert into cities (city)values ('Washington DC')
--insert into cities (city) values ('Atlanta')

 select * from cities 

 -- create the inner join first and again join that resultant table with another inner join at first 
with Pair as (
 select 
	c1.id as from_id,
	c1.city as from_city,
	c2.id as to_id,
	c2.city as to_city
from cities c1 
inner join 
	cities c2
on 
	c1.id <> c2.id )

select p1.*
from 
pair p1
inner join pair p2 
on p1.from_id = p2.to_id and p1.to_id = p2.from_id and p2.from_id <= p2.to_id
	

-- nth highest salary , nth highest sales 

with CTE as (
select prod.product_name,sum(ord.quantity),
row_number() over(order by sum(ord.quantity) desc) as rank
from order_details ord
inner join products prod
on prod.product_id = ord.product_id  
group by prod.product_name
order by sum(ord.quantity) desc)
select product_name from cte where rank = 2




