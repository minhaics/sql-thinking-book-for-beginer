-- id: M12
-- title: Which carrier is fastest?
-- chapter: 11
-- tags: time, AVG, EPOCH
-- ordered: true
-- prompt: For shipments that have been delivered (delivered_at is not NULL), compute per carrier: carrier_name,
--   shipment_count, and avg_days = average number of days from shipped_at to delivered_at (rounded to 2 decimals).
--   Sort by avg_days ascending.
-- hint: EXTRACT(EPOCH FROM an_interval) returns the number of seconds.
SELECT c.name AS carrier_name,
       COUNT(*) AS shipment_count,
       ROUND(AVG(EXTRACT(EPOCH FROM s.delivered_at - s.shipped_at) / 86400)::numeric, 2) AS avg_days
FROM shipments s
JOIN carriers c ON c.carrier_id = s.carrier_id
WHERE s.delivered_at IS NOT NULL
GROUP BY c.carrier_id, c.name
ORDER BY avg_days;
