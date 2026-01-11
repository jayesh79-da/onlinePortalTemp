package com.onlineexamportal.dao;

import com.onlineexamportal.model.User;

import java.sql.*;

public class UserDAO {

    private Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/online_exam",
            "root",
            ""
        );
    }

    // ================= REGISTER USER =================
    public boolean registerUser(User user) {

        String sql = "INSERT INTO users(name, email, password, role) VALUES(?,?,?,?)";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword()); // PLAIN PASSWORD
            ps.setString(4, user.getRole());

            return ps.executeUpdate() == 1;

        } catch (SQLIntegrityConstraintViolationException e) {
            // Email already exists
            return false;
        } catch (Exception e) {
            e.printStackTrace();   // IMPORTANT FOR DEBUG
            return false;
        }
    }

    // ================= LOGIN USER =================
    public User loginUser(String email, String password) {

        String sql = "SELECT * FROM users WHERE email=? AND password=?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setName(rs.getString("name"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                return user;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}
