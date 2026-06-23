package controller;

import dao.PrestasiMuridDAO;
import dao.TadikaDAO;
import model.Pengguna;
import model.Tadika;
import util.DewanUndanganNegeri;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LaporanPrestasiPenyeliaServlet")
public class LaporanPrestasiPenyeliaServlet extends HttpServlet {

    private TadikaDAO tadikaDAO = new TadikaDAO();
    private PrestasiMuridDAO prestasiDAO = new PrestasiMuridDAO();

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

        String tahunStr = request.getParameter("tahun");
        String bulanStr = request.getParameter("bulan");
        String tadikaKod = request.getParameter("tadika");
        String subjek = request.getParameter("subjek");

        int tahun = 2026;
        int bulan = 0; // 0 means all year

        if (tahunStr != null && !tahunStr.isEmpty()) {
            try {
                tahun = Integer.parseInt(tahunStr);
            } catch (NumberFormatException e) {
            }
        }
        if (bulanStr != null && !bulanStr.isEmpty()) {
            try {
                bulan = Integer.parseInt(bulanStr);
            } catch (NumberFormatException e) {
            }
        }

        // Get all tadika under penyelia's DUN
        String dunSeliaan = p.getDunseliaan();
        String[] dunArray = DewanUndanganNegeri.pecahkanDUN(dunSeliaan);
        List<Tadika> semuaTadika = new ArrayList<>();

        for (String dun : dunArray) {
            semuaTadika.addAll(tadikaDAO.getTadikaByDun(dun));
        }

        // Get list of tadika for dropdown
        request.setAttribute("senaraiTadika", semuaTadika);

        // Get list of subjek for filter
        List<String> senaraiSubjek = new ArrayList<>();
        senaraiSubjek.add("Bahasa Melayu");
        senaraiSubjek.add("Bahasa Inggeris");
        senaraiSubjek.add("Matematik");
        senaraiSubjek.add("Sains");
        senaraiSubjek.add("Pendidikan Islam");
        senaraiSubjek.add("Pendidikan Moral");
        request.setAttribute("senaraiSubjek", senaraiSubjek);

        // Get prestasi data for selected tadika
        List<Map<String, Object>> prestasiData = new ArrayList<>();

        if (tadikaKod != null && !tadikaKod.isEmpty()) {
            if (bulan == 0) {
                // Get monthly data for the whole year
                for (int m = 1; m <= 12; m++) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("bulan", m);
                    double purata = prestasiDAO.getPurataKeseluruhan(tadikaKod, m, tahun);
                    item.put("skor", purata);
                    prestasiData.add(item);
                }
            } else {
                // Get data for specific month
                List<Map<String, String>> muridData = prestasiDAO.getDataPentaksiran(tadikaKod, tahun, bulan, subjek);
                for (Map<String, String> data : muridData) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("namamurid", data.get("namamurid"));
                    double markah = 0;
                    String markahStr = data.get("markah");
                    if (markahStr != null && !markahStr.isEmpty() && !"-".equals(markahStr)) {
                        try {
                            markah = Double.parseDouble(markahStr);
                        } catch (NumberFormatException e) {
                            markah = 0;
                        }
                    }
                    item.put("markah", markah);
                    prestasiData.add(item);
                }
            }

            // Calculate summary statistics
            int totalMurid = prestasiData.size();
            double totalMarkah = 0;
            int hadir = 0;
            int gredA = 0, gredB = 0, gredC = 0, gredD = 0;

            for (Map<String, Object> item : prestasiData) {
                double markah = 0;
                if (bulan == 0) {
                    markah = (double) item.get("skor");
                } else {
                    markah = (double) item.get("markah");
                }

                if (markah > 0) {
                    totalMarkah += markah;
                    hadir++;

                    if (markah >= 80) {
                        gredA++;
                    } else if (markah >= 60) {
                        gredB++;
                    } else if (markah >= 50) {
                        gredC++;
                    } else if (markah > 0) {
                        gredD++;
                    }
                }
            }

            double purata = hadir > 0 ? totalMarkah / hadir : 0;
            int tidakHadir = totalMurid - hadir;

            request.setAttribute("purataKeseluruhan", purata);
            request.setAttribute("jumlahMurid", totalMurid);
            request.setAttribute("jumlahHadir", hadir);
            request.setAttribute("jumlahTidakHadir", tidakHadir);
            request.setAttribute("gredA", gredA);
            request.setAttribute("gredB", gredB);
            request.setAttribute("gredC", gredC);
            request.setAttribute("gredD", gredD);
        }

        request.setAttribute("prestasiData", prestasiData);
        request.setAttribute("selectedTahun", tahun);
        request.setAttribute("selectedBulan", bulan);
        request.setAttribute("selectedTadika", tadikaKod);
        request.setAttribute("selectedSubjek", subjek);

        request.getRequestDispatcher("/jsp/laporan_prestasi_penyelia.jsp").forward(request, response);
    }
}
