select * from customers;
select * from orders;

--Q1 Retrieve all customer records.
select * from customers;

--Q2 Display customer names, cities, and segments
select customer_name,
city,
customer_segment
from customers;

--q3 Find customers living in Nairobi.
select customer_name
from customers
where city = 'Nairobi';

--Q4 Find customers registered after January 1, 2025.
select customer_name,
registration_date
from customers
where registration_date > '2025-01-01';

--Q5 Display all unique customer cities.
select distinct city
from customers;

--Q6 Retrieve the 10 most recent orders.
select * from orders
order by order_date desc 
limit 10;

--Q7 Find orders with unit prices above KSh 10,000.
select order_id,
order_date,
product_name,
quantity,
unit_price
from orders
where unit_price > 10000;

--Q8. Find customers whose names start with A.
select customer_name
from customers
where left (customer_name, 1) = 'A';

select customer_name
from customers
where customer_name like 'A%';

--Q9. Retrieve orders with quantities between 2 and 5.
select order_id, product_name, product_category, quantity
from orders
where quantity between 2 and 5;


--Q10. Find orders paid through M-Pesa.
select order_id,
payment_method
from orders
where payment_method = 'M-Pesa';

--SECTION B 
--Q11. Count all customers.
select count (*) from customers;

--Q12. Count all orders.
select count (*) from orders;

--Q13. Calculate completed-order revenue.
SELECT round(sum(quantity * unit_price * (1 - discount / 100)), 2) AS completed_revenue
FROM orders
WHERE order_status = 'Completed';

--Q14. Calculate the average completed-order value.

SELECT round(avg(quantity * unit_price * (1 - discount / 100)), 2) AS Avg_completed_order_value
FROM orders
WHERE order_status = 'Completed';

--Q15. Find the highest and lowest product prices.
select max (unit_price) as highest_price,
min (unit_price) as lowest_price
from orders;

--Q16. Calculate revenue by product category.
SELECT product_category, round(sum(quantity * unit_price * (1 - discount / 100)), 2) AS revenue
FROM orders
WHERE order_status = 'Completed'
group by product_category;

--Q17. Count customers by city.
select city,
count (*) as customer
from customers
group by city;

--Q18. Calculate quantity sold by product.
select product_name,
count (quantity) as units_sold
from orders
group by product_name;

select product_name,
       sum(quantity) as units_sold
from orders
where order_status = 'Completed'
group by product_name
order by units_sold desc;

--Q19. Find categories generating more than KSh 100,000 in revenue.
SELECT product_category,round(sum(quantity * unit_price * (1 - discount / 100)), 2) AS revenue
FROM orders
WHERE order_status = 'Completed'
group by product_category 
having round(sum(quantity * unit_price * (1 - discount / 100)), 2) > 100000;

--Q20. Calculate the percentage of cancelled orders.
select 
round (COUNT(*) FILTER (where order_status = 'Cancelled' ) *100.0/count(*),2) as percentage_cancelled_orders
from orders;

--Section C
select * from customers;
select * from orders;
--Q21. Display orders with customer names and cities.
select c.customer_id,
c.customer_name,
c.city,
o.order_id 
from orders o
join customers c
on o.customer_id = c.customer_id;

--Q22. Calculate total spending by customer.
select c.customer_name,
c.customer_id,
round(sum(o.quantity * o.unit_price * (1 - o.discount / 100)), 2) as total_spending
from customers c
join orders o on c.customer_id = o.customer_id
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name ;

--Q23. Identify customers who have never ordered.
select c.customer_name,
c.customer_id
from customers c
left join orders o
on o.customer_id = c.customer_id
where o.order_id is null;

--Q24. Find the 10 highest-spending customers.
select c.customer_name,
c.customer_id,
round(sum(o.quantity * o.unit_price * (1 - o.discount / 100)), 2) as total_spending
from customers c
join orders o on c.customer_id = o.customer_id
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name 
order by total_spending desc limit 10;


