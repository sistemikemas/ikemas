package dao;

import model.Pengguna;
import util.DBConnection;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PenggunaDAO {

    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes("UTF-8"));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // Log masuk
    public Pengguna login(String username, String password) {
        String sql = "SELECT * FROM pengguna WHERE username = ? AND katalaluan = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, hashPassword(password));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Pengguna p = new Pengguna();
                p.setIdpengguna(rs.getInt("idpengguna"));
                p.setUsername(rs.getString("username"));
                p.setKatalaluan(rs.getString("katalaluan"));
                p.setNama(rs.getString("nama"));
                p.setNotelefon(rs.getString("notelefon"));
                p.setPeranan(rs.getString("peranan"));
                p.setKodtadika(rs.getString("kodtadika"));
                p.setDunseliaan(rs.getString("dunseliaan"));
                p.setTarikhdicipta(rs.getString("tarikhdicipta"));
                p.setGambarprofil(rs.getString("gambarprofil"));
                return p;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Semak username sama ada sudah wujud atau belum
    public boolean isUsernameExists(String username) throws SQLException {
        String sql = "SELECT COUNT(*) FROM pengguna WHERE username = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    // Daftar pengguna baru
    public boolean register(Pengguna p) {
        String sql = "INSERT INTO pengguna (username, katalaluan, nama, notelefon, peranan, kodtadika, dunseliaan) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getUsername());
            ps.setString(2, p.getKatalaluan());
            ps.setString(3, p.getNama());
            ps.setString(4, p.getNotelefon());
            ps.setString(5, p.getPeranan());
            ps.setString(6, p.getKodtadika());
            ps.setString(7, p.getDunseliaan());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Kemaskini kata laluan
    public boolean updatePassword(String username, String hashedPassword) {
        String sql = "UPDATE pengguna SET katalaluan = ? WHERE username = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, hashedPassword);
            ps.setString(2, username);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Profil saya 
    // Dapatkan pengguna by id
    public Pengguna findById(int idpengguna) {
        String sql = "SELECT * FROM pengguna WHERE idpengguna = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idpengguna);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Pengguna p = new Pengguna();
                p.setIdpengguna(rs.getInt("idpengguna"));
                p.setUsername(rs.getString("username"));
                p.setKatalaluan(rs.getString("katalaluan"));
                p.setNama(rs.getString("nama"));
                p.setNotelefon(rs.getString("notelefon"));
                p.setPeranan(rs.getString("peranan"));
                p.setKodtadika(rs.getString("kodtadika"));
                p.setDunseliaan(rs.getString("dunseliaan"));
                p.setTarikhdicipta(rs.getString("tarikhdicipta"));
                p.setGambarprofil(rs.getString("gambarprofil"));
                return p;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Kemaskini profil (nama, no telefon)
    public boolean updateProfile(int idpengguna, String nama, String notelefon) {
        String sql = "UPDATE pengguna SET nama = ?, notelefon = ? WHERE idpengguna = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nama);
            ps.setString(2, notelefon);
            ps.setInt(3, idpengguna);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Tukar kata laluan (dengan semakan kata laluan lama)
    public boolean changePassword(int idpengguna, String oldPassword, String newPassword) {
        String sqlSelect = "SELECT katalaluan FROM pengguna WHERE idpengguna = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement psSelect = conn.prepareStatement(sqlSelect)) {
            psSelect.setInt(1, idpengguna);
            ResultSet rs = psSelect.executeQuery();
            if (rs.next()) {
                String storedHash = rs.getString("katalaluan");
                if (!storedHash.equals(hashPassword(oldPassword))) {
                    return false;
                }
            } else {
                return false;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }

        String sqlUpdate = "UPDATE pengguna SET katalaluan = ? WHERE idpengguna = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate)) {
            psUpdate.setString(1, hashPassword(newPassword));
            psUpdate.setInt(2, idpengguna);
            return psUpdate.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ============ METHOD BARU UNTUK GURU BESAR ============
    // Kira jumlah guru dan guru besar mengikut kod tadika (untuk Guru Besar)
    public int countGuruByTadika(String kodTadika) {
        String sql = "SELECT COUNT(*) FROM pengguna p "
                + "JOIN guru g ON p.idpengguna = g.idpengguna "
                + "WHERE g.kodtadika = ? AND p.peranan IN ('guru', 'gurubesar')";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodTadika);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Dapatkan senarai guru (guru dan guru besar) mengikut kod tadika
    public List<Map<String, String>> getGuruByTadika(String kodTadika) {
        List<Map<String, String>> list = new ArrayList<>();

        String sql = "SELECT p.idpengguna, p.nama, p.notelefon, p.peranan, "
                + "g.kelayakanakademik, g.gredjawatan, "
                + "DATE_FORMAT(g.tarikhlantikan, '%d-%m-%Y') as tarikhkontokan "
                + "FROM pengguna p "
                + "JOIN guru g ON p.idpengguna = g.idpengguna "
                + "WHERE g.kodtadika = ? AND p.peranan IN ('guru', 'gurubesar') "
                + "ORDER BY p.peranan DESC, p.nama";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodTadika);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, String> row = new HashMap<>();
                row.put("idpengguna", String.valueOf(rs.getInt("idpengguna")));
                row.put("nama", rs.getString("nama"));
                row.put("notelefon", rs.getString("notelefon") != null ? rs.getString("notelefon") : "-");
                row.put("peranan", rs.getString("peranan"));
                row.put("kelayakanakademik", rs.getString("kelayakanakademik") != null ? rs.getString("kelayakanakademik") : "-");
                row.put("gredjawatan", rs.getString("gredjawatan") != null ? rs.getString("gredjawatan") : "-");
                row.put("tarikhkontokan", rs.getString("tarikhkontokan") != null ? rs.getString("tarikhkontokan") : "-");
                list.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    // Kira jumlah guru besar mengikut kod tadika
    public int countGuruBesarByTadika(String kodTadika) {
        String sql = "SELECT COUNT(*) FROM pengguna p "
                + "JOIN guru g ON p.idpengguna = g.idpengguna "
                + "WHERE g.kodtadika = ? AND p.peranan = 'gurubesar'";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodTadika);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ===================================================
}
