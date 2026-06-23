// File: PemantauanDAO.java
package dao;

import model.Pemantauan;
import util.DBConnection;
import util.DewanUndanganNegeri;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PemantauanDAO {

    // ==================== METHOD SEDIA ADA ====================
    // Dapatkan jumlah pemantauan bulan ini mengikut DUN
    public int getJumlahPemantauanBulanIniByDun(String dun) throws SQLException {
        if (dun == null || dun.trim().isEmpty()) {
            return 0;
        }

        String sql = "SELECT COUNT(*) FROM pemantauan p "
                + "JOIN tadika t ON p.kodtadika = t.kodtadika "
                + "WHERE UPPER(t.dun) = UPPER(?) AND MONTH(p.tarikhpemantauan) = MONTH(CURDATE()) "
                + "AND YEAR(p.tarikhpemantauan) = YEAR(CURDATE())";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dun);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }

    // Dapatkan jumlah pemantauan mengikut DUN untuk tahun semasa
    public int getJumlahPemantauanTahunIniByDun(String dun) throws SQLException {
        if (dun == null || dun.trim().isEmpty()) {
            return 0;
        }

        String sql = "SELECT COUNT(*) FROM pemantauan p "
                + "JOIN tadika t ON p.kodtadika = t.kodtadika "
                + "WHERE UPPER(t.dun) = UPPER(?) AND YEAR(p.tarikhpemantauan) = YEAR(CURDATE())";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dun);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }

    // Dapatkan senarai pemantauan terkini mengikut DUN (untuk aktiviti)
    public List<Map<String, Object>> getPemantauanTerkiniByDun(String dun, int limit) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        if (dun == null || dun.trim().isEmpty()) {
            return list;
        }

        String sql = "SELECT p.idpemantauan, p.tarikhpemantauan, p.keputusanpemantauan, "
                + "t.namatadika, t.kodtadika "
                + "FROM pemantauan p "
                + "JOIN tadika t ON p.kodtadika = t.kodtadika "
                + "WHERE UPPER(t.dun) = UPPER(?) "
                + "ORDER BY p.tarikhpemantauan DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dun);
            ps.setInt(2, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("idpemantauan", rs.getInt("idpemantauan"));
                item.put("tarikhpemantauan", rs.getTimestamp("tarikhpemantauan"));
                item.put("keputusanpemantauan", rs.getString("keputusanpemantauan"));
                item.put("namatadika", rs.getString("namatadika"));
                item.put("kodtadika", rs.getString("kodtadika"));
                list.add(item);
            }
        }
        return list;
    }

    // ==================== METHOD CRUD TAMBAHAN ====================
    // INSERT - Tambah pemantauan baru
    public boolean insertPemantauan(Pemantauan p) {
        String sql = "INSERT INTO pemantauan (kodtadika, idpenyelia, tarikhpemantauan, aspekdinilai, keputusanpemantauan, catatanpenyelia, tindakansusulan) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, p.getKodtadika());
            ps.setInt(2, p.getIdpenyelia());
            ps.setDate(3, p.getTarikhpemantauan());
            ps.setString(4, p.getAspekdinilai());
            ps.setString(5, p.getKeputusanpemantauan());
            ps.setString(6, p.getCatatanpenyelia());
            ps.setString(7, p.getTindakansusulan());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // SELECT - Dapatkan senarai pemantauan mengikut kod tadika
    public List<Pemantauan> getPemantauanByTadika(String kodtadika) {
        List<Pemantauan> list = new ArrayList<>();

        if (kodtadika == null || kodtadika.isEmpty()) {
            return list;
        }

        String sql = "SELECT * FROM pemantauan WHERE kodtadika = ? ORDER BY tarikhpemantauan DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, kodtadika);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Pemantauan p = new Pemantauan();
                p.setIdpemantauan(rs.getInt("idpemantauan"));
                p.setKodtadika(rs.getString("kodtadika"));
                p.setIdpenyelia(rs.getInt("idpenyelia"));
                p.setTarikhpemantauan(rs.getDate("tarikhpemantauan"));
                p.setAspekdinilai(rs.getString("aspekdinilai"));
                p.setKeputusanpemantauan(rs.getString("keputusanpemantauan"));
                p.setCatatanpenyelia(rs.getString("catatanpenyelia"));
                p.setTindakansusulan(rs.getString("tindakansusulan"));
                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // SELECT - Dapatkan pemantauan mengikut ID
    public Pemantauan getPemantauanById(int id) {
        String sql = "SELECT * FROM pemantauan WHERE idpemantauan = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Pemantauan p = new Pemantauan();
                p.setIdpemantauan(rs.getInt("idpemantauan"));
                p.setKodtadika(rs.getString("kodtadika"));
                p.setIdpenyelia(rs.getInt("idpenyelia"));
                p.setTarikhpemantauan(rs.getDate("tarikhpemantauan"));
                p.setAspekdinilai(rs.getString("aspekdinilai"));
                p.setKeputusanpemantauan(rs.getString("keputusanpemantauan"));
                p.setCatatanpenyelia(rs.getString("catatanpenyelia"));
                p.setTindakansusulan(rs.getString("tindakansusulan"));
                return p;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // UPDATE - Kemaskini pemantauan
    public boolean updatePemantauan(Pemantauan p) {
        String sql = "UPDATE pemantauan SET kodtadika=?, idpenyelia=?, tarikhpemantauan=?, aspekdinilai=?, keputusanpemantauan=?, catatanpenyelia=?, tindakansusulan=? "
                + "WHERE idpemantauan=?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, p.getKodtadika());
            ps.setInt(2, p.getIdpenyelia());
            ps.setDate(3, p.getTarikhpemantauan());
            ps.setString(4, p.getAspekdinilai());
            ps.setString(5, p.getKeputusanpemantauan());
            ps.setString(6, p.getCatatanpenyelia());
            ps.setString(7, p.getTindakansusulan());
            ps.setInt(8, p.getIdpemantauan());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // DELETE - Hapus pemantauan
    public boolean deletePemantauan(int id) {
        String sql = "DELETE FROM pemantauan WHERE idpemantauan = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
