package dao;

import model.Tanggungan;
import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class TanggunganDAO {

    // Insert tanggungan
    public boolean insert(Tanggungan t) {
        String sql = "INSERT INTO tanggungan (idpermohonan, nama, umur, hubungan) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, t.getIdpermohonan());
            ps.setString(2, t.getNama());
            ps.setInt(3, t.getUmur());
            ps.setString(4, t.getHubungan());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get tanggungan by idpermohonan
    public List<Tanggungan> getByIdPermohonan(int idpermohonan) {
        List<Tanggungan> list = new ArrayList<>();
        String sql = "SELECT * FROM tanggungan WHERE idpermohonan = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idpermohonan);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Tanggungan t = new Tanggungan();
                t.setIdtanggungan(rs.getInt("idtanggungan"));
                t.setIdpermohonan(rs.getInt("idpermohonan"));
                t.setNama(rs.getString("nama"));
                t.setUmur(rs.getInt("umur"));
                t.setHubungan(rs.getString("hubungan"));
                list.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Delete tanggungan by idpermohonan
    public boolean deleteByIdPermohonan(int idpermohonan) {
        String sql = "DELETE FROM tanggungan WHERE idpermohonan = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idpermohonan);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
