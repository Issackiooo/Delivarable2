import com.sun.net.httpserver.Headers;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class EHotelsServer {
    private final Database db;

    public EHotelsServer(Database db) {
        this.db = db;
    }

    public static void main(String[] args) throws Exception {
        String dbName = System.getenv().getOrDefault("EHOTELS_DB", "ehotels_d2");
        int port = Integer.parseInt(System.getenv().getOrDefault("EHOTELS_PORT", "8080"));

        Database db = new Database(dbName);
        EHotelsServer app = new EHotelsServer(db);

        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
        server.createContext("/", app::handle);
        server.start();

        System.out.println("e-Hotels app running on http://localhost:" + port + "/dashboard");
        System.out.println("Using database: " + dbName);
    }

    private void handle(HttpExchange exchange) throws IOException {
        try {
            String path = exchange.getRequestURI().getPath();
            if ("/".equals(path)) {
                redirect(exchange, "/dashboard");
                return;
            }

            if ("POST".equalsIgnoreCase(exchange.getRequestMethod()) && path.startsWith("/actions/")) {
                handleAction(exchange, path);
                return;
            }

            switch (path) {
                case "/dashboard" -> render(exchange, "Dashboard", renderDashboard(exchange));
                case "/search" -> render(exchange, "Search", renderSearch(exchange));
                case "/customers" -> render(exchange, "Customers", renderCustomers(exchange));
                case "/employees" -> render(exchange, "Employees", renderEmployees(exchange));
                case "/hotels" -> render(exchange, "Hotels", renderHotels(exchange));
                case "/rooms" -> render(exchange, "Rooms", renderRooms(exchange));
                case "/operations" -> render(exchange, "Operations", renderOperations(exchange));
                case "/views" -> render(exchange, "Views", renderViews(exchange));
                case "/queries" -> render(exchange, "Queries", renderQueries(exchange));
                default -> send(exchange, 404, "Not found");
            }
        } catch (Exception ex) {
            String path = exchange.getRequestURI().getPath();
            Map<String, String> params = parseQuery(exchange.getRequestURI().getRawQuery());
            String html = Html.layout(
                "Error",
                path,
                "",
                ex.getMessage() == null ? "Unexpected error" : ex.getMessage(),
                "<div class=\"panel\"><h2>Request Failed</h2><p>Check the data and try again.</p></div>"
            );
            sendHtml(exchange, 500, html);
        }
    }

    private void render(HttpExchange exchange, String title, String body) throws IOException {
        Map<String, String> params = parseQuery(exchange.getRequestURI().getRawQuery());
        String html = Html.layout(
            title,
            exchange.getRequestURI().getPath(),
            params.getOrDefault("message", ""),
            params.getOrDefault("error", ""),
            body
        );
        sendHtml(exchange, 200, html);
    }

    private String renderDashboard(HttpExchange exchange) throws IOException, InterruptedException {
        String chains = db.queryScalar("SELECT COUNT(*) AS c FROM hotel_chain");
        String hotels = db.queryScalar("SELECT COUNT(*) AS c FROM hotel");
        String rooms = db.queryScalar("SELECT COUNT(*) AS c FROM room");
        String customers = db.queryScalar("SELECT COUNT(*) AS c FROM customer");
        String employees = db.queryScalar("SELECT COUNT(*) AS c FROM employee");
        String bookings = db.queryScalar("SELECT COUNT(*) AS c FROM booking");
        String rentings = db.queryScalar("SELECT COUNT(*) AS c FROM renting");
        String archivedBookings = db.queryScalar("SELECT COUNT(*) AS c FROM booking_archive");
        String archivedRentings = db.queryScalar("SELECT COUNT(*) AS c FROM renting_archive");

        return """
            <div class="metrics">
              %s
              %s
              %s
              %s
              %s
              %s
              %s
              %s
              %s
            </div>
            <div class="grid">
              <section class="panel">
                <h2>Quick Links</h2>
                <div class="stack">
                  <a href="/search">Search available rooms and create a booking or direct renting</a>
                  <a href="/operations">Convert a booking into a renting and insert payments</a>
                  <a href="/views">Display the two required SQL views</a>
                  <a href="/queries">Display the four deliverable queries</a>
                </div>
              </section>
            </div>
            """.formatted(
                metric("Hotel chains", chains),
                metric("Hotels", hotels),
                metric("Rooms", rooms),
                metric("Customers", customers),
                metric("Employees", employees),
                metric("Active bookings", bookings),
                metric("Active rentings", rentings),
                metric("Archived bookings", archivedBookings),
                metric("Archived rentings", archivedRentings)
            );
    }

    private String renderSearch(HttpExchange exchange) throws IOException, InterruptedException {
        Map<String, String> params = parseQuery(exchange.getRequestURI().getRawQuery());
        boolean firstLoad = params.isEmpty();
        String actor = params.getOrDefault("actor", "customer");
        if (!"employee".equals(actor)) {
            actor = "customer";
        }

        String startDate = params.getOrDefault("startDate", firstLoad ? LocalDate.now().toString() : "");
        String endDate = params.getOrDefault("endDate", firstLoad ? LocalDate.now().plusDays(1).toString() : "");
        String capacity = params.getOrDefault("capacity", "");
        String area = params.getOrDefault("area", "");
        String chain = params.getOrDefault("chain", "");
        String stars = params.getOrDefault("stars", "");
        String minRooms = params.getOrDefault("minRooms", "");
        String maxPrice = params.getOrDefault("maxPrice", "");
        String searchWarning = "";
        String searchError = "";

        Database.TableResult chains = db.query("SELECT name, name AS label FROM hotel_chain ORDER BY name");
        Database.TableResult areas = db.query("SELECT DISTINCT hotel_area(address) AS area, hotel_area(address) AS label FROM hotel ORDER BY area");
        Database.TableResult customers = db.query("""
            SELECT
                full_name || '||' || address AS customer_key,
                full_name || ' - ' || address AS label
            FROM customer
            ORDER BY full_name, address
            """);
        Database.TableResult employees = db.query("""
            SELECT
                sin AS employee_key,
                sin || ' - ' || full_name AS label
            FROM employee
            ORDER BY full_name
            """);

        boolean hasStartDate = !isBlank(startDate);
        boolean hasEndDate = !isBlank(endDate);
        boolean validDateRange = false;
        boolean canRunSearch = true;

        if (hasStartDate && hasEndDate) {
            LocalDate parsedStart = LocalDate.parse(startDate);
            LocalDate parsedEnd = LocalDate.parse(endDate);
            if (!parsedStart.isBefore(parsedEnd)) {
                searchError = "End date must be after start date.";
                canRunSearch = false;
            } else {
                validDateRange = true;
            }
        } else if (hasStartDate || hasEndDate) {
            searchWarning = "Choose both start and end dates to search by date range. Until then, the page shows rooms that are currently available now.";
        } else {
            searchWarning = "No dates selected. The page is showing rooms that are currently available now. Choose both dates before creating a booking or renting.";
        }

        if (!isBlank(minRooms)) {
            try {
                int minRoomsValue = Integer.parseInt(minRooms);
                if (minRoomsValue > 5) {
                    searchWarning = joinMessages(searchWarning, "In this seeded dataset each hotel has exactly 5 rooms, so a minimum total rooms value above 5 will always return no results.");
                }
            } catch (NumberFormatException ex) {
                searchError = joinMessages(searchError, "Minimum total rooms must be a whole number.");
                canRunSearch = false;
            }
        }

        if (!isBlank(capacity)) {
            try {
                Integer.parseInt(capacity);
            } catch (NumberFormatException ex) {
                searchError = joinMessages(searchError, "Minimum capacity must be a whole number.");
                canRunSearch = false;
            }
        }

        if (!isBlank(maxPrice)) {
            try {
                Double.parseDouble(maxPrice);
            } catch (NumberFormatException ex) {
                searchError = joinMessages(searchError, "Maximum room price must be numeric.");
                canRunSearch = false;
            }
        }

        Database.TableResult results = new Database.TableResult(List.of(), List.of());
        if (canRunSearch) {
            String searchSql = """
                SELECT *
                FROM search_available_rooms(
                    %s,
                    %s,
                    %s,
                    %s,
                    %s,
                    %s,
                    %s,
                    %s
                )
                """.formatted(
                sqlDate(startDate),
                sqlDate(endDate),
                sqlInt(capacity),
                sqlText(area),
                sqlText(chain),
                sqlInt(stars),
                sqlInt(minRooms),
                sqlNumeric(maxPrice)
            );
            results = db.query(searchSql);
        }

        StringBuilder resultsHtml = new StringBuilder();
        if (!isBlank(searchError)) {
            resultsHtml.append("<div class=\"flash bad\">").append(Html.escape(searchError)).append("</div>");
        } else if (results.rows().isEmpty()) {
            resultsHtml.append("<div class=\"flash bad\">No rooms match the current criteria.</div>");
            resultsHtml.append("""
                <div class="stack">
                  <p class="hint">Try one of these fixes:</p>
                  <p class="hint">1. Start with dates only, then add one filter at a time.</p>
                  <p class="hint">2. Clear either the area or the hotel chain if both are selected.</p>
                  <p class="hint">3. Increase the maximum price or reduce the minimum capacity.</p>
                  <p class="hint">4. Keep minimum total rooms at 5 or less in this dataset.</p>
                </div>
                """);
        } else {
            resultsHtml.append("<p><strong>")
                .append(results.rows().size())
                .append("</strong> rooms found.</p>");
            resultsHtml.append("<div class=\"table-wrap\"><table><thead><tr>")
                .append("<th>Hotel chain</th><th>Hotel</th><th>Area</th><th>Stars</th><th>Room</th><th>Capacity</th><th>Price</th><th>Available now</th><th>Amenities</th><th>Action</th>")
                .append("</tr></thead><tbody>");
            String redirect = exchange.getRequestURI().toString();
            for (Map<String, String> row : results.rows()) {
                resultsHtml.append("<tr>")
                    .append("<td>").append(Html.escape(row.get("hotel_chain_name"))).append("</td>")
                    .append("<td>").append(Html.escape(row.get("hotel_address"))).append("</td>")
                    .append("<td>").append(Html.escape(row.get("area"))).append("</td>")
                    .append("<td>").append(Html.escape(row.get("stars"))).append("</td>")
                    .append("<td>#").append(Html.escape(row.get("room_id"))).append(" (").append(Html.escape(row.get("view_type"))).append(")").append("</td>")
                    .append("<td>").append(Html.escape(row.get("capacity"))).append(" + ").append(Html.escape(row.get("extendable_by"))).append("</td>")
                    .append("<td>$").append(Html.escape(row.get("price"))).append("</td>")
                    .append("<td>").append("t".equalsIgnoreCase(row.get("currently_available")) ? "Yes" : "No").append("</td>")
                    .append("<td>").append(Html.escape(row.get("amenities"))).append("</td>")
                    .append("<td>");

                if (!validDateRange) {
                    resultsHtml.append("<span class=\"hint\">Choose both dates to enable booking or direct renting.</span>");
                } else if ("employee".equals(actor)) {
                    resultsHtml.append("""
                        <form class="inline-form" method="post" action="/actions/rent">
                          %s
                          %s
                          %s
                          %s
                          %s
                          %s
                          %s
                          %s
                          %s
                          %s
                          <label>Customer
                            <select name="customerKey">%s</select>
                          </label>
                          <label>Employee
                            <select name="employeeSin">%s</select>
                          </label>
                          <label>Pay now
                            <select name="payNow">
                              <option value="false">No</option>
                              <option value="true">Yes</option>
                            </select>
                          </label>
                          <label>Amount
                            <input name="paymentAmount" placeholder="Optional">
                          </label>
                          <label>Method
                            <input name="paymentMethod" value="card">
                          </label>
                          <button type="submit">Direct rent</button>
                        </form>
                        """.formatted(
                        Html.hidden("redirect", redirect),
                        Html.hidden("startDate", startDate),
                        Html.hidden("endDate", endDate),
                        Html.hidden("roomId", row.get("room_id")),
                        Html.hidden("hAddr", row.get("hotel_address")),
                        Html.hidden("hcAddr", row.get("hotel_chain_address")),
                        Html.hidden("hcName", row.get("hotel_chain_name")),
                        Html.hidden("actor", actor),
                        Html.hidden("capacity", capacity),
                        Html.hidden("maxPrice", maxPrice),
                        Html.options(customers.rows(), "customer_key", "label", "", false),
                        Html.options(employees.rows(), "employee_key", "label", "", false)
                    ));
                } else {
                    resultsHtml.append("""
                        <form class="inline-form" method="post" action="/actions/book">
                          %s
                          %s
                          %s
                          %s
                          %s
                          %s
                          %s
                          <label>Customer
                            <select name="customerKey">%s</select>
                          </label>
                          <button type="submit">Book</button>
                        </form>
                        """.formatted(
                        Html.hidden("redirect", redirect),
                        Html.hidden("startDate", startDate),
                        Html.hidden("endDate", endDate),
                        Html.hidden("roomId", row.get("room_id")),
                        Html.hidden("hAddr", row.get("hotel_address")),
                        Html.hidden("hcAddr", row.get("hotel_chain_address")),
                        Html.hidden("hcName", row.get("hotel_chain_name")),
                        Html.options(customers.rows(), "customer_key", "label", "", false)
                    ));
                }

                resultsHtml.append("</td></tr>");
            }
            resultsHtml.append("</tbody></table></div>");
        }

        return """
            <div class="grid">
              <section class="panel">
                <div class="section-title">
                  <h2>Room Search</h2>
                  <p class="hint">Changing any filter refreshes the results.</p>
                </div>
                <div class="stack">
                  <p class="hint">How to search: start with the date range only, confirm that results appear, then narrow by area, chain, stars, capacity, or price.</p>
                  <p class="hint">Edge cases: end date must be after start date, and in this dataset every hotel has 5 rooms so minimum total rooms above 5 returns nothing.</p>
                  <p class="hint">Quick examples:
                    <a href="/search?actor=customer&startDate=%s&endDate=%s">today and tomorrow</a>,
                    <a href="/search?actor=customer&startDate=2026-05-10&endDate=2026-05-14&area=Downtown+Toronto">Downtown Toronto</a>,
                    <a href="/search?actor=customer&startDate=2026-05-10&endDate=2026-05-14&chain=Marriott+International&stars=5">Marriott 5-star</a>
                  </p>
                </div>
                %s
                <form method="get" action="/search" data-autosubmit>
                  <div class="grid">
                    <label>User type
                      <select name="actor">
                        <option value="customer"%s>Customer</option>
                        <option value="employee"%s>Employee</option>
                      </select>
                    </label>
                    <label>Start date
                      <input type="date" name="startDate" value="%s">
                    </label>
                    <label>End date
                      <input type="date" name="endDate" value="%s">
                    </label>
                    <label>Minimum capacity
                      <input type="number" min="1" name="capacity" value="%s">
                    </label>
                    <label>Area
                      <select name="area">%s</select>
                    </label>
                    <label>Hotel chain
                      <select name="chain">%s</select>
                    </label>
                    <label>Hotel category
                      <select name="stars">
                        <option value=""></option>
                        <option value="1"%s>1-star</option>
                        <option value="2"%s>2-star</option>
                        <option value="3"%s>3-star</option>
                        <option value="4"%s>4-star</option>
                        <option value="5"%s>5-star</option>
                      </select>
                    </label>
                    <label>Minimum total rooms in hotel
                      <input type="number" min="1" name="minRooms" value="%s">
                    </label>
                    <label>Maximum room price
                      <input type="number" min="0" step="0.01" name="maxPrice" value="%s">
                    </label>
                  </div>
                  <div class="inline-form">
                    <button type="submit">Refresh results</button>
                    <a href="/search">Reset filters</a>
                  </div>
                </form>
              </section>
              <section class="panel">
                <h2>Results</h2>
                <p>Customer mode creates bookings. Employee mode creates direct rentings. Booking and renting buttons appear only when both dates are set.</p>
                %s
              </section>
            </div>
            """.formatted(
            LocalDate.now().toString(),
            LocalDate.now().plusDays(1).toString(),
            isBlank(searchWarning) ? "" : "<div class=\"flash ok\">" + Html.escape(searchWarning) + "</div>",
            actor.equals("customer") ? " selected" : "",
            actor.equals("employee") ? " selected" : "",
            Html.escapeAttribute(startDate),
            Html.escapeAttribute(endDate),
            Html.escapeAttribute(capacity),
            Html.options(areas.rows(), "area", "label", area, true),
            Html.options(chains.rows(), "name", "label", chain, true),
            selected(stars, "1"),
            selected(stars, "2"),
            selected(stars, "3"),
            selected(stars, "4"),
            selected(stars, "5"),
            Html.escapeAttribute(minRooms),
            Html.escapeAttribute(maxPrice),
            resultsHtml.toString()
        );
    }

    private String renderCustomers(HttpExchange exchange) throws IOException, InterruptedException {
        Database.TableResult customers = db.query("""
            SELECT
                full_name,
                address,
                registration_date,
                full_name || '||' || address AS customer_key,
                full_name || ' - ' || address AS label
            FROM customer
            ORDER BY full_name, address
            """);

        Database.TableResult customerTable = db.query("""
            SELECT full_name, address, registration_date
            FROM customer
            ORDER BY full_name, address
            """);

        return """
            <div class="grid">
              <section class="panel">
                <h2>Customers</h2>
                %s
              </section>
              <section class="panel stack">
                <div>
                  <h2>Add customer</h2>
                  <form method="post" action="/actions/add-customer">
                    %s
                    <label>Full name<input name="fullName" required></label>
                    <label>Address<input name="address" required></label>
                    <label>Registration date<input type="date" name="registrationDate" required></label>
                    <button type="submit">Insert customer</button>
                  </form>
                </div>
                <div>
                  <h2>Update customer</h2>
                  <form method="post" action="/actions/update-customer">
                    %s
                    <label>Existing customer
                      <select name="customerKey">%s</select>
                    </label>
                    <label>New full name<input name="fullName" required></label>
                    <label>New address<input name="address" required></label>
                    <label>New registration date<input type="date" name="registrationDate" required></label>
                    <button type="submit">Update customer</button>
                  </form>
                </div>
                <div>
                  <h2>Delete customer</h2>
                  <form method="post" action="/actions/delete-customer">
                    %s
                    <label>Customer
                      <select name="customerKey">%s</select>
                    </label>
                    <button type="submit">Delete customer</button>
                  </form>
                </div>
              </section>
            </div>
            """.formatted(
            Html.table(customerTable),
            Html.hidden("redirect", "/customers"),
            Html.hidden("redirect", "/customers"),
            Html.options(customers.rows(), "customer_key", "label", "", false),
            Html.hidden("redirect", "/customers"),
            Html.options(customers.rows(), "customer_key", "label", "", false)
        );
    }

    private String renderEmployees(HttpExchange exchange) throws IOException, InterruptedException {
        Database.TableResult employeeOptions = db.query("""
            SELECT
                sin AS employee_key,
                sin || ' - ' || full_name AS label
            FROM employee
            ORDER BY full_name
            """);
        Database.TableResult employees = db.query("""
            SELECT
                e.sin,
                e.full_name,
                e.address,
                COALESCE(string_agg(er.role_name, ', ' ORDER BY er.role_name), '') AS roles
            FROM employee e
            LEFT JOIN employee_role er ON er.e_sin = e.sin
            GROUP BY e.sin, e.full_name, e.address
            ORDER BY e.full_name, e.sin
            """);

        return """
            <div class="grid">
              <section class="panel">
                <h2>Employees</h2>
                %s
              </section>
              <section class="panel stack">
                <div>
                  <h2>Add employee</h2>
                  <form method="post" action="/actions/add-employee">
                    %s
                    <label>SIN<input name="sin" required></label>
                    <label>Full name<input name="fullName" required></label>
                    <label>Address<input name="address" required></label>
                    <label>Initial role<input name="roleName" required></label>
                    <button type="submit">Insert employee</button>
                  </form>
                </div>
                <div>
                  <h2>Add role</h2>
                  <form method="post" action="/actions/add-role">
                    %s
                    <label>Employee
                      <select name="employeeSin">%s</select>
                    </label>
                    <label>Role<input name="roleName" required></label>
                    <button type="submit">Insert role</button>
                  </form>
                </div>
                <div>
                  <h2>Update employee</h2>
                  <form method="post" action="/actions/update-employee">
                    %s
                    <label>Employee
                      <select name="employeeSin">%s</select>
                    </label>
                    <label>New full name<input name="fullName" required></label>
                    <label>New address<input name="address" required></label>
                    <button type="submit">Update employee</button>
                  </form>
                </div>
                <div>
                  <h2>Delete employee</h2>
                  <form method="post" action="/actions/delete-employee">
                    %s
                    <label>Employee
                      <select name="employeeSin">%s</select>
                    </label>
                    <button type="submit">Delete employee</button>
                  </form>
                </div>
              </section>
            </div>
            """.formatted(
            Html.table(employees),
            Html.hidden("redirect", "/employees"),
            Html.hidden("redirect", "/employees"),
            Html.options(employeeOptions.rows(), "employee_key", "label", "", false),
            Html.hidden("redirect", "/employees"),
            Html.options(employeeOptions.rows(), "employee_key", "label", "", false),
            Html.hidden("redirect", "/employees"),
            Html.options(employeeOptions.rows(), "employee_key", "label", "", false)
        );
    }

    private String renderHotels(HttpExchange exchange) throws IOException, InterruptedException {
        Database.TableResult hotelOptions = db.query("""
            SELECT
                hc_name || '||' || hc_address || '||' || address AS hotel_key,
                hc_name || ' - ' || address AS label
            FROM hotel
            ORDER BY hc_name, address
            """);
        Database.TableResult chainOptions = db.query("""
            SELECT
                name || '||' || address AS chain_key,
                name || ' - ' || address AS label
            FROM hotel_chain
            ORDER BY name
            """);
        Database.TableResult hotels = db.query("""
            SELECT
                h.hc_name,
                hotel_area(h.address) AS area,
                h.address,
                h.stars,
                COALESCE(e.full_name, '') AS manager_name,
                COALESCE(room_counts.total_rooms, 0) AS total_rooms
            FROM hotel h
            LEFT JOIN hotel_manager hm
              ON hm.hc_name = h.hc_name
             AND hm.hc_addr = h.hc_address
             AND hm.h_addr = h.address
            LEFT JOIN employee e
              ON e.sin = hm.e_sin
            LEFT JOIN (
                SELECT hc_name, hc_address, h_address, COUNT(*) AS total_rooms
                FROM room
                GROUP BY hc_name, hc_address, h_address
            ) room_counts
              ON room_counts.hc_name = h.hc_name
             AND room_counts.hc_address = h.hc_address
             AND room_counts.h_address = h.address
            ORDER BY h.hc_name, h.address
            """);

        return """
            <div class="grid">
              <section class="panel">
                <h2>Hotels</h2>
                %s
              </section>
              <section class="panel stack">
                <div>
                  <h2>Add hotel with initial manager</h2>
                  <form method="post" action="/actions/add-hotel">
                    %s
                    <label>Hotel chain
                      <select name="chainKey">%s</select>
                    </label>
                    <label>Hotel address<input name="hotelAddress" required></label>
                    <label>Stars<input type="number" min="1" max="5" name="stars" required></label>
                    <label>Manager SIN<input name="managerSin" required></label>
                    <label>Manager full name<input name="managerName" required></label>
                    <label>Manager address<input name="managerAddress" required></label>
                    <label>Manager role<input name="managerRole" value="general manager" required></label>
                    <button type="submit">Insert hotel</button>
                  </form>
                </div>
                <div>
                  <h2>Update hotel</h2>
                  <form method="post" action="/actions/update-hotel">
                    %s
                    <label>Hotel
                      <select name="hotelKey">%s</select>
                    </label>
                    <label>New hotel address<input name="hotelAddress" required></label>
                    <label>New stars<input type="number" min="1" max="5" name="stars" required></label>
                    <button type="submit">Update hotel</button>
                  </form>
                </div>
                <div>
                  <h2>Delete hotel</h2>
                  <form method="post" action="/actions/delete-hotel">
                    %s
                    <label>Hotel
                      <select name="hotelKey">%s</select>
                    </label>
                    <button type="submit">Delete hotel</button>
                  </form>
                </div>
              </section>
            </div>
            """.formatted(
            Html.table(hotels),
            Html.hidden("redirect", "/hotels"),
            Html.options(chainOptions.rows(), "chain_key", "label", "", false),
            Html.hidden("redirect", "/hotels"),
            Html.options(hotelOptions.rows(), "hotel_key", "label", "", false),
            Html.hidden("redirect", "/hotels"),
            Html.options(hotelOptions.rows(), "hotel_key", "label", "", false)
        );
    }

    private String renderRooms(HttpExchange exchange) throws IOException, InterruptedException {
        Database.TableResult hotelOptions = db.query("""
            SELECT
                hc_name || '||' || hc_address || '||' || address AS hotel_key,
                hc_name || ' - ' || address AS label
            FROM hotel
            ORDER BY hc_name, address
            """);
        Database.TableResult roomOptions = db.query("""
            SELECT
                hc_name || '||' || hc_address || '||' || h_address || '||' || id AS room_key,
                hc_name || ' - ' || h_address || ' - room #' || id AS label
            FROM room
            ORDER BY hc_name, h_address, id
            """);
        Database.TableResult rooms = db.query("""
            SELECT
                r.hc_name,
                hotel_area(r.h_address) AS area,
                r.h_address,
                r.id AS room_id,
                r.capacity,
                r.extendable_by,
                r.price,
                r.view_type,
                r.is_available,
                COALESCE(am.amenities, '') AS amenities,
                COALESCE(pr.problems, '') AS problems
            FROM room r
            LEFT JOIN (
                SELECT hc_name, hc_addr, h_addr, r_id, string_agg(amenity_desc, ', ' ORDER BY amenity_desc) AS amenities
                FROM room_amenity
                GROUP BY hc_name, hc_addr, h_addr, r_id
            ) am
              ON am.hc_name = r.hc_name
             AND am.hc_addr = r.hc_address
             AND am.h_addr = r.h_address
             AND am.r_id = r.id
            LEFT JOIN (
                SELECT hc_name, hc_addr, h_addr, r_id, string_agg(problem_desc, ', ' ORDER BY problem_desc) AS problems
                FROM room_problem
                GROUP BY hc_name, hc_addr, h_addr, r_id
            ) pr
              ON pr.hc_name = r.hc_name
             AND pr.hc_addr = r.hc_address
             AND pr.h_addr = r.h_address
             AND pr.r_id = r.id
            ORDER BY r.hc_name, r.h_address, r.id
            """);

        return """
            <div class="grid">
              <section class="panel">
                <h2>Rooms</h2>
                %s
              </section>
              <section class="panel stack">
                <div>
                  <h2>Add room</h2>
                  <form method="post" action="/actions/add-room">
                    %s
                    <label>Hotel
                      <select name="hotelKey">%s</select>
                    </label>
                    <label>Room ID<input type="number" min="1" name="roomId" required></label>
                    <label>Capacity<input type="number" min="1" name="capacity" required></label>
                    <label>Extendable by<input type="number" min="0" name="extendableBy" value="0" required></label>
                    <label>Price<input type="number" min="0" step="0.01" name="price" required></label>
                    <label>View
                      <select name="viewType">
                        <option value="none">none</option>
                        <option value="sea">sea</option>
                        <option value="mountain">mountain</option>
                      </select>
                    </label>
                    <label>Amenities (comma separated)<input name="amenities"></label>
                    <label>Problems (comma separated)<input name="problems"></label>
                    <button type="submit">Insert room</button>
                  </form>
                </div>
                <div>
                  <h2>Update room</h2>
                  <form method="post" action="/actions/update-room">
                    %s
                    <label>Room
                      <select name="roomKey">%s</select>
                    </label>
                    <label>Capacity<input type="number" min="1" name="capacity" required></label>
                    <label>Extendable by<input type="number" min="0" name="extendableBy" required></label>
                    <label>Price<input type="number" min="0" step="0.01" name="price" required></label>
                    <label>View
                      <select name="viewType">
                        <option value="none">none</option>
                        <option value="sea">sea</option>
                        <option value="mountain">mountain</option>
                      </select>
                    </label>
                    <button type="submit">Update room</button>
                  </form>
                </div>
                <div>
                  <h2>Replace room amenities</h2>
                  <form method="post" action="/actions/update-amenities">
                    %s
                    <label>Room
                      <select name="roomKey">%s</select>
                    </label>
                    <label>Amenities (comma separated)<input name="amenities"></label>
                    <button type="submit">Replace amenities</button>
                  </form>
                </div>
                <div>
                  <h2>Replace room problems</h2>
                  <form method="post" action="/actions/update-problems">
                    %s
                    <label>Room
                      <select name="roomKey">%s</select>
                    </label>
                    <label>Problems (comma separated)<input name="problems"></label>
                    <button type="submit">Replace problems</button>
                  </form>
                </div>
                <div>
                  <h2>Delete room</h2>
                  <form method="post" action="/actions/delete-room">
                    %s
                    <label>Room
                      <select name="roomKey">%s</select>
                    </label>
                    <button type="submit">Delete room</button>
                  </form>
                </div>
              </section>
            </div>
            """.formatted(
            Html.table(rooms),
            Html.hidden("redirect", "/rooms"),
            Html.options(hotelOptions.rows(), "hotel_key", "label", "", false),
            Html.hidden("redirect", "/rooms"),
            Html.options(roomOptions.rows(), "room_key", "label", "", false),
            Html.hidden("redirect", "/rooms"),
            Html.options(roomOptions.rows(), "room_key", "label", "", false),
            Html.hidden("redirect", "/rooms"),
            Html.options(roomOptions.rows(), "room_key", "label", "", false),
            Html.hidden("redirect", "/rooms"),
            Html.options(roomOptions.rows(), "room_key", "label", "", false)
        );
    }

    private String renderOperations(HttpExchange exchange) throws IOException, InterruptedException {
        Database.TableResult employeeOptions = db.query("""
            SELECT
                sin AS employee_key,
                sin || ' - ' || full_name AS label
            FROM employee
            ORDER BY full_name
            """);
        Database.TableResult bookings = db.query("""
            SELECT
                id,
                c_name,
                hc_name,
                h_addr,
                r_id,
                start_date,
                end_date,
                COALESCE(created_by, '') AS created_by
            FROM booking
            ORDER BY start_date, id
            """);
        Database.TableResult rentings = db.query("""
            SELECT
                rt.id,
                rt.c_name,
                rt.hc_name,
                rt.h_addr,
                rt.r_id,
                rt.start_date,
                rt.end_date,
                rt.is_paid,
                COALESCE(SUM(p.amount), 0.00) AS paid_amount
            FROM renting rt
            LEFT JOIN payment p ON p.renting_id = rt.id
            GROUP BY rt.id, rt.c_name, rt.hc_name, rt.h_addr, rt.r_id, rt.start_date, rt.end_date, rt.is_paid
            ORDER BY rt.start_date, rt.id
            """);

        StringBuilder bookingHtml = new StringBuilder();
        if (bookings.rows().isEmpty()) {
            bookingHtml.append("<p class=\"hint\">There are no active bookings to convert.</p>");
        } else {
            bookingHtml.append("<div class=\"table-wrap ops-wrap\"><table class=\"ops-table\"><thead><tr><th>Booking</th><th>Customer</th><th>Room</th><th>Dates</th><th>Action</th></tr></thead><tbody>");
            for (Map<String, String> row : bookings.rows()) {
                bookingHtml.append("<tr>")
                    .append("<td>").append(Html.escape(row.get("id"))).append("</td>")
                    .append("<td>").append(Html.escape(row.get("c_name"))).append("</td>")
                    .append("<td><div class=\"cell-stack\"><strong>")
                    .append(Html.escape(row.get("hc_name")))
                    .append("</strong><span>")
                    .append(Html.escape(row.get("h_addr")))
                    .append("</span><span>Room #")
                    .append(Html.escape(row.get("r_id")))
                    .append("</span></div></td>")
                    .append("<td><div class=\"cell-stack\"><span>")
                    .append(Html.escape(row.get("start_date")))
                    .append("</span><span>to</span><span>")
                    .append(Html.escape(row.get("end_date")))
                    .append("</span></div></td>")
                    .append("<td class=\"action-cell\">")
                    .append("""
                        <form class="inline-form action-form" method="post" action="/actions/convert-booking">
                          %s
                          %s
                          <label>Employee
                            <select name="employeeSin">%s</select>
                          </label>
                          <label>Pay now
                            <select name="payNow">
                              <option value="false">No</option>
                              <option value="true">Yes</option>
                            </select>
                          </label>
                          <label>Amount
                            <input name="paymentAmount" placeholder="Optional">
                          </label>
                          <label>Method
                            <input name="paymentMethod" value="card">
                          </label>
                          <button type="submit">Convert to renting</button>
                        </form>
                        """.formatted(
                        Html.hidden("redirect", "/operations"),
                          Html.hidden("bookingId", row.get("id")),
                          Html.options(employeeOptions.rows(), "employee_key", "label", "", false)
                      ))
                      .append("</td></tr>");
            }
            bookingHtml.append("</tbody></table></div>");
        }

        StringBuilder rentingHtml = new StringBuilder();
        if (rentings.rows().isEmpty()) {
            rentingHtml.append("<p class=\"hint\">There are no active rentings.</p>");
        } else {
            rentingHtml.append("<div class=\"table-wrap ops-wrap\"><table class=\"ops-table\"><thead><tr><th>Renting</th><th>Customer</th><th>Room</th><th>Dates</th><th>Paid</th><th>Action</th></tr></thead><tbody>");
            for (Map<String, String> row : rentings.rows()) {
                rentingHtml.append("<tr>")
                    .append("<td>").append(Html.escape(row.get("id"))).append("</td>")
                    .append("<td>").append(Html.escape(row.get("c_name"))).append("</td>")
                    .append("<td><div class=\"cell-stack\"><strong>")
                    .append(Html.escape(row.get("hc_name")))
                    .append("</strong><span>")
                    .append(Html.escape(row.get("h_addr")))
                    .append("</span><span>Room #")
                    .append(Html.escape(row.get("r_id")))
                    .append("</span></div></td>")
                    .append("<td><div class=\"cell-stack\"><span>")
                    .append(Html.escape(row.get("start_date")))
                    .append("</span><span>to</span><span>")
                    .append(Html.escape(row.get("end_date")))
                    .append("</span></div></td>")
                    .append("<td><div class=\"cell-stack\"><span>")
                    .append(Html.escape(row.get("paid_amount")))
                    .append("</span><span>Paid flag: ")
                    .append(Html.escape(row.get("is_paid")))
                    .append("</span></div></td>")
                    .append("<td class=\"action-cell\">")
                    .append("""
                        <form class="inline-form action-form" method="post" action="/actions/pay">
                          %s
                          %s
                          <label>Amount<input name="amount" required></label>
                          <label>Method<input name="paymentMethod" value="card" required></label>
                          <button type="submit">Insert payment</button>
                        </form>
                        """.formatted(
                          Html.hidden("redirect", "/operations"),
                          Html.hidden("rentingId", row.get("id"))
                      ))
                      .append("</td></tr>");
            }
            rentingHtml.append("</tbody></table></div>");
        }

        return """
            <div class="grid">
              <section class="panel">
                <div class="section-title">
                  <h2>Operations</h2>
                  <p class="hint">Check-ins and payments use the same clean layout as the search page.</p>
                </div>
                <div class="stack">
                  <p class="hint">Use this page when a customer arrives with an existing booking and an employee needs to convert that booking into a renting.</p>
                  <p class="hint">For walk-in customers without a booking, use <a href="/search?actor=employee">the employee search flow</a> to create a direct renting.</p>
                  <div class="subpanel">
                    <h3>Convert booking to renting</h3>
                    <p class="hint">The employee performing check-in is recorded as the creator of the renting.</p>
                    %s
                  </div>
                  <div class="subpanel">
                    <h3>Insert customer payment</h3>
                    <p class="hint">Add a payment to an active renting. This keeps the operations workflow separate from the room search page.</p>
                    %s
                  </div>
                </div>
              </section>
            </div>
            """.formatted(bookingHtml, rentingHtml);
    }

    private String renderViews(HttpExchange exchange) throws IOException, InterruptedException {
        Database.TableResult view1 = db.query("SELECT * FROM available_rooms_per_area");
        Database.TableResult view2 = db.query("SELECT * FROM hotel_aggregated_capacity");

        return """
            <div class="grid">
              <section class="panel">
                <h2>View 1: Available rooms per area</h2>
                %s
              </section>
              <section class="panel">
                <h2>View 2: Aggregated room capacity per hotel</h2>
                %s
              </section>
            </div>
            """.formatted(Html.table(view1), Html.table(view2));
    }

    private String renderQueries(HttpExchange exchange) throws IOException, InterruptedException {
        Database.TableResult query1 = db.query("""
            SELECT *
            FROM search_available_rooms(
                DATE '2026-05-10',
                DATE '2026-05-14',
                2,
                'Downtown Toronto',
                'Marriott International',
                5,
                5,
                250.00
            )
            """);
        Database.TableResult query2 = db.query("""
            SELECT
                r.hc_name,
                h.stars,
                COUNT(*) AS room_count,
                ROUND(AVG(r.price), 2) AS average_room_price
            FROM room r
            JOIN hotel h
              ON h.hc_name = r.hc_name
             AND h.hc_address = r.hc_address
             AND h.address = r.h_address
            GROUP BY r.hc_name, h.stars
            ORDER BY r.hc_name, h.stars DESC
            """);
        Database.TableResult query3 = db.query("""
            SELECT DISTINCT customer_name, stay_type
            FROM (
                SELECT b.c_name AS customer_name, 'booking' AS stay_type, h.stars
                FROM booking b
                JOIN hotel h
                  ON h.hc_name = b.hc_name
                 AND h.hc_address = b.hc_addr
                 AND h.address = b.h_addr
                UNION ALL
                SELECT r.c_name AS customer_name, 'renting' AS stay_type, h.stars
                FROM renting r
                JOIN hotel h
                  ON h.hc_name = r.hc_name
                 AND h.hc_address = r.hc_addr
                 AND h.address = r.h_addr
            ) AS stays
            WHERE stars = (SELECT MAX(stars) FROM hotel)
            ORDER BY customer_name, stay_type
            """);
        Database.TableResult query4 = db.query("""
            SELECT
                h.hc_name,
                h.address AS hotel_address,
                COUNT(DISTINCT rp.r_id) AS rooms_with_problems,
                e.full_name AS manager_name
            FROM hotel h
            JOIN hotel_manager hm
              ON hm.hc_name = h.hc_name
             AND hm.hc_addr = h.hc_address
             AND hm.h_addr = h.address
            JOIN employee e
              ON e.sin = hm.e_sin
            LEFT JOIN room_problem rp
              ON rp.hc_name = h.hc_name
             AND rp.hc_addr = h.hc_address
             AND rp.h_addr = h.address
            GROUP BY h.hc_name, h.address, e.full_name
            ORDER BY rooms_with_problems DESC, h.hc_name, h.address
            """);

        return """
            <div class="stack">
              <section class="panel">
                <h2>Query 1: Search with multiple criteria</h2>
                <p>This is the same search logic used by the customer and employee interface.</p>
                %s
              </section>
              <section class="panel">
                <h2>Query 2: Aggregation query</h2>
                <p>Average room price and room count per chain and hotel category.</p>
                %s
              </section>
              <section class="panel">
                <h2>Query 3: Nested query</h2>
                <p>Customers who have a booking or renting in a hotel with the maximum category.</p>
                %s
              </section>
              <section class="panel">
                <h2>Query 4: Manager and maintenance overview</h2>
                <p>Hotels with counts of rooms that currently have recorded problems.</p>
                %s
              </section>
            </div>
            """.formatted(
            Html.table(query1),
            Html.table(query2),
            Html.table(query3),
            Html.table(query4)
        );
    }

    private void handleAction(HttpExchange exchange, String path) throws IOException {
        try {
            Map<String, String> form = parseForm(exchange.getRequestBody());
            String redirectTarget = form.getOrDefault("redirect", "/dashboard");

            switch (path) {
                case "/actions/book" -> {
                    require(form, "startDate", "endDate", "roomId", "hAddr", "hcAddr", "hcName", "customerKey");
                    String[] customer = splitKey(form.get("customerKey"), 2);
                    db.queryScalar("""
                        SELECT create_booking(%s, %s, %s, %s, %s, %s, %s, %s, NULL)
                        """.formatted(
                        sqlDate(form.get("startDate")),
                        sqlDate(form.get("endDate")),
                        sqlInt(form.get("roomId")),
                        sqlText(form.get("hAddr")),
                        sqlText(form.get("hcAddr")),
                        sqlText(form.get("hcName")),
                        sqlText(customer[0]),
                        sqlText(customer[1])
                    ));
                    redirect(exchange, withMessage(redirectTarget, "message", "Booking created."));
                    return;
                }
                case "/actions/rent" -> {
                    require(form, "startDate", "endDate", "roomId", "hAddr", "hcAddr", "hcName", "customerKey", "employeeSin");
                    String[] customer = splitKey(form.get("customerKey"), 2);
                    db.queryScalar("""
                        SELECT create_renting(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                        """.formatted(
                        sqlDate(form.get("startDate")),
                        sqlDate(form.get("endDate")),
                        sqlInt(form.get("roomId")),
                        sqlText(form.get("hAddr")),
                        sqlText(form.get("hcAddr")),
                        sqlText(form.get("hcName")),
                        sqlText(customer[0]),
                        sqlText(customer[1]),
                        sqlText(form.get("employeeSin")),
                        sqlBoolean(form.getOrDefault("payNow", "false")),
                        sqlNumeric(form.get("paymentAmount")),
                        sqlText(blankToNull(form.get("paymentMethod")))
                    ));
                    redirect(exchange, withMessage(redirectTarget, "message", "Direct renting created."));
                    return;
                }
                case "/actions/convert-booking" -> {
                    require(form, "bookingId", "employeeSin");
                    db.queryScalar("""
                        SELECT convert_booking_to_renting(%s, %s, %s, %s, %s)
                        """.formatted(
                        sqlLong(form.get("bookingId")),
                        sqlText(form.get("employeeSin")),
                        sqlBoolean(form.getOrDefault("payNow", "false")),
                        sqlNumeric(form.get("paymentAmount")),
                        sqlText(blankToNull(form.get("paymentMethod")))
                    ));
                    redirect(exchange, withMessage(redirectTarget, "message", "Booking converted to renting."));
                    return;
                }
                case "/actions/pay" -> {
                    require(form, "rentingId", "amount", "paymentMethod");
                    db.queryScalar("""
                        SELECT record_payment(%s, %s, %s)
                        """.formatted(
                        sqlLong(form.get("rentingId")),
                        sqlNumeric(form.get("amount")),
                        sqlText(form.get("paymentMethod"))
                    ));
                    redirect(exchange, withMessage(redirectTarget, "message", "Payment inserted."));
                    return;
                }
                case "/actions/add-customer" -> {
                    require(form, "fullName", "address", "registrationDate");
                    db.execute("""
                        INSERT INTO customer (full_name, address, registration_date)
                        VALUES (%s, %s, %s);
                        """.formatted(
                        sqlText(form.get("fullName")),
                        sqlText(form.get("address")),
                        sqlDate(form.get("registrationDate"))
                    ));
                    redirect(exchange, withMessage(redirectTarget, "message", "Customer inserted."));
                    return;
                }
                case "/actions/update-customer" -> {
                    require(form, "customerKey", "fullName", "address", "registrationDate");
                    String[] customer = splitKey(form.get("customerKey"), 2);
                    db.execute("""
                        UPDATE customer
                        SET full_name = %s,
                            address = %s,
                            registration_date = %s
                        WHERE full_name = %s
                          AND address = %s;
                        """.formatted(
                        sqlText(form.get("fullName")),
                        sqlText(form.get("address")),
                        sqlDate(form.get("registrationDate")),
                        sqlText(customer[0]),
                        sqlText(customer[1])
                    ));
                    redirect(exchange, withMessage(redirectTarget, "message", "Customer updated."));
                    return;
                }
                case "/actions/delete-customer" -> {
                    require(form, "customerKey");
                    String[] customer = splitKey(form.get("customerKey"), 2);
                    db.execute("""
                        DELETE FROM customer
                        WHERE full_name = %s
                          AND address = %s;
                        """.formatted(sqlText(customer[0]), sqlText(customer[1])));
                    redirect(exchange, withMessage(redirectTarget, "message", "Customer deleted."));
                    return;
                }
                case "/actions/add-employee" -> {
                    require(form, "sin", "fullName", "address", "roleName");
                    db.execute("""
                        BEGIN;
                        INSERT INTO employee (sin, full_name, address)
                        VALUES (%s, %s, %s);
                        INSERT INTO employee_role (e_sin, role_name)
                        VALUES (%s, %s);
                        COMMIT;
                        """.formatted(
                        sqlText(form.get("sin")),
                        sqlText(form.get("fullName")),
                        sqlText(form.get("address")),
                        sqlText(form.get("sin")),
                        sqlText(form.get("roleName"))
                    ));
                    redirect(exchange, withMessage(redirectTarget, "message", "Employee inserted."));
                    return;
                }
                case "/actions/add-role" -> {
                    require(form, "employeeSin", "roleName");
                    db.execute("""
                        INSERT INTO employee_role (e_sin, role_name)
                        VALUES (%s, %s);
                        """.formatted(
                        sqlText(form.get("employeeSin")),
                        sqlText(form.get("roleName"))
                    ));
                    redirect(exchange, withMessage(redirectTarget, "message", "Role inserted."));
                    return;
                }
                case "/actions/update-employee" -> {
                    require(form, "employeeSin", "fullName", "address");
                    db.execute("""
                        UPDATE employee
                        SET full_name = %s,
                            address = %s
                        WHERE sin = %s;
                        """.formatted(
                        sqlText(form.get("fullName")),
                        sqlText(form.get("address")),
                        sqlText(form.get("employeeSin"))
                    ));
                    redirect(exchange, withMessage(redirectTarget, "message", "Employee updated."));
                    return;
                }
                case "/actions/delete-employee" -> {
                    require(form, "employeeSin");
                    db.execute("DELETE FROM employee WHERE sin = %s;".formatted(sqlText(form.get("employeeSin"))));
                    redirect(exchange, withMessage(redirectTarget, "message", "Employee deleted."));
                    return;
                }
                case "/actions/add-hotel" -> {
                    require(form, "chainKey", "hotelAddress", "stars", "managerSin", "managerName", "managerAddress", "managerRole");
                    String[] chain = splitKey(form.get("chainKey"), 2);
                    db.execute("""
                        SELECT create_hotel_with_manager(%s, %s, %s, %s, %s, %s, %s, %s);
                        """.formatted(
                        sqlText(chain[0]),
                        sqlText(chain[1]),
                        sqlText(form.get("hotelAddress")),
                        sqlInt(form.get("stars")),
                        sqlText(form.get("managerSin")),
                        sqlText(form.get("managerName")),
                        sqlText(form.get("managerAddress")),
                        sqlText(form.get("managerRole"))
                    ));
                    redirect(exchange, withMessage(redirectTarget, "message", "Hotel inserted."));
                    return;
                }
                case "/actions/update-hotel" -> {
                    require(form, "hotelKey", "hotelAddress", "stars");
                    String[] hotel = splitKey(form.get("hotelKey"), 3);
                    db.execute("""
                        UPDATE hotel
                        SET address = %s,
                            stars = %s
                        WHERE hc_name = %s
                          AND hc_address = %s
                          AND address = %s;
                        """.formatted(
                        sqlText(form.get("hotelAddress")),
                        sqlInt(form.get("stars")),
                        sqlText(hotel[0]),
                        sqlText(hotel[1]),
                        sqlText(hotel[2])
                    ));
                    redirect(exchange, withMessage(redirectTarget, "message", "Hotel updated."));
                    return;
                }
                case "/actions/delete-hotel" -> {
                    require(form, "hotelKey");
                    String[] hotel = splitKey(form.get("hotelKey"), 3);
                    db.execute("""
                        DELETE FROM hotel
                        WHERE hc_name = %s
                          AND hc_address = %s
                          AND address = %s;
                        """.formatted(
                        sqlText(hotel[0]),
                        sqlText(hotel[1]),
                        sqlText(hotel[2])
                    ));
                    redirect(exchange, withMessage(redirectTarget, "message", "Hotel deleted."));
                    return;
                }
                case "/actions/add-room" -> {
                    require(form, "hotelKey", "roomId", "capacity", "extendableBy", "price", "viewType");
                    String[] hotel = splitKey(form.get("hotelKey"), 3);
                    db.execute("""
                        BEGIN;
                        INSERT INTO room (id, h_address, hc_address, hc_name, price, extendable_by, view_type, capacity)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s);
                        %s
                        %s
                        COMMIT;
                        """.formatted(
                        sqlInt(form.get("roomId")),
                        sqlText(hotel[2]),
                        sqlText(hotel[1]),
                        sqlText(hotel[0]),
                        sqlNumeric(form.get("price")),
                        sqlInt(form.get("extendableBy")),
                        sqlText(form.get("viewType")),
                        sqlInt(form.get("capacity")),
                        insertListRows("room_amenity", "amenity_desc", splitCsv(form.get("amenities")), hotel, form.get("roomId")),
                        insertListRows("room_problem", "problem_desc", splitCsv(form.get("problems")), hotel, form.get("roomId"))
                    ));
                    redirect(exchange, withMessage(redirectTarget, "message", "Room inserted."));
                    return;
                }
                case "/actions/update-room" -> {
                    require(form, "roomKey", "capacity", "extendableBy", "price", "viewType");
                    String[] room = splitKey(form.get("roomKey"), 4);
                    db.execute("""
                        UPDATE room
                        SET capacity = %s,
                            extendable_by = %s,
                            price = %s,
                            view_type = %s
                        WHERE hc_name = %s
                          AND hc_address = %s
                          AND h_address = %s
                          AND id = %s;
                        """.formatted(
                        sqlInt(form.get("capacity")),
                        sqlInt(form.get("extendableBy")),
                        sqlNumeric(form.get("price")),
                        sqlText(form.get("viewType")),
                        sqlText(room[0]),
                        sqlText(room[1]),
                        sqlText(room[2]),
                        sqlInt(room[3])
                    ));
                    redirect(exchange, withMessage(redirectTarget, "message", "Room updated."));
                    return;
                }
                case "/actions/update-amenities" -> {
                    require(form, "roomKey");
                    String[] room = splitKey(form.get("roomKey"), 4);
                    db.execute("""
                        BEGIN;
                        DELETE FROM room_amenity
                        WHERE hc_name = %s AND hc_addr = %s AND h_addr = %s AND r_id = %s;
                        %s
                        COMMIT;
                        """.formatted(
                        sqlText(room[0]),
                        sqlText(room[1]),
                        sqlText(room[2]),
                        sqlInt(room[3]),
                        insertListRows("room_amenity", "amenity_desc", splitCsv(form.get("amenities")), new String[]{room[0], room[1], room[2]}, room[3])
                    ));
                    redirect(exchange, withMessage(redirectTarget, "message", "Amenities replaced."));
                    return;
                }
                case "/actions/update-problems" -> {
                    require(form, "roomKey");
                    String[] room = splitKey(form.get("roomKey"), 4);
                    db.execute("""
                        BEGIN;
                        DELETE FROM room_problem
                        WHERE hc_name = %s AND hc_addr = %s AND h_addr = %s AND r_id = %s;
                        %s
                        COMMIT;
                        """.formatted(
                        sqlText(room[0]),
                        sqlText(room[1]),
                        sqlText(room[2]),
                        sqlInt(room[3]),
                        insertListRows("room_problem", "problem_desc", splitCsv(form.get("problems")), new String[]{room[0], room[1], room[2]}, room[3])
                    ));
                    redirect(exchange, withMessage(redirectTarget, "message", "Problems replaced."));
                    return;
                }
                case "/actions/delete-room" -> {
                    require(form, "roomKey");
                    String[] room = splitKey(form.get("roomKey"), 4);
                    db.execute("""
                        DELETE FROM room
                        WHERE hc_name = %s
                          AND hc_address = %s
                          AND h_address = %s
                          AND id = %s;
                        """.formatted(
                        sqlText(room[0]),
                        sqlText(room[1]),
                        sqlText(room[2]),
                        sqlInt(room[3])
                    ));
                    redirect(exchange, withMessage(redirectTarget, "message", "Room deleted."));
                    return;
                }
                default -> {
                    redirect(exchange, withMessage(redirectTarget, "error", "Unknown action."));
                    return;
                }
            }
        } catch (Exception ex) {
            Map<String, String> form;
            try {
                form = parseForm(exchange.getRequestBody());
            } catch (Exception ignored) {
                form = Map.of();
            }
            String redirectTarget = form.getOrDefault("redirect", "/dashboard");
            redirect(exchange, withMessage(redirectTarget, "error", ex.getMessage() == null ? "Action failed." : ex.getMessage()));
        }
    }

    private String metric(String label, String value) {
        return "<div class=\"metric\"><span>" + Html.escape(label) + "</span><strong>" + Html.escape(value) + "</strong></div>";
    }

    private void send(HttpExchange exchange, int status, String text) throws IOException {
        byte[] bytes = text.getBytes(StandardCharsets.UTF_8);
        exchange.sendResponseHeaders(status, bytes.length);
        try (OutputStream output = exchange.getResponseBody()) {
            output.write(bytes);
        }
    }

    private void sendHtml(HttpExchange exchange, int status, String html) throws IOException {
        Headers headers = exchange.getResponseHeaders();
        headers.set("Content-Type", "text/html; charset=utf-8");
        send(exchange, status, html);
    }

    private void redirect(HttpExchange exchange, String location) throws IOException {
        exchange.getResponseHeaders().set("Location", location);
        exchange.sendResponseHeaders(303, -1);
        exchange.close();
    }

    private Map<String, String> parseQuery(String rawQuery) {
        Map<String, String> params = new LinkedHashMap<>();
        if (rawQuery == null || rawQuery.isBlank()) {
            return params;
        }
        for (String pair : rawQuery.split("&")) {
            if (pair.isBlank()) {
                continue;
            }
            String[] pieces = pair.split("=", 2);
            String key = urlDecode(pieces[0]);
            String value = pieces.length > 1 ? urlDecode(pieces[1]) : "";
            params.put(key, value);
        }
        return params;
    }

    private Map<String, String> parseForm(InputStream body) throws IOException {
        String content = new String(body.readAllBytes(), StandardCharsets.UTF_8);
        return parseQuery(content);
    }

    private String urlDecode(String value) {
        return URLDecoder.decode(value, StandardCharsets.UTF_8);
    }

    private String withMessage(String base, String key, String value) {
        String separator = base.contains("?") ? "&" : "?";
        return base + separator + key + "=" + Html.url(value);
    }

    private String selected(String current, String value) {
        return value.equals(current) ? " selected" : "";
    }

    private String joinMessages(String current, String next) {
        if (isBlank(current)) {
            return next;
        }
        return current + " " + next;
    }

    private void require(Map<String, String> form, String... keys) {
        for (String key : keys) {
            if (blankToNull(form.get(key)) == null) {
                throw new IllegalArgumentException("Missing field: " + key);
            }
        }
    }

    private String[] splitKey(String key, int expectedParts) {
        String[] parts = key.split("\\|\\|", -1);
        if (parts.length != expectedParts) {
            throw new IllegalArgumentException("Invalid key value.");
        }
        return parts;
    }

    private List<String> splitCsv(String raw) {
        if (raw == null || raw.isBlank()) {
            return List.of();
        }
        return Arrays.stream(raw.split(","))
            .map(String::trim)
            .filter(value -> !value.isBlank())
            .distinct()
            .toList();
    }

    private String insertListRows(String tableName, String descriptionColumn, List<String> items, String[] hotel, String roomId) {
        if (items.isEmpty()) {
            return "";
        }
        List<String> statements = new ArrayList<>();
        for (String item : items) {
            statements.add("""
                INSERT INTO %s (r_id, h_addr, hc_addr, hc_name, %s)
                VALUES (%s, %s, %s, %s, %s);
                """.formatted(
                tableName,
                descriptionColumn,
                sqlInt(roomId),
                sqlText(hotel[2]),
                sqlText(hotel[1]),
                sqlText(hotel[0]),
                sqlText(item)
            ));
        }
        return String.join("\n", statements);
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value;
    }

    private static boolean isBlank(String value) {
        return blankToNull(value) == null;
    }

    private static String sqlText(String value) {
        if (blankToNull(value) == null) {
            return "NULL";
        }
        return "'" + value.replace("'", "''") + "'";
    }

    private static String sqlDate(String value) {
        if (blankToNull(value) == null) {
            return "NULL";
        }
        LocalDate.parse(value);
        return sqlText(value);
    }

    private static String sqlInt(String value) {
        if (blankToNull(value) == null) {
            return "NULL";
        }
        return Integer.toString(Integer.parseInt(value));
    }

    private static String sqlLong(String value) {
        if (blankToNull(value) == null) {
            return "NULL";
        }
        return Long.toString(Long.parseLong(value));
    }

    private static String sqlNumeric(String value) {
        if (blankToNull(value) == null) {
            return "NULL";
        }
        return Double.toString(Double.parseDouble(value));
    }

    private static String sqlBoolean(String value) {
        if (blankToNull(value) == null) {
            return "FALSE";
        }
        return Boolean.parseBoolean(value) ? "TRUE" : "FALSE";
    }
}
