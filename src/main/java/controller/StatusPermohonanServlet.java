package controller;

import com.google.gson.Gson;
import dao.PermohonanDAO;
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

@WebServlet("/StatusPermohonanServlet")
public class StatusPermohonanServlet extends HttpServlet {

    private PermohonanDAO permohonanDAO = new PermohonanDAO();

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

        // Dapatkan semua permohonan
        List<Map<String, String>> semuaPermohonan = permohonanDAO.getPermohonanByIbuBapa(idIbuBapa);

        // Bahagikan kepada draf, dalam proses dan sejarah
        List<Map<String, String>> draf = new java.util.ArrayList<>();
        List<Map<String, String>> dalamProses = new java.util.ArrayList<>();
        List<Map<String, String>> sejarah = new java.util.ArrayList<>();

        for (Map<String, String> permohonan : semuaPermohonan) {
            String status = permohonan.get("status");
            if (status.equalsIgnoreCase("draf")) {
                draf.add(permohonan);
            } else if (status.equalsIgnoreCase("dalamproses") || status.equalsIgnoreCase("Dalam Proses")) {
                dalamProses.add(permohonan);
            } else {
                sejarah.add(permohonan);
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("draf", draf);
        result.put("dalamProses", dalamProses);
        result.put("sejarah", sejarah);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(new Gson().toJson(result));
    }
}
