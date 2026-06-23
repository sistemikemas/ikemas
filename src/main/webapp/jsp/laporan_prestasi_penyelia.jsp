<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Pengguna, model.Tadika, java.util.List, java.util.Map" %>
<%@ page import="util.DewanUndanganNegeri" %>
<%
    Pengguna p = (Pengguna) session.getAttribute("pengguna");
    if (p == null || !p.getPeranan().equals("penyelia")) {
        response.sendRedirect("log_masuk.jsp");
        return;
    }

    List<Tadika> senaraiTadika = (List<Tadika>) request.getAttribute("senaraiTadika");
    List<String> senaraiSubjek = (List<String>) request.getAttribute("senaraiSubjek");
    List<Map<String, Object>> prestasiData = (List<Map<String, Object>>) request.getAttribute("prestasiData");

    Integer selectedTahun = (Integer) request.getAttribute("selectedTahun");
    Integer selectedBulan = (Integer) request.getAttribute("selectedBulan");
    String selectedTadika = (String) request.getAttribute("selectedTadika");
    String selectedSubjek = (String) request.getAttribute("selectedSubjek");

    Double purataKeseluruhan = (Double) request.getAttribute("purataKeseluruhan");
    Integer jumlahMurid = (Integer) request.getAttribute("jumlahMurid");
    Integer jumlahHadir = (Integer) request.getAttribute("jumlahHadir");
    Integer jumlahTidakHadir = (Integer) request.getAttribute("jumlahTidakHadir");
    Integer gredA = (Integer) request.getAttribute("gredA");
    Integer gredB = (Integer) request.getAttribute("gredB");
    Integer gredC = (Integer) request.getAttribute("gredC");
    Integer gredD = (Integer) request.getAttribute("gredD");

    if (prestasiData == null) {
        prestasiData = new java.util.ArrayList<>();
    }
    if (selectedTahun == null) {
        selectedTahun = 2026;
    }
    if (selectedBulan == null) {
        selectedBulan = 0;
    }

    // Format DUN
    String dunSeliaan = p.getDunseliaan();
    String dunDisplay = dunSeliaan;
    if (dunSeliaan != null && dunSeliaan.contains(" ")) {
        int firstSpace = dunSeliaan.indexOf(" ");
        dunDisplay = dunSeliaan.substring(0, firstSpace) + ", " + dunSeliaan.substring(firstSpace + 1);
    }

    String[] bulanNama = {"", "Januari", "Februari", "Mac", "April", "Mei", "Jun",
        "Julai", "Ogos", "September", "Oktober", "November", "Disember"};
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
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <style>
            .filter-section {
                display: flex;
                gap: 16px;
                flex-wrap: wrap;
                align-items: flex-end;
                margin-bottom: 24px;
                padding: 20px;
                background: var(--gray-100);
            }
            .filter-group {
                display: flex;
                flex-direction: column;
                gap: 6px;
            }
            .filter-group label {
                font-size: 12px;
                font-weight: 600;
                color: var(--gray-600);
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            .filter-group select {
                padding: 10px 12px;
                border: 1px solid var(--gray-400);
                font-size: 14px;
                font-family: Georgia, serif;
                background: white;
                min-width: 150px;
            }
            .filter-group select:focus {
                outline: none;
                border-color: var(--primary);
            }
            .btn-filter {
                background: var(--primary);
                color: white;
                border: none;
                padding: 10px 24px;
                cursor: pointer;
                font-family: Georgia, serif;
                font-size: 14px;
                font-weight: 600;
                display: inline-flex;
                align-items: center;
                gap: 8px;
                height: 42px;
            }
            .btn-filter:hover {
                background: var(--primary-dark);
            }
            .stats-mini-grid {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 20px;
                margin-bottom: 24px;
            }
            .grade-distribution {
                display: flex;
                gap: 16px;
                flex-wrap: wrap;
                margin-bottom: 24px;
            }
            .grade-item {
                flex: 1;
                text-align: center;
                padding: 12px;
                background: var(--gray-100);
            }
            .grade-letter {
                font-size: 24px;
                font-weight: 700;
                display: block;
            }
            .grade-count {
                font-size: 20px;
                font-weight: 600;
                color: var(--gray-800);
            }
            .grade-A {
                color: #10b981;
            }
            .grade-B {
                color: #3b82f6;
            }
            .grade-C {
                color: #f59e0b;
            }
            .grade-D {
                color: #ef4444;
            }
            .chart-container {
                margin-bottom: 24px;
                padding: 20px;
                background: white;
                border: 1px solid var(--gray-200);
            }
            @media (max-width: 768px) {
                .filter-section {
                    flex-direction: column;
                    align-items: stretch;
                }
                .stats-mini-grid {
                    grid-template-columns: repeat(2, 1fr);
                    gap: 12px;
                }
                .grade-distribution {
                    flex-direction: column;
                }
                .btn-filter {
                    width: 100%;
                    justify-content: center;
                }
            }
        </style>
    </head>
    <body>
        <div id="toastContainer" class="toast-container"></div>

        <div class="dashboard">
            <aside class="sidebar">
                <div class="sidebar-header">
                    <div class="logo"><h2>i-KEMAS</h2></div>
                    <p>SISTEM PENGURUSAN KANAK-KANAK<br>TABIKA KEMAS</p>
                </div>
                <nav class="nav-menu">
                    <a href="${pageContext.request.contextPath}/DashboardPenyeliaServlet" class="nav-item">
                        <span class="material-icons">dashboard</span><span>Dashboard</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/SenaraiTadikaPenyeliaServlet" class="nav-item">
                        <span class="material-icons">school</span><span>Senarai Tadika</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/TambahGuruAtauGuruBesarServlet" class="nav-item">
                        <span class="material-icons">person_add</span><span>Tambah Guru/Guru Besar</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/PemantauanTadikaPenyeliaServlet" class="nav-item">
                        <span class="material-icons">assignment</span>
                        <span>Pemantauan Tadika</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/LaporanPrestasiPenyeliaServlet" class="nav-item active">
                        <span class="material-icons">bar_chart</span><span>Laporan Prestasi</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/ProfilPenyeliaServlet" class="nav-item">
                        <span class="material-icons">person</span><span>Profil Saya</span>
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
                    <span class="greeting-text" style="color: var(--primary);">DUN: <%= dunDisplay%></span>
                </div>
                <div class="user-info">
                    <div class="user-details">
                        <span class="user-name"><%= p.getNama()%></span>
                        <span class="user-role">Penyelia</span>
                    </div>
                </div>
            </div>

            <main class="main-content">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            Laporan Prestasi
                        </h3>
                    </div>
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/LaporanPrestasiPenyeliaServlet" method="get" class="filter-section">
                            <div class="filter-group">
                                <label>Tahun</label>
                                <select name="tahun">
                                    <option value="2025" <%= selectedTahun == 2025 ? "selected" : ""%>>2025</option>
                                    <option value="2026" <%= selectedTahun == 2026 ? "selected" : ""%>>2026</option>
                                    <option value="2027" <%= selectedTahun == 2027 ? "selected" : ""%>>2027</option>
                                </select>
                            </div>
                            <div class="filter-group">
                                <label>Bulan</label>
                                <select name="bulan">
                                    <option value="0" <%= selectedBulan == 0 ? "selected" : ""%>>Keseluruhan Tahun</option>
                                    <% for (int i = 1; i <= 12; i++) {%>
                                    <option value="<%= i%>" <%= selectedBulan == i ? "selected" : ""%>><%= bulanNama[i]%></option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="filter-group">
                                <label>Tadika</label>
                                <select name="tadika">
                                    <option value="">-- Pilih Tadika --</option>
                                    <% if (senaraiTadika != null) {
                                            for (Tadika t : senaraiTadika) {%>
                                    <option value="<%= t.getKodtadika()%>" <%= selectedTadika != null && selectedTadika.equals(t.getKodtadika()) ? "selected" : ""%>><%= t.getNamatadika()%></option>
                                    <% }
                                        } %>
                                </select>
                            </div>
                            <% if (selectedBulan > 0) { %>
                            <div class="filter-group">
                                <label>Subjek</label>
                                <select name="subjek">
                                    <option value="">Semua Subjek</option>
                                    <% if (senaraiSubjek != null) {
                                            for (String s : senaraiSubjek) {%>
                                    <option value="<%= s%>" <%= (selectedSubjek != null && selectedSubjek.equals(s)) ? "selected" : ""%>><%= s%></option>
                                    <% }
                                        } %>
                                </select>
                            </div>
                            <% } %>
                            <button type="submit" class="btn-filter">
                                <span class="material-icons">search</span> Papar
                            </button>
                        </form>

                        <% if (selectedTadika != null && !selectedTadika.isEmpty() && prestasiData != null && !prestasiData.isEmpty()) {%>

                        <div class="stats-mini-grid">
                            <div class="stat-card">
                                <div class="stat-icon"><span class="material-icons">groups</span></div>
                                <div class="stat-info">
                                    <div class="stat-value"><%= jumlahMurid != null ? jumlahMurid : 0%></div>
                                    <div class="stat-label">Jumlah Murid</div>
                                </div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-icon"><span class="material-icons">trending_up</span></div>
                                <div class="stat-info">
                                    <div class="stat-value"><%= String.format("%.1f", purataKeseluruhan != null ? purataKeseluruhan : 0)%>%</div>
                                    <div class="stat-label">Purata Markah</div>
                                </div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-icon"><span class="material-icons">check_circle</span></div>
                                <div class="stat-info">
                                    <div class="stat-value"><%= jumlahHadir != null ? jumlahHadir : 0%></div>
                                    <div class="stat-label">Hadir</div>
                                </div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-icon"><span class="material-icons">block</span></div>
                                <div class="stat-info">
                                    <div class="stat-value"><%= jumlahTidakHadir != null ? jumlahTidakHadir : 0%></div>
                                    <div class="stat-label">Tidak Hadir</div>
                                </div>
                            </div>
                        </div>

                        <div class="grade-distribution">
                            <div class="grade-item">
                                <span class="grade-letter grade-A">A</span>
                                <span class="grade-count"><%= gredA != null ? gredA : 0%></span>
                                <span class="stat-label">Cemerlang (80-100)</span>
                            </div>
                            <div class="grade-item">
                                <span class="grade-letter grade-B">B</span>
                                <span class="grade-count"><%= gredB != null ? gredB : 0%></span>
                                <span class="stat-label">Baik (60-79)</span>
                            </div>
                            <div class="grade-item">
                                <span class="grade-letter grade-C">C</span>
                                <span class="grade-count"><%= gredC != null ? gredC : 0%></span>
                                <span class="stat-label">Memuaskan (50-59)</span>
                            </div>
                            <div class="grade-item">
                                <span class="grade-letter grade-D">D</span>
                                <span class="grade-count"><%= gredD != null ? gredD : 0%></span>
                                <span class="stat-label">Perlu Bimbingan (0-49)</span>
                            </div>
                        </div>

                        <div class="chart-container">
                            <canvas id="prestasiChart" height="300"></canvas>
                        </div>

                        <div class="table-wrapper">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Bil</th>
                                        <th>Nama</th>
                                        <th>Markah (%)</th>
                                        <th>Gred</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% int bil = 1;
                                        for (Map<String, Object> item : prestasiData) {
                                            String nama = "";
                                            double markah = 0;

                                            if (selectedBulan == 0) {
                                                // Yearly view - has "bulan" and "skor"
                                                Integer bulan = (Integer) item.get("bulan");
                                                Object skorObj = item.get("skor");
                                                if (skorObj != null) {
                                                    markah = (double) skorObj;
                                                }
                                                nama = bulanNama[bulan != null ? bulan : 1];
                                            } else {
                                                // Monthly view - has "namamurid" and "markah"
                                                Object namaObj = item.get("namamurid");
                                                Object markahObj = item.get("markah");
                                                if (namaObj != null) {
                                                    nama = (String) namaObj;
                                                }
                                                if (markahObj != null) {
                                                    markah = (double) markahObj;
                                                }
                                            }

                                            String gred = "";
                                            if (markah >= 80)
                                                gred = "A";
                                            else if (markah >= 60)
                                                gred = "B";
                                            else if (markah >= 50)
                                                gred = "C";
                                            else if (markah > 0)
                                                gred = "D";
                                            else
                                                gred = "-";
                                    %>
                                    <tr>
                                        <td><%= bil++%></td>
                                        <td><%= nama%></td>
                                        <td><%= markah > 0 ? String.format("%.2f", markah) : "-"%></td>
                                        <td><%= gred%></td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>

                        <% } else if (selectedTadika != null && !selectedTadika.isEmpty()) { %>
                        <div class="empty-state">
                            <span class="material-icons">assessment</span>
                            <p>Tiada data prestasi untuk tempoh ini</p>
                        </div>
                        <% } else { %>
                        <div class="empty-state">
                            <p>Sila pilih tadika untuk melihat laporan prestasi</p>
                        </div>
                        <% } %>
                    </div>
                </div>
            </main>
        </div>

        <script>
            let prestasiChart = null;

            <% if (selectedTadika != null && !selectedTadika.isEmpty() && prestasiData != null && !prestasiData.isEmpty()) { %>
            const ctx = document.getElementById('prestasiChart').getContext('2d');

            <% if (selectedBulan == 0) {
                    int[] bulanData = new int[12];
                    for (int i = 0; i < 12; i++) {
                        bulanData[i] = 0;
                    }
                    for (Map<String, Object> item : prestasiData) {
                        Integer bulan = (Integer) item.get("bulan");
                        Object skorObj = item.get("skor");
                        double skor = 0;
                        if (skorObj != null) {
                            skor = (double) skorObj;
                        }
                        if (bulan != null && bulan >= 1 && bulan <= 12) {
                            bulanData[bulan - 1] = (int) Math.round(skor);
                        }
                    }
            %>
            const monthlyData = [<%= bulanData[0]%>, <%= bulanData[1]%>, <%= bulanData[2]%>, <%= bulanData[3]%>, <%= bulanData[4]%>, <%= bulanData[5]%>, <%= bulanData[6]%>, <%= bulanData[7]%>, <%= bulanData[8]%>, <%= bulanData[9]%>, <%= bulanData[10]%>, <%= bulanData[11]%>];
            const bulanLabels = ['Jan', 'Feb', 'Mac', 'Apr', 'Mei', 'Jun', 'Jul', 'Ogo', 'Sep', 'Okt', 'Nov', 'Dis'];

            prestasiChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: bulanLabels,
                    datasets: [{
                            label: 'Purata Markah (%)',
                            data: monthlyData,
                            borderColor: '#13017c',
                            backgroundColor: 'rgba(19, 1, 124, 0.1)',
                            borderWidth: 2,
                            fill: true,
                            tension: 0.3,
                            pointRadius: 4,
                            pointBackgroundColor: '#13017c'
                        }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: true,
                    scales: {y: {beginAtZero: true, max: 100, title: {display: true, text: 'Skor (%)'}}}
                }
            });
            <% } else {
                List<Double> markahList = new java.util.ArrayList<>();
                List<String> namaList = new java.util.ArrayList<>();
                for (Map<String, Object> item : prestasiData) {
                    Object namaObj = item.get("namamurid");
                    Object markahObj = item.get("markah");
                    namaList.add(namaObj != null ? (String) namaObj : "-");
                    markahList.add(markahObj != null ? (double) markahObj : 0);
                }
            %>
            const studentMarks = [<% for (int i = 0; i < markahList.size(); i++) {%><%= (int) Math.round(markahList.get(i))%><%= i < markahList.size() - 1 ? "," : ""%><% } %>];
            const studentNames = [<% for (int i = 0; i < namaList.size(); i++) {%>'<%= namaList.get(i).replace("'", "\\'")%>'<%= i < namaList.size() - 1 ? "," : ""%><% } %>];
                    prestasiChart = new Chart(ctx, {
                        type: 'bar',
                        data: {
                            labels: studentNames,
                            datasets: [{
                                    label: 'Markah (%)',
                                    data: studentMarks,
                                    backgroundColor: studentMarks.map(m => m >= 80 ? '#10b981' : (m >= 60 ? '#3b82f6' : (m >= 50 ? '#f59e0b' : '#ef4444'))),
                                    borderColor: '#13017c',
                                    borderWidth: 1,
                                    borderRadius: 4
                                }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: true,
                            scales: {y: {beginAtZero: true, max: 100, title: {display: true, text: 'Markah (%)'}}},
                            plugins: {
                                tooltip: {callbacks: {label: function (context) {
                                            return 'Markah: ' + context.raw + '%';
                                        }}}
                            }
                        }
                    });
            <% } %>
            <% }%>
        </script>
    </body>
</html>