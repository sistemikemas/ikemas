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

@WebServlet("/LogMasukServlet")
public class LogMasukServlet extends HttpServlet {

    private PenggunaDAO penggunaDAO = new PenggunaDAO(); 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Ambil data dari form log masuk
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // 2. Sahkan log masuk melalui DAO
        Pengguna p = penggunaDAO.login(username, password);

        // 3. Jika berjaya
        if (p != null) {
            HttpSession session = request.getSession();
            session.setAttribute("pengguna", p); // simpan objek pengguna dalam session

            // 4. Redirect berdasarkan peranan
            String peranan = p.getPeranan();
            switch (peranan) {
                case "penyelia":
                    response.sendRedirect("jsp/dashboard_penyelia.jsp");
                    break;
                case "gurubesar":
                    response.sendRedirect("jsp/dashboard_guru_besar.jsp");
                    break;
                case "guru":
                    response.sendRedirect("jsp/dashboard_guru.jsp");
                    break;
                case "ibubapa":
                    response.sendRedirect("jsp/dashboard_ibubapa.jsp");
                    break;
                default:
                    response.sendRedirect("jsp/log_masuk.jsp");
            }
        } // 5. Jika gagal
        else {
            request.setAttribute("error", "Username atau kata laluan salah!");
            request.getRequestDispatcher("jsp/log_masuk.jsp").forward(request, response);
        }
    }
}
