-- ============================================================
-- e-Hotels Sample Queries
-- ============================================================

-- ============================================================
-- QUERY 1 (Aggregation): Average room price per hotel chain
-- and star category. Useful for pricing analysis.
-- ============================================================
SELECT
    hc.name          AS chain_name,
    h.stars,
    ROUND(AVG(r.price), 2) AS avg_price,
    COUNT(r.room_id)       AS num_rooms
FROM hotel_chain hc
JOIN hotel h ON hc.chain_id = h.chain_id
JOIN room r ON h.hotel_id = r.hotel_id
GROUP BY hc.name, h.stars
ORDER BY hc.name, h.stars;

-- ============================================================
-- QUERY 2 (Nested / Subquery): Find customers who have bookings
-- at more than one hotel chain.
-- ============================================================
SELECT c.customer_id, c.full_name
FROM customer c
WHERE c.customer_id IN (
    SELECT b.customer_id
    FROM booking b
    JOIN room r ON b.room_id = r.room_id
    JOIN hotel h ON r.hotel_id = h.hotel_id
    GROUP BY b.customer_id
    HAVING COUNT(DISTINCT h.chain_id) > 1
);

-- ============================================================
-- QUERY 3 (Aggregation): Total revenue per hotel from payments.
-- ============================================================
SELECT
    hc.name           AS chain_name,
    h.address         AS hotel_address,
    h.city,
    SUM(p.amount)     AS total_revenue,
    COUNT(p.payment_id) AS num_payments
FROM payment p
JOIN renting rt ON p.renting_id = rt.renting_id
JOIN room r ON rt.room_id = r.room_id
JOIN hotel h ON r.hotel_id = h.hotel_id
JOIN hotel_chain hc ON h.chain_id = hc.chain_id
GROUP BY hc.name, h.hotel_id, h.address, h.city
ORDER BY total_revenue DESC;

-- ============================================================
-- QUERY 4 (Nested / Subquery): Find hotels that currently have
-- no available rooms.
-- ============================================================
SELECT h.hotel_id, hc.name AS chain_name, h.address, h.city, h.stars
FROM hotel h
JOIN hotel_chain hc ON h.chain_id = hc.chain_id
WHERE NOT EXISTS (
    SELECT 1
    FROM room r
    WHERE r.hotel_id = h.hotel_id
      AND r.is_available = TRUE
);

-- ============================================================
-- QUERY 5: List all rooms with their amenities for a given hotel,
-- ordered by capacity and price.
-- ============================================================
SELECT
    r.room_id,
    r.capacity,
    r.price,
    r.view_type,
    r.extendable_by,
    r.is_available,
    STRING_AGG(ra.amenity, ', ' ORDER BY ra.amenity) AS amenities
FROM room r
LEFT JOIN room_amenity ra ON r.room_id = ra.room_id
WHERE r.hotel_id = 1  -- change to any hotel_id
GROUP BY r.room_id
ORDER BY r.capacity, r.price;
