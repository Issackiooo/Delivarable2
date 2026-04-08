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
- [scripts/setup_db.sh](Deliverable2/scripts/setup_db.sh): rebuilds the database
- [scripts/run_app.sh](Deliverable2/scripts/run_app.sh): compiles and launches the app
- [scripts/setup_db.cmd](Deliverable2/scripts/setup_db.cmd): Windows database setup wrapper
- [scripts/run_app.cmd](Deliverable2/scripts/run_app.cmd): Windows app launcher

## What Each Script Does

- `setup_db`
  - creates the project database if needed
  - drops old project objects
  - recreates the schema
  - creates indexes and views
  - loads the sample data

- `run_queries`
  - runs [sql/04_queries.sql](Deliverable2/sql/04_queries.sql)
  - this is only for demonstrating the required SQL queries
  - you do not need to run it to start the app

- `run_modifications`
  - runs [sql/05_modifications.sql](Deliverable2/sql/05_modifications.sql)
  - this is only for demonstrating updates, deletes, and trigger behavior
  - you do not need to run it to start the app

- `run_app`
  - compiles the Java files
  - starts the web server in the current terminal
  - keeps running until you stop it with `Ctrl + C`

## Start the Project

### What you need first

1. PostgreSQL installed and running
2. `psql` available in your terminal
3. Java and `javac` installed

### macOS or Linux

1. Build the database:

```bash
bash scripts/setup_db.sh ehotels_d2
```

2. Start the web app:

```bash
bash scripts/run_app.sh ehotels_d2
```

3. Open:

```text
http://localhost:8080/dashboard
```

### Windows

1. Build the database:

```bat
scripts\setup_db.cmd ehotels_d2
```

2. Start the web app:

```bat
scripts\run_app.cmd ehotels_d2
```

3. Open:

```text
http://localhost:8080/dashboard
```

## Optional Demo Commands

These are not required to launch the app. They are only for demonstrating Deliverable 2 SQL features.

### macOS or Linux

Run the required query demo:

```bash
bash scripts/run_queries.sh ehotels_d2
```

Run the trigger/modification demo:

```bash
bash scripts/run_modifications.sh ehotels_d2
```

### Windows

Run the required query demo:

```bat
scripts\run_queries.cmd ehotels_d2
```

Run the trigger/modification demo:

```bat
scripts\run_modifications.cmd ehotels_d2
```

## Stop and Start Everything

### Stop the Java web server

The app server runs in the current terminal. Stop it by pressing:

```text
Ctrl + C
```

If you still have an old server process using port `8080`, close that process and start again.

On macOS or Linux:

```bash
lsof -nP -iTCP:8080 -sTCP:LISTEN
kill <PID>
```

On Windows:

```bat
netstat -ano | findstr :8080
taskkill /PID <PID> /F
```

### Start the Java web server again

macOS or Linux:

```bash
bash scripts/run_app.sh ehotels_d2
```

Windows:

```bat
scripts\run_app.cmd ehotels_d2
```

### Stop PostgreSQL completely

macOS with Homebrew:

```bash
brew services stop postgresql@18
```

### Start PostgreSQL again

macOS with Homebrew:

```bash
brew services start postgresql@18
```

Windows:

- If PostgreSQL was installed as a Windows service:
  1. Open `Services`
  2. Find the PostgreSQL service
  3. Click `Start` or `Stop`

- If PostgreSQL was started manually in a terminal:
  - stop that terminal process with `Ctrl + C`
  - then start PostgreSQL again the same way you normally start it on your machine

### Check whether PostgreSQL is running

macOS with Homebrew:

```bash
brew services list | rg postgres
```

Windows:

```bat
sc query type= service | findstr /I postgres
```

### Typical restart sequence

1. Stop the app server with `Ctrl + C`
2. Make sure PostgreSQL is running
3. Rebuild the database if needed

macOS or Linux:

```bash
bash scripts/setup_db.sh ehotels_d2
```

Windows:

```bat
scripts\setup_db.cmd ehotels_d2
```

4. Start the app again

macOS or Linux:

```bash
bash scripts/run_app.sh ehotels_d2
```

Windows:

```bat
scripts\run_app.cmd ehotels_d2
```

## Notes

- The app uses the locally installed `psql` client to talk to PostgreSQL, so there are no framework or package-manager dependencies.
- Default database name: `ehotels_d2`
- Default app port: `8080`
- You can override the port with `EHOTELS_PORT=9090 bash scripts/run_app.sh ehotels_d2`

See [docs/report.md](Deliverable2/docs/report.md) for the deliverable-style report content.
