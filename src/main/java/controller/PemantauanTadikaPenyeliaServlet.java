package controller;

import dao.PemantauanDAO;
import dao.TadikaDAO;
import model.Pengguna;
import model.Tadika;
import model.Pemantauan;
import util.DewanUndanganNegeri;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/PemantauanTadikaPenyeliaServlet")
public class PemantauanTadikaPenyeliaServlet extends HttpServlet {

    private TadikaDAO tadikaDAO = new TadikaDAO();
    private PemantauanDAO pemantauanDAO = new PemantauanDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pengguna") == null) {
            response.sendRedirect(request.getContextPath() + "/log_masuk.jsp");
            return;
        }

        Pengguna p = (Pengguna) session.getAttribute("pengguna");
        if (!p.getPeranan().equals("penyelia")) {
            response.sendRedirect(request.getContextPath() + "/log_masuk.jsp");
            return;
        }

        String action = request.getParameter("action");
        String idPemantauan = request.getParameter("id");
        String search = request.getParameter("search");
        String kodTadika = request.getParameter("kodtadika");
        String tahunStr = request.getParameter("tahun");

        int tahun = tahunStr != null ? Integer.parseInt(tahunStr) : java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
        request.setAttribute("selectedTahun", tahun);

        // Handle DELETE
        if ("delete".equals(action) && idPemantauan != null) {
            boolean deleted = pemantauanDAO.deletePemantauan(Integer.parseInt(idPemantauan));
            String redirectUrl = request.getContextPath() + "/PemantauanTadikaPenyeliaServlet?tahun=" + tahun;
            if (search != null) {
                redirectUrl += "&search=" + search;
            }
            if (deleted) {
                redirectUrl += "&toast_success=" + URLEncoder.encode("Pemantauan berjaya dihapuskan", StandardCharsets.UTF_8);
            } else {
                redirectUrl += "&toast_error=" + URLEncoder.encode("Gagal menghapuskan pemantauan", StandardCharsets.UTF_8);
            }
            response.sendRedirect(redirectUrl);
            return;
        }

        // Get all tadika under penyelia's DUN
        String dunSeliaan = p.getDunseliaan();
        String[] dunArray = DewanUndanganNegeri.pecahkanDUN(dunSeliaan);
        List<Tadika> semuaTadika = new ArrayList<>();

        for (String dun : dunArray) {
            semuaTadika.addAll(tadikaDAO.getTadikaByDun(dun));
        }

        // Filter tadika by search
        if (search != null && !search.trim().isEmpty()) {
            String searchLower = search.toLowerCase().trim();
            List<Tadika> filtered = new ArrayList<>();
            for (Tadika t : semuaTadika) {
                if (t.getKodtadika().toLowerCase().contains(searchLower)
                        || t.getNamatadika().toLowerCase().contains(searchLower)) {
                    filtered.add(t);
                }
            }
            semuaTadika = filtered;
            request.setAttribute("searchValue", search);
        }

        // Get pemantauan list
        List<Pemantauan> senaraiPemantauan = new ArrayList<>();
        if (kodTadika != null && !kodTadika.isEmpty()) {
            senaraiPemantauan = pemantauanDAO.getPemantauanByTadika(kodTadika);
            request.setAttribute("selectedTadika", kodTadika);
        }

        request.setAttribute("senaraiTadika", semuaTadika);
        request.setAttribute("senaraiPemantauan", senaraiPemantauan);

        request.getRequestDispatcher("/jsp/pemantauan_tadika_penyelia.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pengguna") == null) {
            response.sendRedirect(request.getContextPath() + "/log_masuk.jsp");
            return;
        }

        Pengguna p = (Pengguna) session.getAttribute("pengguna");
        if (!p.getPeranan().equals("penyelia")) {
            response.sendRedirect(request.getContextPath() + "/log_masuk.jsp");
            return;
        }

        String action = request.getParameter("action");
        String search = request.getParameter("search");
        String tahunStr = request.getParameter("tahun");
        int tahun = tahunStr != null ? Integer.parseInt(tahunStr) : java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);

        String successMsg = null;
        String errorMsg = null;

        if ("add".equals(action) || "edit".equals(action)) {
            String kodtadika = request.getParameter("kodtadika");
            String tarikhPemantauan = request.getParameter("tarikhpemantauan");
            String aspekdinilai = request.getParameter("aspekdinilai");
            String keputusan = request.getParameter("keputusan");
            String catatan = request.getParameter("catatan");
            String tindakanSusulan = request.getParameter("tindakansusulan");

            Pemantauan pemantauan = new Pemantauan();
            pemantauan.setKodtadika(kodtadika);
            pemantauan.setIdpenyelia(p.getIdpengguna());
            pemantauan.setTarikhpemantauan(Date.valueOf(tarikhPemantauan));
            pemantauan.setAspekdinilai(aspekdinilai);
            pemantauan.setKeputusanpemantauan(keputusan);
            pemantauan.setCatatanpenyelia(catatan);
            pemantauan.setTindakansusulan(tindakanSusulan);

            boolean success = false;

            if ("add".equals(action)) {
                success = pemantauanDAO.insertPemantauan(pemantauan);
                if (success) {
                    successMsg = "Pemantauan berjaya ditambah";
                } else {
                    errorMsg = "Gagal menambah pemantauan";
                }
            } else {
                String id = request.getParameter("id");
                pemantauan.setIdpemantauan(Integer.parseInt(id));
                success = pemantauanDAO.updatePemantauan(pemantauan);
                if (success) {
                    successMsg = "Pemantauan berjaya dikemaskini";
                } else {
                    errorMsg = "Gagal mengemaskini pemantauan";
                }
            }
        }

        String redirectUrl = request.getContextPath() + "/PemantauanTadikaPenyeliaServlet?tahun=" + tahun;
        if (search != null) {
            redirectUrl += "&search=" + search;
        }
        if (successMsg != null) {
            redirectUrl += "&toast_success=" + URLEncoder.encode(successMsg, StandardCharsets.UTF_8);
        }
        if (errorMsg != null) {
            redirectUrl += "&toast_error=" + URLEncoder.encode(errorMsg, StandardCharsets.UTF_8);
        }

        response.sendRedirect(redirectUrl);
    }
}
