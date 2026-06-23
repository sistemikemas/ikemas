package dao;

import util.DBConnection;
import model.PrestasiMurid;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PrestasiMuridDAO {

    // ==================== DAPATKAN PRESTASI MURID UNTUK GRAF (GURU BESAR) ====================
    public List<Map<String, Object>> getPrestasiUntukGraf(String kodTadika, int bulan, int tahun) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT m.namamurid, AVG(p.markahperatus) as purata "
                + "FROM prestasimurid p "
                + "JOIN murid m ON p.nokadpengenalanmurid = m.nokadpengenalan "
                + "WHERE m.kodtadika = ? AND MONTH(p.tarikh) = ? AND YEAR(p.tarikh) = ? "
                + "GROUP BY m.nokadpengenalan "
                + "ORDER BY purata DESC "
                + "LIMIT 10";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodTadika);
            ps.setInt(2, bulan);
            ps.setInt(3, tahun);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("nama", rs.getString("namamurid"));
                row.put("purata", rs.getDouble("purata"));
                list.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ==================== DAPATKAN PURATA MARKAH KESELURUHAN UNTUK TADIKA ====================
    public double getPurataKeseluruhan(String kodTadika, int bulan, int tahun) {
        String sql = "SELECT AVG(p.markahperatus) as purata "
                + "FROM prestasimurid p "
                + "JOIN murid m ON p.nokadpengenalanmurid = m.nokadpengenalan "
                + "WHERE m.kodtadika = ? AND MONTH(p.tarikh) = ? AND YEAR(p.tarikh) = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodTadika);
            ps.setInt(2, bulan);
            ps.setInt(3, tahun);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble("purata");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Dapatkan senarai prestasi murid dengan filter subjek dan tarikh
    public List<Map<String, String>> getPrestasiMuridByTadika(String kodTadika,
            java.sql.Date tarikhDari, java.sql.Date tarikhHingga, String subjek) {
        List<Map<String, String>> list = new ArrayList<>();

        String sql = "SELECT DISTINCT m.nokadpengenalan, m.namamurid, m.jantina, "
                + "(SELECT markahperatus FROM prestasimurid p1 WHERE p1.nokadpengenalanmurid = m.nokadpengenalan "
                + "AND p1.jenisprestasi = 'kesediaantahun1' ";

        if (subjek != null && !subjek.isEmpty() && !subjek.equals("semua")) {
            sql += " AND p1.subjek = '" + subjek + "' ";
        }
        if (tarikhDari != null) {
            sql += " AND p1.tarikh >= '" + tarikhDari + "' ";
        }
        if (tarikhHingga != null) {
            sql += " AND p1.tarikh <= '" + tarikhHingga + "' ";
        }
        sql += "LIMIT 1) as kesediaan_tahun1, "
                + "(SELECT markahperatus FROM prestasimurid p2 WHERE p2.nokadpengenalanmurid = m.nokadpengenalan "
                + "AND p2.jenisprestasi = 'pentaksiranbulanan' ";

        if (subjek != null && !subjek.isEmpty() && !subjek.equals("semua")) {
            sql += " AND p2.subjek = '" + subjek + "' ";
        }
        if (tarikhDari != null) {
            sql += " AND p2.tarikh >= '" + tarikhDari + "' ";
        }
        if (tarikhHingga != null) {
            sql += " AND p2.tarikh <= '" + tarikhHingga + "' ";
        }
        sql += "ORDER BY p2.tarikh DESC LIMIT 1) as pentaksiran_bulanan "
                + "FROM murid m "
                + "WHERE m.kodtadika = ? "
                + "ORDER BY m.namamurid";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodTadika);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, String> row = new HashMap<>();
                row.put("nokadpengenalan", rs.getString("nokadpengenalan"));
                row.put("namamurid", rs.getString("namamurid"));
                row.put("jantina", rs.getString("jantina") != null ? rs.getString("jantina") : "-");

                String kesediaan = rs.getString("kesediaan_tahun1");
                row.put("kesediaan_tahun1", kesediaan != null ? kesediaan : "-");

                String pentaksiran = rs.getString("pentaksiran_bulanan");
                row.put("pentaksiran_bulanan", pentaksiran != null ? pentaksiran : "-");

                // Kira purata
                double purata = 0;
                int count = 0;
                if (kesediaan != null && !kesediaan.equals("-")) {
                    purata += Double.parseDouble(kesediaan);
                    count++;
                }
                if (pentaksiran != null && !pentaksiran.equals("-")) {
                    purata += Double.parseDouble(pentaksiran);
                    count++;
                }
                String purataStr = count > 0 ? String.valueOf(Math.round(purata / count)) : "-";
                row.put("purata", purataStr);

                // Tentukan gred
                String gred = "-";
                if (!purataStr.equals("-")) {
                    double nilaiPurata = Double.parseDouble(purataStr);
                    if (nilaiPurata >= 80) {
                        gred = "A (Cemerlang)";
                    } else if (nilaiPurata >= 60) {
                        gred = "B (Baik)";
                    } else if (nilaiPurata >= 50) {
                        gred = "C (Memuaskan)";
                    } else {
                        gred = "D (Perlu Penambahbaikan)";
                    }
                }
                row.put("gred", gred);

                list.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Dapatkan data trend markah mengikut jenis prestasi dan subjek
    public List<Map<String, Object>> getTrendMarkahByJenis(String kodTadika,
            java.sql.Date tarikhDari, java.sql.Date tarikhHingga, String subjek) {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = "SELECT MONTH(p.tarikh) as bulan, "
                + "AVG(CASE WHEN p.jenisprestasi = 'kesediaantahun1' THEN p.markahperatus END) as purata_kesediaan, "
                + "AVG(CASE WHEN p.jenisprestasi = 'pentaksiranbulanan' THEN p.markahperatus END) as purata_pentaksiran "
                + "FROM prestasimurid p "
                + "JOIN murid m ON p.nokadpengenalanmurid = m.nokadpengenalan "
                + "WHERE m.kodtadika = ? ";

        if (tarikhDari != null) {
            sql += " AND p.tarikh >= ? ";
        }
        if (tarikhHingga != null) {
            sql += " AND p.tarikh <= ? ";
        }
        if (subjek != null && !subjek.isEmpty() && !subjek.equals("semua")) {
            sql += " AND p.subjek = ? ";
        }

        sql += " GROUP BY MONTH(p.tarikh) ORDER BY bulan";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            int index = 1;
            ps.setString(index++, kodTadika);

            if (tarikhDari != null) {
                ps.setDate(index++, tarikhDari);
            }
            if (tarikhHingga != null) {
                ps.setDate(index++, tarikhHingga);
            }
            if (subjek != null && !subjek.isEmpty() && !subjek.equals("semua")) {
                ps.setString(index++, subjek);
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("bulan", rs.getInt("bulan"));

                double purataKesediaan = rs.getDouble("purata_kesediaan");
                row.put("purata_kesediaan", rs.wasNull() ? null : purataKesediaan);

                double purataPentaksiran = rs.getDouble("purata_pentaksiran");
                row.put("purata_pentaksiran", rs.wasNull() ? null : purataPentaksiran);

                list.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Kira jumlah murid dengan filter tarikh dan subjek
    public int countMuridByTadika(String kodTadika,
            java.sql.Date tarikhDari, java.sql.Date tarikhHingga, String subjek) {
        String sql = "SELECT COUNT(DISTINCT m.nokadpengenalan) FROM murid m "
                + "JOIN prestasimurid p ON m.nokadpengenalan = p.nokadpengenalanmurid "
                + "WHERE m.kodtadika = ? ";

        if (tarikhDari != null) {
            sql += " AND p.tarikh >= ? ";
        }
        if (tarikhHingga != null) {
            sql += " AND p.tarikh <= ? ";
        }
        if (subjek != null && !subjek.isEmpty() && !subjek.equals("semua")) {
            sql += " AND p.subjek = ? ";
        }

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            int index = 1;
            ps.setString(index++, kodTadika);

            if (tarikhDari != null) {
                ps.setDate(index++, tarikhDari);
            }
            if (tarikhHingga != null) {
                ps.setDate(index++, tarikhHingga);
            }
            if (subjek != null && !subjek.isEmpty() && !subjek.equals("semua")) {
                ps.setString(index++, subjek);
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Kira purata keseluruhan dengan filter tarikh dan subjek
    public double getPurataKeseluruhan(String kodTadika,
            java.sql.Date tarikhDari, java.sql.Date tarikhHingga, String subjek) {
        String sql = "SELECT AVG(purata) FROM ("
                + "SELECT m.nokadpengenalan, AVG(p.markahperatus) as purata "
                + "FROM murid m "
                + "JOIN prestasimurid p ON m.nokadpengenalan = p.nokadpengenalanmurid "
                + "WHERE m.kodtadika = ? ";

        if (tarikhDari != null) {
            sql += " AND p.tarikh >= ? ";
        }
        if (tarikhHingga != null) {
            sql += " AND p.tarikh <= ? ";
        }
        if (subjek != null && !subjek.isEmpty() && !subjek.equals("semua")) {
            sql += " AND p.subjek = ? ";
        }

        sql += " GROUP BY m.nokadpengenalan) as subquery";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            int index = 1;
            ps.setString(index++, kodTadika);

            if (tarikhDari != null) {
                ps.setDate(index++, tarikhDari);
            }
            if (tarikhHingga != null) {
                ps.setDate(index++, tarikhHingga);
            }
            if (subjek != null && !subjek.isEmpty() && !subjek.equals("semua")) {
                ps.setString(index++, subjek);
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Kira jumlah murid mengikut gred dengan filter tarikh dan subjek
    public int countMuridByGred(String kodTadika,
            java.sql.Date tarikhDari, java.sql.Date tarikhHingga, String subjek, String gred) {
        String sql = "SELECT COUNT(*) FROM ("
                + "SELECT m.nokadpengenalan, AVG(p.markahperatus) as purata "
                + "FROM murid m "
                + "JOIN prestasimurid p ON m.nokadpengenalan = p.nokadpengenalanmurid "
                + "WHERE m.kodtadika = ? ";

        if (tarikhDari != null) {
            sql += " AND p.tarikh >= ? ";
        }
        if (tarikhHingga != null) {
            sql += " AND p.tarikh <= ? ";
        }
        if (subjek != null && !subjek.isEmpty() && !subjek.equals("semua")) {
            sql += " AND p.subjek = ? ";
        }

        sql += " GROUP BY m.nokadpengenalan) as subquery ";

        if ("A".equals(gred)) {
            sql += "WHERE purata >= 80";
        } else if ("B".equals(gred)) {
            sql += "WHERE purata BETWEEN 60 AND 79";
        } else if ("C".equals(gred)) {
            sql += "WHERE purata BETWEEN 50 AND 59";
        } else if ("D".equals(gred)) {
            sql += "WHERE purata < 50";
        } else {
            return 0;
        }

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            int index = 1;
            ps.setString(index++, kodTadika);

            if (tarikhDari != null) {
                ps.setDate(index++, tarikhDari);
            }
            if (tarikhHingga != null) {
                ps.setDate(index++, tarikhHingga);
            }
            if (subjek != null && !subjek.isEmpty() && !subjek.equals("semua")) {
                ps.setString(index++, subjek);
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Dapatkan senarai tahun yang ada prestasi
    public List<Integer> getSenaraiTahun(String kodTadika) {
        List<Integer> list = new ArrayList<>();
        String sql = "SELECT DISTINCT YEAR(p.tarikh) as tahun "
                + "FROM prestasimurid p "
                + "JOIN murid m ON p.nokadpengenalanmurid = m.nokadpengenalan "
                + "WHERE m.kodtadika = ? "
                + "ORDER BY tahun DESC";
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

    // Dapatkan senarai subjek yang tersedia
    public List<String> getSenaraiSubjek(String kodTadika) {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT subjek FROM prestasimurid p "
                + "JOIN murid m ON p.nokadpengenalanmurid = m.nokadpengenalan "
                + "WHERE m.kodtadika = ? AND subjek IS NOT NULL "
                + "ORDER BY subjek";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodTadika);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getString("subjek"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Dapatkan senarai bulan yang ada prestasi
    public List<Integer> getSenaraiBulan(String kodTadika) {
        List<Integer> list = new ArrayList<>();
        String sql = "SELECT DISTINCT MONTH(p.tarikh) as bulan "
                + "FROM prestasimurid p "
                + "JOIN murid m ON p.nokadpengenalanmurid = m.nokadpengenalan "
                + "WHERE m.kodtadika = ? "
                + "ORDER BY bulan";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodTadika);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getInt("bulan"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ==================== METHOD UNTUK KESEDIAAN TAHUN 1 ====================
    // Dapatkan data untuk graf Kesediaan (Bar Chart)
    public List<Map<String, String>> getDataKesediaan(String kodTadika, Integer tahun, String subjek) {
        List<Map<String, String>> list = new ArrayList<>();

        String sql = "SELECT m.nokadpengenalan, m.namamurid, p.markahperatus "
                + "FROM murid m "
                + "JOIN prestasimurid p ON m.nokadpengenalan = p.nokadpengenalanmurid "
                + "WHERE m.kodtadika = ? "
                + "AND p.jenisprestasi = 'kesediaantahun1' ";

        if (tahun != null) {
            sql += " AND YEAR(p.tarikh) = " + tahun;
        }
        if (subjek != null && !subjek.isEmpty() && !subjek.equals("semua")) {
            sql += " AND p.subjek = '" + subjek + "' ";
        }

        sql += " ORDER BY p.markahperatus DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodTadika);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, String> row = new HashMap<>();
                row.put("nokadpengenalan", rs.getString("nokadpengenalan"));
                row.put("namamurid", rs.getString("namamurid"));
                row.put("markah", String.valueOf(rs.getDouble("markahperatus")));
                list.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Kira jumlah murid untuk Kesediaan
    public int countMuridKesediaan(String kodTadika, Integer tahun, String subjek) {
        String sql = "SELECT COUNT(DISTINCT m.nokadpengenalan) FROM murid m "
                + "JOIN prestasimurid p ON m.nokadpengenalan = p.nokadpengenalanmurid "
                + "WHERE m.kodtadika = ? "
                + "AND p.jenisprestasi = 'kesediaantahun1' ";

        if (tahun != null) {
            sql += " AND YEAR(p.tarikh) = " + tahun;
        }
        if (subjek != null && !subjek.isEmpty() && !subjek.equals("semua")) {
            sql += " AND p.subjek = '" + subjek + "' ";
        }

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

    // Kira bilangan gred untuk Kesediaan
    public int countGredKesediaan(String kodTadika, Integer tahun, String subjek, String gred) {
        String sql = "SELECT COUNT(*) FROM ("
                + "SELECT m.nokadpengenalan, p.markahperatus as markah "
                + "FROM murid m "
                + "JOIN prestasimurid p ON m.nokadpengenalan = p.nokadpengenalanmurid "
                + "WHERE m.kodtadika = ? "
                + "AND p.jenisprestasi = 'kesediaantahun1' ";

        if (tahun != null) {
            sql += " AND YEAR(p.tarikh) = " + tahun;
        }
        if (subjek != null && !subjek.isEmpty() && !subjek.equals("semua")) {
            sql += " AND p.subjek = '" + subjek + "' ";
        }

        sql += ") as subquery ";

        if ("A".equals(gred)) {
            sql += "WHERE markah >= 80";
        } else if ("B".equals(gred)) {
            sql += "WHERE markah BETWEEN 60 AND 79";
        } else if ("C".equals(gred)) {
            sql += "WHERE markah BETWEEN 50 AND 59";
        } else if ("D".equals(gred)) {
            sql += "WHERE markah < 50";
        } else {
            return 0;
        }

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

    // ==================== METHOD UNTUK PENTAKSIRAN BULANAN ====================
    // Dapatkan data untuk graf Pentaksiran (Bar Chart)
    public List<Map<String, String>> getDataPentaksiran(String kodTadika, Integer tahun, Integer bulan, String subjek) {
        List<Map<String, String>> list = new ArrayList<>();

        String sql = "SELECT m.nokadpengenalan, m.namamurid, p.tarikh, p.markahperatus "
                + "FROM murid m "
                + "JOIN prestasimurid p ON m.nokadpengenalan = p.nokadpengenalanmurid "
                + "WHERE m.kodtadika = ? "
                + "AND p.jenisprestasi = 'pentaksiranbulanan' ";

        if (tahun != null) {
            sql += " AND YEAR(p.tarikh) = " + tahun;
        }
        if (bulan != null) {
            sql += " AND MONTH(p.tarikh) = " + bulan;
        }
        if (subjek != null && !subjek.isEmpty() && !subjek.equals("semua")) {
            sql += " AND p.subjek = '" + subjek + "' ";
        }

        sql += " ORDER BY p.markahperatus DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodTadika);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, String> row = new HashMap<>();
                row.put("nokadpengenalan", rs.getString("nokadpengenalan"));
                row.put("namamurid", rs.getString("namamurid"));
                java.sql.Date tarikhSQL = rs.getDate("tarikh");
                String tarikhStr = "-";
                if (tarikhSQL != null) {
                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MM-yyyy");
                    tarikhStr = sdf.format(tarikhSQL);
                }
                row.put("tarikh", tarikhStr);
                row.put("markah", String.valueOf(rs.getDouble("markahperatus")));
                list.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Kira jumlah murid untuk Pentaksiran
    public int countMuridPentaksiran(String kodTadika, Integer tahun, Integer bulan, String subjek) {
        String sql = "SELECT COUNT(DISTINCT m.nokadpengenalan) FROM murid m "
                + "JOIN prestasimurid p ON m.nokadpengenalan = p.nokadpengenalanmurid "
                + "WHERE m.kodtadika = ? "
                + "AND p.jenisprestasi = 'pentaksiranbulanan' ";

        if (tahun != null) {
            sql += " AND YEAR(p.tarikh) = " + tahun;
        }
        if (bulan != null) {
            sql += " AND MONTH(p.tarikh) = " + bulan;
        }
        if (subjek != null && !subjek.isEmpty() && !subjek.equals("semua")) {
            sql += " AND p.subjek = '" + subjek + "' ";
        }

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

    // Kira bilangan gred untuk Pentaksiran
    public int countGredPentaksiran(String kodTadika, Integer tahun, Integer bulan, String subjek, String gred) {
        String sql = "SELECT COUNT(*) FROM ("
                + "SELECT m.nokadpengenalan, p.markahperatus as markah "
                + "FROM murid m "
                + "JOIN prestasimurid p ON m.nokadpengenalan = p.nokadpengenalanmurid "
                + "WHERE m.kodtadika = ? "
                + "AND p.jenisprestasi = 'pentaksiranbulanan' ";

        if (tahun != null) {
            sql += " AND YEAR(p.tarikh) = " + tahun;
        }
        if (bulan != null) {
            sql += " AND MONTH(p.tarikh) = " + bulan;
        }
        if (subjek != null && !subjek.isEmpty() && !subjek.equals("semua")) {
            sql += " AND p.subjek = '" + subjek + "' ";
        }

        sql += ") as subquery ";

        if ("A".equals(gred)) {
            sql += "WHERE markah >= 80";
        } else if ("B".equals(gred)) {
            sql += "WHERE markah BETWEEN 60 AND 79";
        } else if ("C".equals(gred)) {
            sql += "WHERE markah BETWEEN 50 AND 59";
        } else if ("D".equals(gred)) {
            sql += "WHERE markah < 50";
        } else {
            return 0;
        }

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

    // ==================== METHOD UNTUK DASHBOARD GURU ====================
    // Method 1: Dapatkan bilangan kehadiran hari ini untuk tadika tertentu
    public int getKehadiranHariIni(String kodTadika) throws SQLException {
        String sql = "SELECT COUNT(DISTINCT p.nokadpengenalanmurid) "
                + "FROM prestasimurid p "
                + "INNER JOIN murid m ON p.nokadpengenalanmurid = m.nokadpengenalan "
                + "WHERE m.kodtadika = ? "
                + "AND p.jenisprestasi = 'kehadiran' "
                + "AND DATE(p.tarikh) = CURDATE() "
                + "AND p.statuskehadiran = 'hadir'";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodTadika);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw e;
        }
        return 0;
    }

    // Method 2: Dapatkan bilangan kehadiran mengikut tarikh tertentu
    public int getKehadiranByDate(String kodTadika, java.time.LocalDate date) throws SQLException {
        String sql = "SELECT COUNT(DISTINCT p.nokadpengenalanmurid) "
                + "FROM prestasimurid p "
                + "INNER JOIN murid m ON p.nokadpengenalanmurid = m.nokadpengenalan "
                + "WHERE m.kodtadika = ? "
                + "AND p.jenisprestasi = 'kehadiran' "
                + "AND DATE(p.tarikh) = ? "
                + "AND p.statuskehadiran = 'hadir'";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, kodTadika);
            ps.setDate(2, java.sql.Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw e;
        }
        return 0;
    }

    // Method 3: Dapatkan purata markah murid untuk bulan dan tahun tertentu
    public double getPurataMarkahByMuridAndMonth(String nokadMurid, int bulan, int tahun) throws SQLException {
        String sql = "SELECT AVG(markahperatus) as purata "
                + "FROM prestasimurid "
                + "WHERE nokadpengenalanmurid = ? "
                + "AND jenisprestasi = 'pentaksiranbulanan' "
                + "AND MONTH(tarikh) = ? "
                + "AND YEAR(tarikh) = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nokadMurid);
            ps.setInt(2, bulan);
            ps.setInt(3, tahun);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("purata");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw e;
        }
        return 0;
    }

    // ==================== METHOD CRUD UNTUK REKOD PRESTASI MURID (GURU) ====================
    // CREATE - Tambah rekod prestasi baru
    public boolean addPrestasi(PrestasiMurid prestasi) {
        String sql = "INSERT INTO prestasimurid (nokadpengenalanmurid, idguru, tarikh, jenisprestasi, subjek, markahperatus, gred, catatan, statuskehadiran) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, prestasi.getNokadpengenalanmurid());
            stmt.setInt(2, prestasi.getIdguru());
            stmt.setDate(3, prestasi.getTarikh());
            stmt.setString(4, prestasi.getJenisprestasi());
            stmt.setString(5, prestasi.getSubjek());

            if (prestasi.getMarkahperatus() != null) {
                stmt.setDouble(6, prestasi.getMarkahperatus());
            } else {
                stmt.setNull(6, java.sql.Types.DECIMAL);
            }

            stmt.setString(7, prestasi.getGred());
            stmt.setString(8, prestasi.getCatatan());
            stmt.setString(9, prestasi.getStatuskehadiran());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // READ - Dapatkan rekod prestasi mengikut ID
    public PrestasiMurid getPrestasiById(int idPrestasi) {
        String sql = "SELECT * FROM prestasimurid WHERE idprestasi = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idPrestasi);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return extractPrestasiFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // READ - Dapatkan semua rekod prestasi untuk seorang murid
    public List<PrestasiMurid> getPrestasiByMurid(String nokadpengenalan) {
        List<PrestasiMurid> list = new ArrayList<>();
        String sql = "SELECT * FROM prestasimurid WHERE nokadpengenalanmurid = ? ORDER BY tarikh DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, nokadpengenalan);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                list.add(extractPrestasiFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // READ - Dapatkan rekod prestasi mengikut murid dan jenis prestasi
    public List<PrestasiMurid> getPrestasiByMuridAndJenis(String nokadpengenalan, String jenis) {
        List<PrestasiMurid> list = new ArrayList<>();
        String sql = "SELECT * FROM prestasimurid WHERE nokadpengenalanmurid = ? AND jenisprestasi = ? ORDER BY tarikh DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, nokadpengenalan);
            stmt.setString(2, jenis);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                list.add(extractPrestasiFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // UPDATE - Kemaskini rekod prestasi
    public boolean updatePrestasi(PrestasiMurid prestasi) {
        String sql = "UPDATE prestasimurid SET jenisprestasi=?, subjek=?, markahperatus=?, gred=?, catatan=?, statuskehadiran=?, tarikh=? "
                + "WHERE idprestasi=?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, prestasi.getJenisprestasi());
            stmt.setString(2, prestasi.getSubjek());

            if (prestasi.getMarkahperatus() != null) {
                stmt.setDouble(3, prestasi.getMarkahperatus());
            } else {
                stmt.setNull(3, java.sql.Types.DECIMAL);
            }

            stmt.setString(4, prestasi.getGred());
            stmt.setString(5, prestasi.getCatatan());
            stmt.setString(6, prestasi.getStatuskehadiran());
            stmt.setDate(7, prestasi.getTarikh());
            stmt.setInt(8, prestasi.getIdprestasi());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // DELETE - Hapus rekod prestasi
    public boolean deletePrestasi(int idPrestasi) {
        String sql = "DELETE FROM prestasimurid WHERE idprestasi = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, idPrestasi);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Helper method untuk extract data dari ResultSet ke object PrestasiMurid
    private PrestasiMurid extractPrestasiFromResultSet(ResultSet rs) throws SQLException {
        PrestasiMurid prestasi = new PrestasiMurid();
        prestasi.setIdprestasi(rs.getInt("idprestasi"));
        prestasi.setNokadpengenalanmurid(rs.getString("nokadpengenalanmurid"));
        prestasi.setIdguru(rs.getInt("idguru"));
        prestasi.setTarikh(rs.getDate("tarikh"));
        prestasi.setJenisprestasi(rs.getString("jenisprestasi"));
        prestasi.setSubjek(rs.getString("subjek"));

        double markah = rs.getDouble("markahperatus");
        prestasi.setMarkahperatus(rs.wasNull() ? null : markah);

        prestasi.setGred(rs.getString("gred"));
        prestasi.setCatatan(rs.getString("catatan"));
        prestasi.setStatuskehadiran(rs.getString("statuskehadiran"));
        return prestasi;
    }

    // Dapatkan rekod prestasi mengikut murid dan tarikh
    public List<PrestasiMurid> getPrestasiByMuridAndDate(String nokadpengenalan, Date tarikh) {
        List<PrestasiMurid> list = new ArrayList<>();
        String sql = "SELECT * FROM prestasimurid WHERE nokadpengenalanmurid = ? AND jenisprestasi = 'kehadiran' AND DATE(tarikh) = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, nokadpengenalan);
            stmt.setDate(2, tarikh);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                list.add(extractPrestasiFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
