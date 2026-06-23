<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Pengguna, dao.TadikaDAO, model.Tadika" %>
<%
    Pengguna p = (Pengguna) session.getAttribute("pengguna");
    if (p == null || !p.getPeranan().equals("guru")) {
        response.sendRedirect("log_masuk.jsp");
        return;
    }
    TadikaDAO tadikaDAO = new TadikaDAO();
    Tadika tadika = tadikaDAO.getTadikaByKod(p.getKodtadika());
    String namaTadika = (tadika != null) ? tadika.getNamatadika() : "Tidak dikenal pasti";

    // Mesej dari server (jika ada)
    String successMsg = (String) request.getAttribute("success");
    String errorMsg = (String) request.getAttribute("error");
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
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    </head>
    <body>
        <!-- Bekas untuk toast notification -->
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
                    <a href="#" class="nav-item active">
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

            <!-- ==================== KANDUNGAN UTAMA ==================== -->
            <main class="main-content">
                <!-- 2 KAD STATISTIK: Jumlah Murid & Kehadiran -->
                <div class="stats-grid" style="grid-template-columns: repeat(2, 1fr);">
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
                            <span class="material-icons">today</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="kehadiranHariIni">-</div>
                            <div class="stat-label">Kehadiran Hari Ini</div>
                        </div>
                    </div>
                </div>

                <!-- GRAF KEHADIRAN BULANAN (GARIS) & PRESTASI MURID (BAR) - 2 KOLOM -->
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
                    <!-- GRAF PRESTASI MURID (BULAN INI) -->
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">Prestasi Murid</h3>
                            <div class="filter-group">
                                <input type="month" id="bulanPrestasi" class="form-control">
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="chart-container">
                                <canvas id="prestasiChart"></canvas>
                            </div>
                            <div id="tiadaDataPrestasi" class="chart-empty" style="display: none;">
                                Tiada data prestasi untuk bulan ini.
                            </div>
                        </div>
                    </div>
                    
                    <!-- GRAF KEHADIRAN BULANAN -->
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">Kehadiran </h3>
                            <div class="filter-group">
                                <input type="month" id="bulanKehadiran" class="form-control">
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="chart-container">
                                <canvas id="kehadiranChart"></canvas>
                            </div>
                            <div id="tiadaDataKehadiran" class="chart-empty" style="display: none;">
                                Tiada data kehadiran untuk bulan ini.
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- SENARAI MURID (RINGKASAN) -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Senarai Murid</h3>
                        <button class="btn-mohon" onclick="window.location.href = '${pageContext.request.contextPath}/SenaraiMuridServlet'">Lihat Semua</button>
                    </div>
                    <div class="table-wrapper">
                        <table class="data-table" id="muridTable">
                            <thead>
                                <tr>
                                    <th>No. MyKid</th>
                                    <th>Nama Murid</th>
                                    <th>Jantina</th>
                                    <th>Tarikh Lahir</th>
                                    <th>Umur</th>
                                </tr>
                            </thead>
                            <tbody id="muridBody">
                                <tr><td colspan="5" class="text-center">Memuat data...</td></tr>
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
                        '<span class="material-icons toast-close">close</span>' +
                        '<div class="toast-progress"></div>';
                container.appendChild(toast);

                const closeToast = function () {
                    if (toast.parentElement) {
                        toast.style.animation = 'fadeOut 0.3s ease-out forwards';
                        setTimeout(function () {
                            toast.remove();
                        }, 300);
                    }
                };
                toast.querySelector('.toast-close').addEventListener('click', closeToast);
                setTimeout(closeToast, duration);
            }

            // Papar mesej dari server
            <% if (successMsg != null && !successMsg.isEmpty()) {%>
            showToast('<%= successMsg%>', 'success', 4000);
            <% } %>
            <% if (errorMsg != null && !errorMsg.isEmpty()) {%>
            showToast('<%= errorMsg%>', 'error', 4000);
            <% }%>

            // ==================== FUNGSI PEMBANTU ====================
            function formatDate(dateString) {
                if (!dateString)
                    return '-';
                var parts = dateString.split('-');
                return parts.length === 3 ? parts[2] + '-' + parts[1] + '-' + parts[0] : dateString;
            }

            function capitalizeEachWord(str) {
                if (!str)
                    return '-';
                return str.toLowerCase().split(' ').map(function (word) {
                    return word.charAt(0).toUpperCase() + word.slice(1);
                }).join(' ');
            }

            function hitungUmur(tarikhLahir) {
                if (!tarikhLahir)
                    return '-';
                var today = new Date();
                var birthDate = new Date(tarikhLahir);
                var age = today.getFullYear() - birthDate.getFullYear();
                var m = today.getMonth() - birthDate.getMonth();
                if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate()))
                    age--;
                return age;
            }

            // ==================== MUAT DATA DASHBOARD ====================
            function loadDashboard() {
                fetch('${pageContext.request.contextPath}/DashboardGuruServlet')
                        .then(function (response) {
                            return response.json();
                        })
                        .then(function (data) {
                            // Kemaskini stat kad
                            document.getElementById('jumlahMurid').innerText = data.jumlahMurid || '0';
                            document.getElementById('kehadiranHariIni').innerText = (data.kehadiranHariIni || '0') + ' / ' + (data.jumlahMurid || '0');

                            // Kemaskini jadual senarai murid (hanya 5 teratas)
                            var tbody = document.getElementById('muridBody');
                            if (data.senaraiMurid && data.senaraiMurid.length > 0) {
                                var rows = '';
                                var limit = Math.min(5, data.senaraiMurid.length);
                                for (var i = 0; i < limit; i++) {
                                    var murid = data.senaraiMurid[i];
                                    rows += '<tr>';
                                    rows += '<td>' + (murid.nokadpengenalan || '-') + '</td>';
                                    rows += '<td>' + capitalizeEachWord(murid.namamurid || '-') + '</td>';
                                    rows += '<td>' + (murid.jantina || '-') + '</td>';
                                    rows += '<td>' + formatDate(murid.tarikhlahir) + '</td>';
                                    rows += '<td>' + hitungUmur(murid.tarikhlahir) + ' tahun</td>';
                                    rows += '</tr>';
                                }
                                tbody.innerHTML = rows;
                            } else {
                                tbody.innerHTML = '<tr><td colspan="5" class="text-center">Tiada murid didaftarkan</td></tr>';
                            }
                        })
                        .catch(function (error) {
                            console.error('Error:', error);
                            showToast('Ralat memuatkan data dashboard', 'error', 4000);
                        });
            }

            // ==================== GRAF KEHADIRAN BULANAN (GARIS) ====================
            let kehadiranChart = null;

            function setDefaultBulanKehadiran() {
                const today = new Date();
                const defaultMonth = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0');
                const input = document.getElementById('bulanKehadiran');
                if (input && !input.value)
                    input.value = defaultMonth;
            }

            function loadKehadiranChart() {
                const bulanTahun = document.getElementById('bulanKehadiran').value;
                if (!bulanTahun)
                    return;

                const [tahun, bulan] = bulanTahun.split('-');
                fetch('${pageContext.request.contextPath}/DashboardGuruServlet?action=kehadiran&bulan=' + parseInt(bulan) + '&tahun=' + parseInt(tahun))
                        .then(response => response.json())
                        .then(data => {
                            const kehadiranData = data.kehadiranHarian || [];
                            const ctx = document.getElementById('kehadiranChart').getContext('2d');

                            if (kehadiranChart)
                                kehadiranChart.destroy();

                            if (kehadiranData.length > 0) {
                                document.getElementById('kehadiranChart').style.display = 'block';
                                document.getElementById('tiadaDataKehadiran').style.display = 'none';

                                const labels = kehadiranData.map(item => item.tarikh);
                                const hadirCount = kehadiranData.map(item => item.hadir);
                                const totalMurid = kehadiranData[0]?.totalMurid || 0;

                                kehadiranChart = new Chart(ctx, {
                                    type: 'line',
                                    data: {
                                        labels: labels,
                                        datasets: [{
                                                label: 'Bilangan Murid Hadir',
                                                data: hadirCount,
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
                                        plugins: {
                                            tooltip: {
                                                callbacks: {
                                                    label: function (context) {
                                                        return 'Hadir: ' + context.raw + ' / ' + totalMurid + ' murid';
                                                    }
                                                }
                                            }
                                        },
                                        scales: {
                                            y: {
                                                beginAtZero: true,
                                                title: {display: false},
                                                max: totalMurid > 0 ? totalMurid + 2 : 10
                                            }
                                        }
                                    }
                                });
                            } else {
                                document.getElementById('kehadiranChart').style.display = 'none';
                                document.getElementById('tiadaDataKehadiran').style.display = 'block';
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            document.getElementById('tiadaDataKehadiran').style.display = 'block';
                            document.getElementById('tiadaDataKehadiran').innerHTML = 'Ralat memuatkan data kehadiran';
                        });
            }

            // ==================== GRAF PRESTASI MURID (BAR) ====================
            let prestasiChart = null;

            function setDefaultBulanPrestasi() {
                const today = new Date();
                const defaultMonth = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0');
                const input = document.getElementById('bulanPrestasi');
                if (input && !input.value)
                    input.value = defaultMonth;
            }

            function loadPrestasiChart() {
                const bulanTahun = document.getElementById('bulanPrestasi').value;
                if (!bulanTahun)
                    return;

                const [tahun, bulan] = bulanTahun.split('-');
                fetch('${pageContext.request.contextPath}/DashboardGuruServlet?action=prestasi&bulan=' + parseInt(bulan) + '&tahun=' + parseInt(tahun))
                        .then(response => response.json())
                        .then(data => {
                            const prestasiData = data.prestasiMurid || [];
                            const ctx = document.getElementById('prestasiChart').getContext('2d');

                            if (prestasiChart)
                                prestasiChart.destroy();

                            if (prestasiData.length > 0) {
                                document.getElementById('prestasiChart').style.display = 'block';
                                document.getElementById('tiadaDataPrestasi').style.display = 'none';

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
                                            legend: {display: false},
                                            tooltip: {
                                                callbacks: {
                                                    label: function (context) {
                                                        return 'Purata: ' + context.raw.toFixed(2) + '%';
                                                    }
                                                }
                                            }
                                        },
                                        scales: {
                                            y: {beginAtZero: true, max: 100}
                                        }
                                    }
                                });
                            } else {
                                document.getElementById('prestasiChart').style.display = 'none';
                                document.getElementById('tiadaDataPrestasi').style.display = 'block';
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            document.getElementById('tiadaDataPrestasi').style.display = 'block';
                            document.getElementById('tiadaDataPrestasi').innerHTML = 'Ralat memuatkan data prestasi';
                        });
            }

            // ==================== INISIALISASI ====================
            document.addEventListener('DOMContentLoaded', function () {
                // Muat data dashboard (stat & senarai murid)
                loadDashboard();

                // Inisialisasi graf kehadiran
                setDefaultBulanKehadiran();
                loadKehadiranChart();
                document.getElementById('bulanKehadiran').addEventListener('change', loadKehadiranChart);

                // Inisialisasi graf prestasi
                setDefaultBulanPrestasi();
                loadPrestasiChart();
                document.getElementById('bulanPrestasi').addEventListener('change', loadPrestasiChart);
            });
        </script>
    </body>
</html>