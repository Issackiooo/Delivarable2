## Project Structure

- [sql/00_reset.sql](Deliverable2/sql/00_reset.sql): drops the objects cleanly
- [sql/01_schema.sql](Deliverable2/sql/01_schema.sql): tables, constraints, triggers, and functions
- [sql/02_indexes_views.sql](Deliverable2/sql/02_indexes_views.sql): indexes and required views
- [sql/03_seed.sql](Deliverable2/sql/03_seed.sql): population script
- [sql/04_queries.sql](Deliverable2/sql/04_queries.sql): required query set
- [sql/05_modifications.sql](Deliverable2/sql/05_modifications.sql): modification and trigger demos
- [app/src/EHotelsServer.java](Deliverable2/app/src/EHotelsServer.java): HTTP server and routes
- [app/src/Database.java](Deliverable2/app/src/Database.java): `psql` wrapper for the app
- [app/src/Html.java](Deliverable2/app/src/Html.java): HTML rendering helpers



## How to run
### Setup PostgresSql on your machine to use psql in terminal 
$env:Path += ";C:\Program Files\PostgreSQL\18\bin"
$env:PGUSER = "postgres"
$env:PGPASSWORD = "YOUR_POSTGRES_PASSWORD"
$env:PGHOST = "localhost"
$env:PGPORT = "5432"

### Run DB + Java program
createdb ehotels_d2
psql -d ehotels_d2 -f sql\00_reset.sql
psql -d ehotels_d2 -f sql\01_schema.sql
psql -d ehotels_d2 -f sql\02_indexes_views.sql
psql -d ehotels_d2 -f sql\03_seed.sql
javac app\src\*.java
java -cp app\src EHotelsServer


