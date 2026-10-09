-- id: H12
-- title: Median order value by region
-- chapter: 11
-- tags: PERCENTILE_CONT, mean vs median
-- ordered: false
-- prompt: For 'delivered' orders, compute per shipping region: region, mean (AVG subtotal, rounded to a whole number)
--   and median (median subtotal, rounded to a whole number). Why is the mean so much larger than the median?
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
