# Reference solutions

> Solve the exercise and check it with `verify.py` before reading. Most exercises have more than one correct solution.


## E01 · Provinces in the Central region (Easy)

```sql
SELECT name
FROM provinces
WHERE region = 'Central'
ORDER BY name;
```


## E02 · The 10 most expensive variants (Easy)

```sql
SELECT sku, variant_name, price
FROM product_variants
ORDER BY price DESC, sku
LIMIT 10;
```


## E03 · Customers who signed up in December 2025 (Easy)

```sql
SELECT customer_id, full_name, signup_date
FROM customers
WHERE signup_date >= DATE '2025-12-01'
  AND signup_date <  DATE '2026-01-01'
ORDER BY signup_date, customer_id;
```


## E04 · Customers without a phone number (Easy)

```sql
SELECT COUNT(*) AS customer_count
FROM customers
WHERE phone IS NULL;
```


## E05 · Unbranded products (Easy)

```sql
SELECT product_id, name
FROM products
WHERE brand IS NULL
ORDER BY product_id;
```


## E06 · Payment methods in use (Easy)

```sql
SELECT DISTINCT method
FROM payments;
```


## E07 · Orders by status (Easy)

```sql
SELECT status, COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY order_count DESC;
```


## E08 · Total stock per warehouse (Easy)

```sql
SELECT warehouse_id, SUM(quantity) AS total_stock
FROM inventory
GROUP BY warehouse_id
ORDER BY warehouse_id;
```


## E09 · Percentage coupons (Easy)

```sql
SELECT code, discount_value, valid_from
FROM coupons
WHERE discount_type = 'percent'
ORDER BY valid_from, code;
```


## E10 · Well-paid customer service staff (Easy)

```sql
SELECT full_name, salary
FROM employees
WHERE department = 'Customer Service'
  AND salary > 15000000
ORDER BY salary DESC, full_name;
```


## E11 · Marketplace average rating (Easy)

```sql
SELECT COUNT(*) AS review_count,
       ROUND(AVG(rating), 2) AS avg_rating
FROM reviews;
```


## E12 · Products and their categories (Easy)

```sql
SELECT p.product_id,
       p.name AS product_name,
       c.name AS category_name
FROM products p
JOIN categories c ON c.category_id = p.category_id
ORDER BY p.product_id
LIMIT 20;
```


## E13 · Line items of order 246 (Easy)

```sql
SELECT v.sku, v.variant_name, oi.quantity, oi.unit_price,
       oi.quantity * oi.unit_price AS line_total
FROM order_items oi
JOIN product_variants v ON v.variant_id = oi.variant_id
WHERE oi.order_id = 246
ORDER BY v.sku;
```


## E14 · Customers by gender (Easy)

```sql
SELECT COALESCE(gender, 'Unknown') AS gender,
       COUNT(*) AS customer_count
FROM customers
GROUP BY COALESCE(gender, 'Unknown');
```


## E15 · Orders per month in 2025 (Easy)

```sql
SELECT EXTRACT(MONTH FROM order_date)::int AS month,
       COUNT(*) AS order_count
FROM orders
WHERE order_date >= '2025-01-01' AND order_date < '2026-01-01'
GROUP BY month
ORDER BY month;
```


## E16 · Shipments still in transit (Easy)

```sql
SELECT shipment_id, order_id
FROM shipments
WHERE delivered_at IS NULL
ORDER BY shipment_id;
```


## E17 · Where are the official stores? (Easy)

```sql
SELECT s.shop_name, p.name AS province_name
FROM sellers s
JOIN provinces p ON p.province_id = s.province_id
WHERE s.is_official
ORDER BY s.shop_name;
```


## E18 · Emails with capital letters (Easy)

```sql
SELECT customer_id, email
FROM customers
WHERE email <> LOWER(email)
ORDER BY customer_id;
```


## E19 · Top 5 provinces by customers (Easy)

```sql
SELECT p.name AS province_name, COUNT(*) AS customer_count
FROM addresses a
JOIN provinces p ON p.province_id = a.province_id
WHERE a.is_default
GROUP BY p.name
ORDER BY customer_count DESC, province_name
LIMIT 5;
```


