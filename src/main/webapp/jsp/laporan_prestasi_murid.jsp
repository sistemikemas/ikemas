<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Pengguna, dao.TadikaDAO, model.Tadika, java.util.List, java.util.Map" %>
<%
    // ==================== SEMAKAN LOG MASUK ====================
    Pengguna p = (Pengguna) session.getAttribute("pengguna");
    if (p == null || !p.getPeranan().equals("gurubesar")) {
        response.sendRedirect("log_masuk.jsp");
        return;
    }

    // ==================== MAKLUMAT TADIKA ====================
    TadikaDAO tadikaDAO = new TadikaDAO();
    Tadika tadika = tadikaDAO.getTadikaByKod(p.getKodtadika());
    String namaTadika = (tadika != null) ? tadika.getNamatadika() : "Tidak dikenal pasti";

    // ==================== DATA UNTUK KESEDIAAN TAHUN 1 ====================
    List<Map<String, String>> dataKesediaan = (List<Map<String, String>>) request.getAttribute("dataKesediaan");
    Integer jumlahMuridKesediaan = (Integer) request.getAttribute("jumlahMuridKesediaan");
    Integer jumlahAKesediaan = (Integer) request.getAttribute("jumlahAKesediaan");
    Integer jumlahBKesediaan = (Integer) request.getAttribute("jumlahBKesediaan");
    Integer jumlahCKesediaan = (Integer) request.getAttribute("jumlahCKesediaan");
    Integer jumlahDKesediaan = (Integer) request.getAttribute("jumlahDKesediaan");
    String tahunKesediaanDipilih = (String) request.getAttribute("tahunKesediaanDipilih");
    String subjekKesediaanDipilih = (String) request.getAttribute("subjekKesediaanDipilih");

    // ==================== DATA UNTUK PENTAKSIRAN BULANAN ====================
    List<Map<String, String>> dataPentaksiran = (List<Map<String, String>>) request.getAttribute("dataPentaksiran");
    Integer jumlahMuridPentaksiran = (Integer) request.getAttribute("jumlahMuridPentaksiran");
    Integer jumlahAPentaksiran = (Integer) request.getAttribute("jumlahAPentaksiran");
    Integer jumlahBPentaksiran = (Integer) request.getAttribute("jumlahBPentaksiran");
    Integer jumlahCPentaksiran = (Integer) request.getAttribute("jumlahCPentaksiran");
    Integer jumlahDPentaksiran = (Integer) request.getAttribute("jumlahDPentaksiran");
    String tahunPentaksiranDipilih = (String) request.getAttribute("tahunPentaksiranDipilih");
    String bulanPentaksiranDipilih = (String) request.getAttribute("bulanPentaksiranDipilih");
    String subjekPentaksiranDipilih = (String) request.getAttribute("subjekPentaksiranDipilih");

    // ==================== DATA UNTUK DROPDOWN ====================
    List<Integer> senaraiTahun = (List<Integer>) request.getAttribute("senaraiTahun");
    List<String> senaraiSubjek = (List<String>) request.getAttribute("senaraiSubjek");
    List<Integer> senaraiBulan = (List<Integer>) request.getAttribute("senaraiBulan");

    // Array nama bulan untuk paparan
    String[] namaBulan = {"Januari", "Februari", "Mac", "April", "Mei", "Jun",
        "Julai", "Ogos", "September", "Oktober", "November", "Disember"};
