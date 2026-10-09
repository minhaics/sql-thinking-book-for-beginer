-- id: M07
-- title: The NOT IN and NULL trap
-- chapter: 8
-- tags: NOT IN, NOT EXISTS, NULL
-- ordered: false
-- prompt: How many customers have NEVER referred anyone (their customer_id does not appear in the referred_by column)?
--   Try writing it with NOT IN first. Is the answer plausible? Explain why.
-- hint: x NOT IN (1, 2, NULL) is never TRUE. Use NOT EXISTS instead.
SELECT COUNT(*) AS customer_count
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM customers r WHERE r.referred_by = c.customer_id
);
