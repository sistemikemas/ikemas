package controller;

import dao.PemantauanDAO;
import dao.TadikaDAO;
import dao.GuruDAO;
import model.Pengguna;
import model.Tadika;
import util.DewanUndanganNegeri;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/DashboardPenyeliaServlet")
public class DashboardPenyeliaServlet extends HttpServlet {

    private TadikaDAO tadikaDAO = new TadikaDAO();
    private PemantauanDAO pemantauanDAO = new PemantauanDAO();
    private GuruDAO guruDAO = new GuruDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pengguna") == null) {
            response.sendRedirect("log_masuk.jsp");
            return;
        }

        Pengguna p = (Pengguna) session.getAttribute("pengguna");
        if (!p.getPeranan().equals("penyelia")) {
            response.sendRedirect("log_masuk.jsp");
            return;
        }

        String dun = p.getDunseliaan();

        // Pecahkan DUN kepada komponen individu
        String[] dunArray = DewanUndanganNegeri.pecahkanDUN(dun);

        try {
            // Dapatkan senarai tadika dari semua DUN
            List<Tadika> senaraiTadika = new ArrayList<>();
            for (String d : dunArray) {
                senaraiTadika.addAll(tadikaDAO.getTadikaByDun(d));
            }

            // Kira statistik
            int jumlahTadika = senaraiTadika.size();
            int jumlahMurid = 0;
            int jumlahGuru = 0;
            int jumlahPemantauan = 0;

            for (String d : dunArray) {
                jumlahPemantauan += pemantauanDAO.getJumlahPemantauanBulanIniByDun(d);
            }

            for (Tadika tadika : senaraiTadika) {
                jumlahMurid += tadikaDAO.getJumlahMuridByKodTadika(tadika.getKodtadika());
                jumlahGuru += guruDAO.getJumlahGuruByKodTadika(tadika.getKodtadika());
            }

            request.setAttribute("jumlahTadika", jumlahTadika);
            request.setAttribute("jumlahMurid", jumlahMurid);
            request.setAttribute("jumlahGuru", jumlahGuru);
            request.setAttribute("jumlahPemantauan", jumlahPemantauan);
            request.setAttribute("senaraiTadika", senaraiTadika);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("jumlahTadika", 0);
            request.setAttribute("jumlahMurid", 0);
            request.setAttribute("jumlahGuru", 0);
            request.setAttribute("jumlahPemantauan", 0);
            request.setAttribute("senaraiTadika", new ArrayList<>());
        }

        request.getRequestDispatcher("/jsp/dashboard_penyelia.jsp").forward(request, response);
    }
}
