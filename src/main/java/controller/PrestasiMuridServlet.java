package controller;

import dao.PrestasiMuridDAO;
import model.Pengguna;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/PrestasiMuridServlet")
public class PrestasiMuridServlet extends HttpServlet {

    private PrestasiMuridDAO prestasiDAO = new PrestasiMuridDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("log_masuk.jsp");
            return;
        }

        Pengguna p = (Pengguna) session.getAttribute("pengguna");
        if (p == null || !p.getPeranan().equals("gurubesar")) {
            response.sendRedirect("log_masuk.jsp");
            return;
        }

        String kodTadika = p.getKodtadika();

        // ==================== PARAMETER UNTUK KESEDIAAN TAHUN 1 ====================
        String tahunKesediaanStr = request.getParameter("tahunKesediaan");
        String subjekKesediaan = request.getParameter("subjekKesediaan");

        Integer tahunKesediaan = null;
        if (tahunKesediaanStr != null && !tahunKesediaanStr.isEmpty()) {
            tahunKesediaan = Integer.parseInt(tahunKesediaanStr);
        }

        // ==================== PARAMETER UNTUK PENTAKSIRAN BULANAN ====================
        String tahunPentaksiranStr = request.getParameter("tahunPentaksiran");
        String bulanPentaksiranStr = request.getParameter("bulanPentaksiran");
        String subjekPentaksiran = request.getParameter("subjekPentaksiran");

        Integer tahunPentaksiran = null;
        Integer bulanPentaksiran = null;

        if (tahunPentaksiranStr != null && !tahunPentaksiranStr.isEmpty()) {
            tahunPentaksiran = Integer.parseInt(tahunPentaksiranStr);
        }
        if (bulanPentaksiranStr != null && !bulanPentaksiranStr.isEmpty()) {
            bulanPentaksiran = Integer.parseInt(bulanPentaksiranStr);
        }

        // ==================== DATA UNTUK KESEDIAAN TAHUN 1 ====================
        // Data untuk graf (bar chart)
        List<Map<String, String>> dataKesediaan = prestasiDAO.getDataKesediaan(kodTadika, tahunKesediaan, subjekKesediaan);

        // Statistik
        int jumlahMuridKesediaan = prestasiDAO.countMuridKesediaan(kodTadika, tahunKesediaan, subjekKesediaan);
        int jumlahAKesediaan = prestasiDAO.countGredKesediaan(kodTadika, tahunKesediaan, subjekKesediaan, "A");
        int jumlahBKesediaan = prestasiDAO.countGredKesediaan(kodTadika, tahunKesediaan, subjekKesediaan, "B");
        int jumlahCKesediaan = prestasiDAO.countGredKesediaan(kodTadika, tahunKesediaan, subjekKesediaan, "C");
        int jumlahDKesediaan = prestasiDAO.countGredKesediaan(kodTadika, tahunKesediaan, subjekKesediaan, "D");

        // ==================== DATA UNTUK PENTAKSIRAN BULANAN ====================
        // Data untuk graf (bar chart)
        List<Map<String, String>> dataPentaksiran = prestasiDAO.getDataPentaksiran(kodTadika, tahunPentaksiran, bulanPentaksiran, subjekPentaksiran);

        // Statistik
        int jumlahMuridPentaksiran = prestasiDAO.countMuridPentaksiran(kodTadika, tahunPentaksiran, bulanPentaksiran, subjekPentaksiran);
        int jumlahAPentaksiran = prestasiDAO.countGredPentaksiran(kodTadika, tahunPentaksiran, bulanPentaksiran, subjekPentaksiran, "A");
        int jumlahBPentaksiran = prestasiDAO.countGredPentaksiran(kodTadika, tahunPentaksiran, bulanPentaksiran, subjekPentaksiran, "B");
        int jumlahCPentaksiran = prestasiDAO.countGredPentaksiran(kodTadika, tahunPentaksiran, bulanPentaksiran, subjekPentaksiran, "C");
        int jumlahDPentaksiran = prestasiDAO.countGredPentaksiran(kodTadika, tahunPentaksiran, bulanPentaksiran, subjekPentaksiran, "D");

        // ==================== SENARAI UNTUK DROPDOWN ====================
        List<Integer> senaraiTahun = prestasiDAO.getSenaraiTahun(kodTadika);
        List<String> senaraiSubjek = prestasiDAO.getSenaraiSubjek(kodTadika);
        List<Integer> senaraiBulan = prestasiDAO.getSenaraiBulan(kodTadika);

        // ==================== SET ATTRIBUTE ====================
        // Untuk Kesediaan
        request.setAttribute("dataKesediaan", dataKesediaan);
        request.setAttribute("jumlahMuridKesediaan", jumlahMuridKesediaan);
        request.setAttribute("jumlahAKesediaan", jumlahAKesediaan);
        request.setAttribute("jumlahBKesediaan", jumlahBKesediaan);
        request.setAttribute("jumlahCKesediaan", jumlahCKesediaan);
        request.setAttribute("jumlahDKesediaan", jumlahDKesediaan);
        request.setAttribute("tahunKesediaanDipilih", tahunKesediaanStr);
        request.setAttribute("subjekKesediaanDipilih", subjekKesediaan);

        // Untuk Pentaksiran
        request.setAttribute("dataPentaksiran", dataPentaksiran);
        request.setAttribute("jumlahMuridPentaksiran", jumlahMuridPentaksiran);
        request.setAttribute("jumlahAPentaksiran", jumlahAPentaksiran);
        request.setAttribute("jumlahBPentaksiran", jumlahBPentaksiran);
        request.setAttribute("jumlahCPentaksiran", jumlahCPentaksiran);
        request.setAttribute("jumlahDPentaksiran", jumlahDPentaksiran);
        request.setAttribute("tahunPentaksiranDipilih", tahunPentaksiranStr);
        request.setAttribute("bulanPentaksiranDipilih", bulanPentaksiranStr);
        request.setAttribute("subjekPentaksiranDipilih", subjekPentaksiran);

        // Untuk dropdown
        request.setAttribute("senaraiTahun", senaraiTahun);
        request.setAttribute("senaraiSubjek", senaraiSubjek);
        request.setAttribute("senaraiBulan", senaraiBulan);

        request.getRequestDispatcher("/jsp/laporan_prestasi_murid.jsp").forward(request, response);
    }
}
