-- ============================================================
-- e-Hotels Seed Data
-- 5 hotel chains, 8 hotels each, 5 rooms per hotel
-- ============================================================

-- ============================================================
-- Hotel Chains
-- ============================================================
INSERT INTO hotel_chain (chain_id, name, address) VALUES
(1, 'Marriott International', '10400 Fernwood Rd, Bethesda, MD'),
(2, 'Hilton Hotels & Resorts', '7930 Jones Branch Dr, McLean, VA'),
(3, 'Hyatt Hotels Corporation', '150 N Riverside Plaza, Chicago, IL'),
(4, 'Wyndham Hotels & Resorts', '22 Sylvan Way, Parsippany, NJ'),
(5, 'InterContinental Hotels Group', '3 Ravinia Dr, Atlanta, GA');

SELECT setval('hotel_chain_chain_id_seq', 5);

-- Hotel chain emails
INSERT INTO hc_email (chain_id, email) VALUES
(1, 'contact@marriott.com'), (1, 'support@marriott.com'),
(2, 'contact@hilton.com'),   (2, 'support@hilton.com'),
(3, 'contact@hyatt.com'),    (3, 'support@hyatt.com'),
(4, 'contact@wyndham.com'),  (4, 'support@wyndham.com'),
(5, 'contact@ihg.com'),      (5, 'support@ihg.com');

-- Hotel chain phones
INSERT INTO hc_phone (chain_id, phone_num) VALUES
(1, '1-800-228-9290'), (1, '1-800-228-9291'),
(2, '1-800-445-8667'), (2, '1-800-445-8668'),
(3, '1-800-233-1234'), (3, '1-800-233-1235'),
(4, '1-800-466-1589'), (4, '1-800-466-1590'),
(5, '1-800-621-0555'), (5, '1-800-621-0556');

-- ============================================================
-- Hotels (8 per chain = 40 hotels)
-- Each chain has at least 3 star categories.
-- At least 2 hotels in the same area per chain.
-- ============================================================

-- Marriott hotels (chain_id=1)
INSERT INTO hotel (hotel_id, chain_id, address, city, stars) VALUES
( 1, 1, '1535 Broadway',            'New York',      5),
( 2, 1, '85 West St',               'New York',      3),
( 3, 1, '900 W Olympic Blvd',       'Los Angeles',   4),
( 4, 1, '540 N Michigan Ave',       'Chicago',       3),
( 5, 1, '525 Bay St',               'Toronto',       5),
( 6, 1, '1128 W Hastings St',       'Vancouver',     4),
( 7, 1, '1633 N Bayshore Dr',       'Miami',         3),
( 8, 1, '55 4th St',                'San Francisco', 4);

-- Hilton hotels (chain_id=2)
INSERT INTO hotel (hotel_id, chain_id, address, city, stars) VALUES
( 9, 2, '1335 6th Ave',             'New York',      4),
(10, 2, '555 Universal Hollywood',  'Los Angeles',   5),
(11, 2, '100 W 1st St',             'Los Angeles',   3),
(12, 2, '720 S Michigan Ave',       'Chicago',       4),
(13, 2, '145 Richmond St W',        'Toronto',       3),
(14, 2, '900 Rene-Levesque W',      'Montreal',      4),
(15, 2, '89 Broad St',              'Boston',        5),
(16, 2, '1301 6th Ave',             'Seattle',       3);

-- Hyatt hotels (chain_id=3)
INSERT INTO hotel (hotel_id, chain_id, address, city, stars) VALUES
(17, 3, '109 E 42nd St',            'New York',      5),
(18, 3, '633 N Saint Clair St',     'Chicago',       4),
(19, 3, '151 E Wacker Dr',          'Chicago',       3),
(20, 3, '345 Stockton St',          'San Francisco', 5),
(21, 3, '370 King St W',            'Toronto',       4),
(22, 3, '655 Burrard St',           'Vancouver',     3),
(23, 3, '1000 H St NW',             'Washington DC', 4),
(24, 3, '650 15th St',              'Denver',        3);

-- Wyndham hotels (chain_id=4)
INSERT INTO hotel (hotel_id, chain_id, address, city, stars) VALUES
(25, 4, '8444 International Dr',    'Orlando',       3),
(26, 4, '6515 International Dr',    'Orlando',       4),
(27, 4, '3475 Las Vegas Blvd S',    'Las Vegas',     5),
(28, 4, '270 W 43rd St',            'New York',      3),
(29, 4, '2455 E Sunrise Blvd',      'Miami',         4),
(30, 4, '90 Bloor St E',            'Toronto',       3),
(31, 4, '1180 Drummond St',         'Montreal',      4),
(32, 4, '402 Queen St',             'Ottawa',        3);

