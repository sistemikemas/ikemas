package controller;

import dao.PenggunaDAO;
import model.Pengguna;
import java.io.IOException;
import java.security.MessageDigest;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/DaftarAkaunBaruServlet")
public class DaftarAkaunBaruServlet extends HttpServlet {

    private PenggunaDAO penggunaDAO = new PenggunaDAO();

    // Hash password
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
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

    // Validasi kekuatan kata laluan
    private boolean isPasswordStrong(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        boolean hasUpper = false, hasLower = false, hasDigit = false, hasSymbol = false;
        String symbols = "@$!%*?&#";
        for (char c : password.toCharArray()) {
            if (Character.isUpperCase(c)) {
                hasUpper = true;
            } else if (Character.isLowerCase(c)) {
                hasLower = true;
            } else if (Character.isDigit(c)) {
                hasDigit = true;
            } else if (symbols.contains(String.valueOf(c))) {
                hasSymbol = true;
            }
        }
        return hasUpper && hasLower && hasDigit && hasSymbol;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String nama = request.getParameter("nama");
        String username = request.getParameter("username");
        String password = request.getParameter("katalaluan");
        String confirmPassword = request.getParameter("confirmPassword");
        String notelefon = request.getParameter("notelefon");

        // Validasi ringkas
        if (nama == null || username == null || password == null || confirmPassword == null || notelefon == null
                || nama.trim().isEmpty() || username.trim().isEmpty() || password.trim().isEmpty() || confirmPassword.trim().isEmpty() || notelefon.trim().isEmpty()) {
            request.setAttribute("error", "Semua maklumat perlu diisi.");
            request.getRequestDispatcher("jsp/daftar_akaun_baru.jsp").forward(request, response);
            return;
        }

        // Semak kata laluan dan pengesahan kata laluan sama atau tidak
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Kata laluan dan pengesahan tidak sepadan.");
            request.getRequestDispatcher("jsp/daftar_akaun_baru.jsp").forward(request, response);
            return;
        }

        // Validasi kekuatan password (standard keselamatan)
        if (!isPasswordStrong(password)) {
            request.setAttribute("error", "Kata laluan mesti mengandungi sekurang-kurangnya 8 aksara, huruf besar, huruf kecil, nombor dan simbol (@$!%*?&#).");
            request.getRequestDispatcher("jsp/daftar_akaun_baru.jsp").forward(request, response);
            return;
        }

        // Semak sama ada username sudah wujud
        try {
            if (penggunaDAO.isUsernameExists(username)) {
                request.setAttribute("error", "Username sudah wujud. Sila pilih username lain.");
                request.getRequestDispatcher("jsp/daftar_akaun_baru.jsp").forward(request, response);
                return;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Ralat sistem: Gagal menyemak username.");
            request.getRequestDispatcher("jsp/daftar_akaun_baru.jsp").forward(request, response);
            return;
        }

        // Cipta objek Pengguna
        Pengguna p = new Pengguna();
        p.setUsername(username);
        p.setKatalaluan(hashPassword(password)); 
        p.setNama(nama);
        p.setNotelefon(notelefon);
        p.setPeranan("ibubapa");
        p.setKodtadika(null);
        p.setDunseliaan(null);

        // Simpan ke database
        boolean success = penggunaDAO.register(p);
        if (success) {
            response.sendRedirect("jsp/log_masuk.jsp?register=success");
        } else {
            request.setAttribute("error", "Pendaftaran gagal. Sila cuba lagi.");
            request.getRequestDispatcher("jsp/daftar_akaun_baru.jsp").forward(request, response);
        }
    }
}
