-- id: E11
-- title: Marketplace average rating
-- chapter: 6
-- tags: AVG, ROUND
-- ordered: false
-- prompt: Compute the number of reviews (review_count) and the average rating (avg_rating, rounded to 2 decimals)
--   across the whole marketplace.
SELECT COUNT(*) AS review_count,
       ROUND(AVG(rating), 2) AS avg_rating
FROM reviews;