-- IHG hotels (chain_id=5)
INSERT INTO hotel (hotel_id, chain_id, address, city, stars) VALUES
(33, 5, '590 W Peachtree St NW',    'Atlanta',       4),
(34, 5, '223 Peachtree St NE',      'Atlanta',       3),
(35, 5, '310 W 40th St',            'New York',      5),
(36, 5, '1000 S Figueroa St',       'Los Angeles',   4),
(37, 5, '300 E Ohio St',            'Chicago',       3),
(38, 5, '220 Bloor St W',           'Toronto',       5),
(39, 5, '1110 Howe St',             'Vancouver',     4),
(40, 5, '510 Atlantic Ave',         'Boston',        3);

SELECT setval('hotel_hotel_id_seq', 40);

-- Hotel emails (1 per hotel for brevity)
INSERT INTO h_email (hotel_id, email) VALUES
( 1,'nyc.broadway@marriott.com'),( 2,'nyc.west@marriott.com'),
( 3,'la@marriott.com'),( 4,'chicago@marriott.com'),
( 5,'toronto@marriott.com'),( 6,'vancouver@marriott.com'),
( 7,'miami@marriott.com'),( 8,'sf@marriott.com'),
( 9,'nyc@hilton.com'),(10,'la.hollywood@hilton.com'),
(11,'la.downtown@hilton.com'),(12,'chicago@hilton.com'),
(13,'toronto@hilton.com'),(14,'montreal@hilton.com'),
(15,'boston@hilton.com'),(16,'seattle@hilton.com'),
(17,'nyc@hyatt.com'),(18,'chicago.north@hyatt.com'),
(19,'chicago.wacker@hyatt.com'),(20,'sf@hyatt.com'),
(21,'toronto@hyatt.com'),(22,'vancouver@hyatt.com'),
(23,'dc@hyatt.com'),(24,'denver@hyatt.com'),
(25,'orlando.intl@wyndham.com'),(26,'orlando.main@wyndham.com'),
(27,'vegas@wyndham.com'),(28,'nyc@wyndham.com'),
(29,'miami@wyndham.com'),(30,'toronto@wyndham.com'),
(31,'montreal@wyndham.com'),(32,'ottawa@wyndham.com'),
(33,'atlanta.main@ihg.com'),(34,'atlanta.peach@ihg.com'),
(35,'nyc@ihg.com'),(36,'la@ihg.com'),
(37,'chicago@ihg.com'),(38,'toronto@ihg.com'),
(39,'vancouver@ihg.com'),(40,'boston@ihg.com');

-- Hotel phones (1 per hotel)
INSERT INTO h_phone (hotel_id, phone_num) VALUES
( 1,'212-555-0101'),( 2,'212-555-0102'),( 3,'310-555-0103'),
( 4,'312-555-0104'),( 5,'416-555-0105'),( 6,'604-555-0106'),
( 7,'305-555-0107'),( 8,'415-555-0108'),( 9,'212-555-0201'),
(10,'310-555-0202'),(11,'310-555-0203'),(12,'312-555-0204'),
(13,'416-555-0205'),(14,'514-555-0206'),(15,'617-555-0207'),
(16,'206-555-0208'),(17,'212-555-0301'),(18,'312-555-0302'),
(19,'312-555-0303'),(20,'415-555-0304'),(21,'416-555-0305'),
(22,'604-555-0306'),(23,'202-555-0307'),(24,'303-555-0308'),
(25,'407-555-0401'),(26,'407-555-0402'),(27,'702-555-0403'),
(28,'212-555-0404'),(29,'305-555-0405'),(30,'416-555-0406'),
(31,'514-555-0407'),(32,'613-555-0408'),(33,'404-555-0501'),
(34,'404-555-0502'),(35,'212-555-0503'),(36,'310-555-0504'),
(37,'312-555-0505'),(38,'416-555-0506'),(39,'604-555-0507'),
(40,'617-555-0508');

-- ============================================================
-- Rooms (5 per hotel = 200 rooms)
-- Different capacities: 1 (single), 2 (double), 2 (double),
--                       3 (triple), 4 (suite)
-- Prices scale with hotel star rating.
-- ============================================================

-- Helper: For each hotel, insert 5 rooms.
-- Stars 3 → base $100, Stars 4 → base $175, Stars 5 → base $300

