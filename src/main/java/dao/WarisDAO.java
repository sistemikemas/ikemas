package dao;

import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class WarisDAO {

    // Insert waris kecemasan (bukan ibu bapa)
    public boolean insert(String idmurid, String namawaris, String alamatwaris, String notelefonwaris, String hubungan) {
        String sql = "INSERT INTO waris (idmurid, namawaris, alamatwaris, notelefonwaris, hubungandenganmurid) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, idmurid);
            ps.setString(2, namawaris);
            ps.setString(3, alamatwaris);
            ps.setString(4, notelefonwaris);
            ps.setString(5, hubungan);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
