<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
%>
<%
    response.setCharacterEncoding("UTF-8");

    String dbUrl = request.getParameter("dbUrl");
    String dbUser = request.getParameter("dbUser");
    String dbPassword = request.getParameter("dbPassword");
    String view = request.getParameter("view");

    if (dbUrl == null || dbUrl.isBlank()) dbUrl = System.getenv("HOTEL_DB_URL");
    if (dbUser == null || dbUser.isBlank()) dbUser = System.getenv("HOTEL_DB_USER");
    if (dbPassword == null || dbPassword.isBlank()) dbPassword = System.getenv("HOTEL_DB_PASSWORD");

    if (dbUrl == null || dbUrl.isBlank()) dbUrl = "jdbc:postgresql://localhost:5432/ehotels";
    if (dbUser == null || dbUser.isBlank()) dbUser = "postgres";
    if (dbPassword == null) dbPassword = "";

    if (view == null || view.isBlank()) view = "city_available";
    if (!("city_available".equals(view) || "hotel_capacity".equals(view) || "booking_archive".equals(view) || "renting_archive".equals(view))) {
        response.setStatus(400);
        out.print("{\"error\":\"Allowed values: city_available, hotel_capacity, booking_archive, renting_archive\"}");
        return;
    }

    try {
        Class.forName("org.postgresql.Driver");
    } catch (ClassNotFoundException e) {
        response.setStatus(500);
        out.print("{\"error\":\"PostgreSQL JDBC driver not found\"}");
        return;
    }

    String sql;
    if ("city_available".equals(view) || "hotel_capacity".equals(view)) {
        sql = "SELECT * FROM locations." + view;
    } else {
        sql = "SELECT * FROM records." + view + " ORDER BY archive_id DESC";
    }
    try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
         Statement st = conn.createStatement();
         ResultSet rs = st.executeQuery(sql)) {

        ResultSetMetaData md = rs.getMetaData();
        int cols = md.getColumnCount();
        StringBuilder json = new StringBuilder();
        json.append("{\"view\":\"").append(view).append("\",\"rows\":[");
        boolean first = true;
        while (rs.next()) {
            if (!first) json.append(',');
            first = false;
            json.append("{");
            for (int i = 1; i <= cols; i++) {
                if (i > 1) json.append(',');
                String k = md.getColumnLabel(i);
                String v = rs.getString(i);
                json.append("\"").append(esc(k)).append("\":");
                if (v == null) json.append("null"); else json.append("\"").append(esc(v)).append("\"");
            }
            json.append("}");
        }
        json.append("]}");
        out.print(json.toString());
    } catch (Exception e) {
        response.setStatus(500);
        out.print("{\"error\":\"" + esc(e.getMessage()) + "\"}");
    }
%>