--Q25. Calculate revenue by customer city.
select c.city,
round(sum(o.quantity * o.unit_price * (1 - o.discount / 100)), 2) as total_revenue_city
from customers c
join orders o on o.customer_id = c.customer_id
where o.order_status = 'Completed'
group by c.city;

--Q26. Identify customers with more than five orders.
select c.customer_id,
c.customer_name,
count (*) as order_count
from customers c
join orders o on o.customer_id = c.customer_id 
group by c.customer_id, c.customer_name
having count (*) > 5;

--Q27. Calculate average customer spending by segment.
SELECT c.customer_segment,
	count(DISTINCT c.customer_id) AS purchasing_customers,
	round(sum(o.quantity *o.unit_price * (1 - o.discount/100)) / count(DISTINCT c.customer_id), 2) AS avg_spending_per_customer
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_segment
ORDER BY avg_spending_per_customer DESC;


--Q28. Identify the most popular category among VIP customers.
select o.product_category,
count (*) as total_orders
from orders o
join customers c on c.customer_id = o.customer_id
where c.customer_segment = 'VIP'
group by o.product_category
order by total_orders desc limit 1;

 -- popular - by orders 
 select * from customers;
select * from orders;
--Q29 Find customers spending above the average total spending per purchasing customer.

WITH customer_totals AS (
    SELECT customer_id,
           SUM(quantity * unit_price * (1 - discount / 100)) AS total_spending
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT ct.customer_id, c.customer_name, ROUND(ct.total_spending, 2) AS total_spending,
       ROUND((SELECT AVG(total_spending) FROM customer_totals), 2) AS avg_total
FROM customer_totals ct
JOIN customers c ON c.customer_id = ct.customer_id
WHERE ct.total_spending > (SELECT AVG(total_spending) FROM customer_totals)
ORDER BY ct.total_spending DESC;

--Q30. Find products priced above the overall average unit price.
SELECT product_name, unit_price
FROM (SELECT DISTINCT product_name, unit_price FROM orders)
WHERE unit_price > (SELECT avg (unit_price) FROM (SELECT DISTINCT product_name, unit_price FROM orders))
ORDER BY unit_price DESC;

--Q31. Use a CTE to identify the three highest-revenue months.
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date AS month,
           ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY 1
)
SELECT month, revenue
FROM monthly
ORDER BY revenue DESC
LIMIT 3;

--Q32. Find customers purchasing from at least three categories.
SELECT c.customer_id, c.customer_name, 
		count(DISTINCT o.product_category) AS categories_bought
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id 
WHERE order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name 
HAVING count(DISTINCT o.product_category) >= 3
ORDER BY categories_bought DESC, c.customer_id;

with customer_categories as (
    select
        customer_id,
        count(distinct product_category) as total_categories---used distinct to count different categories
    from orders where order_status = 'Completed'
    group by customer_id
)
select *
from customer_categories
where total_categories >= 3;

--Q33. Use a CTE to calculate category revenue, cost, profit, and profit margin.
WITH category_totals as(
SELECT 	product_category,
		sum(quantity * unit_price * (1-discount / 100)) AS revenue,
		sum(quantity * cost_price) AS COST
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
)
SELECT product_category,
		round(revenue, 2) AS revenue,
		round(COST, 2) AS COST,
		round(revenue - COST, 2) AS profit,
		round((revenue - cost) / nullif(revenue, 0) * 100, 2) AS profit_margin_pct
FROM category_totals
ORDER BY profit DESC;

--Q34. Find customers whose latest completed order is more than 90 days before the latest order date in the dataset.

WITH latest_orders AS (
    SELECT customer_id, MAX(order_date) AS last_completed_order
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),
today AS (
    SELECT MAX(order_date) AS latest_date FROM orders
)
SELECT lo.customer_id,
       (SELECT customer_name FROM customers c WHERE c.customer_id = lo.customer_id) AS customer_name,
       lo.last_completed_order,
       (SELECT latest_date FROM today) - lo.last_completed_order AS days_since_last_order
FROM latest_orders lo
WHERE (SELECT latest_date FROM today ) - lo.last_completed_order > 90
ORDER BY days_since_last_order DESC, lo.customer_id;