-- Marriott hotels
INSERT INTO room (hotel_id, price, capacity, extendable_by, view_type) VALUES
-- Hotel 1 (NYC, 5-star)
(1, 300.00, 1, 0, 'none'),  (1, 400.00, 2, 1, 'sea'),
(1, 450.00, 2, 0, 'mountain'), (1, 550.00, 3, 1, 'sea'),
(1, 700.00, 4, 2, 'sea'),
-- Hotel 2 (NYC, 3-star)
(2, 100.00, 1, 0, 'none'),  (2, 150.00, 2, 1, 'none'),
(2, 160.00, 2, 0, 'mountain'), (2, 200.00, 3, 1, 'none'),
(2, 280.00, 4, 2, 'none'),
-- Hotel 3 (LA, 4-star)
(3, 175.00, 1, 0, 'none'),  (3, 250.00, 2, 1, 'sea'),
(3, 260.00, 2, 0, 'mountain'), (3, 350.00, 3, 1, 'sea'),
(3, 475.00, 4, 2, 'sea'),
-- Hotel 4 (Chicago, 3-star)
(4, 100.00, 1, 0, 'none'),  (4, 145.00, 2, 1, 'none'),
(4, 155.00, 2, 0, 'mountain'), (4, 200.00, 3, 0, 'none'),
(4, 275.00, 4, 1, 'none'),
-- Hotel 5 (Toronto, 5-star)
(5, 310.00, 1, 0, 'none'),  (5, 410.00, 2, 1, 'sea'),
(5, 420.00, 2, 0, 'mountain'), (5, 540.00, 3, 1, 'sea'),
(5, 690.00, 4, 2, 'sea'),
-- Hotel 6 (Vancouver, 4-star)
(6, 180.00, 1, 0, 'mountain'), (6, 255.00, 2, 1, 'mountain'),
(6, 270.00, 2, 0, 'sea'),   (6, 360.00, 3, 1, 'mountain'),
(6, 480.00, 4, 2, 'sea'),
-- Hotel 7 (Miami, 3-star)
(7, 110.00, 1, 0, 'sea'),   (7, 160.00, 2, 1, 'sea'),
(7, 155.00, 2, 0, 'none'),  (7, 210.00, 3, 1, 'sea'),
(7, 290.00, 4, 2, 'sea'),
-- Hotel 8 (SF, 4-star)
(8, 185.00, 1, 0, 'none'),  (8, 265.00, 2, 1, 'sea'),
(8, 260.00, 2, 0, 'mountain'), (8, 355.00, 3, 1, 'sea'),
(8, 485.00, 4, 2, 'sea');

-- Hilton hotels
INSERT INTO room (hotel_id, price, capacity, extendable_by, view_type) VALUES
(9, 180.00, 1, 0, 'none'),  (9, 260.00, 2, 1, 'none'),
(9, 270.00, 2, 0, 'mountain'), (9, 360.00, 3, 1, 'none'),
(9, 490.00, 4, 2, 'none'),
(10, 320.00, 1, 0, 'sea'),  (10, 420.00, 2, 1, 'sea'),
(10, 440.00, 2, 0, 'mountain'), (10, 560.00, 3, 1, 'sea'),
(10, 720.00, 4, 2, 'sea'),
(11, 105.00, 1, 0, 'none'), (11, 155.00, 2, 1, 'none'),
(11, 165.00, 2, 0, 'none'), (11, 210.00, 3, 0, 'none'),
(11, 285.00, 4, 1, 'none'),
(12, 185.00, 1, 0, 'none'), (12, 260.00, 2, 1, 'mountain'),
(12, 265.00, 2, 0, 'none'), (12, 355.00, 3, 1, 'none'),
(12, 480.00, 4, 2, 'none'),
(13, 105.00, 1, 0, 'none'), (13, 150.00, 2, 1, 'none'),
(13, 155.00, 2, 0, 'none'), (13, 205.00, 3, 0, 'none'),
(13, 280.00, 4, 1, 'none'),
(14, 190.00, 1, 0, 'none'), (14, 270.00, 2, 1, 'mountain'),
(14, 275.00, 2, 0, 'none'), (14, 365.00, 3, 1, 'none'),
(14, 495.00, 4, 2, 'none'),
(15, 330.00, 1, 0, 'sea'),  (15, 430.00, 2, 1, 'sea'),
(15, 440.00, 2, 0, 'mountain'), (15, 570.00, 3, 1, 'sea'),
(15, 730.00, 4, 2, 'sea'),
(16, 100.00, 1, 0, 'mountain'), (16, 148.00, 2, 1, 'mountain'),
(16, 152.00, 2, 0, 'none'), (16, 200.00, 3, 0, 'mountain'),
(16, 270.00, 4, 1, 'mountain');

