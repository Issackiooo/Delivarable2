-- ============================================================
-- e-Hotels Database Schema (DDL)
-- DBMS: PostgreSQL
-- Based on Deliverable 1 relational schema
-- ============================================================

-- Drop tables if they exist (for clean re-creation)
DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS renting_archive CASCADE;
DROP TABLE IF EXISTS booking_archive CASCADE;
DROP TABLE IF EXISTS renting CASCADE;
DROP TABLE IF EXISTS booking CASCADE;
DROP TABLE IF EXISTS room_problem CASCADE;
DROP TABLE IF EXISTS room_amenity CASCADE;
DROP TABLE IF EXISTS room CASCADE;
DROP TABLE IF EXISTS h_phone CASCADE;
DROP TABLE IF EXISTS h_email CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS hotel CASCADE;
DROP TABLE IF EXISTS hc_phone CASCADE;
DROP TABLE IF EXISTS hc_email CASCADE;
DROP TABLE IF EXISTS hotel_chain CASCADE;
DROP TABLE IF EXISTS customer CASCADE;

-- ============================================================
-- Hotel Chain
-- ============================================================
CREATE TABLE hotel_chain (
    chain_id    SERIAL PRIMARY KEY,
    name        VARCHAR(255) UNIQUE NOT NULL,
    address     VARCHAR(255) NOT NULL,
    num_hotels  INT NOT NULL DEFAULT 0
);

-- Multi-valued: hotel chain email addresses
CREATE TABLE hc_email (
    chain_id INT NOT NULL REFERENCES hotel_chain(chain_id) ON DELETE CASCADE,
    email    VARCHAR(255) NOT NULL,
    PRIMARY KEY (chain_id, email)
);

-- Multi-valued: hotel chain phone numbers
CREATE TABLE hc_phone (
    chain_id  INT NOT NULL REFERENCES hotel_chain(chain_id) ON DELETE CASCADE,
    phone_num VARCHAR(20) NOT NULL,
    PRIMARY KEY (chain_id, phone_num)
);

-- ============================================================
-- Hotel
-- ============================================================
CREATE TABLE hotel (
    hotel_id   SERIAL PRIMARY KEY,
    chain_id   INT NOT NULL REFERENCES hotel_chain(chain_id) ON DELETE CASCADE,
    address    VARCHAR(255) NOT NULL,
    city       VARCHAR(100) NOT NULL,        -- area for View 1
    stars      INT NOT NULL CHECK (stars >= 1 AND stars <= 5),
    num_rooms  INT NOT NULL DEFAULT 0,
    manager_id INT,                          -- FK added after employee table
    UNIQUE (chain_id, address)
);

-- Multi-valued: hotel email addresses
CREATE TABLE h_email (
    hotel_id INT NOT NULL REFERENCES hotel(hotel_id) ON DELETE CASCADE,
    email    VARCHAR(255) NOT NULL,
    PRIMARY KEY (hotel_id, email)
);

-- Multi-valued: hotel phone numbers
CREATE TABLE h_phone (
    hotel_id  INT NOT NULL REFERENCES hotel(hotel_id) ON DELETE CASCADE,
    phone_num VARCHAR(20) NOT NULL,
    PRIMARY KEY (hotel_id, phone_num)
);

-- ============================================================
-- Room
-- ============================================================
CREATE TABLE room (
    room_id       SERIAL PRIMARY KEY,
    hotel_id      INT NOT NULL REFERENCES hotel(hotel_id) ON DELETE CASCADE,
    price         NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    capacity      INT NOT NULL CHECK (capacity >= 1),
    extendable_by INT NOT NULL DEFAULT 0 CHECK (extendable_by >= 0),
    view_type     VARCHAR(20) NOT NULL DEFAULT 'none'
                      CHECK (view_type IN ('sea', 'mountain', 'none')),
    is_available  BOOLEAN NOT NULL DEFAULT TRUE
);

-- Multi-valued: room amenities
CREATE TABLE room_amenity (
    room_id INT NOT NULL REFERENCES room(room_id) ON DELETE CASCADE,
    amenity VARCHAR(255) NOT NULL,
    PRIMARY KEY (room_id, amenity)
);

