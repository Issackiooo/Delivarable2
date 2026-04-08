BEGIN;

INSERT INTO hotel_chain (name, address) VALUES
    ('Marriott International', '10400 Fernwood Rd, Bethesda, MD, USA'),
    ('Hilton Hotels & Resorts', '7930 Jones Branch Dr, McLean, VA, USA'),
    ('Hyatt Hotels Corporation', '150 N Riverside Plaza, Chicago, IL, USA'),
    ('Wyndham Hotels & Resorts', '22 Sylvan Way, Parsippany, NJ, USA'),
    ('Fairmont Hotels & Resorts', '401 Bay St, Toronto, ON, Canada');

INSERT INTO hc_phone (hc_name, hc_address, phone_num) VALUES
    ('Marriott International', '10400 Fernwood Rd, Bethesda, MD, USA', '+1-301-380-3000'),
    ('Hilton Hotels & Resorts', '7930 Jones Branch Dr, McLean, VA, USA', '+1-703-883-1000'),
    ('Hyatt Hotels Corporation', '150 N Riverside Plaza, Chicago, IL, USA', '+1-312-750-1234'),
    ('Wyndham Hotels & Resorts', '22 Sylvan Way, Parsippany, NJ, USA', '+1-973-753-6000'),
    ('Fairmont Hotels & Resorts', '401 Bay St, Toronto, ON, Canada', '+1-416-874-2600');

INSERT INTO hc_email (hc_name, hc_address, email) VALUES
    ('Marriott International', '10400 Fernwood Rd, Bethesda, MD, USA', 'contact@marriott-demo.com'),
    ('Hilton Hotels & Resorts', '7930 Jones Branch Dr, McLean, VA, USA', 'contact@hilton-demo.com'),
    ('Hyatt Hotels Corporation', '150 N Riverside Plaza, Chicago, IL, USA', 'contact@hyatt-demo.com'),
    ('Wyndham Hotels & Resorts', '22 Sylvan Way, Parsippany, NJ, USA', 'contact@wyndham-demo.com'),
    ('Fairmont Hotels & Resorts', '401 Bay St, Toronto, ON, Canada', 'contact@fairmont-demo.com');

DO $$
DECLARE
    chain_names TEXT[] := ARRAY[
        'Marriott International',
        'Hilton Hotels & Resorts',
        'Hyatt Hotels Corporation',
        'Wyndham Hotels & Resorts',
        'Fairmont Hotels & Resorts'
    ];
    chain_addresses TEXT[] := ARRAY[
        '10400 Fernwood Rd, Bethesda, MD, USA',
        '7930 Jones Branch Dr, McLean, VA, USA',
        '150 N Riverside Plaza, Chicago, IL, USA',
        '22 Sylvan Way, Parsippany, NJ, USA',
        '401 Bay St, Toronto, ON, Canada'
    ];
    areas TEXT[] := ARRAY[
        'Downtown Toronto',
        'Old Montreal',
        'Midtown Manhattan',
        'Downtown Vancouver',
        'Chicago Loop',
        'Downtown Seattle',
        'Brickell Miami',
        'Old Port Quebec'
    ];
    streets TEXT[] := ARRAY[
        '100 King St W',
        '200 Saint Paul St',
        '350 Madison Ave',
        '999 Canada Pl',
        '151 Wacker Dr',
        '600 Pine St',
        '88 Biscayne Blvd',
        '12 Rue Dalhousie'
    ];
    cities TEXT[] := ARRAY[
        'Toronto, ON, Canada',
        'Montreal, QC, Canada',
        'New York, NY, USA',
        'Vancouver, BC, Canada',
        'Chicago, IL, USA',
        'Seattle, WA, USA',
        'Miami, FL, USA',
        'Quebec City, QC, Canada'
    ];
    stars_cycle INTEGER[] := ARRAY[5, 4, 3, 5, 4, 3, 2, 4];
    amenity_sets TEXT[] := ARRAY[
        'WiFi|TV|Desk',
        'WiFi|TV|Mini Fridge',
        'WiFi|Air Conditioning|Desk',
        'WiFi|TV|Ocean View Balcony',
        'WiFi|TV|Coffee Machine',
        'WiFi|Desk|Mini Fridge',
        'WiFi|TV|Kitchenette',
        'WiFi|TV|Sofa Bed'
    ];
    capacities INTEGER[] := ARRAY[1, 2, 3, 4, 6];
    prices NUMERIC[] := ARRAY[129.00, 169.00, 209.00, 269.00, 349.00];
    views TEXT[] := ARRAY['none', 'mountain', 'sea', 'none', 'mountain'];
    chain_idx INTEGER;
    hotel_idx INTEGER;
    room_idx INTEGER;
    hotel_address TEXT;
    employee_sin TEXT;
    frontdesk_sin TEXT;