-- Hyatt hotels
INSERT INTO room (hotel_id, price, capacity, extendable_by, view_type) VALUES
(17, 310.00, 1, 0, 'none'), (17, 415.00, 2, 1, 'none'),
(17, 425.00, 2, 0, 'mountain'), (17, 545.00, 3, 1, 'none'),
(17, 710.00, 4, 2, 'none'),
(18, 180.00, 1, 0, 'none'), (18, 255.00, 2, 1, 'none'),
(18, 265.00, 2, 0, 'mountain'), (18, 355.00, 3, 1, 'none'),
(18, 475.00, 4, 2, 'none'),
(19, 110.00, 1, 0, 'none'), (19, 155.00, 2, 1, 'none'),
(19, 160.00, 2, 0, 'none'), (19, 210.00, 3, 0, 'none'),
(19, 280.00, 4, 1, 'none'),
(20, 325.00, 1, 0, 'sea'),  (20, 430.00, 2, 1, 'sea'),
(20, 440.00, 2, 0, 'mountain'), (20, 560.00, 3, 1, 'sea'),
(20, 725.00, 4, 2, 'sea'),
(21, 190.00, 1, 0, 'none'), (21, 270.00, 2, 1, 'none'),
(21, 280.00, 2, 0, 'none'), (21, 370.00, 3, 1, 'none'),
(21, 495.00, 4, 2, 'none'),
(22, 100.00, 1, 0, 'mountain'), (22, 150.00, 2, 1, 'mountain'),
(22, 155.00, 2, 0, 'sea'),  (22, 205.00, 3, 0, 'mountain'),
(22, 275.00, 4, 1, 'sea'),
(23, 185.00, 1, 0, 'none'), (23, 265.00, 2, 1, 'none'),
(23, 270.00, 2, 0, 'none'), (23, 360.00, 3, 1, 'none'),
(23, 485.00, 4, 2, 'none'),
(24, 105.00, 1, 0, 'mountain'), (24, 150.00, 2, 1, 'mountain'),
(24, 155.00, 2, 0, 'none'), (24, 205.00, 3, 0, 'mountain'),
(24, 280.00, 4, 1, 'mountain');

-- Wyndham hotels
INSERT INTO room (hotel_id, price, capacity, extendable_by, view_type) VALUES
(25, 100.00, 1, 0, 'none'), (25, 148.00, 2, 1, 'none'),
(25, 155.00, 2, 0, 'none'), (25, 200.00, 3, 0, 'none'),
(25, 270.00, 4, 1, 'none'),
(26, 180.00, 1, 0, 'none'), (26, 255.00, 2, 1, 'none'),
(26, 265.00, 2, 0, 'none'), (26, 355.00, 3, 1, 'none'),
(26, 480.00, 4, 2, 'none'),
(27, 320.00, 1, 0, 'mountain'), (27, 425.00, 2, 1, 'mountain'),
(27, 435.00, 2, 0, 'none'), (27, 555.00, 3, 1, 'mountain'),
(27, 715.00, 4, 2, 'mountain'),
(28, 105.00, 1, 0, 'none'), (28, 152.00, 2, 1, 'none'),
(28, 158.00, 2, 0, 'none'), (28, 205.00, 3, 0, 'none'),
(28, 280.00, 4, 1, 'none'),
(29, 185.00, 1, 0, 'sea'),  (29, 265.00, 2, 1, 'sea'),
(29, 270.00, 2, 0, 'sea'),  (29, 360.00, 3, 1, 'sea'),
(29, 490.00, 4, 2, 'sea'),
(30, 100.00, 1, 0, 'none'), (30, 150.00, 2, 1, 'none'),
(30, 155.00, 2, 0, 'none'), (30, 200.00, 3, 0, 'none'),
(30, 275.00, 4, 1, 'none'),
(31, 185.00, 1, 0, 'none'), (31, 262.00, 2, 1, 'none'),
(31, 268.00, 2, 0, 'mountain'), (31, 358.00, 3, 1, 'none'),
(31, 485.00, 4, 2, 'none'),
(32, 95.00, 1, 0, 'none'),  (32, 140.00, 2, 1, 'none'),
(32, 148.00, 2, 0, 'none'), (32, 195.00, 3, 0, 'none'),
(32, 265.00, 4, 1, 'none');

-- IHG hotels
INSERT INTO room (hotel_id, price, capacity, extendable_by, view_type) VALUES
(33, 180.00, 1, 0, 'none'), (33, 258.00, 2, 1, 'none'),
(33, 262.00, 2, 0, 'none'), (33, 355.00, 3, 1, 'none'),
(33, 478.00, 4, 2, 'none'),
(34, 100.00, 1, 0, 'none'), (34, 148.00, 2, 1, 'none'),
(34, 155.00, 2, 0, 'none'), (34, 200.00, 3, 0, 'none'),
(34, 272.00, 4, 1, 'none'),
(35, 315.00, 1, 0, 'none'), (35, 420.00, 2, 1, 'none'),
(35, 430.00, 2, 0, 'mountain'), (35, 550.00, 3, 1, 'none'),
(35, 710.00, 4, 2, 'none'),
(36, 182.00, 1, 0, 'sea'),  (36, 260.00, 2, 1, 'sea'),
(36, 268.00, 2, 0, 'mountain'), (36, 358.00, 3, 1, 'sea'),
(36, 485.00, 4, 2, 'sea'),
(37, 102.00, 1, 0, 'none'), (37, 150.00, 2, 1, 'none'),
(37, 158.00, 2, 0, 'none'), (37, 202.00, 3, 0, 'none'),
(37, 278.00, 4, 1, 'none'),
(38, 320.00, 1, 0, 'none'), (38, 425.00, 2, 1, 'sea'),
(38, 432.00, 2, 0, 'mountain'), (38, 558.00, 3, 1, 'sea'),
(38, 720.00, 4, 2, 'sea'),
(39, 182.00, 1, 0, 'mountain'), (39, 262.00, 2, 1, 'mountain'),
(39, 268.00, 2, 0, 'sea'),  (39, 358.00, 3, 1, 'mountain'),
(39, 488.00, 4, 2, 'sea'),
(40, 100.00, 1, 0, 'none'), (40, 150.00, 2, 1, 'none'),
(40, 155.00, 2, 0, 'none'), (40, 200.00, 3, 0, 'none'),
(40, 275.00, 4, 1, 'none');

