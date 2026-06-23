package controller;

import com.google.gson.Gson;
import dao.MuridDAO;
import dao.PenggunaDAO;
import dao.PermohonanDAO;
import dao.PrestasiMuridDAO;
import model.Pengguna;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/DashboardGuruBesarServlet")
public class DashboardGuruBesarServlet extends HttpServlet {

    private PermohonanDAO permohonanDAO = new PermohonanDAO();
    private MuridDAO muridDAO = new MuridDAO();
    private PenggunaDAO penggunaDAO = new PenggunaDAO();
    private PrestasiMuridDAO prestasiDAO = new PrestasiMuridDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        Pengguna p = (Pengguna) session.getAttribute("pengguna");
        if (p == null || !p.getPeranan().equals("gurubesar")) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String kodTadika = p.getKodtadika();

        Map<String, Object> result = new HashMap<>();

        // 1. Permohonan baru (status = 'dalamproses')
        int permohonanBaru = permohonanDAO.countByTadikaAndStatus(kodTadika, "dalamproses");
        result.put("permohonanBaru", permohonanBaru);

        // 2. Jumlah murid (status lulus)
        int jumlahMurid = permohonanDAO.countByTadikaAndStatus(kodTadika, "lulus");
        result.put("jumlahMurid", jumlahMurid);

        // 3. Jumlah guru (termasuk guru besar)
        int jumlahGuru = penggunaDAO.countGuruByTadika(kodTadika);
        result.put("jumlahGuru", jumlahGuru);

        // 4. Permohonan terkini (untuk aktiviti terkini)
        List<Map<String, String>> permohonanTerkini = permohonanDAO.getRecentByTadika(kodTadika, 5);
        result.put("permohonanTerkini", permohonanTerkini);

                // 5. Data prestasi murid untuk graf
        String bulanParam = request.getParameter("bulan");
        String tahunParam = request.getParameter("tahun");

        int bulan = (bulanParam != null) ? Integer.parseInt(bulanParam) : java.time.LocalDate.now().getMonthValue();
        int tahun = (tahunParam != null) ? Integer.parseInt(tahunParam) : java.time.LocalDate.now().getYear();

        List<Map<String, Object>> prestasiMurid = prestasiDAO.getPrestasiUntukGraf(kodTadika, bulan, tahun);
        result.put("prestasiMurid", prestasiMurid);

        // 6. Dapatkan senarai tahun yang ada prestasi (letak SEBELUM tulis response)
        List<Integer> senaraiTahun = prestasiDAO.getSenaraiTahun(kodTadika);
        result.put("senaraiTahun", senaraiTahun);

        // 7. Tulis response (hanya SEKALI di hujung)
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(new Gson().toJson(result));
    }
}