## E20 · Provinces with a warehouse or a shop (Easy)

```sql
SELECT province_id FROM warehouses
UNION
SELECT province_id FROM sellers;
```


## M01 · Revenue by category (Medium)

```sql
SELECT c.name AS category_name,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o
JOIN order_items oi     ON oi.order_id   = o.order_id
JOIN product_variants v ON v.variant_id  = oi.variant_id
JOIN products p         ON p.product_id  = v.product_id
JOIN categories c       ON c.category_id = p.category_id
WHERE o.status = 'delivered'
GROUP BY c.category_id, c.name
ORDER BY revenue DESC;
```


## M02 · Customers who never ordered (Medium)

```sql
SELECT COUNT(*) AS customer_count
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;
```


## M03 · Products that never sold (Medium)

```sql
SELECT p.product_id, p.name
FROM products p
WHERE NOT EXISTS (
    SELECT 1
    FROM product_variants v
    JOIN order_items oi ON oi.variant_id = v.variant_id
    WHERE v.product_id = p.product_id
)
ORDER BY p.product_id;
```


## M04 · Shops with many active products (Medium)

```sql
SELECT s.shop_name, COUNT(*) AS product_count
FROM sellers s
JOIN products p ON p.seller_id = s.seller_id
WHERE p.is_active
GROUP BY s.seller_id, s.shop_name
HAVING COUNT(*) >= 12
ORDER BY product_count DESC, s.shop_name;
```


## M05 · Employees and their managers (Medium)

```sql
SELECT e.employee_id, e.full_name,
       COALESCE(m.full_name, 'None') AS manager
FROM employees e
LEFT JOIN employees m ON m.employee_id = e.manager_id
ORDER BY e.employee_id;
```


## M06 · The 10 largest orders (Medium)

```sql
SELECT order_id, SUM(quantity * unit_price) AS subtotal
FROM order_items
GROUP BY order_id
ORDER BY subtotal DESC, order_id
LIMIT 10;
```


## M07 · The NOT IN and NULL trap (Medium)

```sql
SELECT COUNT(*) AS customer_count
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM customers r WHERE r.referred_by = c.customer_id
);
```


## M08 · Running revenue in 2025 (Medium)

```sql
WITH monthly AS (
    SELECT EXTRACT(MONTH FROM o.order_date)::int AS month,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
      AND o.order_date >= '2025-01-01' AND o.order_date < '2026-01-01'
    GROUP BY month
)
SELECT month, revenue,
       SUM(revenue) OVER (ORDER BY month) AS running_total
FROM monthly
ORDER BY month;
```


## M09 · Month-over-month order growth (Medium)

```sql
WITH m AS (
    SELECT TO_CHAR(order_date, 'YYYY-MM') AS month, COUNT(*) AS order_count
    FROM orders
    GROUP BY month
)
SELECT month, order_count,
       ROUND((order_count - LAG(order_count) OVER w) * 100.0 / LAG(order_count) OVER w, 1) AS growth_pct
FROM m
WINDOW w AS (ORDER BY month)
ORDER BY month;
```


## M10 · Order value buckets (Medium)

```sql
WITH t AS (
    SELECT order_id, SUM(quantity * unit_price) AS subtotal
    FROM order_items
    GROUP BY order_id
)
SELECT CASE
         WHEN subtotal < 200000  THEN 'Under 200k'
         WHEN subtotal < 500000  THEN '200k-500k'
         WHEN subtotal < 2000000 THEN '500k-2M'
         ELSE '2M and up'
       END AS bucket,
       COUNT(*) AS order_count
FROM t
GROUP BY bucket;
```


## M11 · Cancellation rate by region (Medium)

```sql
SELECT p.region,
       COUNT(*) AS total_orders,
       COUNT(*) FILTER (WHERE o.status = 'cancelled') AS cancelled_orders,
       ROUND(COUNT(*) FILTER (WHERE o.status = 'cancelled') * 100.0 / COUNT(*), 2) AS cancel_rate_pct
FROM orders o
JOIN addresses a ON a.address_id = o.address_id
JOIN provinces p ON p.province_id = a.province_id
GROUP BY p.region;
```