-- ============================================================
-- Room Amenities (a few per room, for first several hotels)
-- ============================================================
INSERT INTO room_amenity (room_id, amenity)
SELECT r.room_id, a.amenity
FROM room r
CROSS JOIN (VALUES ('TV'), ('Air Conditioning'), ('Wi-Fi')) AS a(amenity)
WHERE r.room_id <= 200;

-- Extra amenities for higher-capacity rooms
INSERT INTO room_amenity (room_id, amenity)
SELECT r.room_id, a.amenity
FROM room r
CROSS JOIN (VALUES ('Mini Bar'), ('Coffee Maker')) AS a(amenity)
WHERE r.capacity >= 3 AND r.room_id <= 200;

-- Fridge for suites
INSERT INTO room_amenity (room_id, amenity)
SELECT r.room_id, 'Fridge'
FROM room r
WHERE r.capacity >= 4 AND r.room_id <= 200;

-- ============================================================
-- Room Problems (a few rooms have issues)
-- ============================================================
INSERT INTO room_problem (room_id, problem_desc) VALUES
(3, 'Leaky faucet in bathroom'),
(8, 'Stained carpet near window'),
(15, 'Broken lamp on nightstand'),
(22, 'AC unit makes noise'),
(30, 'Cracked bathroom tile');

-- ============================================================
-- Customers
-- ============================================================
INSERT INTO customer (customer_id, full_name, address, id_type, id_number, registration_date) VALUES
( 1, 'John Smith',      '123 Main St, New York, NY',       'SSN', '123-45-6789', '2025-01-15'),
( 2, 'Jane Doe',        '456 Oak Ave, Los Angeles, CA',    'Driving Licence', 'DL-98765432', '2025-02-20'),
( 3, 'Robert Johnson',  '789 Pine Rd, Chicago, IL',        'SSN', '234-56-7890', '2025-03-10'),
( 4, 'Emily Davis',     '321 Elm St, Toronto, ON',         'SIN', '987-654-321', '2025-04-05'),
( 5, 'Michael Brown',   '654 Cedar Dr, Vancouver, BC',     'SIN', '876-543-210', '2025-05-12'),
( 6, 'Sarah Wilson',    '987 Maple Ln, Miami, FL',         'Driving Licence', 'DL-11223344', '2025-06-18'),
( 7, 'David Martinez',  '159 Birch Ct, San Francisco, CA', 'SSN', '345-67-8901', '2025-07-22'),
( 8, 'Lisa Anderson',   '753 Walnut St, Boston, MA',       'Driving Licence', 'DL-55667788', '2025-08-30'),
( 9, 'James Taylor',    '852 Spruce Ave, Seattle, WA',     'SSN', '456-78-9012', '2025-09-14'),
(10, 'Maria Garcia',    '951 Ash Blvd, Montreal, QC',      'SIN', '765-432-109', '2025-10-01');

SELECT setval('customer_customer_id_seq', 10);

