// File: TadikaDAO.java
package dao;

import model.Tadika;
import util.DBConnection;
import util.DewanUndanganNegeri;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class TadikaDAO {

    // ==================== KOD SEDIA ADA (TIDAK DIUBAH) ====================
    public List<Tadika> getAllTadika() {
        List<Tadika> list = new ArrayList<>();
        String sql = "SELECT * FROM tadika ORDER BY namatadika";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Tadika t = new Tadika();
                t.setKodtadika(rs.getString("kodtadika"));
                t.setNamatadika(rs.getString("namatadika"));
                t.setAlamat(rs.getString("alamat"));
                t.setBilangankelas(rs.getInt("bilangankelas"));
                t.setDun(rs.getString("dun"));
                t.setIdpenyelia(rs.getInt("idpenyelia"));
                list.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Tadika getTadikaByKod(String kodtadika) {
        String sql = "SELECT * FROM tadika WHERE kodtadika = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodtadika);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Tadika t = new Tadika();
                t.setKodtadika(rs.getString("kodtadika"));
                t.setNamatadika(rs.getString("namatadika"));
                t.setAlamat(rs.getString("alamat"));
                t.setBilangankelas(rs.getInt("bilangankelas"));
                t.setDun(rs.getString("dun"));
                t.setIdpenyelia(rs.getInt("idpenyelia"));
                return t;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Tadika> getTadikaByDun(String dun) {
        List<Tadika> list = new ArrayList<>();
        String sql = "SELECT * FROM tadika WHERE TRIM(UPPER(dun)) = TRIM(UPPER(?)) ORDER BY namatadika";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dun);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Tadika t = new Tadika();
                t.setKodtadika(rs.getString("kodtadika"));
                t.setNamatadika(rs.getString("namatadika"));
                t.setAlamat(rs.getString("alamat"));
                t.setBilangankelas(rs.getInt("bilangankelas"));
                t.setSesipersekolahan(rs.getString("sesipersekolahan")); // ← PASTIKAN ADA
                t.setParlimen(rs.getString("parlimen"));
                t.setDun(rs.getString("dun"));
                t.setIdpenyelia(rs.getInt("idpenyelia"));
                list.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Tadika> getTadikaByDunList(String dunList) {
        List<Tadika> list = new ArrayList<>();
        if (dunList == null || dunList.trim().isEmpty()) {
            return list;
        }

        String[] dunArray = dunList.split(",");
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < dunArray.length; i++) {
            if (i > 0) {
                placeholders.append(",");
            }
            placeholders.append("?");
        }
        String sql = "SELECT * FROM tadika WHERE dun IN (" + placeholders.toString() + ") ORDER BY namatadika";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < dunArray.length; i++) {
                ps.setString(i + 1, dunArray[i].trim());
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Tadika t = new Tadika();
                t.setKodtadika(rs.getString("kodtadika"));
                t.setNamatadika(rs.getString("namatadika"));
                t.setAlamat(rs.getString("alamat"));
                t.setBilangankelas(rs.getInt("bilangankelas"));
                t.setDun(rs.getString("dun"));
                t.setIdpenyelia(rs.getInt("idpenyelia"));
                list.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getJumlahTadikaByDun(String dun) throws SQLException {
        String sql = "SELECT COUNT(*) FROM tadika WHERE UPPER(dun) = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dun.toUpperCase());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }

    public int getJumlahMuridByDun(String dun) throws SQLException {
        String sql = "SELECT COUNT(m.nokadpengenalan) FROM murid m "
                + "JOIN tadika t ON m.kodtadika = t.kodtadika "
                + "WHERE UPPER(t.dun) = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dun.toUpperCase());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }

    public int getJumlahMuridByKodTadika(String kodTadika) throws SQLException {
        String sql = "SELECT COUNT(*) FROM murid WHERE kodtadika = ?";

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

    // ==================== METHOD TAMBAHAN UNTUK DASHBOARD ====================
    // Dapatkan jumlah guru mengikut kod tadika (panggil dari GuruDAO sebenarnya, tapi untuk convenience)
    public int getJumlahGuruByKodTadika(String kodTadika) throws SQLException {
        String sql = "SELECT COUNT(*) FROM guru WHERE kodtadika = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, kodTadika);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    // Generate kod tadika auto berdasarkan DUN
    public String generateKodTadika(String dun) {
        // Tentukan prefix berdasarkan DUN
        String prefix = "";
        if (dun.toUpperCase().contains("TEPOH")) {
            prefix = "TPH";
        } else if (dun.toUpperCase().contains("BUKIT TUNGGAL")) {
            prefix = "BTG";
        } else if (dun.toUpperCase().contains("BULUH GADING")) {
            prefix = "BLG";
        } else if (dun.toUpperCase().contains("SEBERANG TAKIR")) {
            prefix = "SBT";
        } else {
            prefix = "TAD";
        }

        // Cari kod tertinggi untuk prefix ini
        String sql = "SELECT kodtadika FROM tadika WHERE kodtadika LIKE ? ORDER BY kodtadika DESC LIMIT 1";
        String newKod = prefix + "001";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, prefix + "%");
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String lastKod = rs.getString("kodtadika");
                String numberPart = lastKod.substring(prefix.length());
                int nextNum = Integer.parseInt(numberPart) + 1;
                newKod = prefix + String.format("%03d", nextNum);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return newKod;
    }

// Insert tadika baru
    public boolean insertTadika(Tadika t) {
        String sql = "INSERT INTO tadika (kodtadika, namatadika, alamat, bilangankelas, sesipersekolahan, parlimen, dun, idpenyelia) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, t.getKodtadika());
            ps.setString(2, t.getNamatadika());
            ps.setString(3, t.getAlamat());
            ps.setInt(4, t.getBilangankelas());
            ps.setString(5, t.getSesipersekolahan());
            ps.setString(6, t.getParlimen());
            ps.setString(7, t.getDun());
            ps.setInt(8, t.getIdpenyelia());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

// Update tadika
    public boolean updateTadika(Tadika t) {
        String sql = "UPDATE tadika SET namatadika=?, alamat=?, bilangankelas=?, sesipersekolahan=?, parlimen=?, dun=?, idpenyelia=? WHERE kodtadika=?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, t.getNamatadika());
            ps.setString(2, t.getAlamat());
            ps.setInt(3, t.getBilangankelas());
            ps.setString(4, t.getSesipersekolahan());
            ps.setString(5, t.getParlimen());
            ps.setString(6, t.getDun());
            ps.setInt(7, t.getIdpenyelia());
            ps.setString(8, t.getKodtadika());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

// Delete tadika
    public boolean deleteTadika(String kodtadika) {
        String sql = "DELETE FROM tadika WHERE kodtadika = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodtadika);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
