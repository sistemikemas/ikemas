package controller;

import dao.MuridDAO;
import model.Murid;
import model.Pengguna;
import java.io.IOException;
import java.util.List;
import javax.servlet.RequestDispatcher;  // ← IMPORT INI PENTING
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/SenaraiMuridGuruServlet")
public class SenaraiMuridGuruServlet extends HttpServlet {

    private MuridDAO muridDAO = new MuridDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Pengguna pengguna = (Pengguna) session.getAttribute("pengguna");

        // Check if user is logged in and has guru role
        if (pengguna == null || !pengguna.getPeranan().equals("guru")) {
            response.sendRedirect(request.getContextPath() + "/log_masuk.jsp");
            return;
        }

        String kodTadika = pengguna.getKodtadika();

        // Get all students for this tadika
        List<Murid> senaraiMurid = muridDAO.getMuridByKodTadika(kodTadika);

        request.setAttribute("senaraiMurid", senaraiMurid);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/jsp/senarai_murid_guru.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