-- ============================================================
-- Employees (2 per hotel = 80 employees)
-- First employee is the manager, second is receptionist.
-- ============================================================
INSERT INTO employee (employee_id, full_name, address, ssn, hotel_id, role) VALUES
-- Marriott employees
( 1, 'Alice Manager',      '10 Staff Rd, New York, NY',       '100-00-0001',  1, 'Manager'),
( 2, 'Bob Receptionist',   '11 Staff Rd, New York, NY',       '100-00-0002',  1, 'Receptionist'),
( 3, 'Carol Manager',      '12 Staff Rd, New York, NY',       '100-00-0003',  2, 'Manager'),
( 4, 'Dan Receptionist',   '13 Staff Rd, New York, NY',       '100-00-0004',  2, 'Receptionist'),
( 5, 'Eve Manager',        '14 Staff Rd, Los Angeles, CA',    '100-00-0005',  3, 'Manager'),
( 6, 'Frank Receptionist', '15 Staff Rd, Los Angeles, CA',    '100-00-0006',  3, 'Receptionist'),
( 7, 'Grace Manager',      '16 Staff Rd, Chicago, IL',        '100-00-0007',  4, 'Manager'),
( 8, 'Hank Receptionist',  '17 Staff Rd, Chicago, IL',        '100-00-0008',  4, 'Receptionist'),
( 9, 'Ivy Manager',        '18 Staff Rd, Toronto, ON',        '100-00-0009',  5, 'Manager'),
(10, 'Jack Receptionist',  '19 Staff Rd, Toronto, ON',        '100-00-0010',  5, 'Receptionist'),
(11, 'Kate Manager',       '20 Staff Rd, Vancouver, BC',      '100-00-0011',  6, 'Manager'),
(12, 'Leo Receptionist',   '21 Staff Rd, Vancouver, BC',      '100-00-0012',  6, 'Receptionist'),
(13, 'Mia Manager',        '22 Staff Rd, Miami, FL',          '100-00-0013',  7, 'Manager'),
(14, 'Nick Receptionist',  '23 Staff Rd, Miami, FL',          '100-00-0014',  7, 'Receptionist'),
(15, 'Olivia Manager',     '24 Staff Rd, San Francisco, CA',  '100-00-0015',  8, 'Manager'),
(16, 'Pete Receptionist',  '25 Staff Rd, San Francisco, CA',  '100-00-0016',  8, 'Receptionist'),
-- Hilton employees
(17, 'Quinn Manager',      '26 Staff Rd, New York, NY',       '200-00-0001',  9, 'Manager'),
(18, 'Rita Receptionist',  '27 Staff Rd, New York, NY',       '200-00-0002',  9, 'Receptionist'),
(19, 'Sam Manager',        '28 Staff Rd, Los Angeles, CA',    '200-00-0003', 10, 'Manager'),
(20, 'Tina Receptionist',  '29 Staff Rd, Los Angeles, CA',    '200-00-0004', 10, 'Receptionist'),
(21, 'Uma Manager',        '30 Staff Rd, Los Angeles, CA',    '200-00-0005', 11, 'Manager'),
(22, 'Vince Receptionist', '31 Staff Rd, Los Angeles, CA',    '200-00-0006', 11, 'Receptionist'),
(23, 'Wendy Manager',      '32 Staff Rd, Chicago, IL',        '200-00-0007', 12, 'Manager'),
(24, 'Xander Receptionist','33 Staff Rd, Chicago, IL',        '200-00-0008', 12, 'Receptionist'),
(25, 'Yara Manager',       '34 Staff Rd, Toronto, ON',        '200-00-0009', 13, 'Manager'),
(26, 'Zack Receptionist',  '35 Staff Rd, Toronto, ON',        '200-00-0010', 13, 'Receptionist'),
(27, 'Amy Manager',        '36 Staff Rd, Montreal, QC',       '200-00-0011', 14, 'Manager'),
(28, 'Ben Receptionist',   '37 Staff Rd, Montreal, QC',       '200-00-0012', 14, 'Receptionist'),
(29, 'Cara Manager',       '38 Staff Rd, Boston, MA',         '200-00-0013', 15, 'Manager'),
(30, 'Derek Receptionist', '39 Staff Rd, Boston, MA',         '200-00-0014', 15, 'Receptionist'),
(31, 'Elena Manager',      '40 Staff Rd, Seattle, WA',        '200-00-0015', 16, 'Manager'),
(32, 'Finn Receptionist',  '41 Staff Rd, Seattle, WA',        '200-00-0016', 16, 'Receptionist'),
-- Hyatt employees
(33, 'Gina Manager',       '42 Staff Rd, New York, NY',       '300-00-0001', 17, 'Manager'),
(34, 'Hugo Receptionist',  '43 Staff Rd, New York, NY',       '300-00-0002', 17, 'Receptionist'),
(35, 'Irene Manager',      '44 Staff Rd, Chicago, IL',        '300-00-0003', 18, 'Manager'),
(36, 'Jay Receptionist',   '45 Staff Rd, Chicago, IL',        '300-00-0004', 18, 'Receptionist'),
(37, 'Kelly Manager',      '46 Staff Rd, Chicago, IL',        '300-00-0005', 19, 'Manager'),
(38, 'Liam Receptionist',  '47 Staff Rd, Chicago, IL',        '300-00-0006', 19, 'Receptionist'),
(39, 'Monica Manager',     '48 Staff Rd, San Francisco, CA',  '300-00-0007', 20, 'Manager'),
(40, 'Nathan Receptionist','49 Staff Rd, San Francisco, CA',  '300-00-0008', 20, 'Receptionist'),
(41, 'Opal Manager',       '50 Staff Rd, Toronto, ON',        '300-00-0009', 21, 'Manager'),
(42, 'Paul Receptionist',  '51 Staff Rd, Toronto, ON',        '300-00-0010', 21, 'Receptionist'),
(43, 'Quincy Manager',     '52 Staff Rd, Vancouver, BC',      '300-00-0011', 22, 'Manager'),
(44, 'Rosa Receptionist',  '53 Staff Rd, Vancouver, BC',      '300-00-0012', 22, 'Receptionist'),
(45, 'Steve Manager',      '54 Staff Rd, Washington DC',      '300-00-0013', 23, 'Manager'),
(46, 'Tammy Receptionist', '55 Staff Rd, Washington DC',      '300-00-0014', 23, 'Receptionist'),
(47, 'Ulrich Manager',     '56 Staff Rd, Denver, CO',         '300-00-0015', 24, 'Manager'),
(48, 'Vera Receptionist',  '57 Staff Rd, Denver, CO',         '300-00-0016', 24, 'Receptionist'),
-- Wyndham employees
(49, 'Will Manager',       '58 Staff Rd, Orlando, FL',        '400-00-0001', 25, 'Manager'),
(50, 'Xena Receptionist',  '59 Staff Rd, Orlando, FL',        '400-00-0002', 25, 'Receptionist'),
(51, 'Yuri Manager',       '60 Staff Rd, Orlando, FL',        '400-00-0003', 26, 'Manager'),
(52, 'Zoe Receptionist',   '61 Staff Rd, Orlando, FL',        '400-00-0004', 26, 'Receptionist'),
(53, 'Aaron Manager',      '62 Staff Rd, Las Vegas, NV',      '400-00-0005', 27, 'Manager'),
(54, 'Bella Receptionist', '63 Staff Rd, Las Vegas, NV',      '400-00-0006', 27, 'Receptionist'),
(55, 'Chad Manager',       '64 Staff Rd, New York, NY',       '400-00-0007', 28, 'Manager'),
(56, 'Diana Receptionist', '65 Staff Rd, New York, NY',       '400-00-0008', 28, 'Receptionist'),
(57, 'Eli Manager',        '66 Staff Rd, Miami, FL',          '400-00-0009', 29, 'Manager'),
(58, 'Faye Receptionist',  '67 Staff Rd, Miami, FL',          '400-00-0010', 29, 'Receptionist'),
(59, 'Gavin Manager',      '68 Staff Rd, Toronto, ON',        '400-00-0011', 30, 'Manager'),
(60, 'Holly Receptionist', '69 Staff Rd, Toronto, ON',        '400-00-0012', 30, 'Receptionist'),
(61, 'Ivan Manager',       '70 Staff Rd, Montreal, QC',       '400-00-0013', 31, 'Manager'),
(62, 'Jill Receptionist',  '71 Staff Rd, Montreal, QC',       '400-00-0014', 31, 'Receptionist'),
(63, 'Kurt Manager',       '72 Staff Rd, Ottawa, ON',         '400-00-0015', 32, 'Manager'),
(64, 'Lana Receptionist',  '73 Staff Rd, Ottawa, ON',         '400-00-0016', 32, 'Receptionist'),
-- IHG employees
(65, 'Marco Manager',      '74 Staff Rd, Atlanta, GA',        '500-00-0001', 33, 'Manager'),
(66, 'Nina Receptionist',  '75 Staff Rd, Atlanta, GA',        '500-00-0002', 33, 'Receptionist'),
(67, 'Oscar Manager',      '76 Staff Rd, Atlanta, GA',        '500-00-0003', 34, 'Manager'),
(68, 'Penny Receptionist', '77 Staff Rd, Atlanta, GA',        '500-00-0004', 34, 'Receptionist'),
(69, 'Reed Manager',       '78 Staff Rd, New York, NY',       '500-00-0005', 35, 'Manager'),
(70, 'Sally Receptionist', '79 Staff Rd, New York, NY',       '500-00-0006', 35, 'Receptionist'),
(71, 'Tom Manager',        '80 Staff Rd, Los Angeles, CA',    '500-00-0007', 36, 'Manager'),
(72, 'Ursula Receptionist','81 Staff Rd, Los Angeles, CA',    '500-00-0008', 36, 'Receptionist'),
(73, 'Victor Manager',     '82 Staff Rd, Chicago, IL',        '500-00-0009', 37, 'Manager'),
(74, 'Wanda Receptionist', '83 Staff Rd, Chicago, IL',        '500-00-0010', 37, 'Receptionist'),
(75, 'Xavier Manager',     '84 Staff Rd, Toronto, ON',        '500-00-0011', 38, 'Manager'),
(76, 'Yvette Receptionist','85 Staff Rd, Toronto, ON',        '500-00-0012', 38, 'Receptionist'),
(77, 'Zane Manager',       '86 Staff Rd, Vancouver, BC',      '500-00-0013', 39, 'Manager'),
(78, 'Abby Receptionist',  '87 Staff Rd, Vancouver, BC',      '500-00-0014', 39, 'Receptionist'),
(79, 'Brian Manager',      '88 Staff Rd, Boston, MA',         '500-00-0015', 40, 'Manager'),
(80, 'Cindy Receptionist', '89 Staff Rd, Boston, MA',         '500-00-0016', 40, 'Receptionist');

