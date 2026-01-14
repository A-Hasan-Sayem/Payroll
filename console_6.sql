-- https://github.com/dgadiraju/data.git
--create database db_name;
--create user user_name with encrypted password 'password';
--grant all on database db_name to user_name
--SELECT * FROM pg_roles;
-- SELECT grantee, privilege_type FROM information_schema.role_table_grants WHERE table_schema = 'public';
--SELECT datname, pg_catalog.pg_get_userbyid(datdba) AS owner FROM pg_database WHERE datname = 'application';

-- Postgres Table Creation Script
CREATE TABLE departments (
  department_id INT NOT NULL,
  department_name VARCHAR(45) NOT NULL,
  PRIMARY KEY (department_id)
);

CREATE TABLE categories (
  category_id INT NOT NULL,
  category_department_id INT NOT NULL,
  category_name VARCHAR(45) NOT NULL,
  PRIMARY KEY (category_id)
);

CREATE TABLE products (
  product_id INT NOT NULL,
  product_category_id INT NOT NULL,
  product_name VARCHAR(45) NOT NULL,
  product_description VARCHAR(255) NOT NULL,
  product_price FLOAT NOT NULL,
  product_image VARCHAR(255) NOT NULL,
  PRIMARY KEY (product_id)
);

CREATE TABLE customers (
  customer_id INT NOT NULL,
  customer_fname VARCHAR(45) NOT NULL,
  customer_lname VARCHAR(45) NOT NULL,
  customer_email VARCHAR(45) NOT NULL,
  customer_password VARCHAR(45) NOT NULL,
  customer_street VARCHAR(255) NOT NULL,
  customer_city VARCHAR(45) NOT NULL,
  customer_state VARCHAR(45) NOT NULL,
  customer_zipcode VARCHAR(45) NOT NULL,
  PRIMARY KEY (customer_id)
);

CREATE TABLE orders (
  order_id INT NOT NULL,
  order_date TIMESTAMP NOT NULL,
  order_customer_id INT NOT NULL,
  order_status VARCHAR(45) NOT NULL,
  PRIMARY KEY (order_id)
);

CREATE TABLE order_items (
  order_item_id INT NOT NULL,
  order_item_order_id INT NOT NULL,
  order_item_product_id INT NOT NULL,
  order_item_quantity INT NOT NULL,
  order_item_subtotal FLOAT NOT NULL,
  order_item_product_price FLOAT NOT NULL,
  PRIMARY KEY (order_item_id)
);

select count(*) from categories  --58
select count(*) from customers   --12435
select count(*) from departments --6
select count(*) from order_items --172198
select count(*) from orders      --68883
select count(*) from products    --1345

-- create view all_de as select *
from orders o inner join customers c on o.order_customer_id = c.customer_id
    left join order_items oi on o.order_id = oi.order_item_order_id
    left join products p on oi.order_item_product_id = p.product_id
    left join categories ct on ct.category_id = p.product_category_id
    left join departments d on d.department_id = ct.category_department_id

select * from all_de;

create table cat_upsert_chk as
    select *
    from categories
    where category_department_id in (2,3,4)

ALTER TABLE cat_upsert_chk ADD CONSTRAINT cat_upsert_chk_pkey PRIMARY KEY (category_id);


create table order_stg as select * from orders where false;


insert into cat_upsert_chk  (category_id , category_department_id, category_name)
select category_id , category_department_id, category_name
from categories on conflict (category_id)
do update set category_department_id = excluded.category_department_id,
              category_name = excluded.category_name ;

create table daily_revenue as select all_de.order_date, round(sum(all_de.order_item_subtotal)) as Order_revenue
                              from all_de
                              where order_status in ('COMPLETE','CLOSED') and order_item_product_id is not null
                              group by 1
                              order by 1 , 2 desc


alter table daily_revenue rename to daily_product_revenue


explain
select * from daily_revenue

explain
select d.*,
       rank() over(partition by order_date order by Order_revenue desc ) as rk,
       dense_rank() over(partition by order_date order by Order_revenue desc  ) as drk
       from daily_product_revenue d



Explain plan
Choose optimal explain plan

CREATE INDEX index_test
ON orders (order_customer_id);

drop index index_test


select * from cat_upsert_chk

delete from cat_upsert_chk where category_id < 40

delete from temp_cat_upsert


CREATE TABLE temp_cat_upsert AS
SELECT *
FROM categories
WHERE 1 = 0;


INSERT INTO temp_cat_upsert
SELECT *
FROM categories c
WHERE NOT EXISTS (
    SELECT 1
    FROM cat_upsert_chk chk
    WHERE c.category_id = chk.category_id
);


INSERT INTO temp_cat_upsert (category_id, category_department_id, category_name)
SELECT
    c.category_id,
    CASE
        WHEN c.category_department_id IS DISTINCT FROM chk.category_department_id
        THEN c.category_department_id
        ELSE NULL
    END AS category_department_id,
    CASE
        WHEN c.category_name IS DISTINCT FROM chk.category_name
        THEN c.category_name
        ELSE NULL
    END AS category_name
FROM categories c
JOIN cat_upsert_chk chk ON c.category_id = chk.category_id
WHERE
    c.category_department_id IS DISTINCT FROM chk.category_department_id OR
    c.category_name IS DISTINCT FROM chk.category_name;


ALTER TABLE cat_upsert_chk
ADD COLUMN last_updated_at TIMESTAMP,
ADD COLUMN update_flag BOOLEAN;

INSERT INTO cat_upsert_chk ( category_id, category_name, last_updated_at, update_flag)
SELECT
    category_id,
    category_name,
    NOW() AS last_updated_at,
    TRUE AS update_flag
FROM temp_cat_upsert
ON CONFLICT (category_id) DO UPDATE SET
    --category_department_id = COALESCE(EXCLUDED.category_department_id, cat_upsert_chk.category_department_id),
    category_name = COALESCE(EXCLUDED.category_name, cat_upsert_chk.category_name),
    last_updated_at = NOW(),
    update_flag = TRUE;

ALTER TABLE cat_upsert_chk ALTER COLUMN category_department_id DROP NOT NULL;

DELETE FROM temp_cat_upsert t
USING temp_cat_upsert t2
WHERE t.category_id = t2.category_id
AND t.ctid < t2.ctid;




















