package controller;

import dao.PermohonanDAO;
import dao.MuridDAO;
import model.Pengguna;
import model.Permohonan;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import util.DBConnection;

@WebServlet("/KelulusanServlet")
public class KelulusanServlet extends HttpServlet {

    private PermohonanDAO permohonanDAO = new PermohonanDAO();
    private MuridDAO muridDAO = new MuridDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("jsp/log_masuk.jsp");
            return;
        }
        Pengguna p = (Pengguna) session.getAttribute("pengguna");
        if (p == null || !p.getPeranan().equals("gurubesar")) {
            response.sendRedirect("jsp/log_masuk.jsp");
            return;
        }

        String kodTadika = p.getKodtadika();
        if (kodTadika == null) {
            request.setAttribute("error", "Anda belum ditugaskan ke mana-mana tadika.");
            request.getRequestDispatcher("jsp/dashboard_guru_besar.jsp").forward(request, response);
            return;
        }

        List<Permohonan> senarai = permohonanDAO.getByTadika(kodTadika);
        request.setAttribute("senaraiPermohonan", senarai);
        
        // ==================== KIRA STAT DARI LIST ====================
        int countDalamProses = 0;
        int countLulus = 0;
        int countTolak = 0;
        
        if (senarai != null) {
            for (Permohonan perm : senarai) {
                String status = perm.getStatuspermohonan();
                if ("lulus".equals(status)) {
                    countLulus++;
                } else if ("tolak".equals(status)) {
                    countTolak++;
                } else {
                    countDalamProses++;
                }
            }
        }
        
        request.setAttribute("countJumlah", countDalamProses + countLulus + countTolak);
        request.setAttribute("countDalamProses", countDalamProses);
        request.setAttribute("countLulus", countLulus);
        request.setAttribute("countTolak", countTolak);
        // ============================================================
        
        request.getRequestDispatcher("jsp/kelulusan.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("jsp/log_masuk.jsp");
            return;
        }
        Pengguna p = (Pengguna) session.getAttribute("pengguna");
        if (p == null || !p.getPeranan().equals("gurubesar")) {
            response.sendRedirect("jsp/log_masuk.jsp");
            return;
        }

        String action = request.getParameter("action");
        String idStr = request.getParameter("id");
        String catatan = request.getParameter("catatan");

        if (idStr == null || action == null) {
            response.sendRedirect("KelulusanServlet");
            return;
        }

        int idpermohonan = Integer.parseInt(idStr);
        String statusBaru = action.equals("lulus") ? "lulus" : "tolak";

        // ========== DAPATKAN idgurubesar YANG BETUL ==========
        Integer idGuruBesar = null;
        String sql = "SELECT gb.idgurubesar FROM gurubesar gb "
                + "JOIN guru g ON gb.idguru = g.idguru "
                + "JOIN pengguna pg ON g.idpengguna = pg.idpengguna "
                + "WHERE pg.idpengguna = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, p.getIdpengguna());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                idGuruBesar = rs.getInt("idgurubesar");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Jika masih null, cuba dapatkan berdasarkan kodtadika
        if (idGuruBesar == null) {
            String sql2 = "SELECT idgurubesar FROM gurubesar WHERE kodtadika = ?";
            try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql2)) {
                ps.setString(1, p.getKodtadika());
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    idGuruBesar = rs.getInt("idgurubesar");
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        String catatanPenolakan = action.equals("tolak") ? catatan : null;

        System.out.println("=== KELULUSAN ===");
        System.out.println("idpermohonan: " + idpermohonan);
        System.out.println("statusBaru: " + statusBaru);
        System.out.println("idGuruBesar: " + idGuruBesar);

        boolean updated = permohonanDAO.updateStatus(idpermohonan, statusBaru, idGuruBesar, catatanPenolakan);

        if (updated) {
            response.sendRedirect("KelulusanServlet?success=1");
        } else {
            response.sendRedirect("KelulusanServlet?error=1");
        }
    }
}
