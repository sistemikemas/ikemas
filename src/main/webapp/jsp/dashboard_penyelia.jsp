<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Pengguna" %>
<%@ page import="java.util.*, model.Tadika" %>
<%@ page import="dao.TadikaDAO, dao.GuruDAO" %>

<%
    Pengguna p = (Pengguna) session.getAttribute("pengguna");
    if (p == null || !p.getPeranan().equals("penyelia")) {
        response.sendRedirect("log_masuk.jsp");
        return;
    }

    // Create DAO instances
    TadikaDAO tadikaDAO = new TadikaDAO();
    GuruDAO guruDAO = new GuruDAO();

    // Get data from request attributes
    Integer jumlahTadika = (Integer) request.getAttribute("jumlahTadika");
    Integer jumlahMurid = (Integer) request.getAttribute("jumlahMurid");
    Integer jumlahGuru = (Integer) request.getAttribute("jumlahGuru");
    List<Tadika> senaraiTadika = (List<Tadika>) request.getAttribute("senaraiTadika");

    jumlahTadika = (jumlahTadika != null) ? jumlahTadika : 0;
    jumlahMurid = (jumlahMurid != null) ? jumlahMurid : 0;
    jumlahGuru = (jumlahGuru != null) ? jumlahGuru : 0;
    if (senaraiTadika == null) {
        senaraiTadika = new ArrayList<>();
    }

    // Format DUN untuk paparan
    String dunSeliaan = p.getDunseliaan();
    String dunDisplay = dunSeliaan;
    if (dunSeliaan != null && dunSeliaan.contains(" ")) {
        int firstSpace = dunSeliaan.indexOf(" ");
        dunDisplay = dunSeliaan.substring(0, firstSpace) + ", " + dunSeliaan.substring(firstSpace + 1);
    }
%>

