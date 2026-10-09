-- id: H05
-- title: Longest streak of consecutive buying months
-- chapter: 13
-- tags: gaps and islands, ROW_NUMBER
-- ordered: true
-- prompt: Ignore 'cancelled' orders. For each customer, find the longest run of CONSECUTIVE months in which they placed
--   at least one order. If a customer has several runs of the same length, take the earliest. List the 10 customers
--   with the longest runs: customer_id, months, from_month ('YYYY-MM'), to_month ('YYYY-MM');
--   sort by months descending, then customer_id.
-- hint: The "gaps and islands" trick: (month_number - ROW_NUMBER()) is constant within one consecutive run.
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
