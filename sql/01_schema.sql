BEGIN;

CREATE TABLE hotel_chain (
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    num_hotels INTEGER NOT NULL DEFAULT 0 CHECK (num_hotels >= 0),
    CONSTRAINT hotel_chain_pk PRIMARY KEY (name, address)
);

CREATE TABLE hc_phone (
    hc_name TEXT NOT NULL,
    hc_address TEXT NOT NULL,
    phone_num TEXT NOT NULL,
    CONSTRAINT hc_phone_pk PRIMARY KEY (hc_name, hc_address, phone_num),
    CONSTRAINT hc_phone_fk FOREIGN KEY (hc_name, hc_address)
        REFERENCES hotel_chain (name, address)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE hc_email (
    hc_name TEXT NOT NULL,
    hc_address TEXT NOT NULL,
    email TEXT NOT NULL CHECK (position('@' IN email) > 1),
    CONSTRAINT hc_email_pk PRIMARY KEY (hc_name, hc_address, email),
    CONSTRAINT hc_email_fk FOREIGN KEY (hc_name, hc_address)
        REFERENCES hotel_chain (name, address)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE hotel (
    hc_name TEXT NOT NULL,
    hc_address TEXT NOT NULL,
    address TEXT NOT NULL,
    stars INTEGER NOT NULL CHECK (stars BETWEEN 1 AND 5),
    CONSTRAINT hotel_pk PRIMARY KEY (hc_name, hc_address, address),
    CONSTRAINT hotel_chain_fk FOREIGN KEY (hc_name, hc_address)
        REFERENCES hotel_chain (name, address)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE h_phone (
    hc_name TEXT NOT NULL,
    hc_address TEXT NOT NULL,
    h_address TEXT NOT NULL,
    phone_num TEXT NOT NULL,
    CONSTRAINT h_phone_pk PRIMARY KEY (hc_name, hc_address, h_address, phone_num),
    CONSTRAINT h_phone_fk FOREIGN KEY (hc_name, hc_address, h_address)
        REFERENCES hotel (hc_name, hc_address, address)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE h_email (
    hc_name TEXT NOT NULL,
    hc_address TEXT NOT NULL,
    h_address TEXT NOT NULL,
    email TEXT NOT NULL CHECK (position('@' IN email) > 1),
    CONSTRAINT h_email_pk PRIMARY KEY (hc_name, hc_address, h_address, email),
    CONSTRAINT h_email_fk FOREIGN KEY (hc_name, hc_address, h_address)
        REFERENCES hotel (hc_name, hc_address, address)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE room (
    id INTEGER NOT NULL,
    h_address TEXT NOT NULL,
    hc_address TEXT NOT NULL,
    hc_name TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0.00),
    extendable_by INTEGER NOT NULL DEFAULT 0 CHECK (extendable_by >= 0),
    view_type TEXT NOT NULL DEFAULT 'none' CHECK (view_type IN ('sea', 'mountain', 'none')),
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    capacity INTEGER NOT NULL CHECK (capacity >= 1),
    CONSTRAINT room_pk PRIMARY KEY (id, h_address, hc_address, hc_name),
    CONSTRAINT room_hotel_fk FOREIGN KEY (hc_name, hc_address, h_address)
        REFERENCES hotel (hc_name, hc_address, address)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE room_amenity (
    r_id INTEGER NOT NULL,
    h_addr TEXT NOT NULL,
    hc_addr TEXT NOT NULL,
    hc_name TEXT NOT NULL,
    amenity_desc TEXT NOT NULL,
    CONSTRAINT room_amenity_pk PRIMARY KEY (r_id, h_addr, hc_addr, hc_name, amenity_desc),
    CONSTRAINT room_amenity_fk FOREIGN KEY (r_id, h_addr, hc_addr, hc_name)
        REFERENCES room (id, h_address, hc_address, hc_name)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE room_problem (
    r_id INTEGER NOT NULL,
    h_addr TEXT NOT NULL,
    hc_addr TEXT NOT NULL,
    hc_name TEXT NOT NULL,
    problem_desc TEXT NOT NULL,
    CONSTRAINT room_problem_pk PRIMARY KEY (r_id, h_addr, hc_addr, hc_name, problem_desc),
    CONSTRAINT room_problem_fk FOREIGN KEY (r_id, h_addr, hc_addr, hc_name)
        REFERENCES room (id, h_address, hc_address, hc_name)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE customer (
    full_name TEXT NOT NULL,
    address TEXT NOT NULL,
    registration_date DATE NOT NULL,
    CONSTRAINT customer_pk PRIMARY KEY (full_name, address)
);

CREATE TABLE employee (
    sin TEXT NOT NULL,
    full_name TEXT NOT NULL,
    address TEXT NOT NULL,
    CONSTRAINT employee_pk PRIMARY KEY (sin)
);

CREATE TABLE employee_role (
    e_sin TEXT NOT NULL,
    role_name TEXT NOT NULL CHECK (length(trim(role_name)) > 0),
    CONSTRAINT employee_role_pk PRIMARY KEY (e_sin, role_name),
    CONSTRAINT employee_role_fk FOREIGN KEY (e_sin)
        REFERENCES employee (sin)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE hotel_manager (
    e_sin TEXT NOT NULL,
    h_addr TEXT NOT NULL,
    hc_name TEXT NOT NULL,
    hc_addr TEXT NOT NULL,
    CONSTRAINT hotel_manager_pk PRIMARY KEY (e_sin, h_addr, hc_name, hc_addr),
    CONSTRAINT hotel_manager_employee_uniq UNIQUE (e_sin),
    CONSTRAINT hotel_manager_hotel_uniq UNIQUE (h_addr, hc_name, hc_addr),
    CONSTRAINT hotel_manager_employee_fk FOREIGN KEY (e_sin)
        REFERENCES employee (sin)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT hotel_manager_hotel_fk FOREIGN KEY (hc_name, hc_addr, h_addr)
        REFERENCES hotel (hc_name, hc_address, address)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE booking (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    r_id INTEGER NOT NULL,
    h_addr TEXT NOT NULL,
    hc_addr TEXT NOT NULL,
    hc_name TEXT NOT NULL,
    c_name TEXT NOT NULL,
    c_addr TEXT NOT NULL,
    created_by TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT booking_date_chk CHECK (start_date < end_date),
    CONSTRAINT booking_room_fk FOREIGN KEY (r_id, h_addr, hc_addr, hc_name)
        REFERENCES room (id, h_address, hc_address, hc_name)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT booking_customer_fk FOREIGN KEY (c_name, c_addr)
        REFERENCES customer (full_name, address)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT booking_employee_fk FOREIGN KEY (created_by)
        REFERENCES employee (sin)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE TABLE renting (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_paid BOOLEAN NOT NULL DEFAULT FALSE,
    r_id INTEGER NOT NULL,
    h_addr TEXT NOT NULL,
    hc_addr TEXT NOT NULL,
    hc_name TEXT NOT NULL,
    c_name TEXT NOT NULL,
    c_addr TEXT NOT NULL,
    created_by TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT renting_date_chk CHECK (start_date < end_date),
    CONSTRAINT renting_room_fk FOREIGN KEY (r_id, h_addr, hc_addr, hc_name)
        REFERENCES room (id, h_address, hc_address, hc_name)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT renting_customer_fk FOREIGN KEY (c_name, c_addr)
        REFERENCES customer (full_name, address)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT renting_employee_fk FOREIGN KEY (created_by)
        REFERENCES employee (sin)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE TABLE booking_archive (
    id BIGINT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    r_id INTEGER,
    h_addr TEXT,
    hc_addr TEXT,
    hc_name TEXT,
    c_name TEXT,
    c_addr TEXT,
    created_by TEXT,
    created_at TIMESTAMP,
    archived_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    archive_reason TEXT NOT NULL,
    CONSTRAINT booking_archive_pk PRIMARY KEY (id, archived_at)
);

CREATE TABLE renting_archive (
    id BIGINT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_paid BOOLEAN,
    r_id INTEGER,
    h_addr TEXT,
    hc_addr TEXT,
    hc_name TEXT,
    c_name TEXT,
    c_addr TEXT,
    created_by TEXT,
    created_at TIMESTAMP,
    archived_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    archive_reason TEXT NOT NULL,
    CONSTRAINT renting_archive_pk PRIMARY KEY (id, archived_at)
);

CREATE TABLE payment (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    renting_id BIGINT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    payment_method TEXT NOT NULL CHECK (length(trim(payment_method)) > 0),
    paid_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT payment_renting_fk FOREIGN KEY (renting_id)
        REFERENCES renting (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE FUNCTION hotel_area(p_address TEXT)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT trim(split_part(coalesce(p_address, ''), ',', 1));
$$;

CREATE FUNCTION sync_hotel_chain_num_hotels()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP <> 'INSERT' THEN
        UPDATE hotel_chain hc
        SET num_hotels = (
            SELECT COUNT(*)
            FROM hotel h
            WHERE h.hc_name = OLD.hc_name
              AND h.hc_address = OLD.hc_address
        )
        WHERE hc.name = OLD.hc_name
          AND hc.address = OLD.hc_address;
    END IF;

    IF TG_OP <> 'DELETE' THEN
        UPDATE hotel_chain hc
        SET num_hotels = (
            SELECT COUNT(*)
            FROM hotel h
            WHERE h.hc_name = NEW.hc_name
              AND h.hc_address = NEW.hc_address
        )
        WHERE hc.name = NEW.hc_name
          AND hc.address = NEW.hc_address;
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE FUNCTION require_manager_role()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM employee_role
        WHERE e_sin = NEW.e_sin
          AND lower(role_name) LIKE '%manager%'
    ) THEN
        RAISE EXCEPTION 'Hotel manager % must have an employee role containing manager', NEW.e_sin;
    END IF;

    RETURN NEW;
END;
$$;

CREATE FUNCTION ensure_hotel_has_manager()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_hc_name TEXT := COALESCE(NEW.hc_name, OLD.hc_name);
    v_hc_addr TEXT := COALESCE(NEW.hc_address, OLD.hc_address);
    v_h_addr TEXT := COALESCE(NEW.address, OLD.address);
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM hotel_manager hm
        WHERE hm.hc_name = v_hc_name
          AND hm.hc_addr = v_hc_addr
          AND hm.h_addr = v_h_addr
    ) THEN
        RAISE EXCEPTION 'Hotel %, %, % must be created with an initial manager',
            v_hc_name, v_hc_addr, v_h_addr;
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE FUNCTION refresh_room_current_availability(
    p_hc_name TEXT,
    p_hc_addr TEXT,
    p_h_addr TEXT,
    p_room_id INTEGER
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE room r
    SET is_available = NOT EXISTS (
        SELECT 1
        FROM booking b
        WHERE b.hc_name = p_hc_name
          AND b.hc_addr = p_hc_addr
          AND b.h_addr = p_h_addr
          AND b.r_id = p_room_id
          AND daterange(b.start_date, b.end_date, '[)') @> CURRENT_DATE
        UNION ALL
        SELECT 1
        FROM renting rt
        WHERE rt.hc_name = p_hc_name
          AND rt.hc_addr = p_hc_addr
          AND rt.h_addr = p_h_addr
          AND rt.r_id = p_room_id
          AND daterange(rt.start_date, rt.end_date, '[)') @> CURRENT_DATE
    )
    WHERE r.hc_name = p_hc_name
      AND r.hc_address = p_hc_addr
      AND r.h_address = p_h_addr
      AND r.id = p_room_id;
END;
$$;

CREATE FUNCTION refresh_all_room_current_availability()
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    room_row RECORD;
BEGIN
    FOR room_row IN
        SELECT hc_name, hc_address, h_address, id
        FROM room
    LOOP
        PERFORM refresh_room_current_availability(
            room_row.hc_name,
            room_row.hc_address,
            room_row.h_address,
            room_row.id
        );
    END LOOP;
END;
$$;

CREATE FUNCTION sync_room_current_availability_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP <> 'INSERT' THEN
        PERFORM refresh_room_current_availability(OLD.hc_name, OLD.hc_addr, OLD.h_addr, OLD.r_id);
    END IF;

    IF TG_OP <> 'DELETE' THEN
        PERFORM refresh_room_current_availability(NEW.hc_name, NEW.hc_addr, NEW.h_addr, NEW.r_id);
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE FUNCTION ensure_room_time_window_available()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.start_date >= NEW.end_date THEN
        RAISE EXCEPTION 'start_date must be before end_date';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM booking b
        WHERE b.id <> COALESCE(NEW.id, -1)
          AND b.hc_name = NEW.hc_name
          AND b.hc_addr = NEW.hc_addr
          AND b.h_addr = NEW.h_addr
          AND b.r_id = NEW.r_id
          AND daterange(b.start_date, b.end_date, '[)') && daterange(NEW.start_date, NEW.end_date, '[)')
    ) THEN
        RAISE EXCEPTION 'Room is already booked during the requested interval';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM renting rt
        WHERE rt.id <> COALESCE(NEW.id, -1)
          AND rt.hc_name = NEW.hc_name
          AND rt.hc_addr = NEW.hc_addr
          AND rt.h_addr = NEW.h_addr
          AND rt.r_id = NEW.r_id
          AND daterange(rt.start_date, rt.end_date, '[)') && daterange(NEW.start_date, NEW.end_date, '[)')
    ) THEN
        RAISE EXCEPTION 'Room is already rented during the requested interval';
    END IF;

    RETURN NEW;
END;
$$;

CREATE FUNCTION archive_booking_before_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_reason TEXT := coalesce(current_setting('ehotels.archive_reason', TRUE), 'deleted');
BEGIN
    INSERT INTO booking_archive (
        id, start_date, end_date, r_id, h_addr, hc_addr, hc_name,
        c_name, c_addr, created_by, created_at, archive_reason
    )
    VALUES (
        OLD.id, OLD.start_date, OLD.end_date, OLD.r_id, OLD.h_addr, OLD.hc_addr, OLD.hc_name,
        OLD.c_name, OLD.c_addr, OLD.created_by, OLD.created_at, v_reason
    );

    RETURN OLD;
END;
$$;

CREATE FUNCTION archive_renting_before_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_reason TEXT := coalesce(current_setting('ehotels.archive_reason', TRUE), 'deleted');
BEGIN
    INSERT INTO renting_archive (
        id, start_date, end_date, is_paid, r_id, h_addr, hc_addr, hc_name,
        c_name, c_addr, created_by, created_at, archive_reason
    )
    VALUES (
        OLD.id, OLD.start_date, OLD.end_date, OLD.is_paid, OLD.r_id, OLD.h_addr, OLD.hc_addr, OLD.hc_name,
        OLD.c_name, OLD.c_addr, OLD.created_by, OLD.created_at, v_reason
    );

    RETURN OLD;
END;
$$;

CREATE TRIGGER hotel_chain_num_hotels_trg
AFTER INSERT OR UPDATE OR DELETE ON hotel
FOR EACH ROW
EXECUTE FUNCTION sync_hotel_chain_num_hotels();

CREATE CONSTRAINT TRIGGER hotel_manager_requires_role_trg
AFTER INSERT OR UPDATE ON hotel_manager
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION require_manager_role();

CREATE CONSTRAINT TRIGGER hotel_requires_manager_trg
AFTER INSERT OR UPDATE ON hotel
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION ensure_hotel_has_manager();

CREATE TRIGGER booking_room_available_trg
BEFORE INSERT OR UPDATE ON booking
FOR EACH ROW
EXECUTE FUNCTION ensure_room_time_window_available();

CREATE TRIGGER renting_room_available_trg
BEFORE INSERT OR UPDATE ON renting
FOR EACH ROW
EXECUTE FUNCTION ensure_room_time_window_available();

CREATE TRIGGER booking_room_sync_trg
AFTER INSERT OR UPDATE OR DELETE ON booking
FOR EACH ROW
EXECUTE FUNCTION sync_room_current_availability_trigger();

CREATE TRIGGER renting_room_sync_trg
AFTER INSERT OR UPDATE OR DELETE ON renting
FOR EACH ROW
EXECUTE FUNCTION sync_room_current_availability_trigger();

CREATE TRIGGER booking_archive_trg
BEFORE DELETE ON booking
FOR EACH ROW
EXECUTE FUNCTION archive_booking_before_delete();

CREATE TRIGGER renting_archive_trg
BEFORE DELETE ON renting
FOR EACH ROW
EXECUTE FUNCTION archive_renting_before_delete();

CREATE FUNCTION create_hotel_with_manager(
    p_hc_name TEXT,
    p_hc_address TEXT,
    p_hotel_address TEXT,
    p_stars INTEGER,
    p_manager_sin TEXT,
    p_manager_name TEXT,
    p_manager_address TEXT,
    p_manager_role TEXT DEFAULT 'hotel manager'
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO hotel (hc_name, hc_address, address, stars)
    VALUES (p_hc_name, p_hc_address, p_hotel_address, p_stars);

    INSERT INTO employee (sin, full_name, address)
    VALUES (p_manager_sin, p_manager_name, p_manager_address)
    ON CONFLICT (sin) DO UPDATE
    SET full_name = EXCLUDED.full_name,
        address = EXCLUDED.address;

    INSERT INTO employee_role (e_sin, role_name)
    VALUES (p_manager_sin, p_manager_role)
    ON CONFLICT DO NOTHING;

    INSERT INTO hotel_manager (e_sin, h_addr, hc_name, hc_addr)
    VALUES (p_manager_sin, p_hotel_address, p_hc_name, p_hc_address);
END;
$$;

CREATE FUNCTION create_booking(
    p_start_date DATE,
    p_end_date DATE,
    p_room_id INTEGER,
    p_h_addr TEXT,
    p_hc_addr TEXT,
    p_hc_name TEXT,
    p_customer_name TEXT,
    p_customer_addr TEXT,
    p_created_by TEXT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_booking_id BIGINT;
BEGIN
    INSERT INTO booking (
        start_date, end_date, r_id, h_addr, hc_addr, hc_name,
        c_name, c_addr, created_by
    )
    VALUES (
        p_start_date, p_end_date, p_room_id, p_h_addr, p_hc_addr, p_hc_name,
        p_customer_name, p_customer_addr, p_created_by
    )
    RETURNING id INTO v_booking_id;

    RETURN v_booking_id;
END;
$$;

CREATE FUNCTION record_payment(
    p_renting_id BIGINT,
    p_amount NUMERIC,
    p_payment_method TEXT
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_payment_id BIGINT;
    v_total_paid NUMERIC(10, 2);
    v_total_due NUMERIC(10, 2);
BEGIN
    INSERT INTO payment (renting_id, amount, payment_method)
    VALUES (p_renting_id, p_amount, p_payment_method)
    RETURNING id INTO v_payment_id;

    SELECT coalesce(SUM(amount), 0.00)
    INTO v_total_paid
    FROM payment
    WHERE renting_id = p_renting_id;

    SELECT r.price * GREATEST((rt.end_date - rt.start_date), 1)
    INTO v_total_due
    FROM renting rt
    JOIN room r
      ON r.id = rt.r_id
     AND r.h_address = rt.h_addr
     AND r.hc_address = rt.hc_addr
     AND r.hc_name = rt.hc_name
    WHERE rt.id = p_renting_id;

    UPDATE renting
    SET is_paid = (v_total_paid >= coalesce(v_total_due, 0.00))
    WHERE id = p_renting_id;

    RETURN v_payment_id;
END;
$$;

CREATE FUNCTION create_renting(
    p_start_date DATE,
    p_end_date DATE,
    p_room_id INTEGER,
    p_h_addr TEXT,
    p_hc_addr TEXT,
    p_hc_name TEXT,
    p_customer_name TEXT,
    p_customer_addr TEXT,
    p_created_by TEXT,
    p_paid_now BOOLEAN DEFAULT FALSE,
    p_payment_amount NUMERIC DEFAULT NULL,
    p_payment_method TEXT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_renting_id BIGINT;
BEGIN
    INSERT INTO renting (
        start_date, end_date, is_paid, r_id, h_addr, hc_addr, hc_name,
        c_name, c_addr, created_by
    )
    VALUES (
        p_start_date, p_end_date, FALSE, p_room_id, p_h_addr, p_hc_addr, p_hc_name,
        p_customer_name, p_customer_addr, p_created_by
    )
    RETURNING id INTO v_renting_id;

    IF p_paid_now AND p_payment_amount IS NOT NULL THEN
        PERFORM record_payment(v_renting_id, p_payment_amount, coalesce(p_payment_method, 'card'));
    END IF;

    RETURN v_renting_id;
END;
$$;

CREATE FUNCTION convert_booking_to_renting(
    p_booking_id BIGINT,
    p_employee_sin TEXT,
    p_paid_now BOOLEAN DEFAULT FALSE,
    p_payment_amount NUMERIC DEFAULT NULL,
    p_payment_method TEXT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_booking booking%ROWTYPE;
    v_renting_id BIGINT;
BEGIN
    SELECT *
    INTO v_booking
    FROM booking
    WHERE id = p_booking_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Booking % does not exist', p_booking_id;
    END IF;

    PERFORM set_config('ehotels.archive_reason', 'converted_to_renting', TRUE);

    DELETE FROM booking WHERE id = p_booking_id;

    INSERT INTO renting (
        start_date, end_date, is_paid, r_id, h_addr, hc_addr, hc_name,
        c_name, c_addr, created_by
    )
    VALUES (
        v_booking.start_date, v_booking.end_date, FALSE, v_booking.r_id, v_booking.h_addr,
        v_booking.hc_addr, v_booking.hc_name, v_booking.c_name, v_booking.c_addr, p_employee_sin
    )
    RETURNING id INTO v_renting_id;

    IF p_paid_now AND p_payment_amount IS NOT NULL THEN
        PERFORM record_payment(v_renting_id, p_payment_amount, coalesce(p_payment_method, 'card'));
    END IF;

    RETURN v_renting_id;
END;
$$;

CREATE FUNCTION search_available_rooms(
    p_start_date DATE DEFAULT NULL,
    p_end_date DATE DEFAULT NULL,
    p_capacity INTEGER DEFAULT NULL,
    p_area TEXT DEFAULT NULL,
    p_chain_name TEXT DEFAULT NULL,
    p_stars INTEGER DEFAULT NULL,
    p_min_total_rooms INTEGER DEFAULT NULL,
    p_max_price NUMERIC DEFAULT NULL
)
RETURNS TABLE (
    hotel_chain_name TEXT,
    hotel_chain_address TEXT,
    hotel_address TEXT,
    area TEXT,
    stars INTEGER,
    total_rooms BIGINT,
    room_id INTEGER,
    capacity INTEGER,
    extendable_by INTEGER,
    price NUMERIC(10, 2),
    view_type TEXT,
    amenities TEXT,
    currently_available BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_start_date IS NOT NULL
       AND p_end_date IS NOT NULL
       AND p_start_date >= p_end_date THEN
        RAISE EXCEPTION 'start_date must be before end_date';
    END IF;

    RETURN QUERY
    WITH room_counts AS (
        SELECT
            r.hc_name,
            r.hc_address,
            r.h_address,
            COUNT(*) AS total_rooms
        FROM room r
        GROUP BY r.hc_name, r.hc_address, r.h_address
    ),
    amenity_summary AS (
        SELECT
            ra.hc_name,
            ra.hc_addr,
            ra.h_addr,
            ra.r_id,
            string_agg(ra.amenity_desc, ', ' ORDER BY ra.amenity_desc) AS amenities
        FROM room_amenity ra
        GROUP BY ra.hc_name, ra.hc_addr, ra.h_addr, ra.r_id
    )
    SELECT
        r.hc_name,
        r.hc_address,
        r.h_address,
        hotel_area(h.address) AS area,
        h.stars,
        rc.total_rooms,
        r.id,
        r.capacity,
        r.extendable_by,
        r.price,
        r.view_type,
        coalesce(am.amenities, '') AS amenities,
        r.is_available
    FROM room r
    JOIN hotel h
      ON h.hc_name = r.hc_name
     AND h.hc_address = r.hc_address
     AND h.address = r.h_address
    JOIN room_counts rc
      ON rc.hc_name = r.hc_name
     AND rc.hc_address = r.hc_address
     AND rc.h_address = r.h_address
    LEFT JOIN amenity_summary am
      ON am.hc_name = r.hc_name
     AND am.hc_addr = r.hc_address
     AND am.h_addr = r.h_address
     AND am.r_id = r.id
    WHERE (p_capacity IS NULL OR r.capacity >= p_capacity)
      AND (p_area IS NULL OR hotel_area(h.address) = p_area)
      AND (p_chain_name IS NULL OR r.hc_name = p_chain_name)
      AND (p_stars IS NULL OR h.stars = p_stars)
      AND (p_min_total_rooms IS NULL OR rc.total_rooms >= p_min_total_rooms)
      AND (p_max_price IS NULL OR r.price <= p_max_price)
      AND (
            (
                p_start_date IS NOT NULL
                AND p_end_date IS NOT NULL
                AND NOT EXISTS (
                    SELECT 1
                    FROM booking b
                    WHERE b.hc_name = r.hc_name
                      AND b.hc_addr = r.hc_address
                      AND b.h_addr = r.h_address
                      AND b.r_id = r.id
                      AND daterange(b.start_date, b.end_date, '[)') && daterange(p_start_date, p_end_date, '[)')
                    UNION ALL
                    SELECT 1
                    FROM renting rt
                    WHERE rt.hc_name = r.hc_name
                      AND rt.hc_addr = r.hc_address
                      AND rt.h_addr = r.h_address
                      AND rt.r_id = r.id
                      AND daterange(rt.start_date, rt.end_date, '[)') && daterange(p_start_date, p_end_date, '[)')
                )
            )
            OR (
                p_start_date IS NULL
                OR p_end_date IS NULL
            ) AND r.is_available
      )
    ORDER BY r.hc_name, h.stars DESC, r.h_address, r.price, r.id;
END;
$$;

COMMIT;
