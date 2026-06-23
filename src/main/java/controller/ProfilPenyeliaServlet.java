package controller;

import dao.PenggunaDAO;
import model.Pengguna;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ProfilPenyeliaServlet")
public class ProfilPenyeliaServlet extends HttpServlet {

    private PenggunaDAO penggunaDAO = new PenggunaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Pengguna pengguna = (Pengguna) session.getAttribute("pengguna");

        if (pengguna == null || !pengguna.getPeranan().equals("penyelia")) {
            response.sendRedirect(request.getContextPath() + "/log_masuk.jsp");
            return;
        }

        request.getRequestDispatcher("/jsp/profil_penyelia.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Pengguna pengguna = (Pengguna) session.getAttribute("pengguna");

        if (pengguna == null || !pengguna.getPeranan().equals("penyelia")) {
            response.sendRedirect(request.getContextPath() + "/log_masuk.jsp");
            return;
        }

        String action = request.getParameter("action");
        String successMsg = null;
        String errorMsg = null;

        if ("updateProfil".equals(action)) {
            String nama = request.getParameter("nama");
            String notelefon = request.getParameter("notelefon");

            boolean updated = penggunaDAO.updateProfile(pengguna.getIdpengguna(), nama, notelefon);

            if (updated) {
                pengguna.setNama(nama);
                pengguna.setNotelefon(notelefon);
                session.setAttribute("pengguna", pengguna);
                successMsg = "Profil berjaya dikemaskini";
            } else {
                errorMsg = "Gagal mengemaskini profil";
            }

        } else if ("changePassword".equals(action)) {
            String currentPassword = request.getParameter("currentPassword");
            String newPassword = request.getParameter("newPassword");

            boolean updated = penggunaDAO.changePassword(pengguna.getIdpengguna(), currentPassword, newPassword);

            if (updated) {
                successMsg = "Kata laluan berjaya ditukar";
            } else {
                errorMsg = "Kata laluan semasa tidak tepat atau gagal ditukar";
            }
        }

        if (successMsg != null) {
            request.setAttribute("success", successMsg);
        }
        if (errorMsg != null) {
            request.setAttribute("error", errorMsg);
        }

        request.getRequestDispatcher("/jsp/profil_penyelia.jsp").forward(request, response);
    }
}
