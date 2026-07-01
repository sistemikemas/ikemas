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

    List<Map<String, String>> senaraiMurid = (List<Map<String, String>>) request.getAttribute("senaraiMurid");
    Integer jumlahMurid = (Integer) request.getAttribute("jumlahMurid");
    Integer jumlahLelaki = (Integer) request.getAttribute("jumlahLelaki");
    Integer jumlahPerempuan = (Integer) request.getAttribute("jumlahPerempuan");

    if (senaraiMurid == null) {
        response.sendRedirect(request.getContextPath() + "/SenaraiMuridServlet");
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
                    <a href="${pageContext.request.contextPath}/jsp/senarai_guru.jsp" class="nav-item">
                        <span class="material-icons">group</span><span>Senarai Guru</span>
                    </a>
                    <a href="#" class="nav-item active">
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

            <!-- Top Bar -->
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
                <!-- Stats Grid -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon">
                            <span class="material-icons">groups</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="statJumlahMurid"><%= jumlahMurid != null ? jumlahMurid : 0%></div>
                            <div class="stat-label">Jumlah Murid</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon">
                            <span class="material-icons">male</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="statLelaki"><%= jumlahLelaki != null ? jumlahLelaki : 0%></div>
                            <div class="stat-label">Lelaki</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon">
                            <span class="material-icons">female</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="statPerempuan"><%= jumlahPerempuan != null ? jumlahPerempuan : 0%></div>
                            <div class="stat-label">Perempuan</div>
                        </div>
                    </div>
                </div>

                <!-- Senarai Murid Table -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Senarai Murid</h3>
                        <div class="search-box">
                            <span class="material-icons search-icon">search</span>
                            <input type="text" id="searchInput" placeholder="Cari... (Nama, MyKid, Jantina, Bangsa)">
                        </div>
                    </div>

                    <div class="table-wrapper">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>No. MyKid</th>
                                    <th>Nama Murid</th>
                                    <th>Tarikh Lahir</th>
                                    <th>Jantina</th>
                                    <th>Bangsa</th>
                                    <th>Nama Bapa</th>
                                    <th>No. Telefon Bapa</th>
                                    <th>Nama Ibu</th>
                                    <th>No. Telefon Ibu</th>
                                </tr>
                            </thead>
                            <tbody id="tableBody">
                                <% if (senaraiMurid == null || senaraiMurid.isEmpty()) { %>
                                <tr><td colspan="9" class="text-center">Tiada murid berdaftar
                                        <% } else {
                                            for (Map<String, String> murid : senaraiMurid) {
                                        %>
                                <tr>
                                    <td data-label="No. MyKid"><%= murid.get("nokadpengenalan")%></td>
                                    <td data-label="Nama Murid"><%= murid.get("namamurid")%></td>
                                    <td data-label="Tarikh Lahir"><%= murid.get("tarikhlahir")%></td>
                                    <td data-label="Jantina"><%= murid.get("jantina")%></td>
                                    <td data-label="Bangsa"><%= murid.get("bangsa")%></td>
                                    <td data-label="Nama Bapa"><%= murid.get("namabapa")%></td>
                                    <td data-label="No. Telefon Bapa"><%= murid.get("notelefonbapa")%></td>
                                    <td data-label="Nama Ibu"><%= murid.get("namaibu")%></td>
                                    <td data-label="No. Telefon Ibu"><%= murid.get("notelefonibu")%></td>
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

                let visibleJumlah = 0;
                let visibleLelaki = 0;
                let visiblePerempuan = 0;

                for (let i = 0; i < rows.length; i++) {
                    const row = rows[i];
                    const cells = row.getElementsByTagName('td');

                    if (cells.length === 0)
                        continue;

                    let match = false;
                    let jantina = '';

                    for (let j = 0; j < cells.length; j++) {
                        const cellText = cells[j].innerText || cells[j].textContent;
                        if (cellText.toLowerCase().indexOf(filter) > -1) {
                            match = true;
                        }

                        // Kolom Jantina adalah index ke-3
                        if (j === 3) {
                            jantina = cellText.trim().toLowerCase();
                        }
                    }

                    if (filter === '' || match) {
                        row.classList.remove('hidden-row');
                        visibleJumlah++;

                        if (jantina === 'lelaki') {
                            visibleLelaki++;
                        } else if (jantina === 'perempuan') {
                            visiblePerempuan++;
                        }
                    } else {
                        row.classList.add('hidden-row');
                    }
                }

                // Update stat-value
                const statJumlah = document.getElementById('statJumlahMurid');
                const statLelaki = document.getElementById('statLelaki');
                const statPerempuan = document.getElementById('statPerempuan');

                if (statJumlah)
                    statJumlah.innerText = visibleJumlah;
                if (statLelaki)
                    statLelaki.innerText = visibleLelaki;
                if (statPerempuan)
                    statPerempuan.innerText = visiblePerempuan;
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