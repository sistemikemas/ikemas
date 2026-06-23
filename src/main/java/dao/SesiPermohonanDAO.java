package dao;

import util.DBConnection;
import java.sql.*;
import java.util.*;

public class SesiPermohonanDAO {

    // Buka sesi permohonan
    public boolean bukaSesi(int tahun, String dun, int idPengguna) {
        String sql = "INSERT INTO sesipermohonan (tahun, dun, status, tarikhbuka, tarikhtutup, tindakanoleh) "
                + "VALUES (?, ?, 'buka', NOW(), NULL, ?) "
                + "ON DUPLICATE KEY UPDATE status = 'buka', tarikhbuka = NOW(), tarikhtutup = NULL, tindakanoleh = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tahun);
            ps.setString(2, dun);
            ps.setInt(3, idPengguna);
            ps.setInt(4, idPengguna);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Tutup sesi permohonan
    public boolean tutupSesi(int tahun, String dun, int idPengguna) {
        String sql = "INSERT INTO sesipermohonan (tahun, dun, status, tarikhbuka, tarikhtutup, tindakanoleh) "
                + "VALUES (?, ?, 'tutup', NULL, NOW(), ?) "
                + "ON DUPLICATE KEY UPDATE status = 'tutup', tarikhtutup = NOW(), tindakanoleh = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tahun);
            ps.setString(2, dun);
            ps.setInt(3, idPengguna);
            ps.setInt(4, idPengguna);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Dapatkan status semasa sesi
    public Map<String, Object> getStatusSesi(int tahun, String dun) {
        Map<String, Object> result = new HashMap<>();
        String sql = "SELECT tahun, dun, status, tarikhbuka, tarikhtutup FROM sesipermohonan WHERE tahun = ? AND UPPER(dun) = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tahun);
            ps.setString(2, dun.toUpperCase());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                result.put("tahun", rs.getInt("tahun"));
                result.put("dun", rs.getString("dun"));
                result.put("status", rs.getString("status"));
                result.put("tarikhbuka", rs.getTimestamp("tarikhbuka"));
                result.put("tarikhtutup", rs.getTimestamp("tarikhtutup"));
            } else {
                result.put("tahun", tahun);
                result.put("dun", dun);
                result.put("status", "tutup");
                result.put("tarikhbuka", null);
                result.put("tarikhtutup", null);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    // Sejarah sesi
    public List<Map<String, Object>> getSejarahSesiByDun(String dun) {
        List<Map<String, Object>> list = new ArrayList<>();
        // UBAH: guna UPPER() untuk case-insensitive
        String sql = "SELECT s.tahun, s.status, s.tarikhbuka as tarikh, p.nama as namapengguna "
                + "FROM sesipermohonan s "
                + "LEFT JOIN pengguna p ON s.tindakanoleh = p.idpengguna "
                + "WHERE UPPER(s.dun) = ? "
                + "ORDER BY s.tarikhbuka DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dun.toUpperCase());  // Tukar kepada huruf besar
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> record = new HashMap<>();
                record.put("tahun", rs.getInt("tahun"));
                record.put("status", rs.getString("status"));
                Timestamp tarikh = rs.getTimestamp("tarikh");
                if (tarikh != null) {
                    record.put("tarikh", tarikh.getTime());
                }
                record.put("namapengguna", rs.getString("namapengguna"));
                list.add(record);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ==================== TAMBAH METHOD BARU UNTUK PERMOHONAN SERVLET ====================
    // Dapatkan tahun kemasukan yang aktif (status buka) untuk sesuatu DUN
    public Integer getTahunKemasukanByDun(String dun) {
        // UBAH: guna UPPER() untuk case-insensitive
        String sql = "SELECT tahun FROM sesipermohonan WHERE UPPER(dun) = ? AND status = 'buka' LIMIT 1";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dun.toUpperCase());  // Tukar kepada huruf besar
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("tahun");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
