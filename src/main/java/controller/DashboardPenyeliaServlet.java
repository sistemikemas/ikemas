package controller;

import com.google.gson.Gson;
import dao.GuruDAO;
import dao.PemantauanDAO;
import dao.TadikaDAO;
import model.Pengguna;
import model.Tadika;
import util.DewanUndanganNegeri;
import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/DashboardPenyeliaServlet")
public class DashboardPenyeliaServlet extends HttpServlet {

    private TadikaDAO tadikaDAO = new TadikaDAO();
    private PemantauanDAO pemantauanDAO = new PemantauanDAO();
    private GuruDAO guruDAO = new GuruDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Sahkan session dan peranan pengguna
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pengguna") == null) {
            response.sendRedirect("log_masuk.jsp");
            return;
        }

        Pengguna p = (Pengguna) session.getAttribute("pengguna");
        if (!p.getPeranan().equals("penyelia")) {
            response.sendRedirect("log_masuk.jsp");
            return;
        }

        String dun = p.getDunseliaan();

        // Jika ada parameter 'ajax', hantar data dalam format JSON
        if (request.getParameter("ajax") != null) {
            handleAjax(request, response, p, dun);
            return;
        }

        // Jika tiada parameter 'ajax', paparkan halaman HTML
        handleHtml(request, response, p, dun);
    }

    /**
     * Handle permintaan AJAX - Hantar data dalam format JSON Sama macam
     * DashboardGuruBesarServlet
     */
    private void handleAjax(HttpServletRequest request, HttpServletResponse response,
            Pengguna p, String dun) throws IOException {

        String[] dunArray = DewanUndanganNegeri.pecahkanDUN(dun);
        Map<String, Object> result = new HashMap<>();

        try {
            // Dapatkan senarai tadika dari semua DUN
            List<Tadika> senaraiTadika = new ArrayList<>();
            for (String d : dunArray) {
                senaraiTadika.addAll(tadikaDAO.getTadikaByDun(d));
            }

            // Kira statistik utama
            int jumlahTadika = senaraiTadika.size();
            int jumlahMurid = 0;
            int jumlahGuru = 0;

            for (Tadika tadika : senaraiTadika) {
                jumlahMurid += tadikaDAO.getJumlahMuridByKodTadika(tadika.getKodtadika());
                jumlahGuru += guruDAO.getJumlahGuruByKodTadika(tadika.getKodtadika());
            }

            result.put("jumlahTadika", jumlahTadika);
            result.put("jumlahMurid", jumlahMurid);
            result.put("jumlahGuru", jumlahGuru);

            // Senarai 5 tadika teratas untuk jadual ringkasan
            List<Map<String, Object>> tadikaRingkasan = new ArrayList<>();
            int count = 0;
            for (Tadika tadika : senaraiTadika) {
                if (count >= 5) {
                    break;
                }
                count++;

                int jumlahMuridTadika = tadikaDAO.getJumlahMuridByKodTadika(tadika.getKodtadika());
                int jumlahGuruTadika = guruDAO.getJumlahGuruByKodTadika(tadika.getKodtadika());

                Map<String, Object> item = new HashMap<>();
                item.put("kodtadika", tadika.getKodtadika());
                item.put("namatadika", tadika.getNamatadika());
                item.put("jumlahMurid", jumlahMuridTadika);
                item.put("jumlahGuru", jumlahGuruTadika);

                // Tentukan gred berdasarkan bilangan murid
                String gred = "Tiada Data";
                String gredClass = "status-tolak";

                if (jumlahMuridTadika >= 40) {
                    gred = "A (Cemerlang)";
                    gredClass = "status-lulus";
                } else if (jumlahMuridTadika >= 25) {
                    gred = "B (Baik)";
                    gredClass = "status-dalamproses";
                } else if (jumlahMuridTadika >= 10) {
                    gred = "C (Memuaskan)";
                    gredClass = "status-buka";
                } else if (jumlahMuridTadika > 0) {
                    gred = "D (Perlu Penambahbaikan)";
                    gredClass = "status-tolak";
                }

                item.put("gred", gred);
                item.put("gredClass", gredClass);

                tadikaRingkasan.add(item);
            }
            result.put("senaraiTadika", tadikaRingkasan);

        } catch (SQLException e) {
            e.printStackTrace();
            result.put("jumlahTadika", 0);
            result.put("jumlahMurid", 0);
            result.put("jumlahGuru", 0);
            result.put("senaraiTadika", new ArrayList<>());
        }

        // Hantar response dalam format JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(new Gson().toJson(result));
    }

    /**
     * Handle permintaan HTML - Paparkan halaman dashboard Ini adalah kod asal
     * yang dipindahkan dari doGet()
     */
    private void handleHtml(HttpServletRequest request, HttpServletResponse response,
            Pengguna p, String dun) throws ServletException, IOException {

        String[] dunArray = DewanUndanganNegeri.pecahkanDUN(dun);

        try {
            // Dapatkan senarai tadika dari semua DUN
            List<Tadika> senaraiTadika = new ArrayList<>();
            for (String d : dunArray) {
                senaraiTadika.addAll(tadikaDAO.getTadikaByDun(d));
            }

            // Kira statistik
            int jumlahTadika = senaraiTadika.size();
            int jumlahMurid = 0;
            int jumlahGuru = 0;
            int jumlahPemantauan = 0;

            for (String d : dunArray) {
                jumlahPemantauan += pemantauanDAO.getJumlahPemantauanBulanIniByDun(d);
            }

            for (Tadika tadika : senaraiTadika) {
                jumlahMurid += tadikaDAO.getJumlahMuridByKodTadika(tadika.getKodtadika());
                jumlahGuru += guruDAO.getJumlahGuruByKodTadika(tadika.getKodtadika());
            }

            // Hantar data ke JSP melalui request attributes
            request.setAttribute("jumlahTadika", jumlahTadika);
            request.setAttribute("jumlahMurid", jumlahMurid);
            request.setAttribute("jumlahGuru", jumlahGuru);
            request.setAttribute("jumlahPemantauan", jumlahPemantauan);
            request.setAttribute("senaraiTadika", senaraiTadika);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("jumlahTadika", 0);
            request.setAttribute("jumlahMurid", 0);
            request.setAttribute("jumlahGuru", 0);
            request.setAttribute("jumlahPemantauan", 0);
            request.setAttribute("senaraiTadika", new ArrayList<>());
        }

        // Paparkan halaman JSP
        request.getRequestDispatcher("/jsp/dashboard_penyelia.jsp").forward(request, response);
    }
}
