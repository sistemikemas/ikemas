package controller;

import dao.*;
import model.*;
import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/RekodPrestasiMuridServlet")
public class RekodPrestasiMuridServlet extends HttpServlet {

    private MuridDAO muridDAO = new MuridDAO();
    private PrestasiMuridDAO prestasiDAO = new PrestasiMuridDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Pengguna pengguna = (Pengguna) session.getAttribute("pengguna");

        if (pengguna == null || !pengguna.getPeranan().equals("guru")) {
            response.sendRedirect("log_masuk.jsp");
            return;
        }

        String kodTadika = pengguna.getKodtadika();
        String search = request.getParameter("search");
        String jenis = request.getParameter("jenis");

        // Get all students for this tadika
        List<Murid> semuaMurid = muridDAO.getMuridByKodTadika(kodTadika);
        List<Murid> filteredMurid = new ArrayList<>();

        // Filter students based on search
        if (search != null && !search.trim().isEmpty()) {
            for (Murid murid : semuaMurid) {
                if (murid.getNamamurid().toLowerCase().contains(search.toLowerCase())
                        || murid.getNokadpengenalan().contains(search)) {
                    filteredMurid.add(murid);
                }
            }
        } else {
            filteredMurid = semuaMurid;
        }

        // Get prestasi records for filtered students
        Map<String, List<PrestasiMurid>> prestasiMap = new HashMap<>();
        for (Murid murid : filteredMurid) {
            List<PrestasiMurid> prestasiList;
            if (jenis != null && !jenis.isEmpty()) {
                prestasiList = prestasiDAO.getPrestasiByMuridAndJenis(murid.getNokadpengenalan(), jenis);
            } else {
                prestasiList = prestasiDAO.getPrestasiByMurid(murid.getNokadpengenalan());
            }
            if (!prestasiList.isEmpty()) {
                prestasiMap.put(murid.getNokadpengenalan(), prestasiList);
            }
        }

        request.setAttribute("senaraiMurid", filteredMurid);
        request.setAttribute("prestasiMap", prestasiMap);
        request.setAttribute("selectedMurid", search);
        request.setAttribute("selectedJenis", jenis);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/jsp/rekod_prestasi_murid.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Pengguna pengguna = (Pengguna) session.getAttribute("pengguna");

        if (pengguna == null || !pengguna.getPeranan().equals("guru")) {
            response.sendRedirect("log_masuk.jsp");
            return;
        }

        String action = request.getParameter("action");
        String message = null;
        String messageType = "success";

        try {
            if ("add".equals(action)) {
                // Add new prestasi record
                PrestasiMurid prestasi = new PrestasiMurid();
                prestasi.setNokadpengenalanmurid(request.getParameter("nokadpengenalan"));
                prestasi.setJenisprestasi(request.getParameter("jenisprestasi"));
                prestasi.setSubjek(request.getParameter("subjek"));

                String markahStr = request.getParameter("markahperatus");
                if (markahStr != null && !markahStr.isEmpty()) {
                    prestasi.setMarkahperatus(Double.parseDouble(markahStr));
                }

                prestasi.setGred(request.getParameter("gred"));
                prestasi.setCatatan(request.getParameter("catatan"));
                prestasi.setStatuskehadiran(request.getParameter("statuskehadiran"));
                prestasi.setTarikh(java.sql.Date.valueOf(request.getParameter("tarikh")));

                // Get guru ID
                GuruDAO guruDAO = new GuruDAO();
                Guru guru = guruDAO.getGuruByPenggunaId(pengguna.getIdpengguna());
                prestasi.setIdguru(guru.getIdguru());

                boolean success = prestasiDAO.addPrestasi(prestasi);
                if (success) {
                    message = "Rekod prestasi berjaya ditambah";
                } else {
                    message = "Gagal menambah rekod prestasi";
                    messageType = "error";
                }

            } else if ("edit".equals(action)) {
                // Update existing prestasi record
                int idPrestasi = Integer.parseInt(request.getParameter("idprestasi"));
                PrestasiMurid prestasi = prestasiDAO.getPrestasiById(idPrestasi);

                if (prestasi != null) {
                    prestasi.setJenisprestasi(request.getParameter("jenisprestasi"));
                    prestasi.setSubjek(request.getParameter("subjek"));

                    String markahStr = request.getParameter("markahperatus");
                    if (markahStr != null && !markahStr.isEmpty()) {
                        prestasi.setMarkahperatus(Double.parseDouble(markahStr));
                    } else {
                        prestasi.setMarkahperatus(null);
                    }

                    prestasi.setGred(request.getParameter("gred"));
                    prestasi.setCatatan(request.getParameter("catatan"));
                    prestasi.setStatuskehadiran(request.getParameter("statuskehadiran"));
                    prestasi.setTarikh(java.sql.Date.valueOf(request.getParameter("tarikh")));

                    boolean success = prestasiDAO.updatePrestasi(prestasi);
                    if (success) {
                        message = "Rekod prestasi berjaya dikemaskini";
                    } else {
                        message = "Gagal mengemaskini rekod prestasi";
                        messageType = "error";
                    }
                }

            } else if ("delete".equals(action)) {
                // Delete prestasi record
                int idPrestasi = Integer.parseInt(request.getParameter("idprestasi"));
                boolean success = prestasiDAO.deletePrestasi(idPrestasi);
                if (success) {
                    message = "Rekod prestasi berjaya dihapus";
                } else {
                    message = "Gagal menghapus rekod prestasi";
                    messageType = "error";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "Ralat: " + e.getMessage();
            messageType = "error";
        }

        // Set message attributes and redirect back to the list
        if (messageType.equals("success")) {
            request.setAttribute("success", message);
        } else {
            request.setAttribute("error", message);
        }

        // Preserve search parameters
        String search = request.getParameter("search");
        String jenis = request.getParameter("jenis");
        if (search != null && !search.isEmpty()) {
            request.setAttribute("search", search);
        }
        if (jenis != null && !jenis.isEmpty()) {
            request.setAttribute("jenis", jenis);
        }

        doGet(request, response);
    }
}
