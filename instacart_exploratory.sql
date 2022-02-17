			-- EXPLORATORY DATA ANALYSIS AND CLEANING - INSTACART ORDERS


			-- Reviewing the datasets

Select *
From instacart.dbo.aisles as aisles
order by 2

Select *
From instacart.dbo.departments as departments
order by 2

Select *
From instacart.dbo.order_products1 as op1

Select *
From instacart.dbo.order_products2 as op2

Select *
From instacart.dbo.orders AS orders

Select *
From instacart.dbo.products as products
order by 2

			--checking null values

select *
from instacart.dbo.aisles
where aisle is null or aisle_id is null

select *
from instacart.dbo.departments
where department_id is null or department is null

select *
from instacart.dbo.order_products1
where 
	order_id is null or
	product_id is null or
	add_to_cart_order is null or
	reordered is null

select *
from instacart.dbo.order_products2
where 
	order_id is null or
	product_id is null or
	add_to_cart_order is null or
	reordered is null

select *
from instacart.dbo.products
where
	product_id is null or
	product_name is null or 
	aisle_id is null or
	department_id is null
	-- 1 product name null, product_id 11908, aisle_id 31, department_id 7

	select aisle_id, aisle
	from instacart.dbo.aisles
	where aisle_id = 31

	select department, department_id
	from instacart.dbo.departments
	where department_id = 7

update instacart.dbo.products set product_name = 'cold beverage' where product_id = 11908

select *
from instacart.dbo.orders
where
	order_id is null or
	user_id is null or
	eval_set is null or
	order_number is null or
	order_dow is null or
	order_hour_of_day is null or
	days_since_prior_order is null

			-- null values in orders table

-- 63100 days_since_prior_order are null, about 6% of data
select count(*) as 'nullcount'
from instacart.dbo.orders
where days_since_prior_order is null

select count(*) as 'num' 
from instacart.dbo.orders

-- 11 days average with nulls
select avg(days_since_prior_order)
from instacart.dbo.orders

-- replacing the null value with the previous non null value
declare @n int
update instacart.dbo.orders
set
	@n = coalesce(days_since_prior_order, @n),
	days_since_prior_order = coalesce(days_since_prior_order, @n)

select * from instacart.dbo.orders

-- 11 day average after replacing null values
select avg(days_since_prior_order)
from instacart.dbo.orders

-- merging orders_products tables
Select * Into orderproducts
From instacart.dbo.order_products1
union
Select * from instacart.dbo.order_products2

-- 2,097,150 orders total
select count(order_id)
from orderproducts


			-- value counts for the days of the week 0 = Sunday 6 = Saturday
			-- value counts for hours within the day

-- Sunday with the most at 183939, Thursday with least with 130367	
select order_dow, count(*) as 'num'
from instacart.dbo.orders
group by order_dow
order by 'num' desc

-- 10am had the most orders at 88228, 3am had the least at 1649
select order_hour_of_day, count(*) as 'num'
from instacart.dbo.orders
group by order_hour_of_day
order by 'num' desc

-- Sunday = most orders at 2pm with 16784
select order_hour_of_day, count(*) as 'num'
from instacart.dbo.orders
where order_dow = 0
group by order_hour_of_day
order by 'num' desc

-- Monday = most orders at 10am with 16876
select order_hour_of_day, count(*) as 'num'
from instacart.dbo.orders
where order_dow = 1
group by order_hour_of_day
order by 'num' desc

--Tuesday = most orders at 10am with 11969
select order_hour_of_day, count(*) as 'num'
from instacart.dbo.orders
where order_dow = 2
group by order_hour_of_day
order by 'num' desc

--Wednesday = Most orders at 3pm with 11069
select order_hour_of_day, count(*) as 'num'
from instacart.dbo.orders
where order_dow = 3
group by order_hour_of_day
order by 'num' desc

--Thursday = Most orders at 10am with 10714
select order_hour_of_day, count(*) as 'num'
from instacart.dbo.orders
where order_dow = 4
group by order_hour_of_day
order by 'num' desc

-- Friday = Most orders at 10am with 11657
select order_hour_of_day, count(*) as 'num'
from instacart.dbo.orders
where order_dow = 5
group by order_hour_of_day
order by 'num' desc

-- Saturday = Most orders at 2pm with 11889
select order_hour_of_day, count(*) as 'num'
from instacart.dbo.orders
where order_dow = 6
group by order_hour_of_day
order by 'num' desc


			--ranking the departments based weekend and weekday orders