--Q35. Rank customers by spending using `RANK()`.
select
    customer_id,
    sum(quantity * unit_price * (1 - discount / 100)) as spending,
    rank() over (order by sum(quantity * unit_price * (1 - discount / 100)) desc) as customer_rank
from orders
where order_status = 'Completed'
group by customer_id;

--Q36. Number each customer's orders by recency using `ROW_NUMBER()`.
SELECT customer_id, order_id, order_date, order_status,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC, order_id DESC) AS recency_no
FROM orders
ORDER BY customer_id, recency_no;

--Q37. Rank products within categories using `DENSE_RANK()`.
SELECT product_category, product_name,
       ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS revenue,
       DENSE_RANK() OVER (PARTITION BY product_category
                          ORDER BY SUM(quantity * unit_price * (1 - discount / 100)) DESC) AS rank_in_category
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category, product_name
ORDER BY product_category, rank_in_category;

--Q38. Calculate cumulative monthly revenue.
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date AS month,
           SUM(quantity * unit_price * (1 - discount / 100)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY 1
)
SELECT month,
       ROUND(revenue, 2) AS revenue,
       ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS cumulative_revenue
FROM monthly
ORDER BY month;
--Q39. Compare monthly revenue using `LAG()`.
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date AS month,
           SUM(quantity * unit_price * (1 - discount / 100)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY 1
)
SELECT month,
       ROUND(revenue, 2) AS revenue,
       ROUND(LAG(revenue) OVER (ORDER BY month), 2) AS previous_month_revenue,
       ROUND(revenue - LAG(revenue) OVER (ORDER BY month), 2) AS change
FROM monthly
ORDER BY month;

--Q40. Calculate month-over-month revenue growth (%).
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date AS month,
           SUM(quantity * unit_price * (1 - discount / 100)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY 1
)
SELECT month,
       ROUND(revenue, 2) AS revenue,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY month))
             / NULLIF(LAG(revenue) OVER (ORDER BY month), 0) * 100, 2) AS growth_pct
FROM monthly
ORDER BY month;

