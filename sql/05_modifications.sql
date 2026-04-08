-- Trigger demo 1: A hotel manager must have a manager role.
BEGIN;
INSERT INTO employee (sin, full_name, address)
VALUES ('999999999', 'Invalid Manager Demo', '1 Demo Way, Ottawa, ON, Canada');

INSERT INTO hotel (hc_name, hc_address, address, stars)
VALUES (
    'Marriott International',
    '10400 Fernwood Rd, Bethesda, MD, USA',
    'Demo Area, 1 Demo Way, Ottawa, ON, Canada',
    4
);

-- This will fail at commit because the employee has no role containing manager
-- and the hotel must be created with a manager.
INSERT INTO hotel_manager (e_sin, h_addr, hc_name, hc_addr)
VALUES (
    '999999999',
    'Demo Area, 1 Demo Way, Ottawa, ON, Canada',
    'Marriott International',
    '10400 Fernwood Rd, Bethesda, MD, USA'
);

DO $$
BEGIN
    SET CONSTRAINTS ALL IMMEDIATE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Expected trigger failure: %', SQLERRM;
END;
$$;

ROLLBACK;

-- Trigger demo 2: overlapping reservations are rejected.
-- This booking overlaps an existing Marriott booking for the same room and dates.
DO $$
BEGIN
    PERFORM create_booking(
        DATE '2026-05-11',
        DATE '2026-05-13',
        2,
        'Downtown Toronto, 100 King St W, Toronto, ON, Canada',
        '10400 Fernwood Rd, Bethesda, MD, USA',
        'Marriott International',
        'Lina Gomez',
        '56 Collins Ave, Miami, FL, USA',
        NULL
    );
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Expected overlap failure: %', SQLERRM;
END;
$$;

-- Valid modification examples.
UPDATE customer
SET address = '12 Queen St E, Ottawa, ON, Canada'
WHERE full_name = 'Alice Carter'
  AND address = '12 Queen St, Ottawa, ON, Canada';

UPDATE room
SET price = price + 15.00
WHERE hc_name = 'Fairmont Hotels & Resorts'
  AND hc_address = '401 Bay St, Toronto, ON, Canada'
  AND h_address = 'Chicago Loop, 151 Wacker Dr, Chicago, IL, USA'
  AND id = 5;

DELETE FROM room_problem
WHERE hc_name = 'Marriott International'
  AND hc_addr = '10400 Fernwood Rd, Bethesda, MD, USA'
  AND h_addr = 'Downtown Toronto, 100 King St W, Toronto, ON, Canada'
  AND r_id = 5
  AND problem_desc = 'Lamp needs replacement';
