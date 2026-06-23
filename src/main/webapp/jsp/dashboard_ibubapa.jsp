<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Pengguna" %>
<%
    Pengguna p = (Pengguna) session.getAttribute("pengguna");
    if (p == null || !p.getPeranan().equals("ibubapa")) {
        response.sendRedirect("log_masuk.jsp");
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
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    </head>

    <body>
        <div class="dashboard">
            <!-- ==================== SIDEBAR ==================== -->
            <aside class="sidebar">
                <div class="sidebar-header">
                    <div class="logo">
                        <h2>i-KEMAS</h2>
                    </div>
                    <p>SISTEM PENGURUSAN KANAK-KANAK<br>TABIKA KEMAS</p>
                </div>

                <nav class="nav-menu">
                    <a href="#" class="nav-item active">
                        <span class="material-icons">dashboard</span>
                        <span>Dashboard</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/jsp/permohonan.jsp" class="nav-item">
                        <span class="material-icons">person_add</span>
                        <span>Permohonan</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/jsp/status_permohonan.jsp" class="nav-item">
                        <span class="material-icons">assignment</span>
                        <span>Status Permohonan</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/jsp/prestasi_anak.jsp" class="nav-item">
                        <span class="material-icons">bar_chart</span>
                        <span>Prestasi Anak</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/ProfilIbuBapaServlet" class="nav-item">
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
                    <span class="user-name-large"><%= p.getNama()%></span>
                </div>
                <div class="user-info">
                    <div class="user-details">
                        <span class="user-name"><%= p.getNama()%></span>
                        <span class="user-role">Ibu Bapa</span>
                    </div>
                </div>
            </div>

            <!-- ==================== MAIN CONTENT ==================== -->
            <main class="main-content">
                <!-- Stats Grid (3 kad) -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon">
                            <span class="material-icons">groups</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="jumlahAnak">-</div>
                            <div class="stat-label">Jumlah Anak Berdaftar</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon">
                            <span class="material-icons">pending_actions</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="permohonanAktif">-</div>
                            <div class="stat-label">Permohonan Dalam Proses</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon">
                            <span class="material-icons">check_circle</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="permohonanLulus">-</div>
                            <div class="stat-label">Permohonan Lulus</div>
                        </div>
                    </div>
                </div>

                <!-- ==================== CARD JADUAL PERMOHONAN ==================== -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            Permohonan Pendaftaran Terkini
                        </h3>
                        <button class="btn-mohon" onclick="window.location.href = '${pageContext.request.contextPath}/jsp/permohonan.jsp'">Mohon Baru</button>
                    </div>

                    <div class="table-wrapper">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>No. MyKid</th>
                                    <th>Nama Murid</th>
                                    <th>Tadika</th>
                                    <th>Tarikh Mohon</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody id="tableBody">
                                <tr><td colspan="5" class="text-center">Memuat data...<\/td><\/tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- ==================== RINGKASAN PRESTASI ANAK ==================== -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Ringkasan Prestasi Anak</h3>
                        <button class="btn-mohon" onclick="window.location.href = '${pageContext.request.contextPath}/jsp/prestasi_anak.jsp'">Lihat Semua</button>
                    </div>

                    <!-- Teks Purata Markah (tanpa kotak ungu) -->
                    <div style="text-align: center; margin-bottom: 10px;">
                        <span style="font-size: 13px; font-weight: 600; color: var(--gray-600); font-family: Georgia, serif;">Purata Markah (%)</span>
                    </div>

                    <!-- Canvas untuk Graf Bar -->
                    <canvas id="prestasiChart" width="400" height="200" style="max-height: 300px; width: 100%; margin-bottom: 20px;"></canvas>

                    <!-- Kad Prestasi Ringkas -->
                    <div class="prestasi-ringkasan-grid" id="prestasiRingkasanGrid">
                        <div class="loading-anak">Memuat data prestasi...</div>
                    </div>
                </div>
            </main>
        </div>

        <!-- ==================== JAVASCRIPT ==================== -->
        <script>
            let prestasiChart = null;

            // ==================== FUNGSI PEMFORMATAN TEKS ====================
            function formatText(text, type) {
                if (!text)
                    return "-";
                if (type === "status") {
                    if (text === "dalamproses")
                        return "Dalam Proses";
                    if (text === "lulus")
                        return "Lulus";
                    if (text === "tolak")
                        return "Ditolak";
                    return text;
                }
                if (type === "nokad")
                    return text;
                return text.toLowerCase().replace(/\b\w/g, function (c) {
                    return c.toUpperCase();
                });
            }

            // ==================== KEMASKINI KAD STATISTIK ====================
            function updateStats(data) {
                document.getElementById('jumlahAnak').innerText = data.jumlahAnak || '0';
                document.getElementById('permohonanAktif').innerText = data.permohonanDalamProses || '0';
                let lulusCount = 0;
                if (data.permohonan) {
                    for (let i = 0; i < data.permohonan.length; i++) {
                        if (data.permohonan[i].status === 'lulus')
                            lulusCount++;
                    }
                }
                document.getElementById('permohonanLulus').innerText = lulusCount;
            }

            // ==================== PELUKIS JADUAL PERMOHONAN ====================
            function renderTable(data) {
                let tbody = document.getElementById('tableBody');
                if (data.permohonan && data.permohonan.length > 0) {
                    let sortedData = [...data.permohonan];
                    sortedData.sort(function (a, b) {
                        return new Date(b.tarikh) - new Date(a.tarikh);
                    });
                    let latestData = sortedData.slice(0, 5);
                    let rows = '';
                    for (let i = 0; i < latestData.length; i++) {
                        let item = latestData[i];
                        let tarikhBaru = item.tarikh.split('-').reverse().join('-');
                        let statusClass = '';
                        let statusText = '';
                        if (item.status === 'draf') {
                            statusClass = 'status-draf';
                            statusText = 'Draf';
                        } else if (item.status === 'dalamproses') {
                            statusClass = 'status-dalamproses';
                            statusText = 'Dalam Proses';
                        } else if (item.status === 'lulus') {
                            statusClass = 'status-lulus';
                            statusText = 'Lulus';
                        } else if (item.status === 'tolak') {
                            statusClass = 'status-tolak';
                            statusText = 'Ditolak';
                        }
                        rows += '<tr>';
                        rows += '<td data-label="No. MyKid">' + formatText(item.nokad, 'nokad') + '<\/td>';
                        rows += '<td data-label="Nama Murid">' + formatText(item.namamurid) + '<\/td>';
                        rows += '<td data-label="Tadika">' + formatText(item.tadika) + '<\/td>';
                        rows += '<td data-label="Tarikh Mohon">' + tarikhBaru + '<\/td>';
                        rows += '<td data-label="Status"><span class="status-badge ' + statusClass + '">' + statusText + '<\/span><\/td>';
                        rows += '<\/tr>';
                    }
                    tbody.innerHTML = rows;
                } else {
                    tbody.innerHTML = '<tr><td colspan="5" class="text-center">Tiada permohonan.<\/td><\/tr>';
                }
            }

            // ==================== PELUKIS GRAF BAR PRESTASI ====================
            function renderPrestasiChart(prestasiAnak) {
                if (prestasiChart) {
                    prestasiChart.destroy();
                }

                if (prestasiAnak && prestasiAnak.length > 0) {
                    let labels = [];
                    let marks = [];
                    let colors = ['#8b5cf6', '#f59e0b', '#10b981', '#ec4899', '#06b6d4', '#6366f1', '#14b8a6'];

                    for (let i = 0; i < prestasiAnak.length; i++) {
                        labels.push(prestasiAnak[i].nama);
                        marks.push(prestasiAnak[i].purata);
                    }

                    const ctx = document.getElementById('prestasiChart').getContext('2d');
                    prestasiChart = new Chart(ctx, {
                        type: 'bar',
                        data: {
                            labels: labels,
                            datasets: [{
                                    label: '',
                                    data: marks,
                                    backgroundColor: colors.slice(0, prestasiAnak.length),
                                    borderColor: '#13017c',
                                    borderWidth: 1,
                                    borderRadius: 0,
                                    barPercentage: 0.7
                                }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: true,
                            plugins: {
                                legend: {
                                    display: false   // Sembunyikan legend (kotak ungu)
                                },
                                tooltip: {
                                    callbacks: {
                                        label: function (context) {
                                            return 'Purata: ' + context.raw + '%';
                                        }
                                    }
                                }
                            },
                            scales: {
                                y: {
                                    beginAtZero: true,
                                    max: 100,
                                    title: {
                                        display: false,
                                        text: 'Markah (%)'
                                    },
                                    grid: {
                                        color: '#e5e7eb'
                                    }
                                },
                                x: {
                                    title: {
                                        display: false,
                                        text: 'Nama Anak'
                                    },
                                    ticks: {
                                        callback: function (value, index) {
                                            let label = labels[index];
                                            return label.length > 15 ? label.substring(0, 12) + '...' : label;
                                        }
                                    }
                                }
                            },
                            onClick: function (event, activeElements) {
                                if (activeElements.length > 0) {
                                    window.location.href = '${pageContext.request.contextPath}/jsp/prestasi_anak.jsp';
                                }
                            }
                        }
                    });
                }
            }

            // ==================== PELUKIS KAD PRESTASI RINGKAS ====================
            function renderPrestasiRingkasan(prestasiAnak) {
                let container = document.getElementById('prestasiRingkasanGrid');
                if (prestasiAnak && prestasiAnak.length > 0) {
                    let html = '';
                    let maxDisplay = Math.min(prestasiAnak.length, 3);
                    for (let i = 0; i < maxDisplay; i++) {
                        let anak = prestasiAnak[i];
                        let purata = anak.purata;
                        let gred = anak.gred || '-';

                        html += '<div class="prestasi-card" onclick="window.location.href=\'${pageContext.request.contextPath}/jsp/prestasi_anak.jsp\'">';
                        html += '<div class="prestasi-card-info">';
                        html += '<div class="prestasi-card-name">' + formatText(anak.nama) + '</div>';
                        html += '<div class="prestasi-card-stats">';
                        html += '<div class="prestasi-card-markah">📊 ' + purata + '%</div>';
                        html += '<div class="prestasi-card-gred">⭐ Gred: ' + gred + '</div>';
                        html += '</div>';
                        html += '</div>';
                        html += '</div>';
                    }
                    container.innerHTML = html;
                } else {
                    container.innerHTML = '<div class="loading-anak">Tiada data prestasi. Sila buat permohonan terlebih dahulu.</div>';
                }
            }

            // ==================== MUAT DATA DARI SERVER ====================
            fetch('${pageContext.request.contextPath}/DashboardIbubapaServlet')
                    .then(response => response.json())
                    .then(data => {
                        updateStats(data);
                        renderTable(data);
                        renderPrestasiChart(data.prestasiAnak);
                        renderPrestasiRingkasan(data.prestasiAnak);
                    })
                    .catch(error => {
                        console.error("Error:", error);
                        document.getElementById('tableBody').innerHTML = '<td><td colspan="5" class="text-center">Ralat memuat data.<\/td><\/tr>';
                        document.getElementById('prestasiRingkasanGrid').innerHTML = '<div class="loading-anak">Ralat memuat data prestasi.</div>';
                    });
        </script>
    </body>
</html>