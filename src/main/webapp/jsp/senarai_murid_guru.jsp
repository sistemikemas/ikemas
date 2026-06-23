<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Pengguna, dao.TadikaDAO, model.Tadika" %>
<%@ page import="java.util.*, model.Murid" %>
<%
    Pengguna p = (Pengguna) session.getAttribute("pengguna");
    if (p == null || !p.getPeranan().equals("guru")) {
        response.sendRedirect("log_masuk.jsp");
        return;
    }

    TadikaDAO tadikaDAO = new TadikaDAO();
    Tadika tadika = tadikaDAO.getTadikaByKod(p.getKodtadika());
    String namaTadika = (tadika != null) ? tadika.getNamatadika() : "Tidak dikenal pasti";

    // Get data from request attributes
    List<Murid> senaraiMurid = (List<Murid>) request.getAttribute("senaraiMurid");
    if (senaraiMurid == null) {
        senaraiMurid = new ArrayList<>();
    }

    String successMsg = (String) request.getAttribute("success");
    String errorMsg = (String) request.getAttribute("error");

    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MM-yyyy");

    // Kira statistik
    int totalLelaki = 0;
    int totalPerempuan = 0;
    for (Murid murid : senaraiMurid) {
        if ("Lelaki".equalsIgnoreCase(murid.getJantina())) {
            totalLelaki++;
        } else if ("Perempuan".equalsIgnoreCase(murid.getJantina())) {
            totalPerempuan++;
        }
    }
