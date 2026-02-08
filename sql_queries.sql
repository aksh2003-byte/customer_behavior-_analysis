create database customer_behavior;
use customer_behavior;

SELECT * FROM customer_behavior.customers limit 50;

#1 what is the total revenue genrated by male vs feamle cstomers
select gender, sum(purchase_amount) as total_sales from customers c
group by gender;

#which cuustomers used discount but still spent more than the average purchase amount
select customer_id ,discount_applied,purchase_amount from customers 
where discount_applied='yes' and purchase_amount >= (select avg(purchase_amount) from customers);

#3 which are the top 5 products with the highest average review rating

select item_purchased,round(avg(review_rating),2) as avg_rating from customers 
group by item_purchased order by  avg(review_rating) desc limit 5;

#4 compare avg prchase amount between standard and express shipping
select round(avg(purchase_amount),2) as avg_amo,shipping_type from customers
where shipping_type in ("Express", "Standard") group by shipping_type ;

#5 do subscibed customers spend more compare average spend and total revenue between subscribers and non subscribers
select subscription_status ,
count(customer_id) total_customer,
round(avg(purchase_amount),2) as avg_spend,
round(sum(purchase_amount),2) as total_revenue from customers
 group by subscription_status
 order by total_revenue,avg_spend;

##which 5 products have the highest ppercentage of purchase with discount applied 
select item_purchased,
round(100 * sum(case when discount_applied="yes" then 1 else 0 end )/count(*),2) as discount_rate
from customers 
group by item_purchased
order by discount_rate desc
limit 5;

# segment customerr into new, returning and loyal based on their total number of previous purchases and show the count of each segment
#purchase 1st time new between 2 -10 they are returning customer and more than 10 time they are loyal customers

with customer_type as (
select customer_id,previous_purchases,
case 
 when previous_purchases= "1" then "New customers"
 when previous_purchases between "2" and "10" then "Returning customer"
 else "Loyal customer"
 end as customer_segment
 from customers
)
select customer_segment,count(*) as number_of_customer0 from customer_type 
group by customer_segment;

# what are the top 3 most purchased produuct within each category
with top_purchased as (
select category,item_purchased,
count(customer_id)as total_order,
row_number() over(partition by category order by count(customer_id) desc) as item_rank
from customers
group by category,item_purchased
)
select category,item_purchased,total_order,item_rank from top_purchased 
where item_rank <=3;

#are cstomers who are repeat buyers (more than 5 previouus prchases) alos likely to subscribe
select count(customer_id) as customer,subscription_status
from customers
where previous_purchases >=5 
group by subscription_status;

## what is the revenue contribution of each age grouup
with cust_age as (
select customer_id,sum(purchase_amount) as revenue ,age,
case when age <20 then "young" 
when age <40 then "adult" 
else "old"
end as customer_age
from customers
group by purchase_amount,customer_id,age
)
select count(revenue),customer_age from cust_age
group by customer_age,revenue;


# what is the revenue contribution of each age-grouup
select age_group,sum(purchase_amount) as total_revenue from customers
group by age_group
order by total_revenue desc;

