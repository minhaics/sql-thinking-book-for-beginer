-- id: E04
-- title: Customers without a phone number
-- chapter: 4
-- tags: NULL, COUNT
-- ordered: false
-- prompt: How many customers have no phone number?
-- hint: phone = NULL is never true. Use IS NULL.
SELECT COUNT(*) AS customer_count
FROM customers
WHERE phone IS NULL;
