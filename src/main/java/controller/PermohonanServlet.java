package controller;

import dao.IbubapaDAO;
import dao.MuridDAO;
import dao.PermohonanDAO;
import dao.TadikaDAO;
import dao.WarisDAO;
import dao.TanggunganDAO;
import dao.DokumenPermohonanDAO;
import dao.SesiPermohonanDAO;
import model.Murid;
import model.Pengguna;
import model.Permohonan;
import model.Tanggungan;
import model.DokumenPermohonan;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import util.DBConnection;

@WebServlet("/PermohonanServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 50
)
public class PermohonanServlet extends HttpServlet {

    private MuridDAO muridDAO = new MuridDAO();
    private PermohonanDAO permohonanDAO = new PermohonanDAO();
    private TadikaDAO tadikaDAO = new TadikaDAO();
    private WarisDAO warisDAO = new WarisDAO();
    private IbubapaDAO ibubapaDAO = new IbubapaDAO();
    private TanggunganDAO tanggunganDAO = new TanggunganDAO();
    private DokumenPermohonanDAO dokumenDAO = new DokumenPermohonanDAO();
    private SesiPermohonanDAO sesiDAO = new SesiPermohonanDAO();

    // ==================== MUAT HALAMAN BORANG ====================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ==================== HANDLE DELETE DRAF ====================
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean deleted = permohonanDAO.deletePermohonan(id);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + deleted + "}");
            return;
        }

        // ==================== HANDLE EDIT DRAF (LOAD DATA) ====================
        String editId = request.getParameter("edit");
        if (editId != null && !editId.isEmpty()) {
            int idPermohonan = Integer.parseInt(editId);
            Permohonan draf = permohonanDAO.getDrafById(idPermohonan);
            if (draf != null) {
                // Load data murid
                Murid murid = muridDAO.getMuridByNoKad(draf.getNokadpengenalanmurid());
                if (murid != null) {
                    request.setAttribute("editDraf", draf);
                    request.setAttribute("editMurid", murid);
                    // Set current step (simpan dalam session atau attribute)
                    request.setAttribute("currentStep", 1); // Default step 1
                }
            }
            request.setAttribute("senaraiTadika", tadikaDAO.getAllTadika());
            request.getRequestDispatcher("jsp/permohonan.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pengguna") == null) {
            response.sendRedirect("jsp/log_masuk.jsp");
            return;
        }
        Pengguna p = (Pengguna) session.getAttribute("pengguna");
        if (!p.getPeranan().equals("ibubapa")) {
            response.sendRedirect("jsp/log_masuk.jsp");
            return;
        }
        request.setAttribute("senaraiTadika", tadikaDAO.getAllTadika());
        request.getRequestDispatcher("jsp/permohonan.jsp").forward(request, response);
    }

    // ==================== PROSES BORANG YANG DIHANTAR ====================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pengguna") == null) {
            response.sendRedirect("jsp/log_masuk.jsp");
            return;
        }
        Pengguna ibuBapa = (Pengguna) session.getAttribute("pengguna");
        if (!ibuBapa.getPeranan().equals("ibubapa")) {
            response.sendRedirect("jsp/log_masuk.jsp");
            return;
        }

        // ==================== HANDLE SIMPAN DRAF ====================
        String action = request.getParameter("action");
        if ("draf".equals(action)) {
            simpanDraf(request, response);
            return;
        }

        // LANGKAH 1: MAKLUMAT KANAK-KANAK
        String nokad = request.getParameter("nokad");
        String namamurid = request.getParameter("namamurid");
        String tarikhlahirStr = request.getParameter("tarikhlahir");
        String jantina = request.getParameter("jantina");
        String bangsa = request.getParameter("bangsa");
        String alamat = request.getParameter("alamat");
        String poskod = request.getParameter("poskod");
        String kodtadika = request.getParameter("kodtadika");

        // Proses bangsa "Lain-lain"
        if ("Lain-lain".equals(bangsa)) {
            String bangsaLain = request.getParameter("bangsaLain");
            if (bangsaLain != null && !bangsaLain.trim().isEmpty()) {
                bangsa = bangsaLain;
            }
        }

        // Dapatkan tahun kemasukan dari hidden field (dihantar dari JSP)
        String tahunKemasukanStr = request.getParameter("tahunKemasukan");
        Integer tahunKemasukan = null;

        if (tahunKemasukanStr != null && !tahunKemasukanStr.isEmpty()) {
            tahunKemasukan = Integer.parseInt(tahunKemasukanStr);
        } else {
            // Fallback: Cuba dapatkan dari database berdasarkan DUN
            String dun = request.getParameter("dun");
            if (dun != null && !dun.isEmpty()) {
                tahunKemasukan = sesiDAO.getTahunKemasukanByDun(dun);
            }
        }

        if (tahunKemasukan == null) {
            request.setAttribute("toastMessage", "Maaf, tiada sesi permohonan dibuka untuk DUN ini.");
            request.setAttribute("toastType", "error");
            request.setAttribute("senaraiTadika", tadikaDAO.getAllTadika());
            request.getRequestDispatcher("jsp/permohonan.jsp").forward(request, response);
            return;
        }

        // ==================== UPLOAD GAMBAR PASSPORT ====================
        Part filePart = request.getPart("gambarpassport");
        String gambarPassport = null;

        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "passport";

        System.out.println("Upload Passport Path: " + uploadPath);

        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            boolean created = uploadDir.mkdirs();
            System.out.println("Folder passport created: " + created);
        }

        if (filePart != null && filePart.getSize() > 0) {
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            fileName = fileName.replaceAll("\\s+", "_");
            gambarPassport = System.currentTimeMillis() + "_" + fileName;
            String fullPath = uploadPath + File.separator + gambarPassport;
            filePart.write(fullPath);
            System.out.println("Passport saved to: " + fullPath);
        }

        // LANGKAH 2: MAKLUMAT WARIS
        String warisNama = request.getParameter("waris_nama");
        String warisAlamat = request.getParameter("waris_alamat");
        String warisTelefon = request.getParameter("waris_telefon");
        String warisHubungan = request.getParameter("waris_hubungan");

        // LANGKAH 3: MAKLUMAT BAPA
        String namabapa = request.getParameter("namabapa");
        String nokadpengenalanbapa = request.getParameter("nokadpengenalanbapa");
        String bangsabapa = request.getParameter("bangsabapa");
        String notelefonbapa = request.getParameter("notelefonbapa");
        String statusbapa = request.getParameter("statusbapa");
        String pekerjaanbapa = request.getParameter("pekerjaanbapa");
        double pendapatanbapa = 0;
        try {
            pendapatanbapa = Double.parseDouble(request.getParameter("pendapatanbapa"));
        } catch (Exception e) {
        }
        String majikanbapa = request.getParameter("majikanbapa");
        if ("Lain-lain".equals(bangsabapa)) {
            String bangsabapaLain = request.getParameter("bangsabapa_lain");
            if (bangsabapaLain != null && !bangsabapaLain.trim().isEmpty()) {
                bangsabapa = bangsabapaLain;
            }
        }

        // LANGKAH 4: MAKLUMAT IBU
        String namaibu = request.getParameter("namaibu");
        String nokadpengenalanibu = request.getParameter("nokadpengenalanibu");
        String bangsaibu = request.getParameter("bangsaibu");
        String notelefonibu = request.getParameter("notelefonibu");
        String statusibu = request.getParameter("statusibu");
        String pekerjaanibu = request.getParameter("pekerjaanibu");
        double pendapatanibu = 0;
        try {
            pendapatanibu = Double.parseDouble(request.getParameter("pendapatanibu"));
        } catch (Exception e) {
        }
        String majikanibu = request.getParameter("majikanibu");
        if ("Lain-lain".equals(bangsaibu)) {
            String bangsaibuLain = request.getParameter("bangsaibu_lain");
            if (bangsaibuLain != null && !bangsaibuLain.trim().isEmpty()) {
                bangsaibu = bangsaibuLain;
            }
        }

        // LANGKAH 5: MAKLUMAT TANGGUNGAN
        int bilanganTanggungan = 0;
        try {
            bilanganTanggungan = Integer.parseInt(request.getParameter("bilangantanggungan"));
        } catch (Exception e) {
        }
        List<Object[]> senaraiTanggungan = new ArrayList<>();
        for (int i = 0; i < bilanganTanggungan; i++) {
            String namaTanggungan = request.getParameter("tanggungan_nama_" + i);
            String umurTanggungan = request.getParameter("tanggungan_umur_" + i);
            String hubunganTanggungan = request.getParameter("tanggungan_hubungan_" + i);
            if (namaTanggungan != null && !namaTanggungan.trim().isEmpty()) {
                senaraiTanggungan.add(new Object[]{namaTanggungan, umurTanggungan, hubunganTanggungan});
            }
        }

        // ==================== LANGKAH 6: MUAT NAIK DOKUMEN ====================
        String uploadDokumenPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "dokumen";
        File dokumenDir = new File(uploadDokumenPath);
        if (!dokumenDir.exists()) {
            dokumenDir.mkdirs();
        }
        List<String[]> senaraiDokumen = new ArrayList<>();
        String[] jenisDokumen = {"sijillahir", "mykid", "kadpengenalanibu", "kadpengenalanbapa", "slipgaji"};
        String[] namaField = {"dokumen_sijil_lahir", "dokumen_mykid", "dokumen_ic_ibu", "dokumen_ic_bapa", "dokumen_slip_gaji"};
        for (int i = 0; i < jenisDokumen.length; i++) {
            Part dokumenPart = request.getPart(namaField[i]);
            if (dokumenPart != null && dokumenPart.getSize() > 0) {
                String fileName = Paths.get(dokumenPart.getSubmittedFileName()).getFileName().toString();
                String savedFileName = System.currentTimeMillis() + "_" + i + "_" + fileName;
                dokumenPart.write(uploadDokumenPath + File.separator + savedFileName);
                senaraiDokumen.add(new String[]{jenisDokumen[i], savedFileName});
            }
        }

        // ==================== VALIDASI DATA ====================
        if (nokad == null || nokad.trim().isEmpty()) {
            request.setAttribute("toastMessage", "No MyKid wajib diisi.");
            request.setAttribute("toastType", "error");
            request.setAttribute("senaraiTadika", tadikaDAO.getAllTadika());
            request.getRequestDispatcher("jsp/permohonan.jsp").forward(request, response);
            return;
        }
        if (namamurid == null || namamurid.trim().isEmpty()) {
            request.setAttribute("toastMessage", "Nama murid wajib diisi.");
            request.setAttribute("toastType", "error");
            request.setAttribute("senaraiTadika", tadikaDAO.getAllTadika());
            request.getRequestDispatcher("jsp/permohonan.jsp").forward(request, response);
            return;
        }
        if (tarikhlahirStr == null || tarikhlahirStr.trim().isEmpty()) {
            request.setAttribute("toastMessage", "Tarikh lahir wajib diisi.");
            request.setAttribute("toastType", "error");
            request.setAttribute("senaraiTadika", tadikaDAO.getAllTadika());
            request.getRequestDispatcher("jsp/permohonan.jsp").forward(request, response);
            return;
        }
        if (kodtadika == null || kodtadika.trim().isEmpty()) {
            request.setAttribute("toastMessage", "Sila pilih DUN dan Tadika.");
            request.setAttribute("toastType", "error");
            request.setAttribute("senaraiTadika", tadikaDAO.getAllTadika());
            request.getRequestDispatcher("jsp/permohonan.jsp").forward(request, response);
            return;
        }

        // ==================== VALIDASI UMUR (BERDASARKAN TAHUN KEMASUKAN) ====================
        LocalDate tarikhlahir = LocalDate.parse(tarikhlahirStr);
        int tahunLahir = tarikhlahir.getYear();

        int umurKetikaMasuk = tahunKemasukan - tahunLahir;

        System.out.println("Tahun lahir: " + tahunLahir);
        System.out.println("Tahun kemasukan: " + tahunKemasukan);
        System.out.println("Umur ketika masuk: " + umurKetikaMasuk);

        if (umurKetikaMasuk < 5 || umurKetikaMasuk > 6) {
            request.setAttribute("toastMessage", "Maaf, permohonan hanya untuk kanak-kanak yang akan berumur 5 atau 6 tahun pada tahun kemasukan " + tahunKemasukan);
            request.setAttribute("toastType", "error");
            request.setAttribute("senaraiTadika", tadikaDAO.getAllTadika());
            request.getRequestDispatcher("jsp/permohonan.jsp").forward(request, response);
            return;
        }

        // ==================== SEMAK PERMOHONAN AKTIF UNTUK ANAK SAMA ====================
        boolean adaPermohonanAktif = permohonanDAO.isAdaPermohonanAktif(nokad);

        if (adaPermohonanAktif) {
            request.setAttribute("toastMessage", "Maaf, anda sudah mempunyai permohonan dalam proses untuk anak ini. Sila tunggu keputusan sebelum membuat permohonan baru.");
            request.setAttribute("toastType", "error");
            request.setAttribute("senaraiTadika", tadikaDAO.getAllTadika());
            request.getRequestDispatcher("jsp/permohonan.jsp").forward(request, response);
            return;
        }

        // ==================== SEMAK & SIMPAN DATA MURID ====================
        int idIbuBapaUntukMurid = ibuBapa.getIdpengguna();
        boolean muridSudahWujud = muridDAO.isMuridExist(nokad);

        if (muridSudahWujud) {
            // Guna semula rekod murid sedia ada
            System.out.println("Murid sudah wujud dengan No. MyKid: " + nokad);

            // Dapatkan idibubapa dari rekod sedia ada (untuk keselamatan)
            int existingIdIbuBapa = muridDAO.getIdIbuBapaByNoKad(nokad);
            if (existingIdIbuBapa != -1) {
                idIbuBapaUntukMurid = existingIdIbuBapa;
            }

            // Nota: Tidak perlu insert murid baru
            System.out.println("Guna semula murid sedia ada untuk permohonan baru");

        } else {
            // Insert murid baru
            Murid murid = new Murid();
            murid.setNokadpengenalan(nokad);
            murid.setIdibubapa(ibuBapa.getIdpengguna());
            murid.setNamamurid(namamurid);
            murid.setTarikhlahir(Date.valueOf(tarikhlahirStr));
            murid.setUmur(umurKetikaMasuk);
            murid.setJantina(jantina);
            murid.setBangsa(bangsa);
            murid.setAlamat(alamat);
            murid.setPoskod(poskod);
            murid.setKodtadika(kodtadika);
            murid.setTahunmasuk(tahunKemasukan);
            murid.setGambarpassport(gambarPassport);

            boolean muridSaved = muridDAO.insert(murid);
            if (!muridSaved) {
                request.setAttribute("toastMessage", "Gagal menyimpan data murid.");
                request.setAttribute("toastType", "error");
                request.setAttribute("senaraiTadika", tadikaDAO.getAllTadika());
                request.getRequestDispatcher("jsp/permohonan.jsp").forward(request, response);
                return;
            }
            System.out.println("Murid baru berjaya disimpan: " + nokad);
        }

        // ==================== SIMPAN WARIS ====================
        if (warisNama != null && !warisNama.trim().isEmpty()) {
            warisDAO.insert(nokad, warisNama, warisAlamat, warisTelefon, warisHubungan);
        }

        // ==================== SIMPAN MAKLUMAT IBU BAPA ====================
        ibubapaDAO.insert(ibuBapa.getIdpengguna(), namabapa, nokadpengenalanbapa, bangsabapa,
                notelefonbapa, statusbapa, pekerjaanbapa, pendapatanbapa, majikanbapa,
                namaibu, nokadpengenalanibu, bangsaibu, notelefonibu, statusibu, pekerjaanibu,
                pendapatanibu, majikanibu, bilanganTanggungan);

        // ==================== SIMPAN PERMOHONAN ====================
        Permohonan permohonan = new Permohonan();
        permohonan.setNokadpengenalanmurid(nokad);
        permohonan.setKodtadika(kodtadika);
        permohonan.setTarikhpermohonan(Date.valueOf(LocalDate.now()));
        permohonan.setTahunkemasukan(tahunKemasukan);
        permohonan.setStatuspermohonan("dalamproses");
        permohonan.setIdgurubesaryanglulus(null);
        permohonan.setCatatanpenolakan(null);
        boolean permohonanSaved = permohonanDAO.insert(permohonan);

        if (permohonanSaved) {
            // ==================== DAPATKAN ID PERMOHONAN YANG BARU (CARAMANUAL) ====================
            int idPermohonan = 0;
            String sqlId = "SELECT idpermohonan FROM permohonan ORDER BY idpermohonan DESC LIMIT 1";
            try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sqlId); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    idPermohonan = rs.getInt("idpermohonan");
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }

            System.out.println("ID Permohonan: " + idPermohonan);

            // ==================== SIMPAN TANGGUNGAN ====================
            if (senaraiTanggungan != null && !senaraiTanggungan.isEmpty()) {
                for (Object[] tg : senaraiTanggungan) {
                    String namaTg = (String) tg[0];
                    int umurTg = Integer.parseInt((String) tg[1]);
                    String hubunganTg = (String) tg[2];
                    Tanggungan tanggungan = new Tanggungan(idPermohonan, namaTg, umurTg, hubunganTg);
                    tanggunganDAO.insert(tanggungan);
                }
            }

            // ==================== SIMPAN DOKUMEN ====================
            if (senaraiDokumen != null && !senaraiDokumen.isEmpty()) {
                for (String[] dok : senaraiDokumen) {
                    String jenis = dok[0];
                    String namaFail = dok[1];
                    DokumenPermohonan dokumen = new DokumenPermohonan(idPermohonan, jenis, namaFail);
                    dokumenDAO.insert(dokumen);
                }
            }

            // Redirect ke status permohonan
            session.setAttribute("toastMessage", "Permohonan berjaya dihantar.");
            session.setAttribute("toastType", "success");
            request.setAttribute("redirectAfterToast", "true");
            request.getRequestDispatcher("jsp/permohonan.jsp").forward(request, response);
        } else {
            request.setAttribute("toastMessage", "Permohonan gagal disimpan. Sila hubungi tadika.");
            request.setAttribute("toastType", "error");
            request.setAttribute("senaraiTadika", tadikaDAO.getAllTadika());
            request.getRequestDispatcher("jsp/permohonan.jsp").forward(request, response);
        }
    }

    // ==================== SIMPAN DRAF ====================
    private void simpanDraf(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Pengguna ibuBapa = (Pengguna) session.getAttribute("pengguna");

        String nokad = request.getParameter("nokad");
        String tarikhlahirStr = request.getParameter("tarikhlahir");
        String currentStepStr = request.getParameter("currentStep");
        int currentStep = currentStepStr != null ? Integer.parseInt(currentStepStr) : 1;

        // ==================== DEBUGGING ====================
        System.out.println("=== SIMPAN DRAF ===");
        System.out.println("nokad: " + nokad);
        System.out.println("tarikhlahirStr: " + tarikhlahirStr);
        System.out.println("currentStep: " + currentStep);
        System.out.println("kodtadika: " + request.getParameter("kodtadika"));
        System.out.println("tahunKemasukan: " + request.getParameter("tahunKemasukan"));
        System.out.println("dun: " + request.getParameter("dun"));

        // ==================== VALIDASI DATA WAJIB UNTUK DRAF ====================
        String kodtadika = request.getParameter("kodtadika");
        String tahunKemasukanStr = request.getParameter("tahunKemasukan");

        if (kodtadika == null || kodtadika.trim().isEmpty()) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false, \"message\":\"Sila pilih DUN dan Tadika terlebih dahulu sebelum menyimpan draf.\"}");
            return;
        }

        if (tahunKemasukanStr == null || tahunKemasukanStr.trim().isEmpty()) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false, \"message\":\"Sila pilih DUN yang sesi permohonannya dibuka terlebih dahulu.\"}");
            return;
        }
        // ================================================================

        // ==================== VALIDASI UMUR UNTUK DRAF ====================
        Integer tahunKemasukan = Integer.parseInt(tahunKemasukanStr);

        if (tarikhlahirStr != null && !tarikhlahirStr.isEmpty()) {
            LocalDate tarikhlahir = LocalDate.parse(tarikhlahirStr);
            int tahunLahir = tarikhlahir.getYear();
            int umurKetikaMasuk = tahunKemasukan - tahunLahir;

            if (umurKetikaMasuk < 5 || umurKetikaMasuk > 6) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":false, \"message\":\"Maaf, permohonan hanya untuk kanak-kanak yang berumur 5 atau 6 tahun pada tahun kemasukan " + tahunKemasukan + ".\"}");
                return;
            }
        }
        // ================================================================

        session.setAttribute("drafData", request.getParameterMap());
        session.setAttribute("drafCurrentStep", currentStep);

        if (nokad != null && !nokad.trim().isEmpty()) {
            // ==================== SEMAK & SIMPAN MURID DULU ====================
            boolean muridSudahWujud = muridDAO.isMuridExist(nokad);

            if (!muridSudahWujud) {
                // Insert murid baru dari data step 1
                Murid murid = new Murid();
                murid.setNokadpengenalan(nokad);
                murid.setIdibubapa(ibuBapa.getIdpengguna());

                String namamurid = request.getParameter("namamurid");
                murid.setNamamurid(namamurid != null ? namamurid : "Draf - " + nokad);

                if (tarikhlahirStr != null && !tarikhlahirStr.isEmpty()) {
                    murid.setTarikhlahir(Date.valueOf(tarikhlahirStr));
                    LocalDate tarikhlahir = LocalDate.parse(tarikhlahirStr);
                    int tahunLahir = tarikhlahir.getYear();
                    murid.setUmur(tahunKemasukan - tahunLahir);
                } else {
                    murid.setTarikhlahir(Date.valueOf(LocalDate.now()));
                    murid.setUmur(0);
                }

                murid.setJantina(request.getParameter("jantina"));
                murid.setBangsa(request.getParameter("bangsa"));
                murid.setAlamat(request.getParameter("alamat"));
                murid.setPoskod(request.getParameter("poskod"));
                murid.setKodtadika(kodtadika);
                murid.setTahunmasuk(tahunKemasukan);

                boolean muridSaved = muridDAO.insert(murid);
                if (!muridSaved) {
                    response.setContentType("application/json");
                    response.getWriter().write("{\"success\":false, \"message\":\"Gagal menyimpan data murid. Sila cuba lagi.\"}");
                    return;
                }
                System.out.println("Murid baru disimpan untuk draf: " + nokad);
            } else {
                System.out.println("Murid sudah wujud: " + nokad + ", guna semula");
            }
            // ================================================================

            Permohonan permohonan = new Permohonan();
            permohonan.setNokadpengenalanmurid(nokad);
            permohonan.setTarikhpermohonan(Date.valueOf(LocalDate.now()));
            permohonan.setStatuspermohonan("draf");
            permohonan.setKodtadika(kodtadika);
            permohonan.setTahunkemasukan(tahunKemasukan);

            int idPermohonan = permohonanDAO.insertAndGetId(permohonan);
            System.out.println("ID Permohonan: " + idPermohonan);

            if (idPermohonan > 0) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":true, \"idPermohonan\":" + idPermohonan + "}");
                return;
            } else {
                System.out.println("Gagal insert permohonan");
            }
        }

        response.setContentType("application/json");
        response.getWriter().write("{\"success\":false, \"message\":\"Gagal menyimpan draf. Sila cuba lagi.\"}");
    }
}
