# e-Hotels Deliverable 2 Report

## 1. Technologies Used

- DBMS: PostgreSQL
- Server-side language: Java 23
- Client-side technologies: HTML, CSS, minimal JavaScript
- Database access from the app: local `psql` command invoked from Java

This keeps the stack close to the technologies recommended in the project description:

- PostgreSQL for the database
- Java for the server side
- HTML for the client side

No external framework or package manager is required.

## 2. Installation and Execution Steps

### Prerequisites

- PostgreSQL server running locally
- `psql` available in `PATH`
- Java 23 or any Java version that supports `HttpServer` and text blocks
- `javac` available in `PATH`

### Database setup

Run:

```bash
bash scripts/setup_db.sh ehotels_d2
```

This script:

1. Creates the database `ehotels_d2` if it does not exist
2. Drops existing project objects
3. Creates all tables, constraints, triggers, functions, indexes, and views
4. Populates the database with sample data

### Optional SQL-only demos

Run the 4 required queries:

```bash
bash scripts/run_queries.sh ehotels_d2
```

Run the modifications and trigger demos:

```bash
bash scripts/run_modifications.sh ehotels_d2
```

### Run the web application

```bash
bash scripts/run_app.sh ehotels_d2
```

Then open:

```text
http://localhost:8080/dashboard
```

Optional port override:

```bash
EHOTELS_PORT=9090 bash scripts/run_app.sh ehotels_d2
```

## 3. DDL and SQL Files

### Database creation and reset

- [sql/00_reset.sql](/Users/mohamedhamed/Documents/YR2/DB1/Deliverable2/sql/00_reset.sql)
- [sql/01_schema.sql](/Users/mohamedhamed/Documents/YR2/DB1/Deliverable2/sql/01_schema.sql)
- [sql/02_indexes_views.sql](/Users/mohamedhamed/Documents/YR2/DB1/Deliverable2/sql/02_indexes_views.sql)

### Data population

- [sql/03_seed.sql](/Users/mohamedhamed/Documents/YR2/DB1/Deliverable2/sql/03_seed.sql)

### Queries and modification demos

- [sql/04_queries.sql](/Users/mohamedhamed/Documents/YR2/DB1/Deliverable2/sql/04_queries.sql)
- [sql/05_modifications.sql](/Users/mohamedhamed/Documents/YR2/DB1/Deliverable2/sql/05_modifications.sql)

## 4. Schema Implementation Notes

The implementation stays aligned with [schema.txt](/Users/mohamedhamed/Documents/YR2/DB1/Deliverable2/schema.txt) and preserves the submitted structure:

- `hotel_chain`, `hotel`, `room`, `customer`, `employee`, `employee_role`, `hotel_manager`, `booking`, `renting`
- contact tables for chains and hotels
- amenity and problem tables for rooms

Practical implementation details added for Deliverable 2:

- `booking_archive` and `renting_archive` preserve history even if referenced entities are later deleted
- `payment` supports employee-entered renting payments
- `hotel_area(address)` derives the area from the first comma-separated segment of the hotel address, which avoids changing the submitted schema with a new `area` column
- `num_hotels` in `hotel_chain` is maintained by trigger because the submitted schema treated it as derived
- `is_available` in `room` is maintained as a current-date derived value by triggers, while the room search for date ranges uses overlap checks on `booking` and `renting`

## 5. Integrity Constraints and Triggers

### Core constraints

- Primary keys on all entity tables
- Composite foreign keys from hotels to hotel chains, from rooms to hotels, and from amenity/problem tables to rooms
- Date constraints: `start_date < end_date` on both `booking` and `renting`
- Domain constraints:
  - hotel stars in `[1, 5]`
  - room price `>= 0`
  - room capacity `>= 1`
  - room extendability `>= 0`
  - room view in `{sea, mountain, none}`

### Trigger 1: hotel must have a manager

Implemented in [sql/01_schema.sql](/Users/mohamedhamed/Documents/YR2/DB1/Deliverable2/sql/01_schema.sql) with:

- `ensure_hotel_has_manager()`
- constraint trigger `hotel_requires_manager_trg`

Reason:

- The submitted schema explicitly states that a hotel must be created alongside an initial manager.

### Trigger 2: a hotel manager must have a manager role

Implemented with:

- `require_manager_role()`
- constraint trigger `hotel_manager_requires_role_trg`

Reason:

- The submitted schema explicitly states that the corresponding employee must have a role containing the substring `manager`.

### Trigger 3 and 4: prevent overlapping bookings/rentings

Implemented with:

