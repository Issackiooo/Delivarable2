import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

public class Html {
    public static String layout(String title, String activePath, String message, String error, String body) {
        return """
            <!doctype html>
            <html lang="en">
            <head>
              <meta charset="utf-8">
              <meta name="viewport" content="width=device-width, initial-scale=1">
              <title>%s</title>
              <style>
                :root {
                  --bg: #f6f1e8;
                  --panel: #fffaf2;
                  --ink: #1f2a1f;
                  --muted: #59645a;
                  --line: #d7cbb8;
                  --accent: #9a3412;
                  --accent-soft: #f7d7bf;
                  --ok: #2f6d4f;
                  --ok-bg: #e3f3e9;
                  --bad: #8a1c1c;
                  --bad-bg: #fde8e8;
                }
                * { box-sizing: border-box; }
                body {
                  margin: 0;
                  font-family: Georgia, "Times New Roman", serif;
                  color: var(--ink);
                  background:
                    radial-gradient(circle at top right, #f4d8b6 0, transparent 24rem),
                    linear-gradient(180deg, #f8f4ed 0%%, #f0e8db 100%%);
                }
                header {
                  border-bottom: 1px solid var(--line);
                  background: rgba(255, 250, 242, 0.88);
                  backdrop-filter: blur(8px);
                  position: sticky;
                  top: 0;
                  z-index: 10;
                }
                .shell {
                  width: min(1180px, calc(100%% - 2rem));
                  margin: 0 auto;
                }
                .topbar {
                  display: flex;
                  gap: 1rem;
                  align-items: center;
                  justify-content: space-between;
                  padding: 1rem 0;
                }
                h1, h2, h3 {
                  margin: 0 0 0.75rem;
                  font-weight: 600;
                  line-height: 1.1;
                }
                h1 { font-size: 1.8rem; }
                h2 { font-size: 1.25rem; }
                h3 { font-size: 1rem; }
                p { margin: 0 0 1rem; color: var(--muted); }
                nav {
                  display: flex;
                  flex-wrap: wrap;
                  gap: 0.5rem;
                }
                nav a {
                  text-decoration: none;
                  color: var(--ink);
                  padding: 0.45rem 0.7rem;
                  border: 1px solid var(--line);
                  border-radius: 999px;
                  background: #fff;
                }
                nav a.active {
                  background: var(--accent);
                  color: #fff;
                  border-color: var(--accent);
                }
                main {
                  padding: 1.25rem 0 2rem;
                }
                .flash {
                  padding: 0.85rem 1rem;
                  border-radius: 12px;
                  margin-bottom: 1rem;
                  border: 1px solid transparent;
                }
                .flash.ok {
                  background: var(--ok-bg);
                  color: var(--ok);
                  border-color: #b9dfc8;
                }
                .flash.bad {
                  background: var(--bad-bg);
                  color: var(--bad);
                  border-color: #efb9b9;
                }
                .grid {
                  display: grid;
                  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                  gap: 1rem;
                }
                .panel {
                  background: var(--panel);
                  border: 1px solid var(--line);
                  border-radius: 18px;
                  padding: 1rem;
                  min-width: 0;
                  box-shadow: 0 10px 30px rgba(63, 44, 20, 0.06);
                }
                .metrics {
                  display: grid;
                  grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
                  gap: 0.75rem;
                  margin-bottom: 1rem;
                }
                .metric {
                  padding: 0.9rem;
                  border-radius: 16px;
                  border: 1px solid var(--line);
                  background: linear-gradient(180deg, #fff, #fbf4ea);
                }
                .metric strong {
                  display: block;
                  font-size: 1.4rem;
                  color: var(--accent);
                }
                form {
                  display: grid;
                  gap: 0.75rem;
                }
                .inline-form {
                  display: flex;
                  gap: 0.5rem;
                  flex-wrap: wrap;
                  align-items: center;
                }
                .inline-form > * {
                  min-width: 0;
                }
                .inline-form label {
                  flex: 1 1 11rem;
                  min-width: min(11rem, 100%%);
                }
                .inline-form button {
                  flex: 0 0 auto;
                  align-self: end;
                }
                label {
                  display: grid;
                  gap: 0.35rem;
                  font-size: 0.95rem;
                  color: var(--ink);
                }
                input, select, button, textarea {
                  font: inherit;
                }
                input, select, textarea {
                  width: 100%%;
                  padding: 0.6rem 0.7rem;
                  border-radius: 10px;
                  border: 1px solid #cdbda8;
                  background: white;
                }
                button {
                  padding: 0.65rem 0.85rem;
                  border-radius: 10px;
                  border: 1px solid var(--accent);
                  background: var(--accent);
                  color: white;
                  cursor: pointer;
                }
                button.secondary {
                  background: white;
                  color: var(--accent);
                }
                table {
                  width: 100%%;
                  border-collapse: collapse;
                  font-size: 0.94rem;
                }
                .table-wrap {
                  width: 100%%;
                  display: block;
                  overflow-x: auto;
                  overflow-y: hidden;
                  -webkit-overflow-scrolling: touch;
                }
                .table-wrap table {
                  width: max-content;
                  min-width: 100%%;
                }
                th, td {
                  text-align: left;
                  padding: 0.65rem;
                  border-bottom: 1px solid #e2d6c5;
                  vertical-align: top;
                  white-space: nowrap;
                  word-break: normal;
                }
                th {
                  font-size: 0.82rem;
                  letter-spacing: 0.03em;
                  text-transform: uppercase;
                  color: var(--muted);
                }
                .stack {
                  display: grid;
                  gap: 1rem;
                }
                .hint {
                  font-size: 0.9rem;
                  color: var(--muted);
                }
                .section-title {
                  display: flex;
                  justify-content: space-between;
                  gap: 1rem;
                  align-items: baseline;
                }
                .subpanel {
                  padding: 1rem;
                  border: 1px solid #e2d6c5;
                  border-radius: 14px;
                  background: rgba(255, 255, 255, 0.75);
                  min-width: 0;
                }
                .table-wrap.ops-wrap table {
                  min-width: 980px;
                }
                .ops-table td,
                .ops-table th {
                  white-space: normal;
                }
                .cell-stack {
                  display: grid;
                  gap: 0.2rem;
                  min-width: 0;
                }
                .action-cell {
                  min-width: 20rem;
                }
                .action-form {
                  align-items: stretch;
                }
                .action-form label {
                  flex-basis: 10rem;
                }
                code {
                  background: #f6ead8;
                  padding: 0.1rem 0.3rem;
                  border-radius: 4px;
                }
                @media (max-width: 700px) {
                  .topbar {
                    align-items: flex-start;
                    flex-direction: column;
                  }
                  .inline-form {
                    flex-direction: column;
                    align-items: stretch;
                  }
                  .action-cell {
                    min-width: 0;
                  }
                  .table-wrap.ops-wrap table {
                    min-width: 720px;
                  }
                }
              </style>
            </head>
            <body>
              <header>
                <div class="shell topbar">
                  <div>
                    <h1>e-Hotels Deliverable 2</h1>
                  </div>
                  <nav>
                    %s
                  </nav>
                </div>
              </header>
              <main class="shell">
                %s
                %s
                %s
              </main>
              <script>
                document.querySelectorAll('[data-autosubmit] input, [data-autosubmit] select').forEach(function (el) {
                  el.addEventListener('change', function () {
                    if (el.form) el.form.submit();
                  });
                });
              </script>
            </body>
            </html>
            """.formatted(
                escape(title),
                nav(activePath),
                message.isBlank() ? "" : "<div class=\"flash ok\">" + escape(message) + "</div>",
                error.isBlank() ? "" : "<div class=\"flash bad\">" + escape(error) + "</div>",
                body
            );
    }

