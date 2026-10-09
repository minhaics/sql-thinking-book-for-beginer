-- id: E18
-- title: Emails with capital letters
-- chapter: 11
-- tags: LOWER, strings
-- ordered: true
-- prompt: Find customer_id and email of customers whose email contains at least one uppercase letter.
--   Sort by customer_id.
-- hint: A string without uppercase letters is equal to its own LOWER().
SELECT customer_id, email
FROM customers
WHERE email <> LOWER(email)
ORDER BY customer_id;
