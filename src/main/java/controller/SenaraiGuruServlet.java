package controller;

import com.google.gson.Gson;
import dao.PenggunaDAO;
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

@WebServlet("/SenaraiGuruServlet")
public class SenaraiGuruServlet extends HttpServlet {

    private PenggunaDAO penggunaDAO = new PenggunaDAO();

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

        // Dapatkan senarai guru (peranan = 'guru' atau 'gurubesar')
        List<Map<String, String>> senaraiGuru = penggunaDAO.getGuruByTadika(kodTadika);

        // Dapatkan statistik
        int jumlahGuru = penggunaDAO.countGuruByTadika(kodTadika);
        int jumlahGuruBesar = penggunaDAO.countGuruBesarByTadika(kodTadika);

        Map<String, Object> result = new HashMap<>();
        result.put("senaraiGuru", senaraiGuru);
        result.put("jumlahGuru", jumlahGuru);
        result.put("jumlahGuruBesar", jumlahGuruBesar);

        // Jika request AJAX (JSON), hantar JSON
        String acceptHeader = request.getHeader("Accept");
        if (acceptHeader != null && acceptHeader.contains("application/json")) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(new Gson().toJson(result));
        } else {
            // Otherwise, forward to JSP
            request.setAttribute("senaraiGuru", senaraiGuru);
            request.setAttribute("jumlahGuru", jumlahGuru);
            request.setAttribute("jumlahGuruBesar", jumlahGuruBesar);
            request.getRequestDispatcher("/jsp/senarai_guru.jsp").forward(request, response);
        }
    }
}
