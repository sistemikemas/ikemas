<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Pengguna, dao.TadikaDAO, model.Tadika, model.Guru" %>
<%
    Pengguna p = (Pengguna) session.getAttribute("pengguna");
    if (p == null || !p.getPeranan().equals("guru")) {
        response.sendRedirect("log_masuk.jsp");
        return;
    }

    TadikaDAO tadikaDAO = new TadikaDAO();
    Tadika tadika = tadikaDAO.getTadikaByKod(p.getKodtadika());
    String namaTadika = (tadika != null) ? tadika.getNamatadika() : "Tidak dikenal pasti";

    // Dapatkan maklumat guru dari request attribute
    Guru guru = (Guru) request.getAttribute("guru");
    if (guru == null) {
        guru = new Guru();
    }

    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MM-yyyy");
    String tarikhLantikan = (guru.getTarikhlantikan() != null)
            ? sdf.format(guru.getTarikhlantikan()) : "-";

    // Ambil mesej dari request attribute untuk ditunjukkan dalam toast
    String successMsg = (String) request.getAttribute("success");
    String errorMsg = (String) request.getAttribute("error");
%>

<%!
    // Method untuk capitalize each word
    private String toTitleCase(String str) {
        if (str == null || str.isEmpty()) {
            return "-";
        }

        String[] words = str.toLowerCase().split(" ");
        StringBuilder result = new StringBuilder();

        for (String word : words) {
            if (word.length() > 0) {
                result.append(Character.toUpperCase(word.charAt(0)))
                        .append(word.substring(1))
                        .append(" ");
            }
        }
        return result.toString().trim();
    }
