package dao;

import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class IbubapaDAO {

    public boolean insert(int idpengguna,
            String namabapa, String nokadpengenalanbapa, String bangsabapa,
            String notelefonbapa, String statusbapa, String pekerjaanbapa,
            double pendapatanbapa, String majikanbapa,
            String namaibu, String nokadpengenalanibu, String bangsaibu,
            String notelefonibu, String statusibu, String pekerjaanibu,
            double pendapatanibu, String majikanibu,
            int bilangantanggungan) {

        String sql = "INSERT INTO ibubapa (idpengguna, namabapa, nokadpengenalanbapa, bangsabapa, "
                + "notelefonbapa, statusbapa, pekerjaanbapa, pendapatanbapa, majikanbapa, "
                + "namaibu, nokadpengenalanibu, bangsaibu, notelefonibu, statusibu, "
                + "pekerjaanibu, pendapatanibu, majikanibu, bilangantanggungan) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            int i = 1;
            ps.setInt(i++, idpengguna);
            ps.setString(i++, namabapa);
            ps.setString(i++, nokadpengenalanbapa);
            ps.setString(i++, bangsabapa);
            ps.setString(i++, notelefonbapa);
            ps.setString(i++, statusbapa);
            ps.setString(i++, pekerjaanbapa);
            ps.setDouble(i++, pendapatanbapa);
            ps.setString(i++, majikanbapa);
            ps.setString(i++, namaibu);
            ps.setString(i++, nokadpengenalanibu);
            ps.setString(i++, bangsaibu);
            ps.setString(i++, notelefonibu);
            ps.setString(i++, statusibu);
            ps.setString(i++, pekerjaanibu);
            ps.setDouble(i++, pendapatanibu);
            ps.setString(i++, majikanibu);
            ps.setInt(i++, bilangantanggungan);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
