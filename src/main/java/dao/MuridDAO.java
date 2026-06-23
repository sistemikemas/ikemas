package dao;

import model.Murid;
import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MuridDAO {

    public boolean insert(Murid m) {
        String sql = "INSERT INTO murid (nokadpengenalan, idibubapa, namamurid, tarikhlahir, umur, jantina, bangsa, alamat, poskod, kodtadika, tahunmasuk, gambarpassport) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, m.getNokadpengenalan());
            ps.setInt(2, m.getIdibubapa());
            ps.setString(3, m.getNamamurid());
            ps.setDate(4, m.getTarikhlahir());
            ps.setInt(5, m.getUmur());
            ps.setString(6, m.getJantina());
            ps.setString(7, m.getBangsa());
            ps.setString(8, m.getAlamat());
            ps.setString(9, m.getPoskod());
            ps.setString(10, m.getKodtadika());
            ps.setInt(11, m.getTahunmasuk());
            ps.setString(12, m.getGambarpassport());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public String getNamaByNoKad(String nokad) {
        String sql = "SELECT namamurid FROM murid WHERE nokadpengenalan = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nokad);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("namamurid");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "Tidak diketahui";
    }

    public int countByIbuBapa(int idIbuBapa) {
        String sql = "SELECT COUNT(*) FROM murid WHERE idibubapa = ?";
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

    // Method bagi prestasi murid
    // Dapatkan senarai anak berdaftar (status lulus) untuk ibu bapa
    public List<Map<String, String>> getAnakBerdaftarByIbuBapa(int idIbuBapa) {
        List<Map<String, String>> list = new ArrayList<>();

        String sql = "SELECT m.nokadpengenalan, m.namamurid, m.jantina, "
                + "t.namatadika "
                + "FROM murid m "
                + "JOIN permohonan p ON m.nokadpengenalan = p.nokadpengenalanmurid "
                + "JOIN tadika t ON p.kodtadika = t.kodtadika "
                + "WHERE m.idibubapa = ? AND p.statuspermohonan = 'lulus' "
                + "ORDER BY m.namamurid";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idIbuBapa);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, String> row = new HashMap<>();
                row.put("nokad", rs.getString("nokadpengenalan"));
                row.put("namamurid", rs.getString("namamurid"));
                row.put("jantina", rs.getString("jantina"));
                row.put("tadika", rs.getString("namatadika"));
                list.add(row);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    // ============ METHOD UNTUK RINGKASAN ANAK (DASHBOARD) ============
    // Dapatkan senarai anak berdaftar untuk paparan ringkas di dashboard
    public List<Map<String, String>> getRingkasanAnakByIbuBapa(int idIbuBapa) {
        List<Map<String, String>> list = new ArrayList<>();

        String sql = "SELECT m.nokadpengenalan, m.namamurid, m.tarikhLahir, "
                + "TIMESTAMPDIFF(YEAR, m.tarikhLahir, CURDATE()) as umur, "
                + "t.namatadika "
                + "FROM murid m "
                + "JOIN permohonan p ON m.nokadpengenalan = p.nokadpengenalanmurid "
                + "JOIN tadika t ON p.kodtadika = t.kodtadika "
                + "WHERE m.idibubapa = ? AND p.statuspermohonan = 'lulus' "
                + "ORDER BY m.namamurid";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idIbuBapa);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, String> row = new HashMap<>();
                row.put("nokad", rs.getString("nokadpengenalan"));
                row.put("namamurid", rs.getString("namamurid"));
                row.put("umur", String.valueOf(rs.getInt("umur")));
                row.put("tadika", rs.getString("namatadika"));
                list.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Method untuk semak sama ada murid sudah wujud
    public boolean isMuridExist(String nokadpengenalan) {
        String sql = "SELECT COUNT(*) FROM murid WHERE nokadpengenalan = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nokadpengenalan);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

// Method untuk dapatkan idibubapa bagi murid sedia ada
    public int getIdIbuBapaByNoKad(String nokadpengenalan) {
        String sql = "SELECT idibubapa FROM murid WHERE nokadpengenalan = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nokadpengenalan);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("idibubapa");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    // Dapatkan murid berdasarkan No. MyKid
    public Murid getMuridByNoKad(String nokad) {
        String sql = "SELECT * FROM murid WHERE nokadpengenalan = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nokad);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Murid m = new Murid();
                m.setNokadpengenalan(rs.getString("nokadpengenalan"));
                m.setIdibubapa(rs.getInt("idibubapa"));
                m.setNamamurid(rs.getString("namamurid"));
                m.setTarikhlahir(rs.getDate("tarikhlahir"));
                m.setUmur(rs.getInt("umur"));
                m.setJantina(rs.getString("jantina"));
                m.setBangsa(rs.getString("bangsa"));
                m.setAlamat(rs.getString("alamat"));
                m.setPoskod(rs.getString("poskod"));
                m.setKodtadika(rs.getString("kodtadika"));
                m.setTahunmasuk(rs.getInt("tahunmasuk"));
                m.setGambarpassport(rs.getString("gambarpassport"));
                return m;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    // Dapatkan senarai murid mengikut kod tadika (dengan nama ibu bapa)

    public List<Map<String, String>> getMuridByTadika(String kodTadika) {
        List<Map<String, String>> list = new ArrayList<>();

        String sql = "SELECT m.nokadpengenalan, m.namamurid, m.tarikhlahir, m.jantina, m.bangsa, "
                + "i.namabapa, "
                + "i.notelefonbapa, "
                + "i.namaibu, "
                + "i.notelefonibu "
                + "FROM murid m "
                + "JOIN ibubapa i ON m.idibubapa = i.idibubapa "
                + "WHERE m.kodtadika = ? "
                + "ORDER BY m.namamurid";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodTadika);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, String> row = new HashMap<>();
                row.put("nokadpengenalan", rs.getString("nokadpengenalan"));
                row.put("namamurid", rs.getString("namamurid"));
                row.put("tarikhlahir", rs.getDate("tarikhlahir") != null ? new java.text.SimpleDateFormat("dd-MM-yyyy").format(rs.getDate("tarikhlahir")) : "-");
                row.put("jantina", rs.getString("jantina") != null ? rs.getString("jantina") : "-");
                row.put("bangsa", rs.getString("bangsa") != null ? rs.getString("bangsa") : "-");
                row.put("namabapa", rs.getString("namabapa") != null ? rs.getString("namabapa") : "-");
                row.put("notelefonbapa", rs.getString("notelefonbapa") != null ? rs.getString("notelefonbapa") : "-");
                row.put("namaibu", rs.getString("namaibu") != null ? rs.getString("namaibu") : "-");
                row.put("notelefonibu", rs.getString("notelefonibu") != null ? rs.getString("notelefonibu") : "-");
                list.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    // Kira jumlah murid mengikut kod tadika
    public int countMuridByTadika(String kodTadika) {
        String sql = "SELECT COUNT(*) FROM murid WHERE kodtadika = ?";
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

    // Kira jumlah murid mengikut jantina
    public int countMuridByJantina(String kodTadika, String jantina) {
        String sql = "SELECT COUNT(*) FROM murid WHERE kodtadika = ? AND jantina = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodTadika);
            ps.setString(2, jantina);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ==================== METHOD UNTUK DASHBOARD GURU ====================
    // Method 1: Dapatkan jumlah murid mengikut kod tadika
    public int getJumlahMuridByTadika(String kodTadika) throws SQLException {
        String sql = "SELECT COUNT(*) FROM murid WHERE kodtadika = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodTadika);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw e;
        }
        return 0;
    }

    // Method 2: Dapatkan senarai murid (terhad mengikut limit) untuk dashboard
    public List<Murid> getMuridByTadika(String kodTadika, int limit) throws SQLException {
        List<Murid> muridList = new ArrayList<>();
        String sql = "SELECT nokadpengenalan, namamurid, jantina, tarikhlahir, tahunmasuk "
                + "FROM murid WHERE kodtadika = ? "
                + "ORDER BY tahunmasuk DESC, namamurid ASC LIMIT ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodTadika);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Murid murid = new Murid();
                    murid.setNokadpengenalan(rs.getString("nokadpengenalan"));
                    murid.setNamamurid(rs.getString("namamurid"));
                    murid.setJantina(rs.getString("jantina"));
                    murid.setTarikhlahir(rs.getDate("tarikhlahir"));
                    murid.setTahunmasuk(rs.getInt("tahunmasuk"));
                    muridList.add(murid);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw e;
        }
        return muridList;
    }

    // ==================== METHOD UNTUK REKOD PRESTASI MURID (GURU) ====================
    // Dapatkan senarai lengkap murid mengikut kod tadika (tanpa limit)
    public List<Murid> getMuridByKodTadika(String kodTadika) {
        List<Murid> list = new ArrayList<>();
        String sql = "SELECT * FROM murid WHERE kodtadika = ? ORDER BY namamurid ASC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, kodTadika);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Murid murid = new Murid();
                murid.setNokadpengenalan(rs.getString("nokadpengenalan"));
                murid.setIdibubapa(rs.getInt("idibubapa"));
                murid.setNamamurid(rs.getString("namamurid"));
                murid.setTarikhlahir(rs.getDate("tarikhlahir"));
                murid.setUmur(rs.getInt("umur"));
                murid.setJantina(rs.getString("jantina"));
                murid.setBangsa(rs.getString("bangsa"));
                murid.setAlamat(rs.getString("alamat"));
                murid.setPoskod(rs.getString("poskod"));
                murid.setKodtadika(rs.getString("kodtadika"));
                murid.setTahunmasuk(rs.getInt("tahunmasuk"));
                murid.setGambarpassport(rs.getString("gambarpassport"));
                list.add(murid);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    // ================================================================
}
