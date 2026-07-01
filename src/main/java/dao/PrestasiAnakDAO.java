package dao;

import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PrestasiAnakDAO {

    // Dapatkan prestasi mengikut No. MyKid murid
    public List<Map<String, String>> getPrestasiByNokad(String nokad) {
        List<Map<String, String>> list = new ArrayList<>();

        String sql = "SELECT p.idprestasi, p.nokadpengenalanmurid, p.tarikh, "
                + "p.jenisprestasi, p.subjek, p.markahperatus, p.gred, p.catatan, "
                + "p.statuskehadiran, pg.nama as namaguru "
                + "FROM prestasimurid p "
                + "LEFT JOIN guru g ON p.idguru = g.idguru "
                + "LEFT JOIN pengguna pg ON g.idpengguna = pg.idpengguna "
                + "WHERE p.nokadpengenalanmurid = ? "
                + "ORDER BY p.tarikh DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, nokad);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, String> row = new HashMap<>();
                row.put("idprestasi", String.valueOf(rs.getInt("idprestasi")));
                row.put("nokadpengenalanmurid", rs.getString("nokadpengenalanmurid"));
                row.put("tarikh", rs.getString("tarikh"));
                row.put("jenisprestasi", rs.getString("jenisprestasi"));
                row.put("subjek", rs.getString("subjek") != null ? rs.getString("subjek") : "-");
                row.put("markahperatus", rs.getString("markahperatus"));
                row.put("gred", rs.getString("gred"));
                row.put("catatan", rs.getString("catatan") != null ? rs.getString("catatan") : "-");
                row.put("statuskehadiran", rs.getString("statuskehadiran") != null ? rs.getString("statuskehadiran") : "-");
                row.put("namaguru", rs.getString("namaguru") != null ? rs.getString("namaguru") : "-");
                list.add(row);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    // Dapatkan prestasi terkini untuk murid
    public Map<String, String> getPrestasiTerkini(String nokad) {
        Map<String, String> result = new HashMap<>();

        String sql = "SELECT p.jenisprestasi, p.markahperatus, p.gred, p.catatan, p.tarikh "
                + "FROM prestasimurid p "
                + "WHERE p.nokadpengenalanmurid = ? "
                + "ORDER BY p.tarikh DESC "
                + "LIMIT 1";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, nokad);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                result.put("jenisprestasi", rs.getString("jenisprestasi"));
                result.put("markahperatus", rs.getString("markahperatus"));
                result.put("gred", rs.getString("gred"));
                result.put("catatan", rs.getString("catatan") != null ? rs.getString("catatan") : "-");
                result.put("tarikh", rs.getString("tarikh"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return result;
    }

    // Dapatkan ringkasan prestasi (jumlah rekod dan purata markah)
    public Map<String, String> getRingkasanPrestasi(String nokad) {
        Map<String, String> result = new HashMap<>();

        String sql = "SELECT COUNT(*) as jumlah, AVG(p.markahperatus) as purata "
                + "FROM prestasimurid p "
                + "WHERE p.nokadpengenalanmurid = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, nokad);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                result.put("jumlah", rs.getString("jumlah"));
                result.put("purata", rs.getString("purata") != null ? String.format("%.2f", rs.getDouble("purata")) : "0");
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return result;
    }
}
