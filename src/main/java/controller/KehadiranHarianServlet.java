package controller;

import dao.MuridDAO;
import dao.PrestasiMuridDAO;
import dao.GuruDAO;
import model.Murid;
import model.Pengguna;
import model.Guru;
import model.PrestasiMurid;
import java.io.IOException;
import java.sql.Date;
import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/KehadiranHarianServlet")
public class KehadiranHarianServlet extends HttpServlet {

    private MuridDAO muridDAO = new MuridDAO();
    private PrestasiMuridDAO prestasiDAO = new PrestasiMuridDAO();
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

        String kodTadika = pengguna.getKodtadika();
        String tarikhStr = request.getParameter("tarikh");

        Date tarikh;
        if (tarikhStr != null && !tarikhStr.isEmpty()) {
            tarikh = Date.valueOf(tarikhStr);
        } else {
            tarikh = new Date(System.currentTimeMillis());
        }

        // Get all students
        List<Murid> senaraiMurid = muridDAO.getMuridByKodTadika(kodTadika);

        // Get existing attendance for this date
        Map<String, String> kehadiranMap = new HashMap<>();
        for (Murid murid : senaraiMurid) {
            List<PrestasiMurid> prestasiList = prestasiDAO.getPrestasiByMuridAndDate(
                    murid.getNokadpengenalan(), tarikh);

            if (!prestasiList.isEmpty()) {
                PrestasiMurid prestasi = prestasiList.get(0);
                kehadiranMap.put(murid.getNokadpengenalan(), prestasi.getStatuskehadiran());
                if (prestasi.getCatatan() != null) {
                    kehadiranMap.put(murid.getNokadpengenalan() + "_catatan", prestasi.getCatatan());
                }
            }
        }

        request.setAttribute("senaraiMurid", senaraiMurid);
        request.setAttribute("kehadiranMap", kehadiranMap);
        request.setAttribute("tarikh", tarikh.toString());

        request.getRequestDispatcher("/jsp/kehadiran_harian.jsp").forward(request, response);
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
        String tarikhStr = request.getParameter("tarikh");
        Date tarikh = Date.valueOf(tarikhStr);

        // Get changed IDs from form
        String changedIdsStr = request.getParameter("changedIds");
        List<String> changedIds = new ArrayList<>();

        if (changedIdsStr != null && !changedIdsStr.isEmpty()) {
            changedIds = Arrays.asList(changedIdsStr.split(","));
        }

        // Get guru ID
        Guru guru = guruDAO.getGuruByPenggunaId(pengguna.getIdpengguna());

        if ("save".equals(action)) {
            List<Murid> senaraiMurid = muridDAO.getMuridByKodTadika(pengguna.getKodtadika());
            int savedCount = 0;
            int skippedCount = 0;

            for (Murid murid : senaraiMurid) {
                // Hanya proses jika ID dalam senarai changedIds
                if (!changedIds.contains(murid.getNokadpengenalan())) {
                    skippedCount++;
                    continue;
                }

                String status = request.getParameter("status_" + murid.getNokadpengenalan());
                String catatan = request.getParameter("catatan_" + murid.getNokadpengenalan());

                if (status == null) {
                    status = "tidak hadir";
                }
                if (catatan == null) {
                    catatan = "";
                }

                // Check if attendance already exists for this date
                List<PrestasiMurid> existing = prestasiDAO.getPrestasiByMuridAndDate(
                        murid.getNokadpengenalan(), tarikh);

                PrestasiMurid prestasi = new PrestasiMurid();
                prestasi.setNokadpengenalanmurid(murid.getNokadpengenalan());
                prestasi.setIdguru(guru.getIdguru());
                prestasi.setTarikh(tarikh);
                prestasi.setJenisprestasi("kehadiran");
                prestasi.setStatuskehadiran(status);
                prestasi.setCatatan(catatan);

                if (existing.isEmpty()) {
                    if (prestasiDAO.addPrestasi(prestasi)) {
                        savedCount++;
                    }
                } else {
                    prestasi.setIdprestasi(existing.get(0).getIdprestasi());
                    if (prestasiDAO.updatePrestasi(prestasi)) {
                        savedCount++;
                    }
                }
            }

            request.setAttribute("success", savedCount + " rekod kehadiran berjaya disimpan");
        }

        // Refresh the page with current date
        doGet(request, response);
    }
}
