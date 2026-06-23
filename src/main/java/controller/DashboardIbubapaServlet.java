package controller;

import com.google.gson.Gson;
import dao.MuridDAO;
import dao.PermohonanDAO;
import dao.PrestasiAnakDAO;
import model.Pengguna;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/DashboardIbubapaServlet")
public class DashboardIbubapaServlet extends HttpServlet {

    private MuridDAO muridDAO = new MuridDAO();
    private PermohonanDAO permohonanDAO = new PermohonanDAO();
    private PrestasiAnakDAO prestasiAnakDAO = new PrestasiAnakDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        Pengguna p = (Pengguna) session.getAttribute("pengguna");
        if (p == null || !p.getPeranan().equals("ibubapa")) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        int idIbuBapa = p.getIdpengguna();

        int jumlahAnak = permohonanDAO.countAnakBerdaftar(idIbuBapa);
        int permohonanDalamProses = permohonanDAO.countByIbuBapaAndStatus(idIbuBapa, "dalamproses");
        List<Map<String, String>> permohonan = permohonanDAO.getPermohonanByIbuBapa(idIbuBapa);
        List<Map<String, String>> ringkasanAnak = muridDAO.getRingkasanAnakByIbuBapa(idIbuBapa);

        // ============ TAMBAH: Data prestasi untuk graf bar ============
        List<Map<String, Object>> prestasiAnak = new ArrayList<>();
        for (Map<String, String> anak : ringkasanAnak) {
            String nokad = anak.get("nokad");
            String nama = anak.get("namamurid");

            // Dapatkan purata markah untuk anak ini
            Map<String, String> ringkasan = prestasiAnakDAO.getRingkasanPrestasi(nokad);
            double purata = 0;
            try {
                purata = Double.parseDouble(ringkasan.get("purata"));
            } catch (NumberFormatException e) {
                purata = 0;
            }

            // Dapatkan gred terkini
            Map<String, String> prestasiTerkini = prestasiAnakDAO.getPrestasiTerkini(nokad);
            String gredTerkini = prestasiTerkini.get("gred");
            if (gredTerkini == null) {
                gredTerkini = "-";
            }

            Map<String, Object> dataAnak = new HashMap<>();
            dataAnak.put("nokad", nokad);
            dataAnak.put("nama", nama);
            dataAnak.put("purata", purata);
            dataAnak.put("gred", gredTerkini);
            prestasiAnak.add(dataAnak);
        }
        // ===============================================================

        Map<String, Object> result = new HashMap<>();
        result.put("jumlahAnak", jumlahAnak);
        result.put("permohonanDalamProses", permohonanDalamProses);
        result.put("permohonan", permohonan);
        result.put("ringkasanAnak", ringkasanAnak);
        result.put("prestasiAnak", prestasiAnak);  // Data untuk graf bar

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(new Gson().toJson(result));
    }
}
