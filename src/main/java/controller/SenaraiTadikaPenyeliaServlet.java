package controller;

import dao.TadikaDAO;
import model.Pengguna;
import model.Tadika;
import util.DewanUndanganNegeri;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/SenaraiTadikaPenyeliaServlet")
public class SenaraiTadikaPenyeliaServlet extends HttpServlet {

    private TadikaDAO tadikaDAO = new TadikaDAO();

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
        String id = request.getParameter("id");
        String search = request.getParameter("search");

        // Handle DELETE
        if ("delete".equals(action) && id != null) {
            boolean deleted = tadikaDAO.deleteTadika(id);
            String redirectUrl = request.getContextPath() + "/SenaraiTadikaPenyeliaServlet?search=" + (search != null ? search : "");
            if (deleted) {
                redirectUrl += "&toast_success=" + URLEncoder.encode("Tadika berjaya dihapuskan", StandardCharsets.UTF_8);
            } else {
                redirectUrl += "&toast_error=" + URLEncoder.encode("Gagal menghapuskan tadika", StandardCharsets.UTF_8);
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

        // Handle SEARCH
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

        request.setAttribute("senaraiTadika", semuaTadika);
        request.getRequestDispatcher("/jsp/senarai_tadika_penyelia.jsp").forward(request, response);
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
        String successMsg = null;
        String errorMsg = null;

        if ("add".equals(action)) {
            String dun = request.getParameter("dun");
            String kodtadika = tadikaDAO.generateKodTadika(dun);
            String namatadika = request.getParameter("namatadika");
            String alamat = request.getParameter("alamat");
            int bilangankelas = Integer.parseInt(request.getParameter("bilangankelas"));
            String sesipersekolahan = request.getParameter("sesipersekolahan");
            int idpenyelia = p.getIdpengguna();

            Tadika tadika = new Tadika();
            tadika.setKodtadika(kodtadika);
            tadika.setNamatadika(namatadika);
            tadika.setAlamat(alamat);
            tadika.setBilangankelas(bilangankelas);
            tadika.setSesipersekolahan(sesipersekolahan);
            tadika.setDun(dun);
            tadika.setIdpenyelia(idpenyelia);

            boolean success = tadikaDAO.insertTadika(tadika);
            if (success) {
                successMsg = "Tadika berjaya ditambah (Kod: " + kodtadika + ")";
            } else {
                errorMsg = "Gagal menambah tadika. Kod mungkin sudah wujud.";
            }

        } else if ("edit".equals(action)) {
            String kodtadika = request.getParameter("kodtadika");
            String namatadika = request.getParameter("namatadika");
            String alamat = request.getParameter("alamat");
            int bilangankelas = Integer.parseInt(request.getParameter("bilangankelas"));
            String sesipersekolahan = request.getParameter("sesipersekolahan");
            String dun = request.getParameter("dun");
            int idpenyelia = p.getIdpengguna();

            Tadika tadika = new Tadika();
            tadika.setKodtadika(kodtadika);
            tadika.setNamatadika(namatadika);
            tadika.setAlamat(alamat);
            tadika.setBilangankelas(bilangankelas);
            tadika.setSesipersekolahan(sesipersekolahan);
            tadika.setDun(dun);
            tadika.setIdpenyelia(idpenyelia);

            boolean success = tadikaDAO.updateTadika(tadika);
            if (success) {
                successMsg = "Tadika berjaya dikemaskini";
            } else {
                errorMsg = "Gagal mengemaskini tadika";
            }
        }

        // Build redirect URL with toast messages
        String redirectUrl = request.getContextPath() + "/SenaraiTadikaPenyeliaServlet?search=" + (search != null ? search : "");

        if (successMsg != null) {
            redirectUrl += "&toast_success=" + URLEncoder.encode(successMsg, StandardCharsets.UTF_8);
        }
        if (errorMsg != null) {
            redirectUrl += "&toast_error=" + URLEncoder.encode(errorMsg, StandardCharsets.UTF_8);
        }

        response.sendRedirect(redirectUrl);
    }
}
