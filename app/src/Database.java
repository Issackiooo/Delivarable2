import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class Database {
    public record TableResult(List<String> columns, List<Map<String, String>> rows) {
    }

    private final String databaseName;

    public Database(String databaseName) {
        this.databaseName = databaseName;
    }

    public TableResult query(String selectSql) throws IOException, InterruptedException {
        String sql = stripTrailingSemicolon(selectSql);
        String copySql = "COPY (" + sql + ") TO STDOUT WITH (FORMAT csv, HEADER true);";
        String output = runPsql(copySql);
        return parseCsv(output);
    }

    public String queryScalar(String selectSql) throws IOException, InterruptedException {
        TableResult table = query(selectSql);
        if (table.rows().isEmpty() || table.columns().isEmpty()) {
            return "";
        }
        return table.rows().get(0).getOrDefault(table.columns().get(0), "");
    }

    public void execute(String sql) throws IOException, InterruptedException {
        runPsql(sql);
    }

    private String runPsql(String sql) throws IOException, InterruptedException {
        ProcessBuilder builder = new ProcessBuilder(
            "psql",
            "-X",
            "-v",
            "ON_ERROR_STOP=1",
            "-d",
            databaseName
        );
        Process process = builder.start();

        try (BufferedWriter writer = new BufferedWriter(
            new OutputStreamWriter(process.getOutputStream(), StandardCharsets.UTF_8))) {
            writer.write(sql);
            writer.write("\n");
        }

        String stdout;
        try (BufferedReader reader = new BufferedReader(
            new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8))) {
            stdout = reader.lines().reduce("", (left, right) -> left + right + "\n");
        }

        String stderr;
        try (BufferedReader reader = new BufferedReader(
            new InputStreamReader(process.getErrorStream(), StandardCharsets.UTF_8))) {
            stderr = reader.lines().reduce("", (left, right) -> left + right + "\n");
        }

        int exitCode = process.waitFor();
        if (exitCode != 0) {
            throw new IOException(stderr.isBlank() ? "psql command failed" : stderr.strip());
        }
        return stdout;
    }

    private TableResult parseCsv(String csv) {
        List<List<String>> rows = parseCsvRows(csv);
        if (rows.isEmpty()) {
            return new TableResult(List.of(), List.of());
        }

        List<String> columns = rows.get(0);
        List<Map<String, String>> mappedRows = new ArrayList<>();
        for (int i = 1; i < rows.size(); i++) {
            List<String> rawRow = rows.get(i);
            if (rawRow.size() == 1 && rawRow.get(0).isBlank() && columns.size() > 1) {
                continue;
            }

            Map<String, String> row = new LinkedHashMap<>();
            for (int c = 0; c < columns.size(); c++) {
                String value = c < rawRow.size() ? rawRow.get(c) : "";
                row.put(columns.get(c), value);
            }
            mappedRows.add(row);
        }
        return new TableResult(columns, mappedRows);
    }

    private List<List<String>> parseCsvRows(String csv) {
        List<List<String>> rows = new ArrayList<>();
        List<String> currentRow = new ArrayList<>();
        StringBuilder currentField = new StringBuilder();
        boolean inQuotes = false;

        for (int i = 0; i < csv.length(); i++) {
            char ch = csv.charAt(i);
            if (inQuotes) {
                if (ch == '"') {
                    if (i + 1 < csv.length() && csv.charAt(i + 1) == '"') {
                        currentField.append('"');
                        i++;
                    } else {
                        inQuotes = false;
                    }
                } else {
                    currentField.append(ch);
                }
                continue;
            }

            if (ch == '"') {
                inQuotes = true;
            } else if (ch == ',') {
                currentRow.add(currentField.toString());
                currentField.setLength(0);
            } else if (ch == '\n') {
                currentRow.add(currentField.toString());
                currentField.setLength(0);
                rows.add(currentRow);
                currentRow = new ArrayList<>();
            } else if (ch != '\r') {
                currentField.append(ch);
            }
        }

        if (currentField.length() > 0 || !currentRow.isEmpty()) {
            currentRow.add(currentField.toString());
            rows.add(currentRow);
        }

        return rows;
    }

    private String stripTrailingSemicolon(String sql) {
        String stripped = sql.strip();
        if (stripped.endsWith(";")) {
            return stripped.substring(0, stripped.length() - 1);
        }
        return stripped;
    }
}
