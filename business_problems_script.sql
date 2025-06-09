show databases;
use walmart;
show tables;
select count(*) from walmart;
select * from walmart LIMIT 10;

/*BUSINESS PROBLEMS*/
 
/*BP-1 : For each payment methods, find the number of transactions and the number of quantities sold*/
SELECT payment_method, count(*) as number_of_transactions, sum(quantity) as number_of_qty_sold
from walmart 
group by payment_method 
order by count(*) desc;

/*BP-2: Identify the highest rated category in each branch, displaying the branch, category and the avg rating*/
SELECT Branch, category, avg_rating
FROM
(select Branch,category, avg(rating) as avg_rating, 
RANK() OVER(PARTITION BY branch ORDER BY avg(rating) DESC) as ranking
from walmart
group by Branch, category) as ranked_data
WHERE ranking = 1;

/*BP-3: Identify the busiest day for each branch based on the numer of transactions*/
SELECT *
FROM
(SELECT 
	Branch,
    dayname(STR_TO_DATE(date, '%d/%m/%y')) as day_name,
    count(*) as no_of_trans,
    RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) as ranking
FROM  walmart
group by Branch, day_name) as ranked_data
WHERE ranking = 1;

/*BP-4: Calculate the total number of quantity of items sold per payment method. List payment_method and total_quantity.*/
select payment_method, sum(quantity) as no_of_qty_sold from walmart
group by payment_method;

/*BP-5: Determine the avg, max, min rating of products of each category for each city. List the city, avg rating, min rating, max rating.*/
Select city, category, (round(avg(rating),2)) as avg_rating, max(rating) as max_rating, min(rating) as min_rating from walmart
group by city, category
order by city asc;

/*BP-6: Calculate the total profit for each category by considering total profit as (unit_price * quantity * profit_margin).
list category and total_profit, ordered from highest to lowest profit.*/
select category, round(SUM(unit_price*quantity*profit_margin),3) as total_profit from walmart
group by category
order by total_profit desc;

/*BP-7: Determine the most commmon payment method for each branch. display branch and preffered payment_method*/
WITH cte
AS
(select distinct branch, payment_method as preferred_payment_method, count(payment_method) as total_trans,
RANK() OVER(PARTITION BY Branch ORDER BY count(payment_method) DESC) as ranking
from walmart
group by branch, payment_method)
SELECT * FROM cte 
WHERE ranking =1;

/*BP-8: Categorize sales into 3 groups MORNING, AFTERNOON, EVENING. Find out each of the shifts and number of invoices.*/
SELECT
	Branch,
    CASE WHEN EXTRACT(HOUR FROM(CAST(time AS TIME))) < 12 then 'MORNING'
    WHEN EXTRACT(HOUR FROM(CAST(time AS TIME))) BETWEEN 12 AND 17 then 'AFTERNOON'
    ELSE 'EVENING'
    END day_time,
    COUNT(*)
FROM walmart
GROUP BY day_time, Branch
ORDER BY day_time, branch;

/*BP-9: Identify the 5 branches with highest decrease ratio in revenue compared to the last year(consider current year 2023 and last year 2022)*/
select *,
year((STR_TO_DATE(date, '%d/%m/%y'))) as formatted_year
from walmart;

WITH revenue_2022
AS
(select branch, sum(total) as revenue 
from walmart
WHERE year((STR_TO_DATE(date, '%d/%m/%y')))=2022
group by branch),

revenue_2023
AS
(select branch, sum(total) as revenue 
from walmart
WHERE year((STR_TO_DATE(date, '%d/%m/%y')))=2023
group by branch)

SELECT
ls.branch,
ls.revenue as last_year_revenue,
cs.revenue as current_year_revenue,
ROUND((ls.revenue - cs.revenue)/ls.revenue*100,2) as revenue_decrease_ratio
FROM revenue_2022 as ls
JOIN 
revenue_2023 as cs
on ls.branch = cs.branch
WHERE ls.revenue>cs.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;