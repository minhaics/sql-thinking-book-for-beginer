-- id: E03
-- title: Customers who signed up in December 2025
-- chapter: 3
-- tags: WHERE, date range
-- ordered: true
-- prompt: List customer_id, full_name and signup_date of customers who signed up in December 2025.
--   Sort by signup_date, then customer_id.
-- hint: Use a half-open range: >= '2025-12-01' AND < '2026-01-01'.
SELECT customer_id, full_name, signup_date
FROM customers
WHERE signup_date >= DATE '2025-12-01'
  AND signup_date <  DATE '2026-01-01'
ORDER BY signup_date, customer_id;
