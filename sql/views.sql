-- ============================================================
-- e-Hotels Views
-- ============================================================

-- ============================================================
-- VIEW 1: Number of available rooms per area
-- Shows how many rooms are currently available in each city/area.
-- ============================================================
CREATE OR REPLACE VIEW available_rooms_per_area AS
SELECT
    h.city                          AS area,
    COUNT(r.room_id)                AS available_rooms
FROM hotel h
JOIN room r ON h.hotel_id = r.hotel_id
WHERE r.is_available = TRUE
GROUP BY h.city
ORDER BY h.city;

-- ============================================================
-- VIEW 2: Aggregated capacity of all rooms of a specific hotel
-- Shows the total room capacity for every hotel.
-- ============================================================
CREATE OR REPLACE VIEW hotel_aggregated_capacity AS
SELECT
    hc.name                         AS chain_name,
    h.hotel_id,
    h.address                       AS hotel_address,
    h.city,
    h.stars,
    COUNT(r.room_id)                AS total_rooms,
    SUM(r.capacity)                 AS total_capacity
FROM hotel h
JOIN hotel_chain hc ON h.chain_id = hc.chain_id
JOIN room r ON h.hotel_id = r.hotel_id
GROUP BY hc.name, h.hotel_id, h.address, h.city, h.stars
ORDER BY hc.name, h.city;
