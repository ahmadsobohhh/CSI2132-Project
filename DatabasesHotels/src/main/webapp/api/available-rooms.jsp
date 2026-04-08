<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
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

    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");
    String chainId = request.getParameter("chainId");
    String city = request.getParameter("city");
    String minCapacity = request.getParameter("minCapacity");
    String maxPrice = request.getParameter("maxPrice");

    String dbUrl = request.getParameter("dbUrl");
    String dbUser = request.getParameter("dbUser");
    String dbPassword = request.getParameter("dbPassword");

    if (dbUrl == null || dbUrl.isBlank()) dbUrl = System.getenv("HOTEL_DB_URL");
    if (dbUser == null || dbUser.isBlank()) dbUser = System.getenv("HOTEL_DB_USER");
    if (dbPassword == null || dbPassword.isBlank()) dbPassword = System.getenv("HOTEL_DB_PASSWORD");

    if (dbUrl == null || dbUrl.isBlank()) dbUrl = "jdbc:postgresql://localhost:5432/ehotels";
    if (dbUser == null || dbUser.isBlank()) dbUser = "postgres";
    if (dbPassword == null) dbPassword = "";

    if (startDate == null || startDate.isBlank() || endDate == null || endDate.isBlank()) {
        response.setStatus(400);
        out.print("{\"error\":\"startDate and endDate are required\"}");
        return;
    }

    try {
        Class.forName("org.postgresql.Driver");
    } catch (ClassNotFoundException e) {
        response.setStatus(500);
        out.print("{\"error\":\"PostgreSQL JDBC driver not found in Tomcat lib\"}");
        return;
    }

    StringBuilder sql = new StringBuilder();
    sql.append("SELECT h.name AS hotel_name, h.city, h.province, r.hotel_id, r.room_number, r.capacity, r.price, r.view_type ")
       .append("FROM locations.room r ")
       .append("JOIN locations.hotel h ON h.hotel_id = r.hotel_id ")
       .append("WHERE NOT EXISTS (")
       .append("SELECT 1 FROM records.booking_records b ")
       .append("WHERE b.hotel_id = r.hotel_id AND b.room_number = r.room_number ")
       .append("AND b.status = 'Active' ")
       .append("AND b.start_date < ?::date AND b.end_date > ?::date")
       .append(") ")
       .append("AND NOT EXISTS (")
       .append("SELECT 1 FROM records.renting_records rr ")
       .append("WHERE rr.hotel_id = r.hotel_id AND rr.room_number = r.room_number ")
       .append("AND rr.status = 'Checked-In' ")
       .append("AND rr.start_date < ?::date AND rr.end_date > ?::date")
       .append(") ");

    List<Object> params = new ArrayList<>();
    params.add(endDate);
    params.add(startDate);
    params.add(endDate);
    params.add(startDate);

    if (chainId != null && !chainId.isBlank()) {
        sql.append("AND h.chain_id = ? ");
        params.add(Integer.parseInt(chainId));
    }
    if (city != null && !city.isBlank()) {
        sql.append("AND h.city = ? ");
        params.add(city);
    }
    if (minCapacity != null && !minCapacity.isBlank()) {
        sql.append("AND r.capacity >= ? ");
        params.add(Integer.parseInt(minCapacity));
    }
    if (maxPrice != null && !maxPrice.isBlank()) {
        sql.append("AND r.price <= ? ");
        params.add(new BigDecimal(maxPrice));
    }

    sql.append("ORDER BY r.price, r.capacity DESC");

    try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
         PreparedStatement ps = conn.prepareStatement(sql.toString())) {

        for (int i = 0; i < params.size(); i++) {
            Object p = params.get(i);
            int idx = i + 1;
            if (p instanceof Integer) {
                ps.setInt(idx, (Integer) p);
            } else if (p instanceof BigDecimal) {
                ps.setBigDecimal(idx, (BigDecimal) p);
            } else {
                ps.setString(idx, String.valueOf(p));
            }
        }

        try (ResultSet rs = ps.executeQuery()) {
            StringBuilder json = new StringBuilder();
            json.append("{\"rows\":[");
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(',');
                first = false;
                json.append("{")
                    .append("\"hotel_name\":\"").append(esc(rs.getString("hotel_name"))).append("\",")
                    .append("\"city\":\"").append(esc(rs.getString("city"))).append("\",")
                    .append("\"province\":\"").append(esc(rs.getString("province"))).append("\",")
                    .append("\"hotel_id\":").append(rs.getInt("hotel_id")).append(",")
                    .append("\"room_number\":").append(rs.getInt("room_number")).append(",")
                    .append("\"capacity\":").append(rs.getInt("capacity")).append(",")
                    .append("\"price\":").append(rs.getBigDecimal("price")).append(",")
                    .append("\"view_type\":\"").append(esc(rs.getString("view_type"))).append("\"")
                    .append("}");
            }
            json.append("]}");
            out.print(json.toString());
        }

    } catch (Exception e) {
        response.setStatus(500);
        out.print("{\"error\":\"" + esc(e.getMessage()) + "\"}");
    }
%>