SELECT setval('employee_employee_id_seq', 80);

-- Set managers for all hotels
UPDATE hotel SET manager_id =  1 WHERE hotel_id =  1;
UPDATE hotel SET manager_id =  3 WHERE hotel_id =  2;
UPDATE hotel SET manager_id =  5 WHERE hotel_id =  3;
UPDATE hotel SET manager_id =  7 WHERE hotel_id =  4;
UPDATE hotel SET manager_id =  9 WHERE hotel_id =  5;
UPDATE hotel SET manager_id = 11 WHERE hotel_id =  6;
UPDATE hotel SET manager_id = 13 WHERE hotel_id =  7;
UPDATE hotel SET manager_id = 15 WHERE hotel_id =  8;
UPDATE hotel SET manager_id = 17 WHERE hotel_id =  9;
UPDATE hotel SET manager_id = 19 WHERE hotel_id = 10;
UPDATE hotel SET manager_id = 21 WHERE hotel_id = 11;
UPDATE hotel SET manager_id = 23 WHERE hotel_id = 12;
UPDATE hotel SET manager_id = 25 WHERE hotel_id = 13;
UPDATE hotel SET manager_id = 27 WHERE hotel_id = 14;
UPDATE hotel SET manager_id = 29 WHERE hotel_id = 15;
UPDATE hotel SET manager_id = 31 WHERE hotel_id = 16;
UPDATE hotel SET manager_id = 33 WHERE hotel_id = 17;
UPDATE hotel SET manager_id = 35 WHERE hotel_id = 18;
UPDATE hotel SET manager_id = 37 WHERE hotel_id = 19;
UPDATE hotel SET manager_id = 39 WHERE hotel_id = 20;
UPDATE hotel SET manager_id = 41 WHERE hotel_id = 21;
UPDATE hotel SET manager_id = 43 WHERE hotel_id = 22;
UPDATE hotel SET manager_id = 45 WHERE hotel_id = 23;
UPDATE hotel SET manager_id = 47 WHERE hotel_id = 24;
UPDATE hotel SET manager_id = 49 WHERE hotel_id = 25;
UPDATE hotel SET manager_id = 51 WHERE hotel_id = 26;
UPDATE hotel SET manager_id = 53 WHERE hotel_id = 27;
UPDATE hotel SET manager_id = 55 WHERE hotel_id = 28;
UPDATE hotel SET manager_id = 57 WHERE hotel_id = 29;
UPDATE hotel SET manager_id = 59 WHERE hotel_id = 30;
UPDATE hotel SET manager_id = 61 WHERE hotel_id = 31;
UPDATE hotel SET manager_id = 63 WHERE hotel_id = 32;
UPDATE hotel SET manager_id = 65 WHERE hotel_id = 33;
UPDATE hotel SET manager_id = 67 WHERE hotel_id = 34;
UPDATE hotel SET manager_id = 69 WHERE hotel_id = 35;
UPDATE hotel SET manager_id = 71 WHERE hotel_id = 36;
UPDATE hotel SET manager_id = 73 WHERE hotel_id = 37;
UPDATE hotel SET manager_id = 75 WHERE hotel_id = 38;
UPDATE hotel SET manager_id = 77 WHERE hotel_id = 39;
UPDATE hotel SET manager_id = 79 WHERE hotel_id = 40;

