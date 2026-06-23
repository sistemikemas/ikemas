package controller;

import dao.PenggunaDAO;
import java.io.IOException;
import java.security.SecureRandom;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/LupaKataLaluanServlet")
public class LupaKataLaluanServlet extends HttpServlet {

    private PenggunaDAO penggunaDAO = new PenggunaDAO();

    // Jana kata laluan secara rawak
    private String generateRandomPassword() {
        String upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        String lower = "abcdefghijklmnopqrstuvwxyz";
        String digits = "0123456789";
        String symbols = "@$!%*?&";
        String all = upper + lower + digits + symbols;
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder();
        sb.append(upper.charAt(random.nextInt(upper.length())));
        sb.append(lower.charAt(random.nextInt(lower.length())));
        sb.append(digits.charAt(random.nextInt(digits.length())));
        sb.append(symbols.charAt(random.nextInt(symbols.length())));
        for (int i = 0; i < 4; i++) {
            sb.append(all.charAt(random.nextInt(all.length())));
        }
        char[] array = sb.toString().toCharArray();
        for (int i = array.length - 1; i > 0; i--) {
            int j = random.nextInt(i + 1);
            char temp = array[i];
            array[i] = array[j];
            array[j] = temp;
        }
        return new String(array);
    }

    // Hash password (SHA-256)
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("jsp/lupa_kata_laluan.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");

        if (username == null || username.trim().isEmpty()) {
            request.setAttribute("error", "Sila masukkan username.");
            request.getRequestDispatcher("jsp/lupa_kata_laluan.jsp").forward(request, response);
            return;
        }

        try {
            boolean exists = penggunaDAO.isUsernameExists(username);
            if (!exists) {
                request.setAttribute("error", "Username tidak ditemui.");
                request.getRequestDispatcher("jsp/lupa_kata_laluan.jsp").forward(request, response);
                return;
            }

            String newPassword = generateRandomPassword();
            String hashedPassword = hashPassword(newPassword);
            boolean updated = penggunaDAO.updatePassword(username, hashedPassword);

            if (updated) {
                request.setAttribute("success", true);
                request.setAttribute("newPassword", newPassword);
                request.setAttribute("username", username);
                request.getRequestDispatcher("jsp/lupa_kata_laluan.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Gagal menetapkan kata laluan baru. Cuba lagi.");
                request.getRequestDispatcher("jsp/lupa_kata_laluan.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Ralat sistem. Cuba lagi.");
            request.getRequestDispatcher("jsp/lupa_kata_laluan.jsp").forward(request, response);
        }
    }
}
