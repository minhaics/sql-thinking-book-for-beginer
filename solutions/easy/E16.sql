-- id: E16
-- title: Shipments still in transit
-- chapter: 4
-- tags: IS NULL
-- ordered: true
-- prompt: List shipment_id and order_id of shipments that have not been delivered yet (no delivered_at).
--   Sort by shipment_id.
SELECT shipment_id, order_id
FROM shipments
WHERE delivered_at IS NULL
ORDER BY shipment_id;
