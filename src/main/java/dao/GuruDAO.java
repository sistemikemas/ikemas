package dao;

import model.Guru;
import util.DBConnection;
import java.sql.*;

public class GuruDAO {

    // Dapatkan maklumat guru berdasarkan idpengguna
    public Guru getGuruByPenggunaId(int idpengguna) {
        String sql = "SELECT * FROM guru WHERE idpengguna = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idpengguna);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                Guru guru = new Guru();
                guru.setIdguru(rs.getInt("idguru"));
                guru.setIdpengguna(rs.getInt("idpengguna"));
                guru.setKodtadika(rs.getString("kodtadika"));
                guru.setNokadpengenalan(rs.getString("nokadpengenalan"));
                guru.setTarikhlantikan(rs.getDate("tarikhlantikan"));
                guru.setKelayakanakademik(rs.getString("kelayakanakademik"));
                guru.setGredjawatan(rs.getString("gredjawatan"));
                return guru;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Dapatkan jumlah guru mengikut kod tadika
    public int getJumlahGuruByKodTadika(String kodTadika) throws SQLException {
        if (kodTadika == null || kodTadika.trim().isEmpty()) {
            return 0;
        }

        String sql = "SELECT COUNT(*) FROM guru WHERE kodtadika = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, kodTadika);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw e;
        }
        return 0;
    }
}
