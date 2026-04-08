-- Query 1: Search rooms with multiple criteria.
SELECT *
FROM search_available_rooms(
    DATE '2026-05-10',
    DATE '2026-05-14',
    2,
    'Downtown Toronto',
    'Marriott International',
    5,
    5,
    250.00
);

-- Query 2: Aggregation query.
-- Average room price and room count per hotel chain and hotel category.
SELECT
    r.hc_name,
    h.stars,
    COUNT(*) AS room_count,
    ROUND(AVG(r.price), 2) AS average_room_price
FROM room r
JOIN hotel h
  ON h.hc_name = r.hc_name
 AND h.hc_address = r.hc_address
 AND h.address = r.h_address
GROUP BY r.hc_name, h.stars
ORDER BY r.hc_name, h.stars DESC;

-- Query 3: Nested query.
-- Customers who have a booking or renting in a hotel with the maximum category.
SELECT DISTINCT customer_name, stay_type
FROM (
    SELECT b.c_name AS customer_name, 'booking' AS stay_type, h.stars
    FROM booking b
    JOIN hotel h
      ON h.hc_name = b.hc_name
     AND h.hc_address = b.hc_addr
     AND h.address = b.h_addr
    UNION ALL
    SELECT r.c_name AS customer_name, 'renting' AS stay_type, h.stars
    FROM renting r
    JOIN hotel h
      ON h.hc_name = r.hc_name
     AND h.hc_address = r.hc_addr
     AND h.address = r.h_addr
) AS stays
WHERE stars = (SELECT MAX(stars) FROM hotel)
ORDER BY customer_name, stay_type;

-- Query 4: Hotels with unresolved room problems and manager names.
SELECT
    h.hc_name,
    h.address AS hotel_address,
    COUNT(DISTINCT rp.r_id) AS rooms_with_problems,
    e.full_name AS manager_name
FROM hotel h
JOIN hotel_manager hm
  ON hm.hc_name = h.hc_name
 AND hm.hc_addr = h.hc_address
 AND hm.h_addr = h.address
JOIN employee e
  ON e.sin = hm.e_sin
LEFT JOIN room_problem rp
  ON rp.hc_name = h.hc_name
 AND rp.hc_addr = h.hc_address
 AND rp.h_addr = h.address
GROUP BY h.hc_name, h.address, e.full_name
ORDER BY rooms_with_problems DESC, h.hc_name, h.address;