## M12 · Which carrier is fastest? (Medium)

```sql
SELECT c.name AS carrier_name,
       COUNT(*) AS shipment_count,
       ROUND(AVG(EXTRACT(EPOCH FROM s.delivered_at - s.shipped_at) / 86400)::numeric, 2) AS avg_days
FROM shipments s
JOIN carriers c ON c.carrier_id = s.carrier_id
WHERE s.delivered_at IS NOT NULL
GROUP BY c.carrier_id, c.name
ORDER BY avg_days;
```


## M13 · Coupon users who also returned goods (Medium)

```sql
SELECT COUNT(*) AS customer_count
FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id AND o.coupon_id IS NOT NULL)
  AND EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id AND o.status = 'returned');
```


## M14 · In stock in New York, not in Dallas (Medium)

```sql
SELECT COUNT(*) AS variant_count
FROM (
    SELECT i.variant_id FROM inventory i JOIN warehouses w USING (warehouse_id)
    WHERE w.name = 'New York Warehouse' AND i.quantity > 0
    EXCEPT
    SELECT i.variant_id FROM inventory i JOIN warehouses w USING (warehouse_id)
    WHERE w.name = 'Dallas Warehouse' AND i.quantity > 0
) t;
```


## M15 · September birthdays who bought in 2025 (Medium)

```sql
SELECT c.customer_id, c.full_name, c.birth_date
FROM customers c
WHERE EXTRACT(MONTH FROM c.birth_date) = 9
  AND EXISTS (
      SELECT 1 FROM orders o
      WHERE o.customer_id = c.customer_id
        AND o.order_date >= '2025-01-01' AND o.order_date < '2026-01-01'
  )
ORDER BY c.customer_id;
```


## M16 · Peak order days (Medium)

```sql
SELECT order_date::date AS day, COUNT(*) AS order_count
FROM orders
WHERE order_date >= '2025-01-01' AND order_date < '2026-01-01'
GROUP BY day
HAVING COUNT(*) > 100
ORDER BY day;
```


## M17 · The row-multiplication trap (Medium)

```sql
SELECT s.shop_name,
       COUNT(DISTINCT o.order_id) AS order_count,
       SUM(oi.quantity) AS units
FROM orders o
JOIN order_items oi     ON oi.order_id  = o.order_id
JOIN product_variants v ON v.variant_id = oi.variant_id
JOIN products p         ON p.product_id = v.product_id
JOIN sellers s          ON s.seller_id  = p.seller_id
WHERE o.status = 'delivered'
GROUP BY s.seller_id, s.shop_name
ORDER BY units DESC, s.shop_name
LIMIT 10;
```


## M18 · How much do loyal customers spend per order? (Medium)

```sql
WITH order_totals AS (
    SELECT o.order_id, o.customer_id, SUM(oi.quantity * oi.unit_price) AS subtotal
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY o.order_id, o.customer_id
)
SELECT c.customer_id, c.full_name,
       COUNT(*) AS order_count,
       ROUND(AVG(t.subtotal)) AS avg_order_value
FROM order_totals t
JOIN customers c ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.full_name
HAVING COUNT(*) >= 30
ORDER BY avg_order_value DESC, c.customer_id;
```


## H01 · Best-selling product in every category (Hard)

```sql
WITH sales AS (
    SELECT p.category_id, p.product_id, p.name, SUM(oi.quantity) AS units
    FROM orders o
    JOIN order_items oi     ON oi.order_id  = o.order_id
    JOIN product_variants v ON v.variant_id = oi.variant_id
    JOIN products p         ON p.product_id = v.product_id
    WHERE o.status = 'delivered'
    GROUP BY p.category_id, p.product_id, p.name
), ranked AS (
    SELECT *, RANK() OVER (PARTITION BY category_id ORDER BY units DESC) AS rnk
    FROM sales
)
SELECT c.name AS category_name, r.name AS product_name, r.units
FROM ranked r
JOIN categories c ON c.category_id = r.category_id
WHERE r.rnk = 1;
```


## H02 · Revenue rolled up to top-level categories (Hard)

