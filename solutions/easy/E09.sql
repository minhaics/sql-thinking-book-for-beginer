-- id: E09
-- title: Percentage coupons
-- chapter: 3
-- tags: WHERE, ORDER BY
-- ordered: true
-- prompt: List code, discount_value and valid_from of all coupons whose discount_type is 'percent'.
--   Sort by valid_from, then code.
SELECT code, discount_value, valid_from
FROM coupons
WHERE discount_type = 'percent'
ORDER BY valid_from, code;
