package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LogKeluarServlet")
public class LogKeluarServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Dapatkan session semasa (jika ada)
        HttpSession session = request.getSession(false);

        // 2. Jika session wujud, musnahkan (hapus semua data pengguna)
        if (session != null) {
            session.invalidate();
        }

        // 3. Redirect ke halaman log masuk
        response.sendRedirect("jsp/log_masuk.jsp");
    }
}