```sql
WITH RECURSIVE roots AS (
    SELECT category_id, category_id AS root_id
    FROM categories
    WHERE parent_id IS NULL
    UNION ALL
    SELECT c.category_id, r.root_id
    FROM categories c
    JOIN roots r ON c.parent_id = r.category_id
), leaf_revenue AS (
    SELECT p.category_id, SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi     ON oi.order_id  = o.order_id
    JOIN product_variants v ON v.variant_id = oi.variant_id
    JOIN products p         ON p.product_id = v.product_id
    WHERE o.status = 'delivered'
    GROUP BY p.category_id
)
SELECT top.name AS top_category,
       COALESCE(SUM(lr.revenue), 0) AS revenue
FROM categories top
JOIN roots r ON r.root_id = top.category_id
LEFT JOIN leaf_revenue lr ON lr.category_id = r.category_id
WHERE top.parent_id IS NULL
GROUP BY top.category_id, top.name
ORDER BY revenue DESC, top_category;
```


## H03 · Org chart paths (Hard)

```sql
WITH RECURSIVE tree AS (
    SELECT employee_id, 1 AS level, full_name::text AS path
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, t.level + 1, t.path || ' > ' || e.full_name
    FROM employees e
    JOIN tree t ON e.manager_id = t.employee_id
)
SELECT employee_id, level, path
FROM tree
ORDER BY employee_id;
```


## H04 · 90-day repeat purchase rate by cohort (Hard)

```sql
WITH valid_orders AS (
    SELECT customer_id, order_date
    FROM orders
    WHERE status <> 'cancelled'
), first_orders AS (
    SELECT customer_id, MIN(order_date) AS first_at
    FROM valid_orders
    GROUP BY customer_id
), flagged AS (
    SELECT f.customer_id,
           TO_CHAR(f.first_at, 'YYYY-MM') AS cohort,
           EXISTS (
               SELECT 1 FROM valid_orders v
               WHERE v.customer_id = f.customer_id
                 AND v.order_date >  f.first_at
                 AND v.order_date <= f.first_at + INTERVAL '90 days'
           ) AS repeated
    FROM first_orders f
    WHERE f.first_at >= '2024-01-01' AND f.first_at < '2025-01-01'
)
SELECT cohort,
       COUNT(*) AS customer_count,
       COUNT(*) FILTER (WHERE repeated) AS repeat_customers,
       ROUND(COUNT(*) FILTER (WHERE repeated) * 100.0 / COUNT(*), 1) AS repeat_rate_pct
FROM flagged
GROUP BY cohort
ORDER BY cohort;
```


## H05 · Longest streak of consecutive buying months (Hard)

```sql
WITH buying_months AS (
    SELECT DISTINCT customer_id,
           (EXTRACT(YEAR FROM order_date) * 12 + EXTRACT(MONTH FROM order_date))::int AS m
    FROM orders
    WHERE status <> 'cancelled'
), islands AS (
    SELECT customer_id, m,
           m - ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY m) AS grp
    FROM buying_months
), runs AS (
    SELECT customer_id, COUNT(*) AS months, MIN(m) AS first_m, MAX(m) AS last_m,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC, MIN(m)) AS rn
    FROM islands
    GROUP BY customer_id, grp
)
SELECT customer_id, months,
       TO_CHAR(MAKE_DATE((first_m - 1) / 12, (first_m - 1) % 12 + 1, 1), 'YYYY-MM') AS from_month,
       TO_CHAR(MAKE_DATE((last_m - 1) / 12, (last_m - 1) % 12 + 1, 1), 'YYYY-MM') AS to_month
FROM runs
WHERE rn = 1
ORDER BY months DESC, customer_id
LIMIT 10;
```


## H06 · Customers who come back fastest (Hard)

```sql
WITH gaps AS (
    SELECT customer_id, order_date,
           order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS gap
    FROM orders
    WHERE status <> 'cancelled'
)
SELECT customer_id,
       COUNT(*) AS order_count,
       ROUND((AVG(EXTRACT(EPOCH FROM gap)) / 86400)::numeric, 1) AS avg_days
FROM gaps
GROUP BY customer_id
HAVING COUNT(*) >= 5
ORDER BY avg_days, customer_id
LIMIT 10;
```


