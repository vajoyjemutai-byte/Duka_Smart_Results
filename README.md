# Retail Sales & Customer Intelligence (PostgreSQL)

This is an SQL analysis of **Duka Smart Electronics**, a fictional Kenyan retailer that sells phones, laptops,
accessories, TVs and home appliances in ten towns. The data covers **150 customers and 800 orders
from January 2025 to September 2026**.
I set up the database, answered 46 business questions in SQL,
and turned the results into recommendations for management.

All people and companies in the data are fictional.

## What the project covers

- Creating tables with primary keys, foreign keys and constraints
- Filtering, sorting and summarising data (`WHERE`, `GROUP BY`, `HAVING`)
- `INNER JOIN` and `LEFT JOIN`, including finding customers who never ordered
- Subqueries and CTEs (`WITH`)
- Window functions: `RANK`, `DENSE_RANK`, `ROW_NUMBER`, `NTILE`, `LAG`, running totals
- A view, a PL/pgSQL function and `CASE` customer segmentation
- Business insights written for a manager

## Repository contents

| File | Description |
|---|---|
| `schema.sql` | `CREATE TABLE` statements for `customers` and `orders` |
| `queries.sql` | All 46 answers, numbered `-- Q1` to `-- Q46` |
| `insights.md` | Six business insights with findings and recommendations |
| `screenshots/` | Output of the data check and a selection of query results |

The data-loading scripts are not included.

## The data

- **`customers`**: `customer_id`, `customer_name`, `gender`, `city`, `registration_date`, `customer_segment`
- **`orders`**: `order_id`, `customer_id`, `order_date`, `product_name`, `product_category`, `quantity`,
  `unit_price`, `cost_price`, `discount`, `payment_method`, `order_status`

One customer can have many orders (`orders.customer_id` references `customers.customer_id`).

## Business rules used

| Measure | Formula |
|---|---|
| Revenue | `quantity * unit_price * (1 - discount / 100)` |
| Cost | `quantity * cost_price` |
| Profit | `revenue - cost` |
| Profit margin % | `profit / revenue * 100`, using `NULLIF` to avoid dividing by zero |

- Money questions (revenue, cost, profit, spending, averages) use **Completed** orders only.
- Order counts include every order, whatever its status.
- "Today" is the latest `order_date` in the data (30 September 2026), not the computer's date.
- Months mean year and month, using `DATE_TRUNC('month', order_date)`.
- Money is rounded to 2 decimal places.

## How to set it up

You need PostgreSQL 14 or newer and a SQL client such as psql, pgAdmin or DBeaver.

```bash
# 1. Create the database (connected to the default postgres database)
psql -U postgres -d postgres -c "CREATE DATABASE retail_analytics;"

# 2. Create the tables
psql -U postgres -d retail_analytics -f schema.sql

# 3. Load the customer and order data (provided with the assignment)

# 4. Run all the queries
psql -U postgres -d retail_analytics -f queries.sql
```

In pgAdmin or DBeaver, open `queries.sql` and run one question at a time, since each is numbered and
separate. Make sure you are connected to `retail_analytics`.

## Headline results

- Total completed revenue is **KSh 24,155,371.70**, with an overall profit margin of about 12%.
- **Accessories** make up only 4.5% of revenue but have a 42.4% margin, against roughly 10% for phones,
  computing and electronics.
- **Nairobi** produces about 40% of revenue, and the top three cities produce about 63%.
- **47 of 132** purchasing customers have not bought in more than 90 days.
- Revenue for January to September 2026 is **86% higher** than the same months of 2025, but January is
  a very weak month after a December peak.
- **34 High Value customers** generate about 70% of revenue.

The full explanations and recommendations are in [`insights.md`](insights.md).

## Author

Joy Kipkogei · [GitHub profile](https://github.com/vajoyjemutai-byte)