- `ensure_room_time_window_available()`
- triggers `booking_room_available_trg` and `renting_room_available_trg`

Reason:

- A room cannot be booked or rented if it is already reserved during the requested interval.

### Trigger 5 and 6: archive history on delete

Implemented with:

- `archive_booking_before_delete()`
- `archive_renting_before_delete()`

Reason:

- Deliverable 2 requires archive history to remain in the database even if live entities are later removed.

## 6. Database Population

The database population satisfies the project requirements:

- 5 hotel chains
- 8 hotels per chain
- 40 hotels total
- at least 3 categories per chain
- 5 rooms per hotel
- 200 rooms total
- multiple hotels in the same area
- active bookings, active rentings, archived bookings, archived rentings, and payments

Clean seeded row counts after running `bash scripts/setup_db.sh ehotels_d2`:

- `hotel_chain`: 5
- `hotel`: 40
- `room`: 200
- `customer`: 12
- `employee`: 80
- `booking`: 2
- `renting`: 3
- `booking_archive`: 1
- `renting_archive`: 1
- `payment`: 2

## 7. Required Queries

Implemented in [sql/04_queries.sql](/Users/mohamedhamed/Documents/YR2/DB1/Deliverable2/sql/04_queries.sql):

1. Multi-criteria room search using the same logic as the web application
2. Aggregation query: average room price and room count grouped by chain and category
3. Nested query: customers who have a booking or renting in the highest-category hotels
4. Manager and room-problem overview

The room search also exists as the SQL function `search_available_rooms(...)`, which is used directly by the web application.

## 8. Indexes and Justification

Implemented in [sql/02_indexes_views.sql](/Users/mohamedhamed/Documents/YR2/DB1/Deliverable2/sql/02_indexes_views.sql):

1. `idx_hotel_area_expr` on `hotel (hotel_area(address))`
   Used for filtering by area and for the "available rooms per area" view.

2. `idx_room_capacity_price` on `room (capacity, price)`
   Used by the search interface, which filters on room capacity and maximum price.

3. `idx_booking_room_dates` on `booking (hc_name, hc_addr, h_addr, r_id, start_date, end_date)`
   Used when checking whether a room has overlapping bookings for a given interval.

4. `idx_renting_room_dates` on `renting (hc_name, hc_addr, h_addr, r_id, start_date, end_date)`
   Used when checking whether a room has overlapping rentings for a given interval.

Expected workload:

- frequent filtering of rooms by customer-entered criteria
- frequent overlap checks when inserting bookings or rentings
- repeated aggregation by area and hotel in the views

## 9. Views

Implemented in [sql/02_indexes_views.sql](/Users/mohamedhamed/Documents/YR2/DB1/Deliverable2/sql/02_indexes_views.sql):

### View 1: `available_rooms_per_area`

- Counts rooms whose `is_available` value is true
- Groups by derived hotel area

### View 2: `hotel_aggregated_capacity`

- Aggregates room capacity for every hotel
- Also exposes `max_aggregated_capacity` using `capacity + extendable_by`

Both views are displayed in the web application under `/views`.

## 10. Web Application Features

The web application supports the required Deliverable 2 interface features:

- room search with multiple combined criteria:
  - start date
  - end date
  - room capacity
  - area
  - hotel chain
  - hotel category
  - total number of rooms in the hotel
  - maximum room price
- automatic refresh when criteria change
- customer flow:
  - search available rooms
  - create bookings
- employee flow:
  - search available rooms
  - create direct rentings
  - convert a booking to a renting during check-in
  - insert payments for rentings
- CRUD pages for:
  - customers
  - employees
  - hotels
  - rooms
- view display page for the two required SQL views
- query display page for the four required SQL queries

## 11. Application Files

- [app/src/EHotelsServer.java](/Users/mohamedhamed/Documents/YR2/DB1/Deliverable2/app/src/EHotelsServer.java)
- [app/src/Database.java](/Users/mohamedhamed/Documents/YR2/DB1/Deliverable2/app/src/Database.java)
- [app/src/Html.java](/Users/mohamedhamed/Documents/YR2/DB1/Deliverable2/app/src/Html.java)
- [scripts/run_app.sh](/Users/mohamedhamed/Documents/YR2/DB1/Deliverable2/scripts/run_app.sh)

## 12. Verification Summary

Verified locally:

- database rebuild from scratch
- seed data load
- required query script
- trigger/modification script
- Java compilation
- rendering of dashboard, search, operations, views, and queries pages
- booking creation through the UI
- customer insert/delete through the UI
- payment insertion through the UI

The database was rebuilt after verification so the final local state matches the scripted seed data.
