package controller;

import com.google.gson.Gson;
import dao.MuridDAO;
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

@WebServlet("/PrestasiAnakServlet")
public class PrestasiAnakServlet extends HttpServlet {

    private MuridDAO muridDAO = new MuridDAO();
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

        // Dapatkan No. MyKid dari parameter (jika ada)
        String nokadParam = request.getParameter("nokad");

        Map<String, Object> result = new HashMap<>();

        // Dapatkan senarai anak yang berdaftar (status lulus)
        List<Map<String, String>> senaraiAnak = muridDAO.getAnakBerdaftarByIbuBapa(idIbuBapa);
        result.put("senaraiAnak", senaraiAnak);

        // Jika ada nokad dipilih, dapatkan prestasi untuk anak tersebut
        if (nokadParam != null && !nokadParam.isEmpty()) {
            List<Map<String, String>> prestasi = prestasiAnakDAO.getPrestasiByNokad(nokadParam);
            Map<String, String> ringkasan = prestasiAnakDAO.getRingkasanPrestasi(nokadParam);
            result.put("prestasi", prestasi);
            result.put("ringkasan", ringkasan);
            result.put("nokadTerpilih", nokadParam);
        } else if (senaraiAnak != null && !senaraiAnak.isEmpty()) {
            // Jika tiada parameter, ambil anak pertama
            String nokadPertama = senaraiAnak.get(0).get("nokad");
            List<Map<String, String>> prestasi = prestasiAnakDAO.getPrestasiByNokad(nokadPertama);
            Map<String, String> ringkasan = prestasiAnakDAO.getRingkasanPrestasi(nokadPertama);
            result.put("prestasi", prestasi);
            result.put("ringkasan", ringkasan);
            result.put("nokadTerpilih", nokadPertama);
        } else {
            result.put("prestasi", new ArrayList<>());
            result.put("ringkasan", new HashMap<>());
            result.put("nokadTerpilih", null);
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(new Gson().toJson(result));
    }
}
