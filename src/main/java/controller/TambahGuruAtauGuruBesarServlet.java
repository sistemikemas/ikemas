package controller;

import dao.PenggunaDAO;
import dao.TadikaDAO;
import model.Pengguna;
import model.Tadika;
import util.DewanUndanganNegeri;
import com.google.gson.Gson;
import java.io.IOException;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/TambahGuruAtauGuruBesarServlet")
public class TambahGuruAtauGuruBesarServlet extends HttpServlet {

    private final PenggunaDAO penggunaDAO = new PenggunaDAO();
    private final TadikaDAO tadikaDAO = new TadikaDAO();

    // ==================== GENERATE RANDOM PASSWORD ====================
    private String generateRandomPassword() {
        String upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        String lower = "abcdefghijklmnopqrstuvwxyz";
        String digits = "0123456789";
        String symbols = "@$!%*?&";
        String all = upper + lower + digits + symbols;
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder();

        // Ensure at least one from each category
        sb.append(upper.charAt(random.nextInt(upper.length())));
        sb.append(lower.charAt(random.nextInt(lower.length())));
        sb.append(digits.charAt(random.nextInt(digits.length())));
        sb.append(symbols.charAt(random.nextInt(symbols.length())));

        // Add 4 more random characters
        for (int i = 0; i < 4; i++) {
            sb.append(all.charAt(random.nextInt(all.length())));
        }

        // Shuffle
        char[] array = sb.toString().toCharArray();
        for (int i = array.length - 1; i > 0; i--) {
            int j = random.nextInt(i + 1);
            char temp = array[i];
            array[i] = array[j];
            array[j] = temp;
        }
        return new String(array);
    }

    // ==================== GENERATE USERNAME ====================
    private String generateUsername(String nama) {
        String base = nama.toLowerCase()
                .replaceAll("[^a-z0-9\\s]", "")
                .replaceAll("\\s+", "_");
        Random rand = new Random();
        int randomNum = rand.nextInt(900) + 100;
        String username = base + "_" + randomNum;

        try {
            while (penggunaDAO.isUsernameExists(username)) {
                randomNum = rand.nextInt(900) + 100;
                username = base + "_" + randomNum;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return username;
    }

    // ==================== HASH PASSWORD ====================
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

    // ==================== DO GET ====================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pengguna") == null) {
            response.sendRedirect(request.getContextPath() + "/log_masuk.jsp");
            return;
        }

        Pengguna p = (Pengguna) session.getAttribute("pengguna");
        if (!p.getPeranan().equals("penyelia")) {
            response.sendRedirect(request.getContextPath() + "/log_masuk.jsp");
            return;
        }

        // Handle AJAX request for tadika by DUN
        String action = request.getParameter("action");
        String dun = request.getParameter("dun");

        if ("getTadikaByDun".equals(action) && dun != null && !dun.isEmpty()) {
            List<Tadika> tadikaList = tadikaDAO.getTadikaByDun(dun);
            List<Map<String, String>> result = new ArrayList<>();

            for (Tadika t : tadikaList) {
                Map<String, String> item = new HashMap<>();
                item.put("kodtadika", t.getKodtadika());
                item.put("namatadika", t.getNamatadika());
                result.add(item);
            }

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            new Gson().toJson(result, response.getWriter());
            return;
        }

        // Load tadika list for the dropdown (all DUN under penyelia)
        String dunSeliaan = p.getDunseliaan();
        String[] dunArray = DewanUndanganNegeri.pecahkanDUN(dunSeliaan);
        List<Tadika> tadikaList = new ArrayList<>();

        for (String d : dunArray) {
            List<Tadika> list = tadikaDAO.getTadikaByDun(d);
            if (list != null) {
                tadikaList.addAll(list);
            }
        }

        request.setAttribute("senaraiTadika", tadikaList);
        request.getRequestDispatcher("/jsp/tambah_guru_atau_guru_besar.jsp").forward(request, response);
    }

    // ==================== DO POST ====================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pengguna") == null) {
            response.sendRedirect(request.getContextPath() + "/log_masuk.jsp");
            return;
        }

        Pengguna penyelia = (Pengguna) session.getAttribute("pengguna");
        if (!penyelia.getPeranan().equals("penyelia")) {
            response.sendRedirect(request.getContextPath() + "/log_masuk.jsp");
            return;
        }

        String nama = request.getParameter("nama");
        String peranan = request.getParameter("peranan");
        String kodtadika = request.getParameter("kodtadika");

        // Validation
        if (nama == null || peranan == null || kodtadika == null || nama.trim().isEmpty()) {
            request.setAttribute("error", "Semua maklumat perlu diisi.");
            doGet(request, response);
            return;
        }

        // Create new user
        String username = generateUsername(nama);
        String passwordRaw = generateRandomPassword();
        String hashedPassword = hashPassword(passwordRaw);

        Pengguna guru = new Pengguna();
        guru.setUsername(username);
        guru.setKatalaluan(hashedPassword);
        guru.setNama(nama);
        guru.setNotelefon(null);
        guru.setPeranan(peranan);
        guru.setKodtadika(kodtadika);
        guru.setDunseliaan(null);

        boolean success = penggunaDAO.register(guru);

        if (success) {
            request.setAttribute("success", true);
            request.setAttribute("newPassword", passwordRaw);
            request.setAttribute("username", username);
            request.setAttribute("nama", nama);
        } else {
            request.setAttribute("error", "Gagal menambah pengguna. Cuba lagi.");
        }

        doGet(request, response);
    }
}
