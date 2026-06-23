package controller;

import dao.PenggunaDAO;
import dao.GuruDAO;
import model.Pengguna;
import model.Guru;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ProfilGuruServlet")
public class ProfilGuruServlet extends HttpServlet {

    private PenggunaDAO penggunaDAO = new PenggunaDAO();
    private GuruDAO guruDAO = new GuruDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Pengguna pengguna = (Pengguna) session.getAttribute("pengguna");

        if (pengguna == null || !pengguna.getPeranan().equals("guru")) {
            response.sendRedirect(request.getContextPath() + "/log_masuk.jsp");
            return;
        }

        // Dapatkan maklumat guru
        Guru guru = guruDAO.getGuruByPenggunaId(pengguna.getIdpengguna());
        request.setAttribute("guru", guru);

        request.getRequestDispatcher("/jsp/profil_guru.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Pengguna pengguna = (Pengguna) session.getAttribute("pengguna");

        if (pengguna == null || !pengguna.getPeranan().equals("guru")) {
            response.sendRedirect(request.getContextPath() + "/log_masuk.jsp");
            return;
        }

        String action = request.getParameter("action");
        String successMsg = null;
        String errorMsg = null;

        if ("updateProfil".equals(action)) {
            // Update profil - guna method updateProfile sedia ada
            String nama = request.getParameter("nama");
            String notelefon = request.getParameter("notelefon");

            boolean updated = penggunaDAO.updateProfile(pengguna.getIdpengguna(), nama, notelefon);

            if (updated) {
                // Update session
                pengguna.setNama(nama);
                pengguna.setNotelefon(notelefon);
                session.setAttribute("pengguna", pengguna);
                successMsg = "Profil berjaya dikemaskini";
            } else {
                errorMsg = "Gagal mengemaskini profil";
            }

        } else if ("changePassword".equals(action)) {
            // Tukar kata laluan - guna method changePassword sedia ada
            String currentPassword = request.getParameter("currentPassword");
            String newPassword = request.getParameter("newPassword");

            boolean updated = penggunaDAO.changePassword(pengguna.getIdpengguna(), currentPassword, newPassword);

            if (updated) {
                successMsg = "Kata laluan berjaya ditukar";
            } else {
                errorMsg = "Kata laluan semasa tidak tepat atau gagal ditukar";
            }
        }

        // Refresh data guru
        Guru guru = guruDAO.getGuruByPenggunaId(pengguna.getIdpengguna());
        request.setAttribute("guru", guru);

        if (successMsg != null) {
            request.setAttribute("success", successMsg);
        }
        if (errorMsg != null) {
            request.setAttribute("error", errorMsg);
        }

        request.getRequestDispatcher("/jsp/profil_guru.jsp").forward(request, response);
    }
}