    public static String table(Database.TableResult table) {
        if (table.columns().isEmpty()) {
            return "<p class=\"hint\">No columns returned.</p>";
        }
        if (table.rows().isEmpty()) {
            return "<p class=\"hint\">No rows found.</p>";
        }

        StringBuilder html = new StringBuilder();
        html.append("<div class=\"table-wrap\"><table><thead><tr>");
        for (String column : table.columns()) {
            html.append("<th>").append(escape(column.replace('_', ' '))).append("</th>");
        }
        html.append("</tr></thead><tbody>");
        for (Map<String, String> row : table.rows()) {
            html.append("<tr>");
            for (String column : table.columns()) {
                html.append("<td>").append(escape(row.getOrDefault(column, ""))).append("</td>");
            }
            html.append("</tr>");
        }
        html.append("</tbody></table></div>");
        return html.toString();
    }

    public static String options(List<Map<String, String>> rows, String valueKey, String labelKey, String selected, boolean includeBlank) {
        StringBuilder html = new StringBuilder();
        if (includeBlank) {
            html.append("<option value=\"\"></option>");
        }
        for (Map<String, String> row : rows) {
            String value = row.getOrDefault(valueKey, "");
            String label = row.getOrDefault(labelKey, value);
            html.append("<option value=\"")
                .append(escapeAttribute(value))
                .append("\"");
            if (value.equals(selected)) {
                html.append(" selected");
            }
            html.append(">")
                .append(escape(label))
                .append("</option>");
        }
        return html.toString();
    }

    public static String hidden(String name, String value) {
        return "<input type=\"hidden\" name=\"" + escapeAttribute(name) + "\" value=\"" + escapeAttribute(value) + "\">";
    }

    public static String escape(String input) {
        return input == null ? "" : input
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;");
    }

    public static String escapeAttribute(String input) {
        return escape(input);
    }

    public static String url(String input) {
        return URLEncoder.encode(input, StandardCharsets.UTF_8);
    }

    private static String nav(String activePath) {
        List<String> items = List.of(
            link("/dashboard", "Dashboard", activePath),
            link("/search", "Search", activePath),
            link("/customers", "Customers", activePath),
            link("/employees", "Employees", activePath),
            link("/hotels", "Hotels", activePath),
            link("/rooms", "Rooms", activePath),
            link("/operations", "Operations", activePath),
            link("/views", "Views", activePath),
            link("/queries", "Queries", activePath)
        );
        return String.join("", items);
    }

    private static String link(String href, String label, String activePath) {
        String active = activePath.startsWith(href) ? " class=\"active\"" : "";
        return "<a href=\"" + href + "\"" + active + ">" + label + "</a>";
    }
}
