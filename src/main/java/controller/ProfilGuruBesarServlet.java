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

@WebServlet("/ProfilGuruBesarServlet")
public class ProfilGuruBesarServlet extends HttpServlet {

    private PenggunaDAO penggunaDAO = new PenggunaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pengguna") == null) {
            response.sendRedirect("log_masuk.jsp");
            return;
        }
        Pengguna p = (Pengguna) session.getAttribute("pengguna");
        request.setAttribute("pengguna", p);
        request.getRequestDispatcher("jsp/profil_guru_besar.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pengguna") == null) {
            response.sendRedirect("log_masuk.jsp");
            return;
        }
        Pengguna p = (Pengguna) session.getAttribute("pengguna");

        String action = request.getParameter("action");
        if ("updateProfil".equals(action)) {
            // Kemaskini nama dan no telefon
            String nama = request.getParameter("nama");
            String notelefon = request.getParameter("notelefon");
            if (nama != null && !nama.trim().isEmpty()) {
                boolean success = penggunaDAO.updateProfile(p.getIdpengguna(), nama, notelefon);
                if (success) {
                    // Update session
                    p.setNama(nama);
                    p.setNotelefon(notelefon);
                    session.setAttribute("pengguna", p);
                    request.setAttribute("success", "Profil berjaya dikemaskini.");
                } else {
                    request.setAttribute("error", "Gagal mengemaskini profil.");
                }
            }
            request.setAttribute("pengguna", p);
            request.getRequestDispatcher("jsp/profil_guru_besar.jsp").forward(request, response);

        } else if ("changePassword".equals(action)) {
            // Tukar kata laluan
            String currentPassword = request.getParameter("currentPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            // Sahkan password semasa
            Pengguna loginCheck = penggunaDAO.login(p.getUsername(), currentPassword);
            if (loginCheck == null) {
                request.setAttribute("error", "Kata laluan semasa salah.");
                request.setAttribute("pengguna", p);
                request.getRequestDispatcher("jsp/profil_guru_besar.jsp").forward(request, response);
                return;
            }

            // Validasi password baru
            if (newPassword == null || newPassword.length() < 8 || !newPassword.matches(".*[A-Z].*")
                    || !newPassword.matches(".*[a-z].*") || !newPassword.matches(".*[0-9].*") || !newPassword.matches(".*[@$!%*?&].*")) {
                request.setAttribute("error", "Kata laluan baru mesti mempunyai sekurang-kurangnya 8 aksara, mengandungi huruf besar, huruf kecil, nombor dan simbol (@$!%*?&).");
                request.setAttribute("pengguna", p);
                request.getRequestDispatcher("jsp/profil_guru_besar.jsp").forward(request, response);
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("error", "Kata laluan baru dan sahkan kata laluan tidak sama.");
                request.setAttribute("pengguna", p);
                request.getRequestDispatcher("jsp/profil_guru_besar.jsp").forward(request, response);
                return;
            }

            String hashedNew = hashPassword(newPassword);
            boolean updated = penggunaDAO.updatePassword(p.getUsername(), hashedNew);
            if (updated) {
                request.setAttribute("success", "Kata laluan berjaya ditukar. Sila log masuk semula.");
                // Logout pengguna
                session.invalidate();
                response.sendRedirect("log_masuk.jsp");
                return;
            } else {
                request.setAttribute("error", "Gagal menukar kata laluan.");
                request.setAttribute("pengguna", p);
                request.getRequestDispatcher("jsp/profil_guru_besar.jsp").forward(request, response);
            }
        } else {
            response.sendRedirect("jsp/dashboard_guru_besar.jsp");
        }
    }

    private String hashPassword(String password) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes("UTF-8"));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
