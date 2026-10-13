select * from Customer limit 10
-- total revenue genrerated by m vs f 
select 	gender ,SUM (purchase_amount) as revenue 
from Customer 
group by gender

--Which customers used a discount but still spent more than the average purchase amount?

select customer_id,purchase_amount
from Customer
where discount_applied='Yes' and purchase_amount >= (select AVG(purchase_amount) from Customer )

--Which are the top 5 products with the highest average review rating?

select item_purchased ,Round(AVG(review_rating::numeric),2) as "Average Product rating"
from Customer
group by item_purchased 
order by avg(review_rating::numeric) desc
limit 5;

--Compare the average Purchase Amounts between Standard and Express Shipping.

select shipping_type,
ROUND(AVG(purchase_amount::numeric),2)
from Customer
where shipping_type in ('Express','Standard')
group by shipping_type

--Do subscribed customers spend more? Compare average spend and total revenue
--between subscribers and non-subscribers

select subscription_status,
Count (customer_id) as total_customer,
ROUND(AVG(purchase_amount),2) as avg_spend,
ROUND(SUM(purchase_amount),2) as total_revenue
from Customer
group by subscription_status
order by avg_spend,total_revenue desc

--Which 5 products have the highest percentage of purchases with discounts applied?
select item_purchased,
ROund(100 *SUM(CASE when discount_applied='Yes' then 1 else 0 end)/count(*),2) as discount_rate
from Customer
group by item_purchased
order by discount_rate desc
limit 5

--Segment customers into New, Returning,
--and Loyal based on their total number of previous purchases, and show the count of each segment.
with customer_type as(
select customer_id,previous_purchases,
CASE 
	when previous_purchases= 1 then 'New'
	when previous_purchases BETWEEN 2 and 10 then 'Returning'
	else 'Loyal'
	End as customer_segment
from Customer
)

select customer_segment ,count(*) as "Number of customers" 
from Customer_type
group by customer_segment

--What are the top 3 most purchased products within each category?
with item_counts as(
select category,
item_purchased ,
count (customer_id) as total_orders,
ROW_Number() over(partition by category order by count(customer_id )desc )as item_rank
from customer 
group by category,item_purchased

)

select item_rank,category,item_purchased ,total_orders
from item_counts
where item_rank <=3;


--Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe?
select subscription_status,
count(customer_id )as repeat_buyers
from customer
where previous_purchases >5
group by subscription_Status
--What is the revenue contribution of each age group?
select age_group,
sum(purchase_amount) as total_revenue
from customer 
group by age_group
order by total_revenue desc;