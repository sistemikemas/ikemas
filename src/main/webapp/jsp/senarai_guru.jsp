<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Pengguna, dao.TadikaDAO, model.Tadika, java.util.List, java.util.Map" %>
<%
    Pengguna p = (Pengguna) session.getAttribute("pengguna");
    if (p == null || !p.getPeranan().equals("gurubesar")) {
        response.sendRedirect("log_masuk.jsp");
        return;
    }

    TadikaDAO tadikaDAO = new TadikaDAO();
    Tadika tadika = tadikaDAO.getTadikaByKod(p.getKodtadika());
    String namaTadika = (tadika != null) ? tadika.getNamatadika() : "Tidak dikenal pasti";

    List<Map<String, String>> senaraiGuru = (List<Map<String, String>>) request.getAttribute("senaraiGuru");
    Integer jumlahGuru = (Integer) request.getAttribute("jumlahGuru");
    Integer jumlahGuruBesar = (Integer) request.getAttribute("jumlahGuruBesar");

    if (senaraiGuru == null) {
        response.sendRedirect(request.getContextPath() + "/SenaraiGuruServlet");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ms">
    <head>
        <meta charset="UTF-8">
        <title>i-KEMAS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/image/logo-sistem.png">
    </head>
    <body>
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
                    <a href="${pageContext.request.contextPath}/jsp/dashboard_guru_besar.jsp" class="nav-item">
                        <span class="material-icons">dashboard</span><span>Dashboard</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/KelulusanServlet" class="nav-item">
                        <span class="material-icons">approval</span><span>Kelulusan Permohonan</span>
                    </a>
                    <a href="#" class="nav-item active">
                        <span class="material-icons">group</span><span>Senarai Guru</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/SenaraiMuridServlet" class="nav-item">
                        <span class="material-icons">groups</span><span>Senarai Murid</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/PrestasiMuridServlet" class="nav-item">
                        <span class="material-icons">bar_chart</span><span>Laporan Prestasi Murid</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/ProfilGuruBesarServlet" class="nav-item">
                        <span class="material-icons">person</span>
                        <span>Profil Saya</span>
                    </a>
                </nav>
                <div class="sidebar-footer">
                    <a href="${pageContext.request.contextPath}/LogKeluarServlet" class="nav-item logout">
                        <span class="material-icons">logout</span><span>Log Keluar</span>
                    </a>
                </div>
            </aside>

            <div class="top-bar">
                <div class="greeting">
                    <span class="greeting-text">Selamat Sejahtera,</span>
                    <span class="greeting-text" style="color: var(--primary);"><%= p.getKodtadika()%> - <%= namaTadika%></span>
                </div>
                <div class="user-info">
                    <div class="user-details">
                        <span class="user-name"><%= p.getNama()%></span>
                        <span class="user-role">Guru Besar</span>
                    </div>
                </div>
            </div>

            <main class="main-content">
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon">
                            <span class="material-icons">school</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="statJumlahGuru"><%= jumlahGuru != null ? jumlahGuru : 0%></div>
                            <div class="stat-label">Jumlah Guru</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon">
                            <span class="material-icons">star</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="statGuruBesar"><%= jumlahGuruBesar != null ? jumlahGuruBesar : 0%></div>
                            <div class="stat-label">Guru Besar</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon">
                            <span class="material-icons">group</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="statJumlahKeseluruhan"><%= (jumlahGuru != null ? jumlahGuru : 0) + (jumlahGuruBesar != null ? jumlahGuruBesar : 0)%></div>
                            <div class="stat-label">Jumlah Keseluruhan</div>
                        </div>
                    </div>
                </div>

                <!-- Senarai Guru Table -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Senarai Guru</h3>
                        <div class="search-box">
                            <span class="material-icons search-icon">search</span>
                            <input type="text" id="searchInput" placeholder="Cari... (Nama, No. Telefon, Peranan, Kelayakan)">
                        </div>
                    </div>

                    <div class="table-wrapper">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Nama</th>
                                    <th>No. Telefon</th>
                                    <th>Peranan</th>
                                    <th>Kelayakan Akademik</th>
                                    <th>Gred Jawatan</th>
                                    <th>Tarikh Lantikan</th>
                                </tr>
                            </thead>
                            <tbody id="tableBody">
                                <% if (senaraiGuru == null || senaraiGuru.isEmpty()) { %>
                                <tr><td colspan="6" class="text-center">Tiada guru berdaftar.<\/td><\/tr>
                                        <% } else {
                                            for (Map<String, String> guru : senaraiGuru) {
                                                String peranan = guru.get("peranan");
                                                String perananDisplay = "guru".equals(peranan) ? "Guru" : "Guru Besar";
                                                String perananClass = "gurubesar".equals(peranan) ? "status-lulus" : "status-dalamproses";
                                        %>
                                <tr>
                                    <td data-label="Nama"><%= guru.get("nama")%>
                                        <% if ("gurubesar".equals(peranan)) { %>
                                        <% }%>
                                    </td>
                                    <td data-label="No. Telefon"><%= guru.get("notelefon")%></td>
                                    <td data-label="Peranan"><span class="status-badge <%= perananClass%>"><%= perananDisplay%></span></td>
                                    <td data-label="Kelayakan Akademik"><%= guru.get("kelayakanakademik")%></td>
                                    <td data-label="Gred Jawatan"><%= guru.get("gredjawatan")%></td>
                                    <td data-label="Tarikh Lantikan"><%= guru.get("tarikhkontokan")%></td>
                                </tr>
                                <% }
                                    }%>
                            </tbody>
                        </table>
                    </div>
                </div>
            </main>
        </div>

        <!-- Toast Notification -->
        <div id="toast" class="toast">
            <span class="toast-icon"></span>
            <span id="toastMessage"></span>
        </div>

        <script>
            function showToast(message, type) {
                var toast = document.getElementById('toast');
                var toastIcon = toast.querySelector('.toast-icon');

                toast.className = 'toast';
                if (type === 'error') {
                    toast.classList.add('error');
                    toastIcon.innerHTML = '❌';
                } else if (type === 'warning') {
                    toast.classList.add('warning');
                    toastIcon.innerHTML = '⚠️';
                } else {
                    toastIcon.innerHTML = '✅';
                }

                document.getElementById('toastMessage').innerHTML = message;
                toast.style.display = 'flex';

                setTimeout(function () {
                    toast.style.display = 'none';
                }, 3000);
            }

            // ==================== FUNGSI SEARCH ====================
            function searchTable() {
                const input = document.getElementById('searchInput');
                if (!input)
                    return;

                const filter = input.value.toLowerCase().trim();
                const tableBody = document.getElementById('tableBody');
                if (!tableBody)
                    return;

                const rows = tableBody.getElementsByTagName('tr');

                let visibleGuru = 0;
                let visibleGuruBesar = 0;

                for (let i = 0; i < rows.length; i++) {
                    const row = rows[i];
                    const cells = row.getElementsByTagName('td');

                    if (cells.length === 0)
                        continue;

                    let match = false;
                    let peranan = '';

                    for (let j = 0; j < cells.length; j++) {
                        const cellText = cells[j].innerText || cells[j].textContent;
                        if (cellText.toLowerCase().indexOf(filter) > -1) {
                            match = true;
                        }

                        if (j === 2) {
                            peranan = cellText.trim().toLowerCase();
                        }
                    }

                    if (filter === '' || match) {
                        row.classList.remove('hidden-row');

                        if (peranan === 'guru') {
                            visibleGuru++;
                        } else if (peranan === 'guru besar') {
                            visibleGuruBesar++;
                        }
                    } else {
                        row.classList.add('hidden-row');
                    }
                }

                const statGuru = document.getElementById('statJumlahGuru');
                const statGuruBesar = document.getElementById('statGuruBesar');
                const statJumlah = document.getElementById('statJumlahKeseluruhan');

                if (statGuru)
                    statGuru.innerText = visibleGuru;
                if (statGuruBesar)
                    statGuruBesar.innerText = visibleGuruBesar;
                if (statJumlah)
                    statJumlah.innerText = visibleGuru + visibleGuruBesar;
            }

            // Event listener untuk search input
            document.addEventListener('DOMContentLoaded', function () {
                const searchInput = document.getElementById('searchInput');
                if (searchInput) {
                    searchInput.addEventListener('keyup', searchTable);
                }
            });
        </script>
    </body>
</html>