--Q41. Divide customers into four spending groups using `NTILE(4)`.
WITH customer_totals AS (
    SELECT customer_id,
           SUM(quantity * unit_price * (1 - discount / 100)) AS total_spending
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT NTILE(4) OVER (ORDER BY total_spending DESC) AS spending_group,
       ct.customer_id, c.customer_name, ROUND(ct.total_spending, 2) AS total_spending
FROM customer_totals ct
JOIN customers c ON c.customer_id = ct.customer_id
ORDER BY spending_group, total_spending DESC;
--Q42. Calculate each category's share of total revenue using window functions.
SELECT product_category,
       ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS revenue,
       ROUND(100.0 * SUM(quantity * unit_price * (1 - discount / 100))
             / SUM(SUM(quantity * unit_price * (1 - discount / 100))) OVER (), 2) AS revenue_share_pct
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
ORDER BY revenue DESC;

--Q43. Create a `monthly_sales_summary` view (month, orders, revenue, cost, profit). Then `SELECT` from it.
CREATE OR REPLACE VIEW monthly_sales_summary AS
SELECT DATE_TRUNC('month', order_date)::date AS month,
       COUNT(*) AS orders,
       ROUND(COALESCE(SUM(quantity * unit_price * (1 - discount / 100))
             FILTER (WHERE order_status = 'Completed'), 0), 2) AS revenue,
       ROUND(COALESCE(SUM(quantity * cost_price)
             FILTER (WHERE order_status = 'Completed'), 0), 2) AS cost,
       ROUND(COALESCE(SUM(quantity * unit_price * (1 - discount / 100) - quantity * cost_price)
             FILTER (WHERE order_status = 'Completed'), 0), 2) AS profit
FROM orders
GROUP BY 1;
SELECT * FROM monthly_sales_summary ORDER BY month;

--Q44. Create a PostgreSQL function that returns completed-order revenue for a supplied customer ID. Show
   -- it working for one customer **and** for an ID that does not exist (it should return 0, not NULL).
CREATE OR REPLACE FUNCTION customer_completed_revenue(p_customer_id INTEGER)
RETURNS NUMERIC
LANGUAGE plpgsql AS $$
DECLARE
    v_revenue NUMERIC;
BEGIN
    SELECT COALESCE(SUM(quantity * unit_price * (1 - discount / 100)), 0)
    INTO v_revenue
    FROM orders
    WHERE customer_id = p_customer_id
      AND order_status = 'Completed';
    RETURN ROUND(v_revenue, 2);
END;
$$;
select customer_completed_revenue (141);
select customer_completed_revenue (255);

--Q45. Segment customers into High, Medium and Low Value. **Explain why you chose your thresholds** — for
    --example percentiles, or round KSh amounts based on what the data looks like.
SELECT CASE WHEN COALESCE(s.total_spending, 0) >= 250000 THEN 'High Value'
            WHEN COALESCE(s.total_spending, 0) >= 50000  THEN 'Medium Value'
            ELSE 'Low Value' END AS value_band,
       COUNT(*) AS customers,
       ROUND(SUM(COALESCE(s.total_spending, 0)), 2) AS band_revenue
FROM customers c
LEFT JOIN (SELECT customer_id,
                  SUM(quantity * unit_price * (1 - discount / 100)) AS total_spending
           FROM orders WHERE order_status = 'Completed'
           GROUP BY customer_id) s ON s.customer_id = c.customer_id
GROUP BY 1
ORDER BY band_revenue DESC;

-- Q45: Segment customers into High / Medium / Low Value
-- Thresholds (completed spending, KSh), chosen from the data's percentiles:
--   among the 132 purchasing customers: 25th pct = 35,201, median = 89,999,
--   75th pct = 252,835, 90th pct = 569,359, max = 848,119 (spending is right-skewed).
--   High   : >= 250,000  (round number just under the 75th percentile -> roughly the top quarter)
--   Medium : 50,000 to < 250,000 (sits between the 25th pct and the 75th pct: the middle half)
--   Low    : < 50,000, including the 18 customers with no completed orders (spend = 0)
-- Round figures are easy for management to remember and apply; percentiles keep them honest.

--Q46. Produce a management report: the top five customers, top five products, the most profitable category, 
--and the lowest-revenue month.

WITH cust AS (
    SELECT c.customer_name AS item,
           SUM(o.quantity * o.unit_price * (1 - o.discount / 100)) AS revenue
    FROM orders o JOIN customers c ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Completed' GROUP BY c.customer_id, c.customer_name
    ORDER BY revenue DESC LIMIT 5
), prod AS (
    SELECT product_name AS item,
           SUM(quantity * unit_price * (1 - discount / 100)) AS revenue
    FROM orders WHERE order_status = 'Completed' GROUP BY product_name
    ORDER BY revenue DESC LIMIT 5
), cat AS (
    SELECT product_category AS item,
           SUM(quantity * unit_price * (1 - discount / 100) - quantity * cost_price) AS revenue
    FROM orders WHERE order_status = 'Completed' GROUP BY product_category
    ORDER BY revenue DESC LIMIT 1
), mon AS (
    SELECT TO_CHAR(DATE_TRUNC('month', order_date), 'YYYY-MM') AS item,
           SUM(quantity * unit_price * (1 - discount / 100)) AS revenue
    FROM orders WHERE order_status = 'Completed' GROUP BY 1
    ORDER BY revenue ASC LIMIT 1
)
SELECT '1. Top 5 customers (revenue)' AS section, item, ROUND(revenue, 2) AS value FROM cust
UNION ALL SELECT '2. Top 5 products (revenue)', item, ROUND(revenue, 2) FROM prod
UNION ALL SELECT '3. Most profitable category (profit)', item, ROUND(revenue, 2) FROM cat
UNION ALL SELECT '4. Lowest-revenue month (revenue)', item, ROUND(revenue, 2) FROM mon
ORDER BY 1, 3 DESC;

