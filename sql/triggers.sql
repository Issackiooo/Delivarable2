-- ============================================================
-- e-Hotels Triggers
-- ============================================================

-- ============================================================
-- TRIGGER 1: Automatically update hotel_chain.num_hotels
-- When a hotel is inserted or deleted, keep the count in sync.
-- This enforces the derived attribute num_hotels on HotelChain.
-- ============================================================
CREATE OR REPLACE FUNCTION update_num_hotels()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE hotel_chain
        SET num_hotels = num_hotels + 1
        WHERE chain_id = NEW.chain_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE hotel_chain
        SET num_hotels = num_hotels - 1
        WHERE chain_id = OLD.chain_id;
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' AND NEW.chain_id <> OLD.chain_id THEN
        UPDATE hotel_chain SET num_hotels = num_hotels - 1
        WHERE chain_id = OLD.chain_id;
        UPDATE hotel_chain SET num_hotels = num_hotels + 1
        WHERE chain_id = NEW.chain_id;
        RETURN NEW;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_num_hotels
AFTER INSERT OR DELETE OR UPDATE ON hotel
FOR EACH ROW EXECUTE FUNCTION update_num_hotels();

-- ============================================================
-- TRIGGER 2: Automatically update hotel.num_rooms
-- When a room is inserted or deleted, keep the count in sync.
-- ============================================================
CREATE OR REPLACE FUNCTION update_num_rooms()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE hotel SET num_rooms = num_rooms + 1
        WHERE hotel_id = NEW.hotel_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE hotel SET num_rooms = num_rooms - 1
        WHERE hotel_id = OLD.hotel_id;
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' AND NEW.hotel_id <> OLD.hotel_id THEN
        UPDATE hotel SET num_rooms = num_rooms - 1
        WHERE hotel_id = OLD.hotel_id;
        UPDATE hotel SET num_rooms = num_rooms + 1
        WHERE hotel_id = NEW.hotel_id;
        RETURN NEW;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_num_rooms
AFTER INSERT OR DELETE OR UPDATE ON room
FOR EACH ROW EXECUTE FUNCTION update_num_rooms();

-- ============================================================
-- TRIGGER 3: Archive bookings before delete
-- When a booking is deleted, copy it to booking_archive so
-- the history is preserved even if room/customer is deleted.
-- ============================================================
CREATE OR REPLACE FUNCTION archive_booking()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO booking_archive
        (booking_id, customer_id, customer_name, room_id,
         hotel_address, chain_name, start_date, end_date, booking_date)
    SELECT
        OLD.booking_id,
        OLD.customer_id,
        c.full_name,
        OLD.room_id,
        h.address || ', ' || h.city,
        hc.name,
        OLD.start_date,
        OLD.end_date,
        OLD.booking_date
    FROM room r
    JOIN hotel h ON r.hotel_id = h.hotel_id
    JOIN hotel_chain hc ON h.chain_id = hc.chain_id
    LEFT JOIN customer c ON OLD.customer_id = c.customer_id
    WHERE r.room_id = OLD.room_id;

    -- If room was already deleted (CASCADE), insert with NULLs for hotel info
    IF NOT FOUND THEN
        INSERT INTO booking_archive
            (booking_id, customer_id, customer_name, room_id,
             start_date, end_date, booking_date)
        VALUES (
            OLD.booking_id, OLD.customer_id,
            (SELECT full_name FROM customer WHERE customer_id = OLD.customer_id),
            OLD.room_id, OLD.start_date, OLD.end_date, OLD.booking_date
        );
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_archive_booking
BEFORE DELETE ON booking
FOR EACH ROW EXECUTE FUNCTION archive_booking();

-- ============================================================
-- TRIGGER 4: Archive rentings before delete
-- ============================================================
CREATE OR REPLACE FUNCTION archive_renting()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO renting_archive
        (renting_id, booking_id, customer_id, customer_name, room_id,
         hotel_address, chain_name, employee_id, employee_name,
         start_date, end_date, checkin_date)
    SELECT
        OLD.renting_id,
        OLD.booking_id,
        OLD.customer_id,
        c.full_name,
        OLD.room_id,
        h.address || ', ' || h.city,
        hc.name,
        OLD.employee_id,
        e.full_name,
        OLD.start_date,
        OLD.end_date,
        OLD.checkin_date
    FROM room r
    JOIN hotel h ON r.hotel_id = h.hotel_id
    JOIN hotel_chain hc ON h.chain_id = hc.chain_id
    LEFT JOIN customer c ON OLD.customer_id = c.customer_id
    LEFT JOIN employee e ON OLD.employee_id = e.employee_id
    WHERE r.room_id = OLD.room_id;

    IF NOT FOUND THEN
        INSERT INTO renting_archive
            (renting_id, booking_id, customer_id, customer_name, room_id,
             employee_id, start_date, end_date, checkin_date)
        VALUES (
            OLD.renting_id, OLD.booking_id, OLD.customer_id,
            (SELECT full_name FROM customer WHERE customer_id = OLD.customer_id),
            OLD.room_id, OLD.employee_id,
            OLD.start_date, OLD.end_date, OLD.checkin_date
        );
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_archive_renting
BEFORE DELETE ON renting
FOR EACH ROW EXECUTE FUNCTION archive_renting();
