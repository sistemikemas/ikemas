package controller;

import dao.MuridDAO;
import model.Pengguna;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/SenaraiMuridServlet")
public class SenaraiMuridServlet extends HttpServlet {

    private MuridDAO muridDAO = new MuridDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("log_masuk.jsp");
            return;
        }

        Pengguna p = (Pengguna) session.getAttribute("pengguna");
        if (p == null || !p.getPeranan().equals("gurubesar")) {
            response.sendRedirect("log_masuk.jsp");
            return;
        }

        String kodTadika = p.getKodtadika();

        // Dapatkan senarai murid
        List<Map<String, String>> senaraiMurid = muridDAO.getMuridByTadika(kodTadika);

        // Dapatkan statistik
        int jumlahMurid = muridDAO.countMuridByTadika(kodTadika);
        int jumlahLelaki = muridDAO.countMuridByJantina(kodTadika, "Lelaki");
        int jumlahPerempuan = muridDAO.countMuridByJantina(kodTadika, "Perempuan");

        request.setAttribute("senaraiMurid", senaraiMurid);
        request.setAttribute("jumlahMurid", jumlahMurid);
        request.setAttribute("jumlahLelaki", jumlahLelaki);
        request.setAttribute("jumlahPerempuan", jumlahPerempuan);

        request.getRequestDispatcher("/jsp/senarai_murid.jsp").forward(request, response);
    }
}
