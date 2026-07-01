package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    /*   
    private static final String URL = "jdbc:mysql://localhost:3306/s69935_ikemas";
    private static final String USER = "root";
    private static final String PASSWORD = "admin";
     */
    
    private static final String URL = "jdbc:mysql://localhost:3306/s69935_ikemas";
    private static final String USER = "s69935";
    private static final String PASSWORD = "Syafiqah159_";

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
