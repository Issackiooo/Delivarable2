-- ============================================================
-- e-Hotels Indexes
-- ============================================================

-- ============================================================
-- INDEX 1: room(hotel_id, is_available)
--
-- Justification: The most frequent query in this application is
-- searching for available rooms. Users filter by hotel and
-- availability status. This composite index speeds up queries
-- that join room with hotel and filter on is_available, such as
-- the room search endpoint and the "available rooms per area" view.
-- Without this index, every room search would require a full
-- table scan on the room table.
-- ============================================================
CREATE INDEX idx_room_hotel_available
ON room (hotel_id, is_available);

-- ============================================================
-- INDEX 2: booking(room_id, start_date, end_date)
--
-- Justification: When checking room availability for a date range,
-- the system must find all bookings that overlap with the requested
-- dates. This composite index allows PostgreSQL to quickly locate
-- bookings for a specific room and then range-scan on dates,
-- avoiding a full scan of the booking table. This is critical
-- for the room search feature which checks every candidate room
-- against existing bookings.
-- ============================================================
CREATE INDEX idx_booking_room_dates
ON booking (room_id, start_date, end_date);

-- ============================================================
-- INDEX 3: hotel(chain_id, stars)
--
-- Justification: Users frequently filter hotels by hotel chain
-- and star category. The room search allows filtering by chain
-- and/or star rating. This index supports both individual filters
-- (all hotels of a chain, all 5-star hotels) and combined filters
-- (all 4-star Marriott hotels) efficiently. It also accelerates
-- aggregation queries that group hotels by chain and category.
-- ============================================================
CREATE INDEX idx_hotel_chain_stars
ON hotel (chain_id, stars);