%>
<!DOCTYPE html>
<html lang="ms">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>i-KEMAS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/image/logo-sistem.png">
    </head>
    <body>
        <div id="toastContainer" class="toast-container"></div>

        <div class="dashboard">
            <!-- Sidebar -->
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
                    <a href="${pageContext.request.contextPath}/SenaraiMuridGuruServlet" class="nav-item active">
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
                    <a href="${pageContext.request.contextPath}/ProfilGuruServlet" class="nav-item">
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

            <!-- Top Bar -->
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

            <!-- Main Content -->
            <main class="main-content">
                <!-- Stats Ringkasan - guna class stat-card yang sedia ada -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon">
                            <span class="material-icons">groups</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="totalMurid">0</div>
                            <div class="stat-label">Jumlah Murid</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon">
                            <span class="material-icons">male</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="totalLelaki">0</div>
                            <div class="stat-label">Lelaki</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon">
                            <span class="material-icons">female</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="totalPerempuan">0</div>
                            <div class="stat-label">Perempuan</div>
                        </div>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Senarai Murid</h3>
                        <div class="search-container">
                            <div class="search-box">
                                <span class="material-icons search-icon">search</span>
                                <input type="text" id="searchInput" placeholder="Cari... (Nama, No. MyKid)">
                            </div>
                        </div>
                    </div>

                    <!-- Murid Table -->
                    <div class="table-wrapper">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>No. MyKid</th>
                                    <th>Nama Murid</th>
                                    <th>Jantina</th>
                                    <th>Tarikh Lahir</th>
                                    <th>Umur</th>
                                    <th>Tahun Masuk</th>
                                </tr>
                            </thead>
                            <tbody id="tableBody">
                                <%
                                    if (senaraiMurid == null || senaraiMurid.isEmpty()) {
                                %>
                                <tr>
                                    <td colspan="6" class="text-center">
                                        <div class="empty-state">
                                            <span class="material-icons">school</span>
                                            <p>Tiada murid berdaftar</p>
                                        </div>
                                    </td>
                                </tr>
                                <%
                                } else {
                                    for (Murid murid : senaraiMurid) {
                                        String tarikhLahir = murid.getTarikhlahir() != null
                                                ? sdf.format(murid.getTarikhlahir()) : "-";

                                        // Handle umur dengan selamat
                                        String umurText = "-";
                                        Integer umur = murid.getUmur();
                                        if (umur != null && umur > 0) {
                                            umurText = umur + " tahun";
                                        }

                                        // Handle tahun masuk dengan selamat
                                        String tahunMasukText = "-";
                                        Integer tahunMasuk = murid.getTahunmasuk();
                                        if (tahunMasuk != null && tahunMasuk > 0) {
                                            tahunMasukText = String.valueOf(tahunMasuk);
                                        }
                                %>
                                <tr>
                                    <td><%= murid.getNokadpengenalan() != null ? murid.getNokadpengenalan() : "-"%></td>
                                    <td><%= murid.getNamamurid() != null ? murid.getNamamurid() : "-"%></td>
                                    <td><%= murid.getJantina() != null ? murid.getJantina() : "-"%></td>
                                    <td><%= tarikhLahir%></td>
                                    <td><%= umurText%></td>
                                    <td><%= tahunMasukText%></td>
                                </tr>
                                <%
                                        }
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </main>
        </div>

        <script>
            // ==================== TOAST NOTIFICATION ====================
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

            // Show messages from server
            <% if (successMsg != null && !successMsg.isEmpty()) {%>
            showToast('<%= successMsg.replace("'", "\\'")%>', 'success', 4000);
            <% } %>
            <% if (errorMsg != null && !errorMsg.isEmpty()) {%>
            showToast('<%= errorMsg.replace("'", "\\'")%>', 'error', 4000);
            <% }%>

            // Update stats awal
            function updateInitialStats() {
                const totalMurid = <%= senaraiMurid.size()%>;
                const totalLelaki = <%= totalLelaki%>;
                const totalPerempuan = <%= totalPerempuan%>;

                document.getElementById('totalMurid').innerText = totalMurid;
                document.getElementById('totalLelaki').innerText = totalLelaki;
                document.getElementById('totalPerempuan').innerText = totalPerempuan;
            }

            // ==================== FUNGSI SEARCH ====================
            function filterTable() {
                const searchInput = document.getElementById('searchInput');
                const searchTerm = searchInput ? searchInput.value.toLowerCase().trim() : '';

                const tableBody = document.getElementById('tableBody');
                if (!tableBody)
                    return;

                const rows = tableBody.getElementsByTagName('tr');
                let visibleCount = 0;
                let visibleLelaki = 0;
                let visiblePerempuan = 0;

                for (let i = 0; i < rows.length; i++) {
                    const row = rows[i];
                    // Skip jika row adalah empty state (colspan)
                    if (row.querySelector('td[colspan]')) {
                        row.style.display = '';
                        continue;
                    }

                    const cells = row.getElementsByTagName('td');
                    if (cells.length === 0)
                        continue;

                    let match = false;
                    let jantina = '';

                    for (let j = 0; j < cells.length; j++) {
                        const cellText = cells[j].innerText.toLowerCase();
                        if (cellText.indexOf(searchTerm) > -1) {
                            match = true;
                        }
                        // Kolom Jantina adalah index ke-2
                        if (j === 2) {
                            jantina = cellText;
                        }
                    }

                    if (searchTerm === '' || match) {
                        row.style.display = '';
                        visibleCount++;
                        if (jantina === 'lelaki')
                            visibleLelaki++;
                        if (jantina === 'perempuan')
                            visiblePerempuan++;
                    } else {
                        row.style.display = 'none';
                    }
                }

                // Update stats
                document.getElementById('totalMurid').innerText = visibleCount;
                document.getElementById('totalLelaki').innerText = visibleLelaki;
                document.getElementById('totalPerempuan').innerText = visiblePerempuan;
            }

            // ==================== INISIALISASI ====================
            document.addEventListener('DOMContentLoaded', function () {
                updateInitialStats();

                const searchInput = document.getElementById('searchInput');
                if (searchInput) {
                    searchInput.addEventListener('keyup', filterTable);
                }
            });
        </script>
    </body>
</html>