-- ============================================================
-- Sample Bookings
-- ============================================================
INSERT INTO booking (booking_id, customer_id, room_id, start_date, end_date, booking_date) VALUES
(1, 1, 1,  '2026-05-01', '2026-05-05', '2026-04-01'),
(2, 2, 12, '2026-05-10', '2026-05-14', '2026-04-02'),
(3, 3, 23, '2026-06-01', '2026-06-07', '2026-04-03'),
(4, 4, 34, '2026-06-15', '2026-06-20', '2026-04-04'),
(5, 5, 45, '2026-07-01', '2026-07-05', '2026-04-05'),
(6, 1, 56, '2026-07-10', '2026-07-15', '2026-04-06'),
(7, 6, 67, '2026-05-20', '2026-05-25', '2026-04-07'),
(8, 7, 78, '2026-08-01', '2026-08-05', '2026-04-07');

SELECT setval('booking_booking_id_seq', 8);

-- ============================================================
-- Sample Rentings (some from bookings, some direct)
-- ============================================================
INSERT INTO renting (renting_id, booking_id, customer_id, room_id, employee_id, start_date, end_date, checkin_date) VALUES
(1, NULL, 8, 89, 17, '2026-04-01', '2026-04-05', '2026-04-01'),
(2, NULL, 9, 100, 31, '2026-04-02', '2026-04-06', '2026-04-02'),
(3, NULL, 10, 5, 2, '2026-04-03', '2026-04-08', '2026-04-03');

SELECT setval('renting_renting_id_seq', 3);

-- ============================================================
-- Sample Payments
-- ============================================================
INSERT INTO payment (payment_id, renting_id, amount, payment_date) VALUES
(1, 1, 980.00,  '2026-04-05'),
(2, 2, 600.00,  '2026-04-06'),
(3, 3, 3500.00, '2026-04-08');

SELECT setval('payment_payment_id_seq', 3);
