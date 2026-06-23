package controller;

import dao.MuridDAO;
import dao.PrestasiMuridDAO;
import model.Pengguna;
import model.Murid;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.time.temporal.TemporalAdjusters;

@WebServlet("/DashboardGuruServlet")
public class DashboardGuruServlet extends HttpServlet {

    private MuridDAO muridDAO;
    private PrestasiMuridDAO prestasiDAO;

    @Override
    public void init() {
        muridDAO = new MuridDAO();
        prestasiDAO = new PrestasiMuridDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Pengguna pengguna = (Pengguna) session.getAttribute("pengguna");

        if (pengguna == null || !pengguna.getPeranan().equals("guru")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        String kodTadika = pengguna.getKodtadika();

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            if (action == null) {
                // Dashboard utama - return semua data
                Map<String, Object> dashboardData = getDashboardData(kodTadika);
                String json = new Gson().toJson(dashboardData);
                response.getWriter().write(json);

            } else if (action.equals("kehadiran")) {
                // Data kehadiran untuk graf garis
                int bulan = Integer.parseInt(request.getParameter("bulan"));
                int tahun = Integer.parseInt(request.getParameter("tahun"));
                List<Map<String, Object>> kehadiranData = getKehadiranData(kodTadika, bulan, tahun);
                String json = new Gson().toJson(Map.of("kehadiranHarian", kehadiranData));
                response.getWriter().write(json);

            } else if (action.equals("prestasi")) {
                // Data prestasi untuk graf bar
                int bulan = Integer.parseInt(request.getParameter("bulan"));
                int tahun = Integer.parseInt(request.getParameter("tahun"));
                List<Map<String, Object>> prestasiData = getPrestasiData(kodTadika, bulan, tahun);
                String json = new Gson().toJson(Map.of("prestasiMurid", prestasiData));
                response.getWriter().write(json);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }

    private Map<String, Object> getDashboardData(String kodTadika) throws SQLException {
        Map<String, Object> data = new HashMap<>();

        // 1. Jumlah murid
        int jumlahMurid = muridDAO.getJumlahMuridByTadika(kodTadika);
        data.put("jumlahMurid", jumlahMurid);

        // 2. Kehadiran hari ini
        int kehadiranHariIni = prestasiDAO.getKehadiranHariIni(kodTadika);
        data.put("kehadiranHariIni", kehadiranHariIni);

        // 3. Senarai murid (5 terbaru)
        List<Murid> senaraiMurid = muridDAO.getMuridByTadika(kodTadika, 5);
        List<Map<String, Object>> muridList = new ArrayList<>();
        for (Murid murid : senaraiMurid) {
            Map<String, Object> muridMap = new HashMap<>();
            muridMap.put("nokadpengenalan", murid.getNokadpengenalan());
            muridMap.put("namamurid", murid.getNamamurid());
            muridMap.put("jantina", murid.getJantina());
            muridMap.put("tarikhlahir", murid.getTarikhlahir().toString());
            muridList.add(muridMap);
        }
        data.put("senaraiMurid", muridList);

        return data;
    }

    private List<Map<String, Object>> getKehadiranData(String kodTadika, int bulan, int tahun) throws SQLException {
        List<Map<String, Object>> result = new ArrayList<>();

        // Dapatkan jumlah murid
        int totalMurid = muridDAO.getJumlahMuridByTadika(kodTadika);

        // Dapatkan semua hari dalam bulan tersebut
        LocalDate firstDay = LocalDate.of(tahun, bulan, 1);
        LocalDate lastDay = firstDay.with(TemporalAdjusters.lastDayOfMonth());

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM");

        // Loop setiap hari dalam bulan
        for (LocalDate date = firstDay; !date.isAfter(lastDay); date = date.plusDays(1)) {
            // Skip weekend (Sabtu=Ahad=1-7, kita skip Sabtu=6 & Ahad=7)
            int dayOfWeek = date.getDayOfWeek().getValue();
            if (dayOfWeek == 6 || dayOfWeek == 7) {
                continue; // Skip Sabtu dan Ahad
            }

            int hadir = prestasiDAO.getKehadiranByDate(kodTadika, date);

            Map<String, Object> dayData = new HashMap<>();
            dayData.put("tarikh", date.format(formatter));
            dayData.put("hadir", hadir);
            dayData.put("totalMurid", totalMurid);
            result.add(dayData);
        }

        return result;
    }

    private List<Map<String, Object>> getPrestasiData(String kodTadika, int bulan, int tahun) throws SQLException {
        List<Map<String, Object>> result = new ArrayList<>();

        // Dapatkan semua murid di tadika ini (guna limit besar untuk dapat semua)
        List<Murid> semuaMurid = muridDAO.getMuridByTadika(kodTadika, 999);

        for (Murid murid : semuaMurid) {
            // Dapatkan purata markah untuk bulan tersebut
            double purataMarkah = prestasiDAO.getPurataMarkahByMuridAndMonth(
                    murid.getNokadpengenalan(), bulan, tahun);

            if (purataMarkah > 0) { // Hanya tunjuk yang ada rekod
                Map<String, Object> prestasiMap = new HashMap<>();
                prestasiMap.put("nama", murid.getNamamurid());
                prestasiMap.put("purata", Math.round(purataMarkah * 100.0) / 100.0);
                result.add(prestasiMap);
            }
        }

        // Sort by purata descending (tertinggi dulu)
        result.sort((a, b) -> Double.compare(
                (Double) b.get("purata"),
                (Double) a.get("purata")
        ));

        return result;
    }
}