-- Weekend orders
select department_id, count(*) as 'total' 
into dept_weekend
from instacart.dbo.products
where product_id in (
	select product_id
	from orderproducts
	where order_id in (
		select order_id
		from instacart.dbo.orders
		where order_dow = 0 or order_dow = 6
		)
	)
group by department_id

select * from dept_weekend

--Weekday orders
select department_id, count(*) as 'total' 
into dept_weekday
from instacart.dbo.products
where product_id in (
	select product_id
	from orderproducts
	where order_id in (
		select order_id
		from instacart.dbo.orders
		where order_dow > 0 and order_dow < 6
		)
	)
group by department_id

select * from dept_weekday

			-- joining department names to dept_id

-- weekend totals per department
select departments.department, dept_weekend.department_id, dept_weekend.total
into weekend_orders
from instacart.dbo.departments
left join dept_weekend
on instacart.dbo.departments.department_id = dept_weekend.department_id
order by total desc

select * from weekend_orders
order by total desc

-- weekday totals per department
select departments.department, dept_weekday.department_id, dept_weekday.total
into weekday_orders
from instacart.dbo.departments
left join dept_weekday
on instacart.dbo.departments.department_id = dept_weekday.department_id
order by total desc

select * from weekday_orders
order by total desc

			-- ranking departments based on morning and afternoon orders, excluding overnight

-- morning orders
select department_id, count(*) as 'total' 
into dept_morning
from instacart.dbo.products
where product_id in (
	select product_id
	from orderproducts
	where order_id in (
		select order_id
		from instacart.dbo.orders
		where order_hour_of_day < 12 or order_hour_of_day > 6
		)
	)
group by department_id

--afternoon orders
select department_id, count(*) as 'total' 
into dept_afternoon
from instacart.dbo.products
where product_id in (
	select product_id
	from orderproducts
	where order_id in (
		select order_id
		from instacart.dbo.orders
		where order_hour_of_day < 22 or order_dow > 12
		)
	)
group by department_id

			--joining department names with totals

-- morning total orders per department
select departments.department, dept_morning.department_id, dept_morning.total
into morning_orders
from instacart.dbo.departments
left join dept_morning
on instacart.dbo.departments.department_id = dept_morning.department_id
order by total desc

select * from morning_orders
order by total desc

-- afternoon total orders per department
select departments.department, dept_afternoon.department_id, dept_afternoon.total
into afternoon_orders
from instacart.dbo.departments
left join dept_afternoon
on instacart.dbo.departments.department_id = dept_afternoon.department_id
order by total desc

select * from afternoon_orders
order by total desc

			-- weekday vs weekend difference

-- positive number indicates more sales during weekday
select weekday_orders.department, weekday_orders.department_id, weekday_orders.total - weekend_orders.total as 'total'
into weekday_vs_weekend
from weekday_orders
join weekend_orders
 on weekday_orders.department_id = weekend_orders.department_id 
order by 'total' desc

-- snacks, personal care, and panty departments are most shopped during the week
select * from weekday_vs_weekend
order by total desc

			-- morning vs afternoon difference

-- positive total indicates more sales during morning
select morning_orders.department, morning_orders.department_id, morning_orders.total - afternoon_orders.total as 'total'
into morning_vs_afternoon
from morning_orders
join afternoon_orders
 on morning_orders.department_id = afternoon_orders.department_id 
order by 'total' desc

-- personal care products mostly shopped in the morning
select * from morning_vs_afternoon
order by total desc


			-- Ranking products to determine most shopped/ least shopped product

select product_id, count(*) as 'total'
into product_total
from orderproducts
where order_id in (
	select order_id
	from instacart.dbo.orders
	)
group by product_id

select instacart.dbo.products.product_name, product_total.product_id, product_total.total
from instacart.dbo.products
join product_total
on instacart.dbo.products.product_id = product_total.product_id
order by total desc

-- Most picked product are bananas, 2nd most is a bag of bananas.  Top 10 products are all from produce dept.
-- Milk was most picked nonproduce product at 11th
select * from product_total


			--- Summary

-- Sunday was the busiest day for instacart, with thursday being slowest day
-- 10 am saw the biggest spike in orders with 3am having the the biggest dip
-- different days of the week had different times of day where orders spiked
-- snacks department had the most products shopped regardless of time of day, weekday or weekend
-- personal care department had the biggest difference in products picked morning vs afternoon
-- Most shopped item are bananas, top 10 products picked were all produce
-- Milk was the most picked nonproduce product picked - ranked 11th




