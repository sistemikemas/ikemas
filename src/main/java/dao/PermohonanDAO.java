package dao;

import model.Permohonan;
import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PermohonanDAO {

    // ==================== INSERT PERMOHONAN ====================
    public boolean insert(Permohonan p) {
        String sql = "INSERT INTO permohonan (nokadpengenalanmurid, kodtadika, tarikhpermohonan, tahunkemasukan, statuspermohonan, idgurubesaryanglulus, catatanpenolakan) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getNokadpengenalanmurid());
            ps.setString(2, p.getKodtadika());
            ps.setDate(3, p.getTarikhpermohonan());
            ps.setInt(4, p.getTahunkemasukan());
            ps.setString(5, p.getStatuspermohonan());
            ps.setObject(6, p.getIdgurubesaryanglulus(), java.sql.Types.INTEGER);
            ps.setString(7, p.getCatatanpenolakan());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ==================== DAPATKAN ID PERMOHONAN TERAKHIR ====================
    public int getLastInsertId() {
        int id = 0;
        String sql = "SELECT LAST_INSERT_ID()";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                id = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return id;
    }

    // ==================== DAPATKAN PERMOHONAN MENGIKUT TADIKA ====================
    public List<Permohonan> getByTadika(String kodtadika) {
        List<Permohonan> list = new ArrayList<>();
        String sql = "SELECT * FROM permohonan WHERE kodtadika = ? AND statuspermohonan != 'draf' ORDER BY tarikhpermohonan DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodtadika);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Permohonan p = new Permohonan();
                p.setIdpermohonan(rs.getInt("idpermohonan"));
                p.setNokadpengenalanmurid(rs.getString("nokadpengenalanmurid"));
                p.setKodtadika(rs.getString("kodtadika"));
                p.setTarikhpermohonan(rs.getDate("tarikhpermohonan"));
                p.setTahunkemasukan(rs.getInt("tahunkemasukan"));
                p.setStatuspermohonan(rs.getString("statuspermohonan"));
                p.setIdgurubesaryanglulus(rs.getInt("idgurubesaryanglulus"));
                p.setCatatanpenolakan(rs.getString("catatanpenolakan"));
                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ==================== KEMASKINI STATUS PERMOHONAN ====================
    public boolean updateStatus(int idpermohonan, String statusBaru, Integer idGuruBesar, String catatanPenolakan) {
        String sql = "UPDATE permohonan SET statuspermohonan = ?, idgurubesaryanglulus = ?, catatanpenolakan = ? WHERE idpermohonan = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, statusBaru);
            if (idGuruBesar == null) {
                ps.setNull(2, java.sql.Types.INTEGER);
            } else {
                ps.setInt(2, idGuruBesar);
            }
            ps.setString(3, catatanPenolakan);
            ps.setInt(4, idpermohonan);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ==================== DELETE PERMOHONAN (UNTUK DRAF) ====================
    public boolean deletePermohonan(int idpermohonan) {
        String sql = "DELETE FROM permohonan WHERE idpermohonan = ? AND statuspermohonan = 'draf'";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idpermohonan);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ==================== KIRA PERMOHONAN MENGIKUT STATUS ====================
    public int countByIbuBapaAndStatus(int idIbuBapa, String status) {
        String sql = "SELECT COUNT(*) FROM permohonan p JOIN murid m ON p.nokadpengenalanmurid = m.nokadpengenalan WHERE m.idibubapa = ? AND p.statuspermohonan = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idIbuBapa);
            ps.setString(2, status);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ==================== KIRA ANAK BERDAFTAR ====================
    public int countAnakBerdaftar(int idIbuBapa) {
        String sql = "SELECT COUNT(*) FROM permohonan p "
                + "JOIN murid m ON p.nokadpengenalanmurid = m.nokadpengenalan "
                + "WHERE m.idibubapa = ? AND p.statuspermohonan = 'lulus'";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idIbuBapa);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ==================== KIRA PERMOHONAN MENGIKUT TADIKA ====================
    public int countByTadikaAndStatus(String kodTadika, String status) {
        String sql = "SELECT COUNT(*) FROM permohonan p "
                + "JOIN murid m ON p.nokadpengenalanmurid = m.nokadpengenalan "
                + "WHERE m.kodtadika = ? AND p.statuspermohonan = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodTadika);
            ps.setString(2, status);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ==================== DAPATKAN PERMOHONAN TERKINI MENGIKUT TADIKA (TANPA DRAF) ====================
    public List<Map<String, String>> getRecentByTadika(String kodTadika, int limit) {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT p.idpermohonan, p.nokadpengenalanmurid, p.tarikhpermohonan, p.statuspermohonan, "
                + "m.namamurid "
                + "FROM permohonan p "
                + "JOIN murid m ON p.nokadpengenalanmurid = m.nokadpengenalan "
                + "WHERE m.kodtadika = ? AND p.statuspermohonan != 'draf' "
                + "ORDER BY p.tarikhpermohonan DESC "
                + "LIMIT ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodTadika);
            ps.setInt(2, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> row = new HashMap<>();
                row.put("idpermohonan", String.valueOf(rs.getInt("idpermohonan")));
                row.put("nokad", rs.getString("nokadpengenalanmurid"));
                row.put("namamurid", rs.getString("namamurid"));
                row.put("tarikh", rs.getString("tarikhpermohonan"));
                row.put("status", rs.getString("statuspermohonan"));
                list.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ==================== DAPATKAN PERMOHONAN UNTUK IBU BAPA (TERMASUK DRAF) ====================
    public List<Map<String, String>> getPermohonanByIbuBapa(int idIbuBapa) {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT p.idpermohonan, m.nokadpengenalan, m.namamurid, "
                + "p.tarikhpermohonan, p.statuspermohonan, p.catatanpenolakan, "
                + "YEAR(p.tahunkemasukan) as tahun_kemasukan, " 
                + "t.namatadika "
                + "FROM permohonan p "
                + "JOIN murid m ON p.nokadpengenalanmurid = m.nokadpengenalan "
                + "JOIN tadika t ON p.kodtadika = t.kodtadika "
                + "WHERE m.idibubapa = ? "
                + "ORDER BY p.tarikhpermohonan DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idIbuBapa);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> row = new HashMap<>();
                row.put("idpermohonan", String.valueOf(rs.getInt("idpermohonan")));
                row.put("nokad", rs.getString("nokadpengenalan"));
                row.put("namamurid", rs.getString("namamurid"));
                row.put("tarikh", rs.getString("tarikhpermohonan"));
                row.put("status", rs.getString("statuspermohonan"));
                row.put("tadika", rs.getString("namatadika"));
                row.put("catatanpenolakan", rs.getString("catatanpenolakan"));
                row.put("tahunkemasukan", rs.getString("tahun_kemasukan"));
                list.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ==================== SEMAK PERMOHONAN AKTIF UNTUK ANAK SAMA ====================
    public boolean isAdaPermohonanAktif(String nokadAnak) {
        String sql = "SELECT COUNT(*) FROM permohonan WHERE nokadpengenalanmurid = ? AND statuspermohonan = 'dalamproses'";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nokadAnak);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public int insertAndGetId(Permohonan p) {
        String sql = "INSERT INTO permohonan (nokadpengenalanmurid, kodtadika, tarikhpermohonan, tahunkemasukan, statuspermohonan) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, p.getNokadpengenalanmurid());
            ps.setString(2, p.getKodtadika());
            ps.setDate(3, p.getTarikhpermohonan());
            ps.setInt(4, p.getTahunkemasukan());
            ps.setString(5, p.getStatuspermohonan());
            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Map<String, String>> getDrafByIbuBapa(int idIbuBapa) {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT p.idpermohonan, p.nokadpengenalanmurid, p.tarikhpermohonan, p.statuspermohonan, "
                + "YEAR(p.tahunkemasukan) as tahun_kemasukan, "
                + "m.namamurid, t.namatadika "
                + "FROM permohonan p "
                + "JOIN murid m ON p.nokadpengenalanmurid = m.nokadpengenalan "
                + "JOIN tadika t ON p.kodtadika = t.kodtadika "
                + "WHERE m.idibubapa = ? AND p.statuspermohonan = 'draf' "
                + "ORDER BY p.tarikhpermohonan DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idIbuBapa);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> row = new HashMap<>();
                row.put("idpermohonan", String.valueOf(rs.getInt("idpermohonan")));
                row.put("nokad", rs.getString("nokadpengenalanmurid"));
                row.put("namamurid", rs.getString("namamurid"));
                row.put("tarikh", rs.getString("tarikhpermohonan"));
                row.put("tadika", rs.getString("namatadika"));
                row.put("status", rs.getString("statuspermohonan"));
                row.put("tahunkemasukan", rs.getString("tahun_kemasukan"));
                list.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ==================== DAPATKAN PERMOHONAN DRAF MENGIKUT ID ====================
    public Permohonan getDrafById(int idPermohonan) {
        String sql = "SELECT * FROM permohonan WHERE idpermohonan = ? AND statuspermohonan = 'draf'";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idPermohonan);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Permohonan p = new Permohonan();
                p.setIdpermohonan(rs.getInt("idpermohonan"));
                p.setNokadpengenalanmurid(rs.getString("nokadpengenalanmurid"));
                p.setKodtadika(rs.getString("kodtadika"));
                p.setTarikhpermohonan(rs.getDate("tarikhpermohonan"));
                p.setTahunkemasukan(rs.getInt("tahunkemasukan"));
                p.setStatuspermohonan(rs.getString("statuspermohonan"));
                return p;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Dapatkan senarai tahun yang ada permohonan untuk tadika tersebut
    public List<Integer> getTahunPermohonanByTadika(String kodTadika) {
        List<Integer> list = new ArrayList<>();
        String sql = "SELECT DISTINCT YEAR(tarikhpermohonan) as tahun FROM permohonan WHERE kodtadika = ? ORDER BY tahun DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodTadika);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getInt("tahun"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
