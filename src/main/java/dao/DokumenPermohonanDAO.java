package dao;

import model.DokumenPermohonan;
import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DokumenPermohonanDAO {

    // Insert dokumen
    public boolean insert(DokumenPermohonan d) {
        String sql = "INSERT INTO dokumenpermohonan (idpermohonan, jenisdokumen, namafail) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, d.getIdpermohonan());
            ps.setString(2, d.getJenisdokumen());
            ps.setString(3, d.getNamafail());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get dokumen by idpermohonan
    public List<DokumenPermohonan> getByIdPermohonan(int idpermohonan) {
        List<DokumenPermohonan> list = new ArrayList<>();
        String sql = "SELECT * FROM dokumenpermohonan WHERE idpermohonan = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idpermohonan);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                DokumenPermohonan d = new DokumenPermohonan();
                d.setIddokumen(rs.getInt("iddokumen"));
                d.setIdpermohonan(rs.getInt("idpermohonan"));
                d.setJenisdokumen(rs.getString("jenisdokumen"));
                d.setNamafail(rs.getString("namafail"));
                d.setTarikhupload(rs.getTimestamp("tarikhupload"));
                list.add(d);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Delete dokumen by idpermohonan
    public boolean deleteByIdPermohonan(int idpermohonan) {
        String sql = "DELETE FROM dokumenpermohonan WHERE idpermohonan = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idpermohonan);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
