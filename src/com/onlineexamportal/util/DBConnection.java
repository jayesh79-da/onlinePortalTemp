package com.onlineexamportal.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/online_exam";
    private static final String USER = "root";
    private static final String PASSWORD = "";

    // static String url  = System.getenv("DB_URL");
    // static String user = System.getenv("DB_USER");
    // static String pass = System.getenv("DB_PASS");

    // public static Connection getConnection() {
        
    //     try {
    //         Class.forName("com.mysql.cj.jdbc.Driver");

    //         // Check if environment variables are set
    //         if (url == null || user == null || pass == null) {
    //             throw new RuntimeException(
    //                 "Database environment variables not set! Please define DB_URL, DB_USER, DB_PASS"
    //             );
    //         }

    //         return DriverManager.getConnection(url, user, pass);

    //     } catch (ClassNotFoundException | SQLException e) {
    //         e.printStackTrace();
    //     }
    //     return null;
    // }


public static Connection getConnection() {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(URL, USER, PASSWORD);
    } catch (ClassNotFoundException | SQLException e) {
        e.printStackTrace();
    }
    return null;
}


}