-- Multi-valued: room problems/damages
CREATE TABLE room_problem (
    room_id     INT NOT NULL REFERENCES room(room_id) ON DELETE CASCADE,
    problem_desc VARCHAR(255) NOT NULL,
    PRIMARY KEY (room_id, problem_desc)
);

-- ============================================================
-- Customer
-- ============================================================
CREATE TABLE customer (
    customer_id       SERIAL PRIMARY KEY,
    full_name         VARCHAR(255) NOT NULL,
    address           VARCHAR(255) NOT NULL,
    id_type           VARCHAR(50) NOT NULL
                          CHECK (id_type IN ('SSN', 'SIN', 'Driving Licence')),
    id_number         VARCHAR(50) NOT NULL,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE
);

-- ============================================================
-- Employee
-- ============================================================
CREATE TABLE employee (
    employee_id SERIAL PRIMARY KEY,
    full_name   VARCHAR(255) NOT NULL,
    address     VARCHAR(255) NOT NULL,
    ssn         VARCHAR(20) NOT NULL UNIQUE,
    hotel_id    INT NOT NULL REFERENCES hotel(hotel_id) ON DELETE CASCADE,
    role        VARCHAR(100) NOT NULL
);

-- Now add the manager FK on hotel
ALTER TABLE hotel
    ADD CONSTRAINT fk_hotel_manager
    FOREIGN KEY (manager_id) REFERENCES employee(employee_id)
    ON DELETE SET NULL;

-- ============================================================
-- Booking
-- ============================================================
CREATE TABLE booking (
    booking_id   SERIAL PRIMARY KEY,
    customer_id  INT NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    room_id      INT NOT NULL REFERENCES room(room_id) ON DELETE CASCADE,
    start_date   DATE NOT NULL,
    end_date     DATE NOT NULL,
    booking_date DATE NOT NULL DEFAULT CURRENT_DATE,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (end_date > start_date)
);

-- ============================================================
-- Renting
-- ============================================================
CREATE TABLE renting (
    renting_id   SERIAL PRIMARY KEY,
    booking_id   INT REFERENCES booking(booking_id) ON DELETE SET NULL,
    customer_id  INT NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    room_id      INT NOT NULL REFERENCES room(room_id) ON DELETE CASCADE,
    employee_id  INT NOT NULL REFERENCES employee(employee_id) ON DELETE CASCADE,
    start_date   DATE NOT NULL,
    end_date     DATE NOT NULL,
    checkin_date DATE NOT NULL DEFAULT CURRENT_DATE,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (end_date > start_date)
);

-- ============================================================
-- Payment
-- ============================================================
CREATE TABLE payment (
    payment_id   SERIAL PRIMARY KEY,
    renting_id   INT NOT NULL REFERENCES renting(renting_id) ON DELETE CASCADE,
    amount       NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE
);

-- ============================================================
-- Archive tables (self-contained, no FK constraints)
-- Information persists even if the room/customer is deleted.
-- ============================================================
CREATE TABLE booking_archive (
    archive_id    SERIAL PRIMARY KEY,
    booking_id    INT NOT NULL,
    customer_id   INT,
    customer_name VARCHAR(255),
    room_id       INT,
    hotel_address VARCHAR(255),
    chain_name    VARCHAR(255),
    start_date    DATE NOT NULL,
    end_date      DATE NOT NULL,
    booking_date  DATE,
    archived_date DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE renting_archive (
    archive_id    SERIAL PRIMARY KEY,
    renting_id    INT NOT NULL,
    booking_id    INT,
    customer_id   INT,
    customer_name VARCHAR(255),
    room_id       INT,
    hotel_address VARCHAR(255),
    chain_name    VARCHAR(255),
    employee_id   INT,
    employee_name VARCHAR(255),
    start_date    DATE NOT NULL,
    end_date      DATE NOT NULL,
    checkin_date  DATE,
    archived_date DATE NOT NULL DEFAULT CURRENT_DATE
);