<%!
    // ==================== FUNGSI UNTUK GRED ====================
    String getGred(double skor) {
        if (skor >= 80) {
            return "Cemerlang";
        }
        if (skor >= 60) {
            return "Baik";
        }
        if (skor >= 50) {
            return "Memuaskan";
        }
        return "Perlu Penambahbaikan";
    }

    String getGredClass(double skor) {
        if (skor >= 80) {
            return "status-lulus";
        }
        if (skor >= 60) {
            return "status-dalamproses";
        }
        if (skor >= 50) {
            return "status-buka";
        }
        return "status-tolak";
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
        <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
        <meta http-equiv="Pragma" content="no-cache">
        <meta http-equiv="Expires" content="0">
    </head>
    <body>
        <div id="toastContainer" class="toast-container"></div>

        <div class="dashboard">
            <!-- ==================== SIDEBAR ==================== -->
            <aside class="sidebar">
                <div class="sidebar-header">
                    <div class="logo"><h2>i-KEMAS</h2></div>
                    <p>SISTEM PENGURUSAN KANAK-KANAK<br>TABIKA KEMAS</p>
                </div>
                <nav class="nav-menu">
                    <a href="${pageContext.request.contextPath}/DashboardPenyeliaServlet" class="nav-item active">
                        <span class="material-icons">dashboard</span>
                        <span>Dashboard</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/SenaraiTadikaPenyeliaServlet" class="nav-item">
                        <span class="material-icons">school</span>
                        <span>Senarai Tadika</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/TambahGuruAtauGuruBesarServlet" class="nav-item">
                        <span class="material-icons">person_add</span>
                        <span>Tambah Guru/Guru Besar</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/PemantauanTadikaPenyeliaServlet" class="nav-item">
                        <span class="material-icons">assignment</span>
                        <span>Pemantauan Tadika</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/LaporanPrestasiPenyeliaServlet" class="nav-item">
                        <span class="material-icons">bar_chart</span>
                        <span>Laporan Prestasi</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/ProfilPenyeliaServlet" class="nav-item">
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
                    <span class="greeting-text" style="color: var(--primary);">DUN: <%= dunDisplay%></span>
                </div>
                <div class="user-info">
                    <div class="user-details">
                        <span class="user-name"><%= p.getNama()%></span>
                        <span class="user-role">Penyelia</span>
                    </div>
                </div>
            </div>

            <!-- ==================== MAIN CONTENT ==================== -->
            <main class="main-content">
                <!-- Stats Grid - 3 KAD -->
                <div class="stats-grid" style="grid-template-columns: repeat(3, 1fr);">
                    <div class="stat-card">
                        <div class="stat-icon"><span class="material-icons">school</span></div>
                        <div class="stat-info">
                            <div class="stat-value"><%= jumlahTadika%></div>
                            <div class="stat-label">Jumlah Tadika</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon"><span class="material-icons">groups</span></div>
                        <div class="stat-info">
                            <div class="stat-value"><%= jumlahMurid%></div>
                            <div class="stat-label">Jumlah Murid</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon"><span class="material-icons">badge</span></div>
                        <div class="stat-info">
                            <div class="stat-value"><%= jumlahGuru%></div>
                            <div class="stat-label">Jumlah Guru</div>
                        </div>
                    </div>
                </div>

                <!-- Kawalan Sesi Permohonan -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Kawalan Sesi Permohonan</h3>
                        <a href="#" class="btn-primary">Sejarah Sesi</a>
                    </div>
                    <div class="card-body">
                        <div class="sesi-container">
                            <div class="sesi-info-wrapper">
                                <div class="sesi-info-item">
                                    <span class="sesi-label">DUN:</span>
                                    <span class="sesi-value"><%= dunSeliaan != null ? dunSeliaan : "Tiada DUN"%></span>
                                </div>
                                <div class="sesi-info-item">
                                    <div class="year-picker">
                                        <span class="year-picker-label">Tahun Sesi:</span>
                                        <div class="year-input-group">
                                            <button type="button" class="year-btn" id="btnTahunKurang">−</button>
                                            <input type="number" id="tahunSesiInput" class="year-input" 
                                                   min="2027" max="2030" step="1" value="2027">
                                            <button type="button" class="year-btn" id="btnTahunTambah">+</button>
                                        </div>
                                    </div>
                                </div>
                                <div class="sesi-info-item">
                                    <span class="sesi-label">Status:</span>
                                    <span class="status-badge" id="statusSesi">-</span>
                                </div>
                                <div class="sesi-info-item" id="tarikhBukaRow" style="display:none;">
                                    <span class="sesi-label">Tarikh Buka:</span>
                                    <span class="sesi-value" id="tarikhBuka">-</span>
                                </div>
                                <div class="sesi-info-item" id="tarikhTutupRow" style="display:none;">
                                    <span class="sesi-label">Tarikh Tutup:</span>
                                    <span class="sesi-value" id="tarikhTutup">-</span>
                                </div>
                            </div>
                            <div class="sesi-action-buttons">
                                <button class="btn-success" id="btnBukaSesi">Buka Sesi</button>
                                <button class="btn-danger" id="btnTutupSesi">Tutup Sesi</button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Senarai Tadika (Ringkasan 5 Teratas) -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            Senarai Tadika
                        </h3>
                        <button class="btn-mohon" onclick="window.location.href = '${pageContext.request.contextPath}/SenaraiTadikaPenyeliaServlet'">
                            Lihat Semua
                        </button>
                    </div>
                    <div class="table-wrapper">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Kod Tadika</th>
                                    <th>Nama Tadika</th>
                                    <th>Bilangan Murid</th>
                                    <th>Bilangan Guru</th>
                                    <th>Gred</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (senaraiTadika.isEmpty()) { %>
                                <tr><td colspan="5" class="text-center">Tiada tadika dalam DUN ini</td></tr>
                                <% } else {
                                    int count = 0;
                                    for (Tadika tadika : senaraiTadika) {
                                        if (count >= 5) {
                                            break;
                                        }
                                        count++;

                                        // Dapatkan jumlah murid dan guru untuk setiap tadika
                                        int jumlahMuridTadika = 0;
                                        int jumlahGuruTadika = 0;

                                        try {
                                            jumlahMuridTadika = tadikaDAO.getJumlahMuridByKodTadika(tadika.getKodtadika());
                                            jumlahGuruTadika = guruDAO.getJumlahGuruByKodTadika(tadika.getKodtadika());
                                        } catch (Exception e) {
                                            // Handle error
                                        }

                                        // Tentukan gred berdasarkan bilangan murid
                                        String gred = "Tiada Data";
                                        String gredClass = "status-tolak";

                                        if (jumlahMuridTadika >= 40) {
                                            gred = "A (Cemerlang)";
                                            gredClass = "status-lulus";
                                        } else if (jumlahMuridTadika >= 25) {
                                            gred = "B (Baik)";
                                            gredClass = "status-dalamproses";
                                        } else if (jumlahMuridTadika >= 10) {
                                            gred = "C (Memuaskan)";
                                            gredClass = "status-buka";
                                        } else if (jumlahMuridTadika > 0) {
                                            gred = "D (Perlu Penambahbaikan)";
                                            gredClass = "status-tolak";
                                        }
                                %>
                                <tr>
                                    <td><%= tadika.getKodtadika()%></td>
                                    <td><%= tadika.getNamatadika()%></td>
                                    <td><%= jumlahMuridTadika%></td>
                                    <td><%= jumlahGuruTadika%></td>
                                    <td><span class="status-badge <%= gredClass%>"><%= gred%></span></td>
                                </tr>
                                <% }
                                    }%>
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

            // ==================== SESI PERMOHONAN ====================
            const inputTahun = document.getElementById('tahunSesiInput');

            function getTahun() {
                return parseInt(inputTahun.value);
            }

            function loadStatusSesi() {
                const tahun = getTahun();
                const dun = "<%= p.getDunseliaan() != null ? p.getDunseliaan() : ""%>";
                const url = '${pageContext.request.contextPath}/SesiPermohonanServlet?tahun=' + tahun + '&dun=' + encodeURIComponent(dun) + '&_=' + new Date().getTime();

                fetch(url, {method: 'GET', cache: 'no-store'})
                        .then(response => response.text())
                        .then(text => {
                            const data = JSON.parse(text.trim());
                            const statusSpan = document.getElementById('statusSesi');

                            if (data.status === 'buka') {
                                statusSpan.innerText = 'DIBUKA';
                                statusSpan.className = 'status-badge status-buka';
                                document.getElementById('tarikhBukaRow').style.display = 'flex';
                                document.getElementById('tarikhTutupRow').style.display = 'none';
                                if (data.tarikhbuka) {
                                    document.getElementById('tarikhBuka').innerText = new Date(data.tarikhbuka).toLocaleString('ms-MY');
                                }
                            } else {
                                statusSpan.innerText = 'DITUTUP';
                                statusSpan.className = 'status-badge status-tutup';
                                document.getElementById('tarikhBukaRow').style.display = 'none';
                                document.getElementById('tarikhTutupRow').style.display = 'flex';
                                document.getElementById('tarikhTutup').innerText = data.tarikhtutup ? new Date(data.tarikhtutup).toLocaleString('ms-MY') : '-';
                            }
                        })
                        .catch(error => {
                            document.getElementById('statusSesi').innerText = 'DITUTUP';
                            document.getElementById('statusSesi').className = 'status-badge status-tutup';
                        });
            }

            // Event Listeners
            document.getElementById('btnTahunTambah')?.addEventListener('click', function () {
                let tahun = getTahun();
                if (tahun < 2030) {
                    inputTahun.value = tahun + 1;
                    loadStatusSesi();
                }
            });
            document.getElementById('btnTahunKurang')?.addEventListener('click', function () {
                let tahun = getTahun();
                if (tahun > 2027) {
                    inputTahun.value = tahun - 1;
                    loadStatusSesi();
                }
            });
            inputTahun?.addEventListener('change', function () {
                loadStatusSesi();
            });

            document.getElementById('btnBukaSesi')?.addEventListener('click', function () {
                const tahun = getTahun();
                if (confirm('Buka sesi permohonan untuk DUN ini bagi tahun ' + tahun + '?')) {
                    fetch('${pageContext.request.contextPath}/SesiPermohonanServlet', {
                        method: 'POST',
                        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                        body: 'action=buka&tahun=' + tahun
                    }).then(response => {
                        if (response.ok) {
                            loadStatusSesi();
                            showToast('Sesi tahun ' + tahun + ' telah DIBUKA', 'success', 4000);
                        } else {
                            showToast('Gagal membuka sesi', 'error', 4000);
                        }
                    }).catch(error => {
                        showToast('Gagal membuka sesi', 'error', 4000);
                    });
                }
            });

            document.getElementById('btnTutupSesi')?.addEventListener('click', function () {
                const tahun = getTahun();
                if (confirm('Tutup sesi permohonan untuk DUN ini bagi tahun ' + tahun + '?')) {
                    fetch('${pageContext.request.contextPath}/SesiPermohonanServlet', {
                        method: 'POST',
                        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                        body: 'action=tutup&tahun=' + tahun
                    }).then(response => {
                        if (response.ok) {
                            loadStatusSesi();
                            showToast('Sesi tahun ' + tahun + ' telah DITUTUP', 'success', 4000);
                        } else {
                            showToast('Gagal menutup sesi', 'error', 4000);
                        }
                    }).catch(error => {
                        showToast('Gagal menutup sesi', 'error', 4000);
                    });
                }
            });

            document.addEventListener('DOMContentLoaded', function () {
                loadStatusSesi();
            });
        </script>
    </body>
</html>