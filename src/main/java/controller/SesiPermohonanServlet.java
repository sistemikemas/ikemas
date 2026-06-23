// File: SesiPermohonanServlet.java
package controller;

import com.google.gson.Gson;
import dao.SesiPermohonanDAO;
import model.Pengguna;
import util.DewanUndanganNegeri;  // TAMBAH: Import untuk pemetaan DUN
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/SesiPermohonanServlet")
public class SesiPermohonanServlet extends HttpServlet {

    private SesiPermohonanDAO sesiDAO = new SesiPermohonanDAO();

    // ==================== POST: BUKA / TUTUP SESI ====================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pengguna") == null) {
            response.sendRedirect("jsp/log_masuk.jsp");
            return;
        }

        Pengguna p = (Pengguna) session.getAttribute("pengguna");
        if (!p.getPeranan().equals("penyelia")) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        String tahunStr = request.getParameter("tahun");
        int tahun = (tahunStr != null) ? Integer.parseInt(tahunStr) : 2027;
        String dun = p.getDunseliaan();

        // Dapatkan pecahan DUN (contoh: "Tepoh Bukit Tunggal" -> ["TEPOH", "BUKIT TUNGGAL"])
        String[] pecahanDUN = DewanUndanganNegeri.pecahkanDUN(dun);

        boolean success = false;

        if ("buka".equals(action)) {
            // Untuk setiap DUN dalam pecahan, buka sesi
            for (String d : pecahanDUN) {
                if (sesiDAO.bukaSesi(tahun, d, p.getIdpengguna())) {
                    success = true;
                }
            }
        } else if ("tutup".equals(action)) {
            // Untuk setiap DUN dalam pecahan, tutup sesi
            for (String d : pecahanDUN) {
                if (sesiDAO.tutupSesi(tahun, d, p.getIdpengguna())) {
                    success = true;
                }
            }
        }

        response.sendRedirect("jsp/dashboard_penyelia.jsp?sesi=" + (success ? "success" : "fail"));
    }

    // ==================== GET: AMBIL STATUS SESI (JSON) ====================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();

        try {
            String action = request.getParameter("action");
            String tahunStr = request.getParameter("tahun");
            String dun = request.getParameter("dun");

            // TAMBAH: Standardkan nama DUN jika ada parameter dun
            if (dun != null && !dun.isEmpty()) {
                dun = DewanUndanganNegeri.getStandardDUN(dun);
            }

            int tahun = (tahunStr != null) ? Integer.parseInt(tahunStr) : 2027;

            // Handler untuk sejarah sesi
            if ("sejarah".equals(action)) {
                List<Map<String, Object>> sejarahList = sesiDAO.getSejarahSesiByDun(dun);
                out.write(new Gson().toJson(sejarahList));
            } // Handler untuk status semasa
            else {
                Map<String, Object> status = sesiDAO.getStatusSesi(tahun, dun);
                // Buang tarikhbuka dan tarikhtutup dari response (punca masalah)
                status.remove("tarikhbuka");
                status.remove("tarikhtutup");
                out.write(new Gson().toJson(status));
            }
        } catch (Exception e) {
            e.printStackTrace();
            // Return error sebagai JSON
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            error.put("status", "tutup");
            out.write(new Gson().toJson(error));
        }
    }
}
