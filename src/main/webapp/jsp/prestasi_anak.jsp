<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>i-KEMAS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/prestasi_anak.css">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/image/logo-sistem.png">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    </head>
    <body>
        <div class="dashboard">
            <!-- SIDEBAR - SAMA DENGAN DASHBOARD -->
            <aside class="sidebar">
                <div class="sidebar-header">
                    <div class="logo">
                        <h2>i-KEMAS</h2>
                    </div>
                    <p>SISTEM PENGURUSAN KANAK-KANAK<br>TABIKA KEMAS</p>
                </div>
                <nav class="nav-menu">
                    <a href="${pageContext.request.contextPath}/jsp/dashboard_ibubapa.jsp" class="nav-item">
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
                    <a href="#" class="nav-item active">
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

            <!-- TOP BAR - SAMA DENGAN DASHBOARD -->
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

            <!-- MAIN CONTENT - GAYA SAMA DENGAN DASHBOARD -->
            <main class="main-content">

                <!-- Loading State -->
                <div id="loadingState" class="loading-state">
                    <div class="spinner"></div>
                    <p>Memuatkan data...</p>
                </div>

                <!-- Content -->
                <div id="contentState" style="display: none;">
                    <!-- Pilihan Anak -->
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">Pilih Anak</h3>
                        </div>
                        <div class="card-body">
                            <div class="child-selector">
                                <div class="selector-wrapper" id="childSelector">
                                    <!-- Dynamic child buttons will appear here -->
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Ringkasan Prestasi -->
                    <div class="stats-grid" id="ringkasanGrid" style="display: none;">
                        <div class="stat-card">
                            <div class="stat-icon">
                                <span class="material-icons">assessment</span>
                            </div>
                            <div class="stat-info">
                                <div class="stat-value" id="jumlahPrestasi">-</div>
                                <div class="stat-label">Jumlah Rekod Prestasi</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon">
                                <span class="material-icons">star</span>
                            </div>
                            <div class="stat-info">
                                <div class="stat-value" id="purataMarkah">-</div>
                                <div class="stat-label">Purata Markah (%)</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon">
                                <span class="material-icons">trending_up</span>
                            </div>
                            <div class="stat-info">
                                <div class="stat-value" id="gredTerbaik">-</div>
                                <div class="stat-label">Gred Terkini</div>
                            </div>
                        </div>
                    </div>

                    <!-- Carta Prestasi -->
                    <div class="card" id="chartCard" style="display: none;">
                        <div class="card-header">
                            <h3 class="card-title">Graf Prestasi</h3>
                        </div>
                        <div class="card-body">
                            <canvas id="prestasiChart" width="400" height="200"></canvas>
                        </div>
                    </div>

                    <!-- Jadual Prestasi -->
                    <div class="card" id="tableCard" style="display: none;">
                        <div class="card-header">
                            <h3 class="card-title">Senarai Prestasi</h3>
                        </div>
                        <div class="table-wrapper">
                            <table class="data-table" id="prestasiTable">
                                <thead>
                                    <tr>
                                        <th>Tarikh</th>
                                        <th>Jenis Prestasi</th>
                                        <th>Subjek</th>
                                        <th>Markah (%)</th>
                                        <th>Gred</th>
                                        <th>Guru</th>
                                        <th>Catatan</th>
                                    </tr>
                                </thead>
                                <tbody id="prestasiBody">
                                    <tr>
                                        <td colspan="7" class="text-center">Tiada rekod prestasi</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
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
            var prestasiChart = null;
            var currentNokad = null;

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

            function capitalizeEachWord(str) {
                if (!str)
                    return '-';
                return str.toLowerCase().split(' ').map(function (word) {
                    return word.charAt(0).toUpperCase() + word.slice(1);
                }).join(' ');
            }

            function getGredBadge(gred) {
                if (!gred)
                    return '-';
                var lowerGred = gred.toLowerCase();
                if (lowerGred.includes('cemerlang') || lowerGred === 'a') {
                    return '<span class="gred-badge gred-cemerlang">' + gred + '</span>';
                } else if (lowerGred.includes('sangat baik') || lowerGred === 'b') {
                    return '<span class="gred-badge gred-sangatbaik">' + gred + '</span>';
                } else if (lowerGred.includes('baik') || lowerGred === 'c') {
                    return '<span class="gred-badge gred-baik">' + gred + '</span>';
                } else {
                    return '<span class="gred-badge">' + gred + '</span>';
                }
            }

            function renderChildSelector(senaraiAnak, nokadTerpilih) {
                var container = document.getElementById('childSelector');
                var html = '';

                for (var i = 0; i < senaraiAnak.length; i++) {
                    var anak = senaraiAnak[i];
                    var isActive = (anak.nokad === nokadTerpilih);
                    html += '<button class="child-btn ' + (isActive ? 'active' : '') + '" onclick="loadPrestasi(\'' + anak.nokad + '\')">';
                    html += '<div class="child-info">';
                    html += '<strong>' + capitalizeEachWord(anak.namamurid) + '</strong>';
                    html += '<small>' + capitalizeEachWord(anak.tadika || '') + '</small>';
                    html += '</div>';
                    html += '</button>';
                }

                container.innerHTML = html;
            }

            function updateRingkasan(ringkasan, prestasiList) {
                if (ringkasan && Object.keys(ringkasan).length > 0) {
                    document.getElementById('jumlahPrestasi').innerText = ringkasan.jumlah || '0';
                    document.getElementById('purataMarkah').innerText = ringkasan.purata || '0';

                    if (prestasiList && prestasiList.length > 0) {
                        document.getElementById('gredTerbaik').innerHTML = getGredBadge(prestasiList[0].gred);
                    } else {
                        document.getElementById('gredTerbaik').innerHTML = '-';
                    }
                    document.getElementById('ringkasanGrid').style.display = 'grid';
                } else {
                    document.getElementById('ringkasanGrid').style.display = 'none';
                }
            }

            function updateChart(prestasiList) {
                if (prestasiChart) {
                    prestasiChart.destroy();
                }

                if (prestasiList && prestasiList.length > 0) {
                    var reversed = [];
                    var labels = [];
                    var marks = [];

                    for (var i = prestasiList.length - 1; i >= 0; i--) {
                        reversed.push(prestasiList[i]);
                    }

                    for (var i = 0; i < reversed.length; i++) {
                        labels.push(reversed[i].jenisprestasi || reversed[i].tarikh);
                        marks.push(parseFloat(reversed[i].markahperatus) || 0);
                    }

                    var ctx = document.getElementById('prestasiChart').getContext('2d');
                    prestasiChart = new Chart(ctx, {
                        type: 'line',
                        data: {
                            labels: labels,
                            datasets: [{
                                    label: 'Markah (%)',
                                    data: marks,
                                    borderColor: '#13017c',
                                    backgroundColor: 'rgba(19, 1, 124, 0.1)',
                                    borderWidth: 2,
                                    fill: true,
                                    tension: 0.3,
                                    pointBackgroundColor: '#13017c',
                                    pointBorderColor: '#fff',
                                    pointBorderWidth: 2,
                                    pointRadius: 5,
                                    pointHoverRadius: 7
                                }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: true,
                            scales: {
                                y: {
                                    beginAtZero: true,
                                    max: 100,
                                    title: {
                                        display: false
                                    },
                                    grid: {
                                        color: '#e9edf2'
                                    }
                                },
                                x: {
                                    title: {
                                        display: false
                                    },
                                    grid: {
                                        display: false
                                    }
                                }
                            },
                            plugins: {
                                legend: {
                                    display: false
                                },
                                tooltip: {
                                    enabled: true,
                                    callbacks: {
                                        label: function (context) {
                                            return 'Markah: ' + context.raw + '%';
                                        }
                                    }
                                }
                            }
                        }
                    });
                    document.getElementById('chartCard').style.display = 'block';
                } else {
                    document.getElementById('chartCard').style.display = 'none';
                }
            }

            function updateTable(prestasiList) {
                var tbody = document.getElementById('prestasiBody');

                if (prestasiList && prestasiList.length > 0) {
                    var rows = '';
                    for (var i = 0; i < prestasiList.length; i++) {
                        var item = prestasiList[i];
                        rows += '<tr>';
                        rows += '<td>' + formatDate(item.tarikh) + '<\/td>';
                        rows += '<td>' + (item.jenisprestasi || '-') + '<\/td>';
                        rows += '<td>' + (item.subjek || '-') + '<\/td>';
                        rows += '<td>' + (item.markahperatus ? item.markahperatus + '%' : '-') + '<\/td>';
                        rows += '<td>' + getGredBadge(item.gred) + '<\/td>';
                        rows += '<td>' + (item.namaguru || '-') + '<\/td>';
                        rows += '<td class="catatan-cell">' + (item.catatan || '-') + '<\/td>';
                        rows += '<\/tr>';
                    }
                    tbody.innerHTML = rows;
                    document.getElementById('tableCard').style.display = 'block';
                } else {
                    tbody.innerHTML = '<tr><td colspan="7" class="text-center">Tiada rekod prestasi<\/td><\/tr>';
                    document.getElementById('tableCard').style.display = 'block';
                }
            }

            function loadPrestasi(nokad) {
                if (currentNokad === nokad)
                    return;
                currentNokad = nokad;

                showToast('Memuatkan data prestasi.', 'warning');

                fetch('${pageContext.request.contextPath}/PrestasiAnakServlet?nokad=' + nokad)
                        .then(function (response) {
                            return response.json();
                        })
                        .then(function (data) {
                            renderChildSelector(data.senaraiAnak, nokad);
                            updateRingkasan(data.ringkasan, data.prestasi);
                            updateChart(data.prestasi);
                            updateTable(data.prestasi);

                            showToast('Data prestasi berjaya dimuatkan', 'success');
                        })
                        .catch(function (error) {
                            console.error('Error:', error);
                            showToast('Ralat memuatkan data prestasi', 'error');
                        });
            }

            function init() {
                document.getElementById('loadingState').style.display = 'flex';
                document.getElementById('contentState').style.display = 'none';

                fetch('${pageContext.request.contextPath}/PrestasiAnakServlet')
                        .then(function (response) {
                            return response.json();
                        })
                        .then(function (data) {
                            if (data.senaraiAnak && data.senaraiAnak.length > 0) {
                                renderChildSelector(data.senaraiAnak, data.nokadTerpilih);

                                if (data.prestasi) {
                                    updateRingkasan(data.ringkasan, data.prestasi);
                                    updateChart(data.prestasi);
                                    updateTable(data.prestasi);
                                }
                            } else {
                                document.getElementById('childSelector').innerHTML = '<div class="no-child">Tiada anak berdaftar</div>';
                            }

                            document.getElementById('loadingState').style.display = 'none';
                            document.getElementById('contentState').style.display = 'block';
                        })
                        .catch(function (error) {
                            console.error('Error:', error);
                            document.getElementById('loadingState').style.display = 'none';
                            showToast('Ralat memuatkan data. Sila cuba lagi.', 'error');
                            document.getElementById('contentState').style.display = 'block';
                        });
            }

            document.addEventListener('DOMContentLoaded', init);
        </script>
    </body>
</html>