%>
<!DOCTYPE html>
<html lang="ms">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>i-KEMAS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/profil_akaun.css">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/image/logo-sistem.png">
    </head>
    <body>
        <!-- ==================== TOAST CONTAINER (OVERLAY) ==================== -->
        <div id="toastContainer" class="toast-container"></div>

        <div class="dashboard">
            <!-- ==================== SIDEBAR ==================== -->
            <aside class="sidebar">
                <div class="sidebar-header">
                    <div class="logo">
                        <h2>i-KEMAS</h2>
                    </div>
                    <p>SISTEM PENGURUSAN KANAK-KANAK <br> TABIKA KEMAS</p>
                </div>
                <nav class="nav-menu">
                    <a href="${pageContext.request.contextPath}/jsp/dashboard_guru.jsp" class="nav-item">
                        <span class="material-icons">dashboard</span>
                        <span>Dashboard</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/SenaraiMuridGuruServlet" class="nav-item">
                        <span class="material-icons">groups</span>
                        <span>Senarai Murid</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/RekodPrestasiMuridServlet" class="nav-item">
                        <span class="material-icons">bar_chart</span>
                        <span>Rekod Prestasi Murid</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/KehadiranHarianServlet" class="nav-item">
                        <span class="material-icons">event_available</span>
                        <span>Kehadiran Harian</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/ProfilGuruServlet" class="nav-item active">
                        <span class="material-icons">person</span>
                        <span>Profil Saya</span>
                    </a>
                </nav>
                <div class="sidebar-footer">
                    <a href="${pageContext.request.contextPath}/LogKeluarServlet" class="nav-item logout">
                        <span class="material-icons">logout</span>
                        <span>Log Keluar</span>
                    </a>
                </div>
            </aside>

            <!-- ==================== TOP BAR ==================== -->
            <div class="top-bar">
                <div class="greeting">
                    <span class="greeting-text">Selamat Sejahtera,</span>
                    <span class="greeting-text" style="color: var(--primary);"><%= p.getKodtadika()%> - <%= namaTadika%></span>
                </div>
                <div class="user-info">
                    <div class="user-details">
                        <span class="user-name"><%= p.getNama()%></span>
                        <span class="user-role">Guru</span>
                    </div>
                </div>
            </div>

            <!-- ==================== MAIN CONTENT ==================== -->
            <main class="main-content">
                <div class="stats-grid">
                    <!-- ==================== MAKLUMAT AKAUN ==================== -->
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">
                                Maklumat Akaun
                            </h3>
                        </div>
                        <div class="card-body">
                            <form action="${pageContext.request.contextPath}/ProfilGuruServlet" method="post" class="profile-form" id="profileForm">
                                <input type="hidden" name="action" value="updateProfil">

                                <div class="form-group">
                                    <label>Nama Penuh</label>
                                    <input type="text" name="nama" class="form-control" value="<%= p.getNama()%>" required>
                                </div>

                                <div class="form-group">
                                    <label>Username</label>
                                    <input type="text" class="form-control" value="<%= p.getUsername()%>" disabled>
                                    <small>Username tidak boleh diubah</small>
                                </div>

                                <div class="form-group">
                                    <label>No. Telefon</label>
                                    <input type="text" name="notelefon" class="form-control" value="<%= p.getNotelefon() != null ? p.getNotelefon() : ""%>">
                                </div>

                                <div class="form-actions">
                                    <button type="submit" class="btn-primary">
                                        Kemaskini
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <!-- ==================== TUKAR KATA LALUAN ==================== -->
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">
                                Tukar Kata Laluan
                            </h3>
                        </div>
                        <div class="card-body">
                            <form action="${pageContext.request.contextPath}/ProfilGuruServlet" method="post" class="profile-form" id="passwordForm">
                                <input type="hidden" name="action" value="changePassword">

                                <div class="form-group">
                                    <label>Kata Laluan Semasa</label>
                                    <input type="password" name="currentPassword" class="form-control" required>
                                </div>

                                <div class="form-group">
                                    <label>Kata Laluan Baru</label>
                                    <input type="password" name="newPassword" class="form-control" required>
                                    <small>Minimum 8 aksara, mengandungi huruf besar, huruf kecil, nombor dan simbol (@$!%*?&)</small>
                                </div>

                                <div class="form-group">
                                    <label>Sahkan Kata Laluan</label>
                                    <input type="password" name="confirmPassword" class="form-control" required>
                                </div>

                                <div class="form-actions">
                                    <button type="submit" class="btn-primary">
                                        Tukar Kata Laluan
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <!-- ==================== MAKLUMAT PERIBADI GURU ==================== -->
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">
                                Maklumat Peribadi
                            </h3>
                        </div>
                        <div class="card-body">
                            <div class="profile-form">
                                <div class="form-group">
                                    <label>Kod Tadika</label>
                                    <input type="text" class="form-control" value="<%= p.getKodtadika()%>" disabled>
                                </div>

                                <div class="form-group">
                                    <label>Nama Tadika</label>
                                    <input type="text" class="form-control" value="<%= toTitleCase(namaTadika)%>" disabled>
                                </div>
                                <div class="form-group">
                                    <label>No. Kad Pengenalan</label>
                                    <input type="text" class="form-control" value="<%= guru.getNokadpengenalan() != null ? guru.getNokadpengenalan() : "-"%>" disabled>
                                </div>

                                <div class="form-group">
                                    <label>Tarikh Lantikan</label>
                                    <input type="text" class="form-control" value="<%= tarikhLantikan%>" disabled>
                                </div>

                                <div class="form-group">
                                    <label>Kelayakan Akademik</label>
                                    <input type="text" class="form-control" value="<%= guru.getKelayakanakademik() != null ? guru.getKelayakanakademik() : "-"%>" disabled>
                                </div>

                                <div class="form-group">
                                    <label>Gred Jawatan</label>
                                    <input type="text" class="form-control" value="<%= guru.getGredjawatan() != null ? guru.getGredjawatan() : "-"%>" disabled>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>

        <script>
            // ==================== TOAST NOTIFICATION (OVERLAY) ====================
            function showToast(message, type, duration) {
                type = type || 'info';
                duration = duration || 5000;
                const container = document.getElementById('toastContainer');
                if (!container)
                    return;

                const toast = document.createElement('div');
                toast.className = 'toast ' + type;

                toast.innerHTML = '<div class="toast-content">' + message + '</div>' +
                        '<div class="toast-progress"></div>';

                container.appendChild(toast);

                setTimeout(function () {
                    if (toast.parentElement) {
                        toast.style.animation = 'fadeOut 0.3s ease-out forwards';
                        setTimeout(function () {
                            toast.remove();
                        }, 300);
                    }
                }, duration);
            }

            // ==================== PAPAR TOAST UNTUK MESEJ DARI SERVER ====================
            <% if (successMsg != null && !successMsg.isEmpty()) {%>
            showToast('<%= successMsg%>', 'success', 4000);
            <% } %>

            <% if (errorMsg != null && !errorMsg.isEmpty()) {%>
            showToast('<%= errorMsg%>', 'error', 4000);
            <% }%>

            // ==================== VALIDASI FORM SEBELUM SUBMIT ====================
            document.getElementById('passwordForm')?.addEventListener('submit', function (e) {
                var newPass = document.querySelector('input[name="newPassword"]').value;
                var confirmPass = document.querySelector('input[name="confirmPassword"]').value;

                // Semak sama ada password dan confirm password sepadan
                if (newPass !== confirmPass) {
                    e.preventDefault();
                    showToast('Kata laluan baru dan sahkan kata laluan tidak sepadan', 'error', 4000);
                    return;
                }

                // Semak panjang password (minimum 8 aksara)
                if (newPass.length < 8) {
                    e.preventDefault();
                    showToast('Kata laluan baru mesti sekurang-kurangnya 8 aksara', 'error', 4000);
                    return;
                }

                // Semak sama ada mengandungi huruf besar
                if (!/[A-Z]/.test(newPass)) {
                    e.preventDefault();
                    showToast('Kata laluan baru mesti mengandungi sekurang-kurangnya 1 huruf besar (A-Z)', 'error', 4000);
                    return;
                }

                // Semak sama ada mengandungi huruf kecil
                if (!/[a-z]/.test(newPass)) {
                    e.preventDefault();
                    showToast('Kata laluan baru mesti mengandungi sekurang-kurangnya 1 huruf kecil (a-z)', 'error', 4000);
                    return;
                }

                // Semak sama ada mengandungi nombor
                if (!/[0-9]/.test(newPass)) {
                    e.preventDefault();
                    showToast('Kata laluan baru mesti mengandungi sekurang-kurangnya 1 nombor (0-9)', 'error', 4000);
                    return;
                }

                // Semak sama ada mengandungi simbol (@$!%*?&)
                if (!/[@$!%*?&]/.test(newPass)) {
                    e.preventDefault();
                    showToast('Kata laluan baru mesti mengandungi sekurang-kurangnya 1 simbol (@$!%*?&)', 'error', 4000);
                    return;
                }
            });

            document.getElementById('profileForm')?.addEventListener('submit', function (e) {
                var nama = document.querySelector('input[name="nama"]').value;
                if (nama.trim() === '') {
                    e.preventDefault();
                    showToast('Sila masukkan nama penuh', 'error', 4000);
                }
            });
        </script>
    </body>
</html>