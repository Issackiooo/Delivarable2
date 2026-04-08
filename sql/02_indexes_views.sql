CREATE INDEX idx_hotel_area_expr
    ON hotel (hotel_area(address));

CREATE INDEX idx_room_capacity_price
    ON room (capacity, price);

CREATE INDEX idx_booking_room_dates
    ON booking (hc_name, hc_addr, h_addr, r_id, start_date, end_date);

CREATE INDEX idx_renting_room_dates
    ON renting (hc_name, hc_addr, h_addr, r_id, start_date, end_date);

CREATE VIEW available_rooms_per_area AS
SELECT
    hotel_area(h.address) AS area,
    COUNT(*) FILTER (WHERE r.is_available) AS available_room_count
FROM hotel h
JOIN room r
  ON r.hc_name = h.hc_name
 AND r.hc_address = h.hc_address
 AND r.h_address = h.address
GROUP BY hotel_area(h.address)
ORDER BY hotel_area(h.address);

CREATE VIEW hotel_aggregated_capacity AS
SELECT
    h.hc_name,
    h.hc_address,
    h.address AS hotel_address,
    hotel_area(h.address) AS area,
    h.stars,
    COUNT(r.id) AS total_rooms,
    COALESCE(SUM(r.capacity), 0) AS aggregated_capacity,
    COALESCE(SUM(r.capacity + r.extendable_by), 0) AS max_aggregated_capacity
FROM hotel h
LEFT JOIN room r
  ON r.hc_name = h.hc_name
 AND r.hc_address = h.hc_address
 AND r.h_address = h.address
GROUP BY h.hc_name, h.hc_address, h.address, hotel_area(h.address), h.stars
ORDER BY h.hc_name, h.address;