BEGIN
    FOR chain_idx IN 1..array_length(chain_names, 1) LOOP
        FOR hotel_idx IN 1..8 LOOP
            hotel_address := format(
                '%s, %s, %s',
                areas[hotel_idx],
                streets[hotel_idx],
                cities[hotel_idx]
            );

            employee_sin := chain_idx::TEXT || 'M' || lpad(hotel_idx::TEXT, 3, '0');
            frontdesk_sin := chain_idx::TEXT || 'F' || lpad(hotel_idx::TEXT, 3, '0');

            PERFORM create_hotel_with_manager(
                chain_names[chain_idx],
                chain_addresses[chain_idx],
                hotel_address,
                stars_cycle[hotel_idx],
                employee_sin,
                format('%s Manager %s', split_part(chain_names[chain_idx], ' ', 1), hotel_idx),
                format('Manager Residence %s, %s', hotel_idx, cities[hotel_idx]),
                'general manager'
            );

            INSERT INTO employee (sin, full_name, address)
            VALUES (
                frontdesk_sin,
                format('%s Front Desk %s', split_part(chain_names[chain_idx], ' ', 1), hotel_idx),
                format('Front Desk Residence %s, %s', hotel_idx, cities[hotel_idx])
            );

            INSERT INTO employee_role (e_sin, role_name)
            VALUES
                (frontdesk_sin, 'front desk'),
                (frontdesk_sin, 'reservation agent');

            INSERT INTO h_phone (hc_name, hc_address, h_address, phone_num)
            VALUES (
                chain_names[chain_idx],
                chain_addresses[chain_idx],
                hotel_address,
                format('+1-555-%03s-%04s', chain_idx * 10 + hotel_idx, 1000 + hotel_idx)
            );

            INSERT INTO h_email (hc_name, hc_address, h_address, email)
            VALUES (
                chain_names[chain_idx],
                chain_addresses[chain_idx],
                hotel_address,
                lower(format('hotel%s_%s@demo-ehotels.com', chain_idx, hotel_idx))
            );

            FOR room_idx IN 1..5 LOOP
                INSERT INTO room (
                    id, h_address, hc_address, hc_name, price,
                    extendable_by, view_type, capacity
                )
                VALUES (
                    room_idx,
                    hotel_address,
                    chain_addresses[chain_idx],
                    chain_names[chain_idx],
                    prices[room_idx] + (chain_idx * 12) + (hotel_idx * 3),
                    CASE WHEN room_idx IN (2, 4, 5) THEN 1 ELSE 0 END,
                    views[room_idx],
                    capacities[room_idx]
                );

                INSERT INTO room_amenity (r_id, h_addr, hc_addr, hc_name, amenity_desc)
                SELECT
                    room_idx,
                    hotel_address,
                    chain_addresses[chain_idx],
                    chain_names[chain_idx],
                    amenity_item
                FROM unnest(string_to_array(amenity_sets[room_idx], '|')) AS amenity_item;
            END LOOP;
        END LOOP;
    END LOOP;
END;
$$;

INSERT INTO room_problem (r_id, h_addr, hc_addr, hc_name, problem_desc) VALUES
    (5, 'Downtown Toronto, 100 King St W, Toronto, ON, Canada', '10400 Fernwood Rd, Bethesda, MD, USA', 'Marriott International', 'Lamp needs replacement'),
    (3, 'Old Montreal, 200 Saint Paul St, Montreal, QC, Canada', '7930 Jones Branch Dr, McLean, VA, USA', 'Hilton Hotels & Resorts', 'Air conditioning maintenance pending'),
    (4, 'Brickell Miami, 88 Biscayne Blvd, Miami, FL, USA', '150 N Riverside Plaza, Chicago, IL, USA', 'Hyatt Hotels Corporation', 'Minor carpet damage');

