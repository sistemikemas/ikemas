<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Pengguna, dao.TadikaDAO, model.Tadika" %>
<%
    Pengguna p = (Pengguna) session.getAttribute("pengguna");
    if (p == null || !p.getPeranan().equals("gurubesar")) {
        response.sendRedirect("log_masuk.jsp");
        return;
    }
    TadikaDAO tadikaDAO = new TadikaDAO();
    Tadika tadika = tadikaDAO.getTadikaByKod(p.getKodtadika());
    String namaTadika = (tadika != null) ? tadika.getNamatadika() : "Tidak dikenal pasti";
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
                    <a href="#" class="nav-item active">
                        <span class="material-icons">dashboard</span>
                        <span>Dashboard</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/KelulusanServlet" class="nav-item">
                        <span class="material-icons">approval</span>
                        <span>Kelulusan Permohonan</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/SenaraiGuruServlet" class="nav-item">
                        <span class="material-icons">group</span>
                        <span>Senarai Guru</span>
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
                        <span class="user-role">Guru Besar</span>
                    </div>
                </div>
            </div>

            <!-- ==================== MAIN CONTENT ==================== -->
            <main class="main-content">
                <!-- Stats Grid -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon">
                            <span class="material-icons">pending_actions</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="permohonanBaru">-</div>
                            <div class="stat-label">Permohonan Baru</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon">
                            <span class="material-icons">school</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="jumlahMurid">-</div>
                            <div class="stat-label">Jumlah Murid</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon">
                            <span class="material-icons">group</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="jumlahGuru">-</div>
                            <div class="stat-label">Jumlah Guru</div>
                        </div>
                    </div>
                </div>

                <!-- Aktiviti Terkini -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Kelulusan Permohonan Terkini</h3>
                        <button class="btn-mohon" onclick="window.location.href = '${pageContext.request.contextPath}/KelulusanServlet'">Lihat Semua</button>
                    </div>
                    <div class="table-wrapper">
                        <table class="data-table" id="aktivitiTable">
                            <thead>
                                <tr>
                                    <th>Tarikh Mohon</th>
                                    <th>No. MyKid</th>
                                    <th>Nama Murid</th>
                                    <th>Status</th>
                                    <th>Tindakan</th>
                                </tr>
                            </thead>
                            <tbody id="aktivitiBody">
                                <tr><td colspan="5" class="text-center">Memuat data...<\/td><\/tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- ==================== GRAF PRESTASI MURID ==================== -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Prestasi Murid</h3>
                        <div class="filter-group">
                            <input type="month" id="bulanTahunFilter" class="form-control">
                            <button class="btn-mohon" onclick="window.location.href = '${pageContext.request.contextPath}/jsp/laporan_prestasi_murid.jsp'">Lihat Semua</button>
                        </div>
                    </div>
                    <div class="card-body">
                        <div style="text-align: center; margin-bottom: 10px;">
                            <span style="font-size: 13px; font-weight: 600; color: var(--gray-600); font-family: Georgia, serif;">Purata Markah (%)</span>
                        </div>
                        <div class="chart-container">
                            <canvas id="prestasiChart"></canvas>
                        </div>
                        <div id="tiadaDataMsg" class="chart-empty" style="display: none;">
                            Tiada data prestasi untuk bulan ini
                        </div>
                    </div>
                </div>
            </main>
        </div>

        <!-- Toast Notification - guna class toast dari dashboard.css -->
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
                    toastIcon.innerHTML = '';
                } else if (type === 'warning') {
                    toast.classList.add('warning');
                    toastIcon.innerHTML = '';
                } else {
                    toastIcon.innerHTML = '';
                }

                document.getElementById('toastMessage').innerHTML = message;
                toast.style.display = 'flex';

                setTimeout(function () {
                    toast.style.display = 'none';
                }, 3000);
            }

            function formatDate(dateString) {
                if (!dateString)
                    return '-';
                var parts = dateString.split('-');
                if (parts.length === 3) {
                    return parts[2] + '-' + parts[1] + '-' + parts[0];
                }
                return dateString;
            }

            function getStatusBadge(status) {
                var statusClass = '';
                var statusText = '';

                if (status === 'lulus') {
                    statusClass = 'status-lulus';
                    statusText = 'Lulus';
                } else if (status === 'tolak') {
                    statusClass = 'status-tolak';
                    statusText = 'Ditolak';
                } else {
                    statusClass = 'status-dalamproses';
                    statusText = 'Dalam Proses';
                }

                return '<span class="status-badge ' + statusClass + '">' + statusText + '</span>';
            }

            function capitalizeEachWord(str) {
                if (!str)
                    return '-';
                return str.toLowerCase().split(' ').map(function (word) {
                    return word.charAt(0).toUpperCase() + word.slice(1);
                }).join(' ');
            }

            function loadDashboard() {
                fetch('${pageContext.request.contextPath}/DashboardGuruBesarServlet')
                        .then(function (response) {
                            return response.json();
                        })
                        .then(function (data) {
                            document.getElementById('permohonanBaru').innerText = data.permohonanBaru || '0';
                            document.getElementById('jumlahMurid').innerText = data.jumlahMurid || '0';
                            document.getElementById('jumlahGuru').innerText = data.jumlahGuru || '0';

                            var tbody = document.getElementById('aktivitiBody');
                            if (data.permohonanTerkini && data.permohonanTerkini.length > 0) {
                                var rows = '';
                                for (var i = 0; i < data.permohonanTerkini.length; i++) {
                                    var item = data.permohonanTerkini[i];
                                    rows += '<tr>';
                                    rows += '<td>' + formatDate(item.tarikh) + '<\/td>';
                                    rows += '<td>' + (item.nokad || '-') + '<\/td>';
                                    rows += '<td>' + capitalizeEachWord(item.namamurid || '-') + '<\/td>';
                                    rows += '<td>' + getStatusBadge(item.status) + '<\/td>';
                                    rows += '<td>';
                                    if (item.status === 'dalamproses') {
                                        rows += '<a href="${pageContext.request.contextPath}/KelulusanServlet" class="btn-link">Lulus/Tolak<\/a>';
                                    } else {
                                        rows += '-';
                                    }
                                    rows += '<\/td>';
                                    rows += '<\/tr>';
                                }
                                tbody.innerHTML = rows;
                            } else {
                                tbody.innerHTML = '<tr><td colspan="5" class="text-center">Tiada permohonan terkini<\/td><\/tr>';
                            }
                        })
                        .catch(function (error) {
                            console.error('Error:', error);
                            document.getElementById('aktivitiBody').innerHTML = '<td><td colspan="5" class="text-center">Ralat memuat data<\/td><\/tr>';
                            showToast('Ralat memuatkan data dashboard', 'error');
                        });
            }

            document.addEventListener('DOMContentLoaded', function () {
                loadDashboard();
            });

            // ==================== GRAF PRESTASI MURID (AUTO LOAD) ====================
            let prestasiChart = null;

            // Set value default ke bulan semasa (format: YYYY-MM)
            const today = new Date();
            const defaultMonth = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0');
            document.getElementById('bulanTahunFilter').value = defaultMonth;

            function loadPrestasiChart() {
                const bulanTahun = document.getElementById('bulanTahunFilter').value;
                if (!bulanTahun)
                    return;

                const [tahun, bulan] = bulanTahun.split('-');

                fetch('${pageContext.request.contextPath}/DashboardGuruBesarServlet?bulan=' + parseInt(bulan) + '&tahun=' + parseInt(tahun))
                        .then(response => response.json())
                        .then(data => {
                            const prestasiData = data.prestasiMurid || [];
                            const ctx = document.getElementById('prestasiChart').getContext('2d');

                            if (prestasiChart) {
                                prestasiChart.destroy();
                            }

                            if (prestasiData.length > 0) {
                                document.getElementById('prestasiChart').style.display = 'block';
                                document.getElementById('tiadaDataMsg').style.display = 'none';

                                const labels = prestasiData.map(item => item.nama);
                                const marks = prestasiData.map(item => item.purata);
                                const colors = ['#8b5cf6', '#f59e0b', '#10b981', '#ec4899', '#06b6d4', '#6366f1', '#14b8a6', '#ef4444', '#84cc16', '#a855f7'];

                                prestasiChart = new Chart(ctx, {
                                    type: 'bar',
                                    data: {
                                        labels: labels,
                                        datasets: [{
                                                label: 'Purata Markah (%)',
                                                data: marks,
                                                backgroundColor: colors.slice(0, prestasiData.length),
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
                                                position: ''
                                            },
                                            tooltip: {
                                                callbacks: {
                                                    label: function (context) {
                                                        return 'Purata: ' + context.raw.toFixed(2) + '%';
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
                                                }
                                            },
                                            x: {
                                                title: {
                                                    display: false,
                                                    text: 'Nama Murid'
                                                },
                                                ticks: {
                                                    callback: function (value, index) {
                                                        let label = labels[index];
                                                        return label.length > 15 ? label.substring(0, 12) + '...' : label;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                });
                            } else {
                                document.getElementById('prestasiChart').style.display = 'none';
                                document.getElementById('tiadaDataMsg').style.display = 'block';
                            }
                        })
                        .catch(error => {
                            console.error('Error loading chart:', error);
                            document.getElementById('tiadaDataMsg').style.display = 'block';
                            document.getElementById('tiadaDataMsg').innerHTML = 'Ralat memuatkan data prestasi';
                        });
            }

            // Load graf pertama kali
            loadPrestasiChart();

            // Auto load bila tukar bulan/tahun (tanpa butang)
            document.getElementById('bulanTahunFilter').addEventListener('change', function () {
                loadPrestasiChart();
            });
        </script>
    </body>
</html>