%>
<!DOCTYPE html>
<html lang="ms">
    <head>
        <meta charset="UTF-8">
        <title>i-KEMAS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/image/logo-sistem.png">
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    </head>
    <body>
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
                    <a href="${pageContext.request.contextPath}/jsp/dashboard_guru_besar.jsp" class="nav-item">
                        <span class="material-icons">dashboard</span><span>Dashboard</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/KelulusanServlet" class="nav-item">
                        <span class="material-icons">approval</span><span>Kelulusan Permohonan</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/jsp/senarai_guru.jsp" class="nav-item">
                        <span class="material-icons">group</span><span>Senarai Guru</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/jsp/senarai_murid.jsp" class="nav-item">
                        <span class="material-icons">groups</span><span>Senarai Murid</span>
                    </a>
                    <a href="#" class="nav-item active">
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

            <!-- ==================== TOP BAR ==================== -->
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
                <!-- ==================== BAHAGIAN 1: KESEDIAAN TAHUN 1 ==================== -->
                <div class="section-title-prestasi">
                    Kesediaan Tahun 1
                </div>

                <!-- Filter untuk Kesediaan -->
                <form method="get" action="${pageContext.request.contextPath}/PrestasiMuridServlet" class="filter-group-prestasi">
                    <div class="filter-item">
                        <label>Tahun:</label>
                        <select name="tahunKesediaan">
                            <option value="">Semua Tahun</option>
                            <% if (senaraiTahun != null) {
                                    for (Integer tahun : senaraiTahun) {%>
                            <option value="<%= tahun%>" <%= (tahunKesediaanDipilih != null && tahun.toString().equals(tahunKesediaanDipilih)) ? "selected" : ""%>><%= tahun%></option>
                            <% }
                                } %>
                        </select>
                    </div>
                    <div class="filter-item">
                        <label>Subjek:</label>
                        <select name="subjekKesediaan">
                            <option value="semua">Semua Subjek</option>
                            <% if (senaraiSubjek != null) {
                                    for (String sub : senaraiSubjek) {%>
                            <option value="<%= sub%>" <%= (subjekKesediaanDipilih != null && sub.equals(subjekKesediaanDipilih)) ? "selected" : ""%>><%= sub%></option>
                            <% }
                                }%>
                        </select>
                    </div>
                    <input type="hidden" name="tahunPentaksiran" value="<%= tahunPentaksiranDipilih != null ? tahunPentaksiranDipilih : ""%>">
                    <input type="hidden" name="bulanPentaksiran" value="<%= bulanPentaksiranDipilih != null ? bulanPentaksiranDipilih : ""%>">
                    <input type="hidden" name="subjekPentaksiran" value="<%= subjekPentaksiranDipilih != null ? subjekPentaksiranDipilih : ""%>">
                    <button type="submit" class="btn-filter">Cari</button>
                    <button type="button" onclick="window.location.href = '${pageContext.request.contextPath}/PrestasiMuridServlet'" class="btn-reset">Reset</button>
                </form>

                <!-- Statistik Kesediaan (5 stat) -->
                <div class="stat-mini-grid">
                    <div class="stat-mini-card">
                        <div class="stat-mini-value" id="statJumlahKesediaan"><%= jumlahMuridKesediaan != null ? jumlahMuridKesediaan : 0%></div>
                        <div class="stat-mini-label">Jumlah Murid</div>
                    </div>
                    <div class="stat-mini-card">
                        <div class="stat-mini-value" id="statAKesediaan"><%= jumlahAKesediaan != null ? jumlahAKesediaan : 0%></div>
                        <div class="stat-mini-label">A (Cemerlang)</div>
                    </div>
                    <div class="stat-mini-card">
                        <div class="stat-mini-value" id="statBKesediaan"><%= jumlahBKesediaan != null ? jumlahBKesediaan : 0%></div>
                        <div class="stat-mini-label">B (Baik)</div>
                    </div>
                    <div class="stat-mini-card">
                        <div class="stat-mini-value" id="statCKesediaan"><%= jumlahCKesediaan != null ? jumlahCKesediaan : 0%></div>
                        <div class="stat-mini-label">C (Memuaskan)</div>
                    </div>
                    <div class="stat-mini-card">
                        <div class="stat-mini-value" id="statDKesediaan"><%= jumlahDKesediaan != null ? jumlahDKesediaan : 0%></div>
                        <div class="stat-mini-label">D (Penambahbaikan)</div>
                    </div>
                </div>

                <!-- Graf 1: Horizontal Bar Chart untuk Kesediaan -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Kesediaan Tahun 1</h3>
                    </div>
                    <div class="chart-container">
                        <canvas id="kesediaanChart" style="max-height: 400px; width: 100%;"></canvas>
                    </div>
                </div>

                <!-- Jadual 1: Senarai Prestasi Kesediaan -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Senarai Murid</h3>
                        <div class="search-box">
                            <span class="material-icons search-icon">search</span>
                            <input type="text" id="searchKesediaan" placeholder="Cari ... (Nama, MyKid)">
                        </div>
                    </div>
                    <div class="table-wrapper">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>No. MyKid</th>
                                    <th>Nama Murid</th>
                                    <th>Markah (%)</th>
                                    <th>Gred</th>
                                </tr>
                            </thead>
                            <tbody id="tableKesediaan">
                                <% if (dataKesediaan == null || dataKesediaan.isEmpty()) { %>
                                <tr><td colspan="4" class="text-center">Tiada data.
                                        <% } else {
                                            for (Map<String, String> item : dataKesediaan) {
                                                double markah = Double.parseDouble(item.get("markah"));
                                                String gred = "";
                                                if (markah >= 80)
                                                    gred = "A";
                                                else if (markah >= 60)
                                                    gred = "B";
                                                else if (markah >= 50)
                                                    gred = "C";
                                                else
                                                    gred = "D";
                                        %>
                                <tr>
                                    <td><%= item.get("nokadpengenalan")%></td>
                                    <td><%= item.get("namamurid")%></td>
                                    <td><%= item.get("markah")%></td>
                                    <td><%= gred%></td>
                                </tr>
                                <% }
                                    } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- ==================== BAHAGIAN 2: PENTAKSIRAN BULANAN ==================== -->
                <div class="section-title">
                    Pentaksiran Bulanan
                </div>

                <!-- Filter untuk Pentaksiran -->
                <form method="get" action="${pageContext.request.contextPath}/PrestasiMuridServlet" class="filter-group-prestasi">
                    <div class="filter-item">
                        <label>Tahun:</label>
                        <select name="tahunPentaksiran">
                            <option value="">Semua Tahun</option>
                            <% if (senaraiTahun != null) {
                                    for (Integer tahun : senaraiTahun) {%>
                            <option value="<%= tahun%>" <%= (tahunPentaksiranDipilih != null && tahun.toString().equals(tahunPentaksiranDipilih)) ? "selected" : ""%>><%= tahun%></option>
                            <% }
                                } %>
                        </select>
                    </div>
                    <div class="filter-item">
                        <label>Bulan:</label>
                        <select name="bulanPentaksiran">
                            <option value="">Semua Bulan</option>
                            <% if (senaraiBulan != null) {
                                    for (Integer bulan : senaraiBulan) {%>
                            <option value="<%= bulan%>" <%= (bulanPentaksiranDipilih != null && bulan.toString().equals(bulanPentaksiranDipilih)) ? "selected" : ""%>><%= namaBulan[bulan - 1]%></option>
                            <% }
                                } %>
                        </select>
                    </div>
                    <div class="filter-item">
                        <label>Subjek:</label>
                        <select name="subjekPentaksiran">
                            <option value="semua">Semua Subjek</option>
                            <% if (senaraiSubjek != null) {
                                    for (String sub : senaraiSubjek) {%>
                            <option value="<%= sub%>" <%= (subjekPentaksiranDipilih != null && sub.equals(subjekPentaksiranDipilih)) ? "selected" : ""%>><%= sub%></option>
                            <% }
                                }%>
                        </select>
                    </div>
                    <input type="hidden" name="tahunKesediaan" value="<%= tahunKesediaanDipilih != null ? tahunKesediaanDipilih : ""%>">
                    <input type="hidden" name="subjekKesediaan" value="<%= subjekKesediaanDipilih != null ? subjekKesediaanDipilih : ""%>">
                    <button type="submit" class="btn-filter">Cari</button>
                    <button type="button" onclick="window.location.href = '${pageContext.request.contextPath}/PrestasiMuridServlet'" class="btn-reset">Reset</button>
                </form>

                <!-- Statistik Pentaksiran (5 stat) -->
                <div class="stat-mini-grid">
                    <div class="stat-mini-card">
                        <div class="stat-mini-value" id="statJumlahPentaksiran"><%= jumlahMuridPentaksiran != null ? jumlahMuridPentaksiran : 0%></div>
                        <div class="stat-mini-label">Jumlah Murid</div>
                    </div>
                    <div class="stat-mini-card">
                        <div class="stat-mini-value" id="statAPentaksiran"><%= jumlahAPentaksiran != null ? jumlahAPentaksiran : 0%></div>
                        <div class="stat-mini-label">A (Cemerlang)</div>
                    </div>
                    <div class="stat-mini-card">
                        <div class="stat-mini-value" id="statBPentaksiran"><%= jumlahBPentaksiran != null ? jumlahBPentaksiran : 0%></div>
                        <div class="stat-mini-label">B (Baik)</div>
                    </div>
                    <div class="stat-mini-card">
                        <div class="stat-mini-value" id="statCPentaksiran"><%= jumlahCPentaksiran != null ? jumlahCPentaksiran : 0%></div>
                        <div class="stat-mini-label">C (Memuaskan)</div>
                    </div>
                    <div class="stat-mini-card">
                        <div class="stat-mini-value" id="statDPentaksiran"><%= jumlahDPentaksiran != null ? jumlahDPentaksiran : 0%></div>
                        <div class="stat-mini-label">D (Penambahbaikan)</div>
                    </div>
                </div>

                <!-- Graf 2: Horizontal Bar Chart untuk Pentaksiran -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Pentaksiran Bulanan</h3>
                    </div>
                    <div class="chart-container">
                        <canvas id="pentaksiranChart" style="max-height: 400px; width: 100%;"></canvas>
                    </div>
                </div>

                <!-- Jadual 2: Senarai Prestasi Pentaksiran -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Senarai Murid</h3>
                        <div class="search-box">
                            <span class="material-icons search-icon">search</span>
                            <input type="text" id="searchPentaksiran" placeholder="Cari ... (Nama, MyKid, Tarikh)">                        </div>
                    </div>
                    <div class="table-wrapper">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>No. MyKid</th>
                                    <th>Nama Murid</th>
                                    <th>Tarikh</th>
                                    <th>Markah (%)</th>
                                    <th>Gred</th>
                                </tr>
                            </thead>
                            <tbody id="tablePentaksiran">
                                <% if (dataPentaksiran == null || dataPentaksiran.isEmpty()) { %>
                                <tr><td colspan="5" class="text-center">Tiada data.
                                        <% } else {
                                            for (Map<String, String> item : dataPentaksiran) {
                                                double markah = Double.parseDouble(item.get("markah"));
                                                String gred = "";
                                                if (markah >= 80)
                                                    gred = "A";
                                                else if (markah >= 60)
                                                    gred = "B";
                                                else if (markah >= 50)
                                                    gred = "C";
                                                else
                                                    gred = "D";
                                        %>
                                        <%
                                            String tarikhPaparan = item.get("tarikh") != null ? item.get("tarikh") : "-";
                                        %>
                                <tr>
                                    <td><%= item.get("nokadpengenalan")%></td>
                                    <td><%= item.get("namamurid")%></td>
                                    <td><%= tarikhPaparan%></td>
                                    <td><%= item.get("markah")%></td>
                                    <td><%= gred%></td>
                                </tr>
                                <% }
                                    } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </main>
        </div>

        <script>
            // ==================== GRAF 1: KESEDIAAN TAHUN 1 (HORIZONTAL BAR CHART) ====================
            const kesediaanLabels = [];
            const kesediaanData = [];

            <% if (dataKesediaan != null) {
                    for (Map<String, String> item : dataKesediaan) {%>
            kesediaanLabels.push("<%= item.get("namamurid")%>");
            kesediaanData.push(<%= Double.parseDouble(item.get("markah"))%>);
            <% }
                } %>

            const ctxKesediaan = document.getElementById('kesediaanChart').getContext('2d');
            new Chart(ctxKesediaan, {
                type: 'bar',
                data: {
                    labels: kesediaanLabels,
                    datasets: [{
                            label: 'Markah (%)',
                            data: kesediaanData,
                            backgroundColor: 'rgba(19, 1, 124, 0.8)',
                            borderRadius: 5
                        }]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    maintainAspectRatio: true,
                    scales: {
                        x: {
                            beginAtZero: true,
                            max: 100,
                            title: {display: false, text: 'Markah (%)'},
                            ticks: {callback: function (value) {
                                    return value + '%';
                                }}
                        },
                        y: {title: {display: false, text: 'Nama Murid'}}
                    },
                    plugins: {legend: {position: ''}}
                }
            });

            // ==================== GRAF 2: PENTAKSIRAN BULANAN (HORIZONTAL BAR CHART) ====================
            const pentaksiranLabels = [];
            const pentaksiranData = [];

            <% if (dataPentaksiran != null) {
                    for (Map<String, String> item : dataPentaksiran) {%>
            pentaksiranLabels.push("<%= item.get("namamurid")%>");
            pentaksiranData.push(<%= Double.parseDouble(item.get("markah"))%>);
            <% }
                }%>

            const ctxPentaksiran = document.getElementById('pentaksiranChart').getContext('2d');
            new Chart(ctxPentaksiran, {
                type: 'bar',
                data: {
                    labels: pentaksiranLabels,
                    datasets: [{
                            label: 'Markah (%)',
                            data: pentaksiranData,
                            backgroundColor: 'rgba(34, 197, 94, 0.8)',
                            borderRadius: 5
                        }]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    maintainAspectRatio: true,
                    scales: {
                        x: {
                            beginAtZero: true,
                            max: 100,
                            title: {display: false, text: 'Markah (%)'},
                            ticks: {callback: function (value) {
                                    return value + '%';
                                }}
                        },
                        y: {title: {display: false, text: 'Nama Murid'}}
                    },
                    plugins: {legend: {position: ''}}
                }
            });

            // ==================== FUNGSI SEARCH UNTUK JADUAL KESEDIAAN ====================
            function searchTableKesediaan() {
                const input = document.getElementById('searchKesediaan');
                const filter = input.value.toLowerCase().trim();
                const tableBody = document.getElementById('tableKesediaan');
                const rows = tableBody.getElementsByTagName('tr');

                let visibleJumlah = 0;
                let visibleA = 0, visibleB = 0, visibleC = 0, visibleD = 0;

                for (let i = 0; i < rows.length; i++) {
                    const row = rows[i];
                    const cells = row.getElementsByTagName('td');
                    if (cells.length === 0)
                        continue;

                    let match = false;
                    let markah = 0;

                    for (let j = 0; j < cells.length; j++) {
                        const cellText = cells[j].innerText || cells[j].textContent;
                        if (cellText.toLowerCase().indexOf(filter) > -1)
                            match = true;
                        if (j === 2)
                            markah = parseFloat(cellText);
                    }

                    if (filter === '' || match) {
                        row.classList.remove('hidden-row');
                        visibleJumlah++;
                        if (markah >= 80)
                            visibleA++;
                        else if (markah >= 60)
                            visibleB++;
                        else if (markah >= 50)
                            visibleC++;
                        else if (!isNaN(markah))
                            visibleD++;
                    } else {
                        row.classList.add('hidden-row');
                    }
                }

                document.getElementById('statJumlahKesediaan').innerText = visibleJumlah;
                document.getElementById('statAKesediaan').innerText = visibleA;
                document.getElementById('statBKesediaan').innerText = visibleB;
                document.getElementById('statCKesediaan').innerText = visibleC;
                document.getElementById('statDKesediaan').innerText = visibleD;
            }

            // ==================== FUNGSI SEARCH UNTUK JADUAL PENTAKSIRAN ====================
            function searchTablePentaksiran() {
                const input = document.getElementById('searchPentaksiran');
                const filter = input.value.toLowerCase().trim();
                const tableBody = document.getElementById('tablePentaksiran');
                const rows = tableBody.getElementsByTagName('tr');

                let visibleJumlah = 0;
                let visibleA = 0, visibleB = 0, visibleC = 0, visibleD = 0;

                for (let i = 0; i < rows.length; i++) {
                    const row = rows[i];
                    const cells = row.getElementsByTagName('td');
                    if (cells.length === 0)
                        continue;

                    let match = false;
                    let markah = 0;

                    for (let j = 0; j < cells.length; j++) {
                        const cellText = cells[j].innerText || cells[j].textContent;
                        if (cellText.toLowerCase().indexOf(filter) > -1)
                            match = true;
                        if (j === 3)
                            markah = parseFloat(cellText);
                    }

                    if (filter === '' || match) {
                        row.classList.remove('hidden-row');
                        visibleJumlah++;
                        if (markah >= 80)
                            visibleA++;
                        else if (markah >= 60)
                            visibleB++;
                        else if (markah >= 50)
                            visibleC++;
                        else if (!isNaN(markah))
                            visibleD++;
                    } else {
                        row.classList.add('hidden-row');
                    }
                }

                document.getElementById('statJumlahPentaksiran').innerText = visibleJumlah;
                document.getElementById('statAPentaksiran').innerText = visibleA;
                document.getElementById('statBPentaksiran').innerText = visibleB;
                document.getElementById('statCPentaksiran').innerText = visibleC;
                document.getElementById('statDPentaksiran').innerText = visibleD;
            }

            // ==================== EVENT LISTENER UNTUK SEARCH ====================
            document.getElementById('searchKesediaan').addEventListener('keyup', searchTableKesediaan);
            document.getElementById('searchPentaksiran').addEventListener('keyup', searchTablePentaksiran);
        </script>
    </body>
</html>