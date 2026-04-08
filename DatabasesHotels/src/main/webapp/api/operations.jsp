<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="jakarta.servlet.http.HttpServletResponse" %>
<%@ page import="jakarta.servlet.jsp.JspWriter" %>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    private Integer asInt(String v) {
        if (v == null || v.isBlank()) return null;
        return Integer.valueOf(v.trim());
    }

    private Boolean asBool(String v) {
        if (v == null || v.isBlank()) return null;
        return Boolean.valueOf(v.trim());
    }

    private void ok(JspWriter out, int changed) throws java.io.IOException {
        out.print("{\"ok\":true,\"changed\":" + changed + "}");
    }

    private void fail(HttpServletResponse response, JspWriter out, String msg) throws java.io.IOException {
        response.setStatus(400);
        out.print("{\"ok\":false,\"error\":\"" + esc(msg) + "\"}");
    }
%>
<%
    response.setCharacterEncoding("UTF-8");

    String action = request.getParameter("action");
    String dbUrl = request.getParameter("dbUrl");
    String dbUser = request.getParameter("dbUser");
    String dbPassword = request.getParameter("dbPassword");

    if (dbUrl == null || dbUrl.isBlank()) dbUrl = System.getenv("HOTEL_DB_URL");
    if (dbUser == null || dbUser.isBlank()) dbUser = System.getenv("HOTEL_DB_USER");
    if (dbPassword == null || dbPassword.isBlank()) dbPassword = System.getenv("HOTEL_DB_PASSWORD");

    if (dbUrl == null || dbUrl.isBlank()) dbUrl = "jdbc:postgresql://localhost:5432/ehotels";
    if (dbUser == null || dbUser.isBlank()) dbUser = "postgres";
    if (dbPassword == null) dbPassword = "";

    if (action == null || action.isBlank()) {
        fail(response, out, "Missing action");
        return;
    }

    try {
        Class.forName("org.postgresql.Driver");
    } catch (ClassNotFoundException e) {
        response.setStatus(500);
        out.print("{\"ok\":false,\"error\":\"PostgreSQL JDBC driver not found\"}");
        return;
    }

    try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword)) {
        conn.setAutoCommit(false);

        if ("create_booking".equals(action)) {
            String sql = "INSERT INTO records.booking_records (booking_id, room_number, hotel_id, customer_id, start_date, end_date, status) VALUES ((SELECT COALESCE(MAX(booking_id),0)+1 FROM records.booking_records), ?, ?, ?, ?::date, ?::date, 'Active') RETURNING booking_id";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, asInt(request.getParameter("room_number")));
                ps.setInt(2, asInt(request.getParameter("hotel_id")));
                ps.setInt(3, asInt(request.getParameter("customer_id")));
                ps.setString(4, request.getParameter("start_date"));
                ps.setString(5, request.getParameter("end_date"));
                int newBookingId = -1;
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        newBookingId = rs.getInt("booking_id");
                    }
                }
                conn.commit();
                out.print("{\"ok\":true,\"changed\":1,\"booking_id\":" + newBookingId + "}");
            }
        } else if ("create_renting".equals(action)) {
            String sql = "INSERT INTO records.renting_records (renting_id, room_number, hotel_id, customer_id, employee_id, start_date, end_date, payment_amount, status) VALUES ((SELECT COALESCE(MAX(renting_id),0)+1 FROM records.renting_records), ?, ?, ?, ?, ?::date, ?::date, ?, 'Checked-In') RETURNING renting_id";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, asInt(request.getParameter("room_number")));
                ps.setInt(2, asInt(request.getParameter("hotel_id")));
                ps.setInt(3, asInt(request.getParameter("customer_id")));
                ps.setInt(4, asInt(request.getParameter("employee_id")));
                ps.setString(5, request.getParameter("start_date"));
                ps.setString(6, request.getParameter("end_date"));
                Integer pay = asInt(request.getParameter("payment_amount"));
                if (pay == null) ps.setNull(7, Types.INTEGER); else ps.setInt(7, pay);
                int newRentingId = -1;
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        newRentingId = rs.getInt("renting_id");
                    }
                }
                conn.commit();
                out.print("{\"ok\":true,\"changed\":1,\"renting_id\":" + newRentingId + "}");
            }
        } else if ("transform_booking_to_renting".equals(action)) {
            Integer bookingId = asInt(request.getParameter("booking_id"));
            Integer employeeId = asInt(request.getParameter("employee_id"));
            Integer payment = asInt(request.getParameter("payment_amount"));
            if (bookingId == null || employeeId == null) {
                fail(response, out, "booking_id and employee_id are required");
                conn.rollback();
                return;
            }

                String ins = "INSERT INTO records.renting_records (renting_id, room_number, hotel_id, customer_id, employee_id, start_date, end_date, payment_amount, status) " +
                    "SELECT (SELECT COALESCE(MAX(renting_id),0)+1 FROM records.renting_records), room_number, hotel_id, customer_id, ?, start_date, end_date, ?, 'Checked-In' " +
                    "FROM records.booking_records WHERE booking_id = ? AND status = 'Active' RETURNING renting_id";
            int inserted = 0;
            int newRentingId = -1;
            try (PreparedStatement ps = conn.prepareStatement(ins)) {
                ps.setInt(1, employeeId);
                if (payment == null) ps.setNull(2, Types.INTEGER); else ps.setInt(2, payment);
                ps.setInt(3, bookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        inserted = 1;
                        newRentingId = rs.getInt("renting_id");
                    }
                }
            }

            if (inserted == 0) {
                fail(response, out, "No active booking found for booking_id");
                conn.rollback();
                return;
            }

            String upd = "UPDATE records.booking_records SET status = 'Transformed' WHERE booking_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(upd)) {
                ps.setInt(1, bookingId);
                ps.executeUpdate();
            }

            conn.commit();
            out.print("{\"ok\":true,\"changed\":" + inserted + ",\"renting_id\":" + newRentingId + ",\"booking_id\":" + bookingId + "}");
        } else if ("add_payment".equals(action)) {
            String sql = "UPDATE records.renting_records SET payment_amount = ? WHERE renting_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, asInt(request.getParameter("payment_amount")));
                ps.setInt(2, asInt(request.getParameter("renting_id")));
                int c = ps.executeUpdate();
                conn.commit();
                ok(out, c);
            }
        } else if ("checkout_renting".equals(action)) {
            String sql = "UPDATE records.renting_records SET status = 'Checked-Out' WHERE renting_id = ? AND status <> 'Checked-Out' RETURNING renting_id";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, asInt(request.getParameter("renting_id")));
                int changed = 0;
                int rentingId = -1;
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        changed = 1;
                        rentingId = rs.getInt("renting_id");
                    }
                }
                conn.commit();
                out.print("{\"ok\":true,\"changed\":" + changed + ",\"renting_id\":" + rentingId + "}");
            }
        } else if ("archive_booking".equals(action)) {
            Integer bookingId = asInt(request.getParameter("booking_id"));
            if (bookingId == null) {
                fail(response, out, "booking_id is required");
                conn.rollback();
                return;
            }

            String ins = "INSERT INTO records.booking_archive (archive_id, original_booking_id, customer_name_snap, hotel_name_snap, room_number_snap, start_date_snap, end_date_snap) " +
                    "SELECT (SELECT COALESCE(MAX(archive_id),0)+1 FROM records.booking_archive), b.booking_id, " +
                    "CONCAT_WS(' ', c.first_name, c.middle_name, c.last_name), h.name, b.room_number, b.start_date, b.end_date " +
                    "FROM records.booking_records b " +
                    "JOIN people.customer c ON c.customer_id = b.customer_id " +
                    "JOIN locations.hotel h ON h.hotel_id = b.hotel_id " +
                    "WHERE b.booking_id = ? RETURNING archive_id";

            int archiveId = -1;
            int changed = 0;
            try (PreparedStatement ps = conn.prepareStatement(ins)) {
                ps.setInt(1, bookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        archiveId = rs.getInt("archive_id");
                        changed = 1;
                    }
                }
            }

            if (changed == 0) {
                fail(response, out, "No booking found for booking_id");
                conn.rollback();
                return;
            }

            try (PreparedStatement del = conn.prepareStatement("DELETE FROM records.booking_records WHERE booking_id = ?")) {
                del.setInt(1, bookingId);
                del.executeUpdate();
            }

            conn.commit();
            out.print("{\"ok\":true,\"changed\":" + changed + ",\"archive_id\":" + archiveId + ",\"booking_id\":" + bookingId + "}");
        } else if ("create_customer".equals(action)) {
            String sql = "INSERT INTO people.customer (customer_id, first_name, middle_name, last_name, street_number, street_name, city, province, postal_code, id_type, id_number) VALUES ((SELECT COALESCE(MAX(customer_id),0)+1 FROM people.customer), ?, ?, ?, ?, ?, ?, ?, ?, ?::people.gid, ?) RETURNING customer_id";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, request.getParameter("first_name"));
                ps.setString(2, request.getParameter("middle_name"));
                ps.setString(3, request.getParameter("last_name"));
                Integer streetNumber = asInt(request.getParameter("street_number"));
                if (streetNumber == null) ps.setNull(4, Types.INTEGER); else ps.setInt(4, streetNumber);
                ps.setString(5, request.getParameter("street_name"));
                ps.setString(6, request.getParameter("city"));
                ps.setString(7, request.getParameter("province"));
                ps.setString(8, request.getParameter("postal_code"));
                ps.setString(9, request.getParameter("id_type"));
                Integer idNumber = asInt(request.getParameter("id_number"));
                if (idNumber == null) ps.setNull(10, Types.INTEGER); else ps.setInt(10, idNumber);
                int newCustomerId = -1;
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        newCustomerId = rs.getInt("customer_id");
                    }
                }
                conn.commit();
                out.print("{\"ok\":true,\"changed\":1,\"customer_id\":" + newCustomerId + "}");
            }
        } else if ("update_customer".equals(action)) {
            String sql = "UPDATE people.customer SET first_name=?, middle_name=?, last_name=?, street_number=?, street_name=?, city=?, province=?, postal_code=? WHERE customer_id=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, request.getParameter("first_name"));
                ps.setString(2, request.getParameter("middle_name"));
                ps.setString(3, request.getParameter("last_name"));
                Integer streetNumber = asInt(request.getParameter("street_number"));
                if (streetNumber == null) ps.setNull(4, Types.INTEGER); else ps.setInt(4, streetNumber);
                ps.setString(5, request.getParameter("street_name"));
                ps.setString(6, request.getParameter("city"));
                ps.setString(7, request.getParameter("province"));
                ps.setString(8, request.getParameter("postal_code"));
                ps.setInt(9, asInt(request.getParameter("customer_id")));
                int c = ps.executeUpdate();
                conn.commit();
                ok(out, c);
            }
        } else if ("delete_customer".equals(action)) {
            String sql = "DELETE FROM people.customer WHERE customer_id=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, asInt(request.getParameter("customer_id")));
                int c = ps.executeUpdate();
                conn.commit();
                ok(out, c);
            }
        } else if ("create_employee".equals(action)) {
            String sql = "INSERT INTO people.employee (employee_id, chain_id, hotel_id, first_name, middle_name, last_name, street_number, street_name, city, province, postal_code, sin, government_id) VALUES ((SELECT COALESCE(MAX(employee_id),0)+1 FROM people.employee), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?::people.gid9)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                Integer chainId = asInt(request.getParameter("chain_id"));
                Integer hotelId = asInt(request.getParameter("hotel_id"));
                if (chainId == null) ps.setNull(1, Types.INTEGER); else ps.setInt(1, chainId);
                if (hotelId == null) ps.setNull(2, Types.INTEGER); else ps.setInt(2, hotelId);
                ps.setString(3, request.getParameter("first_name"));
                ps.setString(4, request.getParameter("middle_name"));
                ps.setString(5, request.getParameter("last_name"));
                Integer streetNumber = asInt(request.getParameter("street_number"));
                if (streetNumber == null) ps.setNull(6, Types.INTEGER); else ps.setInt(6, streetNumber);
                ps.setString(7, request.getParameter("street_name"));
                ps.setString(8, request.getParameter("city"));
                ps.setString(9, request.getParameter("province"));
                ps.setString(10, request.getParameter("postal_code"));
                Integer sin = asInt(request.getParameter("sin"));
                if (sin == null) ps.setNull(11, Types.NUMERIC); else ps.setInt(11, sin);
                String gov = request.getParameter("government_id");
                if (gov == null || gov.isBlank()) ps.setNull(12, Types.VARCHAR); else ps.setString(12, gov);
                int c = ps.executeUpdate();
                conn.commit();
                ok(out, c);
            }
        } else if ("update_employee".equals(action)) {
            String sql = "UPDATE people.employee SET chain_id=?, hotel_id=?, first_name=?, middle_name=?, last_name=?, street_number=?, street_name=?, city=?, province=?, postal_code=? WHERE employee_id=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                Integer chainId = asInt(request.getParameter("chain_id"));
                Integer hotelId = asInt(request.getParameter("hotel_id"));
                if (chainId == null) ps.setNull(1, Types.INTEGER); else ps.setInt(1, chainId);
                if (hotelId == null) ps.setNull(2, Types.INTEGER); else ps.setInt(2, hotelId);
                ps.setString(3, request.getParameter("first_name"));
                ps.setString(4, request.getParameter("middle_name"));
                ps.setString(5, request.getParameter("last_name"));
                Integer streetNumber = asInt(request.getParameter("street_number"));
                if (streetNumber == null) ps.setNull(6, Types.INTEGER); else ps.setInt(6, streetNumber);
                ps.setString(7, request.getParameter("street_name"));
                ps.setString(8, request.getParameter("city"));
                ps.setString(9, request.getParameter("province"));
                ps.setString(10, request.getParameter("postal_code"));
                ps.setInt(11, asInt(request.getParameter("employee_id")));
                int c = ps.executeUpdate();
                conn.commit();
                ok(out, c);
            }
        } else if ("delete_employee".equals(action)) {
            String sql = "DELETE FROM people.employee WHERE employee_id=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, asInt(request.getParameter("employee_id")));
                int c = ps.executeUpdate();
                conn.commit();
                ok(out, c);
            }
        } else if ("create_hotel".equals(action)) {
            String sql = "INSERT INTO locations.hotel (hotel_id, chain_id, manager_id, rating, name, street_number, street_name, city, province, postal_code) VALUES ((SELECT COALESCE(MAX(hotel_id),0)+1 FROM locations.hotel), ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, asInt(request.getParameter("chain_id")));
                ps.setInt(2, asInt(request.getParameter("manager_id")));
                Integer rating = asInt(request.getParameter("rating"));
                if (rating == null) ps.setNull(3, Types.INTEGER); else ps.setInt(3, rating);
                ps.setString(4, request.getParameter("name"));
                Integer streetNumber = asInt(request.getParameter("street_number"));
                if (streetNumber == null) ps.setNull(5, Types.INTEGER); else ps.setInt(5, streetNumber);
                ps.setString(6, request.getParameter("street_name"));
                ps.setString(7, request.getParameter("city"));
                ps.setString(8, request.getParameter("province"));
                ps.setString(9, request.getParameter("postal_code"));
                int c = ps.executeUpdate();
                conn.commit();
                ok(out, c);
            }
        } else if ("update_hotel".equals(action)) {
            String sql = "UPDATE locations.hotel SET chain_id=?, manager_id=?, rating=?, name=?, street_number=?, street_name=?, city=?, province=?, postal_code=? WHERE hotel_id=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, asInt(request.getParameter("chain_id")));
                ps.setInt(2, asInt(request.getParameter("manager_id")));
                Integer rating = asInt(request.getParameter("rating"));
                if (rating == null) ps.setNull(3, Types.INTEGER); else ps.setInt(3, rating);
                ps.setString(4, request.getParameter("name"));
                Integer streetNumber = asInt(request.getParameter("street_number"));
                if (streetNumber == null) ps.setNull(5, Types.INTEGER); else ps.setInt(5, streetNumber);
                ps.setString(6, request.getParameter("street_name"));
                ps.setString(7, request.getParameter("city"));
                ps.setString(8, request.getParameter("province"));
                ps.setString(9, request.getParameter("postal_code"));
                ps.setInt(10, asInt(request.getParameter("hotel_id")));
                int c = ps.executeUpdate();
                conn.commit();
                ok(out, c);
            }
        } else if ("delete_hotel".equals(action)) {
            String sql = "DELETE FROM locations.hotel WHERE hotel_id=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, asInt(request.getParameter("hotel_id")));
                int c = ps.executeUpdate();
                conn.commit();
                ok(out, c);
            }
        } else if ("create_room".equals(action)) {
            String sql = "INSERT INTO locations.room (room_number, hotel_id, price, capacity, view_type, is_extendable) VALUES ((SELECT COALESCE(MAX(room_number),0)+1 FROM locations.room), ?, ?, ?, ?::locations.view_type, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, asInt(request.getParameter("hotel_id")));
                ps.setInt(2, asInt(request.getParameter("price")));
                ps.setInt(3, asInt(request.getParameter("capacity")));
                ps.setString(4, request.getParameter("view_type"));
                Boolean ex = asBool(request.getParameter("is_extendable"));
                if (ex == null) ps.setNull(5, Types.BOOLEAN); else ps.setBoolean(5, ex);
                int c = ps.executeUpdate();
                conn.commit();
                ok(out, c);
            }
        } else if ("update_room".equals(action)) {
            String sql = "UPDATE locations.room SET price=?, capacity=?, view_type=?::locations.view_type, is_extendable=? WHERE room_number=? AND hotel_id=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, asInt(request.getParameter("price")));
                ps.setInt(2, asInt(request.getParameter("capacity")));
                ps.setString(3, request.getParameter("view_type"));
                Boolean ex = asBool(request.getParameter("is_extendable"));
                if (ex == null) ps.setNull(4, Types.BOOLEAN); else ps.setBoolean(4, ex);
                ps.setInt(5, asInt(request.getParameter("room_number")));
                ps.setInt(6, asInt(request.getParameter("hotel_id")));
                int c = ps.executeUpdate();
                conn.commit();
                ok(out, c);
            }
        } else if ("delete_room".equals(action)) {
            String sql = "DELETE FROM locations.room WHERE room_number=? AND hotel_id=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, asInt(request.getParameter("room_number")));
                ps.setInt(2, asInt(request.getParameter("hotel_id")));
                int c = ps.executeUpdate();
                conn.commit();
                ok(out, c);
            }
        } else {
            fail(response, out, "Unknown action: " + action);
            conn.rollback();
            return;
        }
    } catch (Exception e) {
        response.setStatus(500);
        out.print("{\"ok\":false,\"error\":\"" + esc(e.getMessage()) + "\"}");
    }
%>