## H07 · Payment reconciliation (Hard)

```sql
WITH merchandise AS (
    SELECT order_id, SUM(quantity * unit_price) AS subtotal
    FROM order_items
    GROUP BY order_id
), collected AS (
    SELECT order_id, SUM(amount) AS collected
    FROM payments
    WHERE status = 'success'
    GROUP BY order_id
), expected AS (
    SELECT o.order_id,
           GREATEST(m.subtotal - CASE c.discount_type
                                   WHEN 'percent' THEN ROUND(m.subtotal * c.discount_value / 100, -3)
                                   WHEN 'fixed'   THEN c.discount_value
                                   ELSE 0
                                 END, 0) + s.shipping_fee AS expected
    FROM orders o
    JOIN merchandise m ON m.order_id = o.order_id
    JOIN shipments s   ON s.order_id = o.order_id
    LEFT JOIN coupons c ON c.coupon_id = o.coupon_id
    WHERE o.status = 'delivered'
)
SELECT e.order_id, e.expected,
       COALESCE(k.collected, 0) AS collected,
       COALESCE(k.collected, 0) - e.expected AS difference
FROM expected e
LEFT JOIN collected k ON k.order_id = e.order_id
WHERE COALESCE(k.collected, 0) <> e.expected
ORDER BY e.order_id;
```


## H08 · 7-day moving average in November 2025 (Hard)

```sql
WITH daily AS (
    SELECT o.order_date::date AS day, SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status <> 'cancelled'
    GROUP BY 1
), moving AS (
    SELECT day, revenue,
           ROUND(AVG(revenue) OVER (ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS avg_7d
    FROM daily
)
SELECT day, revenue, avg_7d
FROM moving
WHERE day >= '2025-11-01' AND day < '2025-12-01'
ORDER BY day;
```


## H09 · Region × quarter pivot table (Hard)

```sql
SELECT EXTRACT(QUARTER FROM o.order_date)::int AS quarter,
       COUNT(*) FILTER (WHERE p.region = 'North')   AS north,
       COUNT(*) FILTER (WHERE p.region = 'Central') AS central,
       COUNT(*) FILTER (WHERE p.region = 'South')   AS south
FROM orders o
JOIN addresses a ON a.address_id = o.address_id
JOIN provinces p ON p.province_id = a.province_id
WHERE o.order_date >= '2025-01-01' AND o.order_date < '2026-01-01'
GROUP BY quarter
ORDER BY quarter;
```


## H10 · Customers loyal to a product (Hard)

```sql
SELECT o.customer_id, v.product_id, COUNT(DISTINCT o.order_id) AS order_count
FROM orders o
JOIN order_items oi     ON oi.order_id  = o.order_id
JOIN product_variants v ON v.variant_id = oi.variant_id
WHERE o.status <> 'cancelled'
GROUP BY o.customer_id, v.product_id
HAVING COUNT(DISTINCT o.order_id) >= 6
ORDER BY order_count DESC, o.customer_id, v.product_id;
```


## H11 · Frequently bought together (Hard)

```sql
WITH order_products AS (
    SELECT DISTINCT oi.order_id, v.product_id
    FROM order_items oi
    JOIN product_variants v ON v.variant_id = oi.variant_id
)
SELECT a.product_id AS product_a, b.product_id AS product_b, COUNT(*) AS order_count
FROM order_products a
JOIN order_products b ON b.order_id = a.order_id AND a.product_id < b.product_id
GROUP BY a.product_id, b.product_id
ORDER BY order_count DESC, product_a, product_b
LIMIT 10;
```


## H12 · Median order value by region (Hard)

```sql
WITH t AS (
    SELECT o.order_id, p.region, SUM(oi.quantity * oi.unit_price) AS subtotal
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN addresses a    ON a.address_id = o.address_id
    JOIN provinces p    ON p.province_id = a.province_id
    WHERE o.status = 'delivered'
    GROUP BY o.order_id, p.region
)
SELECT region,
       ROUND(AVG(subtotal)) AS mean,
       ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY subtotal)::numeric) AS median
FROM t
GROUP BY region;
```
