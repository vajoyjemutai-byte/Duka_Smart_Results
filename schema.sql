-- duka smart electronics: database schema
-- database: retail_analytics (postgresql 14+)
--
-- create the database first (connected to the default "postgres" database):
--     create database retail_analytics;
-- then connect to retail_analytics and run this file.


-- one row per customer
create table if not exists customers (
    customer_id       integer      primary key,
    customer_name     varchar(100) not null,
    gender            varchar(10),                 -- male / female
    city              varchar(50),                 -- one of ten kenyan towns
    registration_date date,
    customer_segment  varchar(20)                  -- retail / corporate / vip
);

-- one row per order
create table if not exists orders (
    order_id         integer       primary key,
    customer_id      integer       not null references customers (customer_id),
    order_date       date          not null,
    product_name     varchar(100),
    product_category varchar(50),                  -- electronics, accessories, home appliances,
                                                   -- computing, mobile phones
    quantity         integer       check (quantity > 0),
    unit_price       numeric(12,2),                -- ksh per unit, before discount
    cost_price       numeric(12,2),                -- ksh cost of one unit
    discount         numeric(5,2)  check (discount between 0 and 100),  -- percentage: 10 = 10% off
    payment_method   varchar(30),                  -- m-pesa, cash, card, bank transfer
    order_status     varchar(20)                   -- completed, pending, cancelled
);