INSERT INTO customer (full_name, address, registration_date) VALUES
    ('Alice Carter', '12 Queen St, Ottawa, ON, Canada', DATE '2025-10-01'),
    ('Benjamin Lee', '77 Bloor St, Toronto, ON, Canada', DATE '2025-10-03'),
    ('Camila Diaz', '500 Burrard St, Vancouver, BC, Canada', DATE '2025-10-04'),
    ('Daniel Smith', '88 Robson St, Vancouver, BC, Canada', DATE '2025-10-06'),
    ('Emma Nguyen', '44 Yonge St, Toronto, ON, Canada', DATE '2025-10-07'),
    ('Farah Khan', '300 Bay St, Toronto, ON, Canada', DATE '2025-10-10'),
    ('Gabriel Martin', '15 Rue Sherbrooke, Montreal, QC, Canada', DATE '2025-10-12'),
    ('Hana Suzuki', '95 King St, Halifax, NS, Canada', DATE '2025-10-14'),
    ('Ivan Petrov', '76 Granville St, Vancouver, BC, Canada', DATE '2025-10-16'),
    ('Julia Brown', '820 Michigan Ave, Chicago, IL, USA', DATE '2025-10-18'),
    ('Karim Hassan', '11 Front St, Toronto, ON, Canada', DATE '2025-10-19'),
    ('Lina Gomez', '56 Collins Ave, Miami, FL, USA', DATE '2025-10-20');

SELECT create_booking(
    DATE '2026-05-10',
    DATE '2026-05-14',
    2,
    'Downtown Toronto, 100 King St W, Toronto, ON, Canada',
    '10400 Fernwood Rd, Bethesda, MD, USA',
    'Marriott International',
    'Alice Carter',
    '12 Queen St, Ottawa, ON, Canada',
    NULL
);

SELECT create_booking(
    DATE '2026-05-12',
    DATE '2026-05-15',
    1,
    'Old Montreal, 200 Saint Paul St, Montreal, QC, Canada',
    '7930 Jones Branch Dr, McLean, VA, USA',
    'Hilton Hotels & Resorts',
    'Benjamin Lee',
    '77 Bloor St, Toronto, ON, Canada',
    NULL
);

SELECT create_booking(
    DATE '2026-05-11',
    DATE '2026-05-13',
    4,
    'Midtown Manhattan, 350 Madison Ave, New York, NY, USA',
    '150 N Riverside Plaza, Chicago, IL, USA',
    'Hyatt Hotels Corporation',
    'Camila Diaz',
    '500 Burrard St, Vancouver, BC, Canada',
    NULL
);

SELECT create_renting(
    DATE '2026-04-07',
    DATE '2026-04-10',
    3,
    'Downtown Vancouver, 999 Canada Pl, Vancouver, BC, Canada',
    '22 Sylvan Way, Parsippany, NJ, USA',
    'Wyndham Hotels & Resorts',
    'Daniel Smith',
    '88 Robson St, Vancouver, BC, Canada',
    '4F004',
    TRUE,
    900.00,
    'card'
);

SELECT create_renting(
    DATE '2026-04-08',
    DATE '2026-04-11',
    5,
    'Chicago Loop, 151 Wacker Dr, Chicago, IL, USA',
    '401 Bay St, Toronto, ON, Canada',
    'Fairmont Hotels & Resorts',
    'Emma Nguyen',
    '44 Yonge St, Toronto, ON, Canada',
    '5F005',
    FALSE,
    NULL,
    NULL
);

SELECT create_renting(
    DATE '2026-03-25',
    DATE '2026-03-28',
    2,
    'Brickell Miami, 88 Biscayne Blvd, Miami, FL, USA',
    '10400 Fernwood Rd, Bethesda, MD, USA',
    'Marriott International',
    'Farah Khan',
    '300 Bay St, Toronto, ON, Canada',
    '1F007',
    TRUE,
    800.00,
    'cash'
);

SELECT convert_booking_to_renting(2, '2F002', TRUE, 700.00, 'card');

DELETE FROM renting WHERE id = 3;

SELECT refresh_all_room_current_availability();

COMMIT;
