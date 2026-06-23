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

    List<Murid> senaraiMurid = (List<Murid>) request.getAttribute("senaraiMurid");
    if (senaraiMurid == null) {
        senaraiMurid = new ArrayList<>();
    }

    Map<String, String> kehadiranMap = (Map<String, String>) request.getAttribute("kehadiranMap");
    if (kehadiranMap == null) {
        kehadiranMap = new HashMap<>();
    }

    String tarikhPilih = (String) request.getAttribute("tarikh");
    if (tarikhPilih == null) {
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
        tarikhPilih = sdf.format(new java.util.Date());
    }

    String successMsg = (String) request.getAttribute("success");
    String errorMsg = (String) request.getAttribute("error");

    // Format tarikh untuk paparan
    java.text.SimpleDateFormat sdfDisplay = new java.text.SimpleDateFormat("dd MMMM yyyy");
    String tarikhDisplay = "";
    try {
        java.util.Date date = new java.text.SimpleDateFormat("yyyy-MM-dd").parse(tarikhPilih);
        tarikhDisplay = sdfDisplay.format(date);
    } catch (Exception e) {
        tarikhDisplay = tarikhPilih;
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
                    <a href="${pageContext.request.contextPath}/SenaraiMuridGuruServlet" class="nav-item">
                        <span class="material-icons">groups</span>
                        <span>Senarai Murid</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/RekodPrestasiMuridServlet" class="nav-item">
                        <span class="material-icons">bar_chart</span>
                        <span>Rekod Prestasi Murid</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/KehadiranHarianServlet" class="nav-item active">
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
                <!-- Stats Ringkasan -->
                <div class="kelulusan-stats-grid" style="grid-template-columns: repeat(3, 1fr);">
                    <div class="stat-card">
                        <div class="stat-icon"><span class="material-icons">school</span></div>
                        <div class="stat-info">
                            <div class="stat-value" id="totalMurid">0</div>
                            <div class="stat-label">Jumlah Murid</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon"><span class="material-icons">check_circle</span></div>
                        <div class="stat-info">
                            <div class="stat-value" id="totalHadir">0</div>
                            <div class="stat-label">Hadir</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon"><span class="material-icons">block</span></div>
                        <div class="stat-info">
                            <div class="stat-value" id="totalTidakHadir">0</div>
                            <div class="stat-label">Tidak Hadir</div>
                        </div>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            Kehadiran Harian
                        </h3>
                        <div class="search-container">
                            <div class="filter-group">
                                <label>Tarikh:</label>
                                <input type="date" id="tarikhInput" class="form-control" value="<%= tarikhPilih%>" style="width: auto;">
                                <button id="btnCari" class="btn-primary" style="padding: 8px 20px;">
                                    <span class="material-icons">search</span> Cari
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Borang Kehadiran -->
                    <form action="${pageContext.request.contextPath}/KehadiranHarianServlet" method="post" id="kehadiranForm">
                        <input type="hidden" name="action" value="save">
                        <input type="hidden" name="tarikh" id="hiddenTarikh" value="<%= tarikhPilih%>">

                        <div class="table-wrapper">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th width="12%">No. MyKid</th>
                                        <th width="25%">Nama Murid</th>
                                        <th width="10%">Jantina</th>
                                        <th width="18%">Status Kehadiran</th>
                                        <th width="35%">Catatan</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (senaraiMurid.isEmpty()) { %>
                                    <tr><td colspan="5" class="text-center">Tiada murid berdaftar</td><tr>
                                        <% } else {
                                            for (Murid murid : senaraiMurid) {
                                                String status = kehadiranMap.get(murid.getNokadpengenalan());
                                                String statusAsal = status;
                                                if (status == null) {
                                                    status = "hadir";
                                                    statusAsal = "hadir";
                                                }
                                                String catatan = kehadiranMap.get(murid.getNokadpengenalan() + "_catatan");
                                                String catatanAsal = catatan;
                                                if (catatan == null) {
                                                    catatan = "";
                                                }
                                                if (catatanAsal == null)
                                                    catatanAsal = "";
                                        %>
                                    <tr>
                                        <td data-label="No. MyKid"><%= murid.getNokadpengenalan()%></td>
                                        <td data-label="Nama Murid"><%= murid.getNamamurid()%></td>
                                        <td data-label="Jantina"><%= murid.getJantina() != null ? murid.getJantina() : "-"%></td>
                                        <td data-label="Status Kehadiran">
                                            <select name="status_<%= murid.getNokadpengenalan()%>" 
                                                    class="status-select" 
                                                    data-nokad="<%= murid.getNokadpengenalan()%>"
                                                    data-original="<%= statusAsal%>"
                                                    style="padding: 6px 10px; border: 1px solid #dce1e8; font-family: Georgia, serif; width: 100%;">
                                                <option value="hadir" <%= "hadir".equals(status) ? "selected" : ""%>>Hadir</option>
                                                <option value="tidak hadir" <%= "tidak hadir".equals(status) ? "selected" : ""%>>Tidak Hadir</option>
                                            </select>
                                        </td>
                                        <td data-label="Catatan">
                                            <input type="text" 
                                                   name="catatan_<%= murid.getNokadpengenalan()%>" 
                                                   class="form-control catatan-input" 
                                                   data-nokad="<%= murid.getNokadpengenalan()%>"
                                                   data-original="<%= catatanAsal%>"
                                                   value="<%= catatan%>" 
                                                   placeholder="Tiada catatan" 
                                                   style="width: 100%; padding: 6px 10px;">
                                        </td>
                                    </tr>
                                    <% }
                                        } %>
                                </tbody>
                            </table>
                        </div>

                        <div style="margin-top: 24px; text-align: right;">
                            <button type="submit" class="btn-primary" id="btnSimpan">
                                Simpan
                            </button>
                        </div>
                    </form>
                </div>
            </main>
        </div>

        <script>
            let toastTimeout = null;

            function showToast(message, type, duration) {
                type = type || 'info';
                duration = duration || 3000;
                const container = document.getElementById('toastContainer');
                if (!container)
                    return;

                if (toastTimeout) {
                    clearTimeout(toastTimeout);
                }

                const toast = document.createElement('div');
                toast.className = 'toast ' + type;
                toast.innerHTML = '<div class="toast-content">' + message + '</div><div class="toast-progress"></div>';
                container.appendChild(toast);

                toastTimeout = setTimeout(function () {
                    if (toast.parentElement) {
                        toast.style.animation = 'fadeOut 0.3s ease-out forwards';
                        setTimeout(function () {
                            toast.remove();
                        }, 300);
                    }
                    toastTimeout = null;
                }, duration);
            }

            <% if (successMsg != null && !successMsg.isEmpty()) {%>
            showToast('<%= successMsg.replace("'", "\\'")%>', 'success', 4000);
            <% } %>
            <% if (errorMsg != null && !errorMsg.isEmpty()) {%>
            showToast('<%= errorMsg.replace("'", "\\'")%>', 'error', 4000);
            <% }%>

            function updateStats() {
                const selects = document.querySelectorAll('.status-select');
                let total = selects.length;
                let hadir = 0, tidakHadir = 0;
                selects.forEach(select => {
                    if (select.value === 'hadir')
                        hadir++;
                    else if (select.value === 'tidak hadir')
                        tidakHadir++;
                });
                document.getElementById('totalMurid').innerText = total;
                document.getElementById('totalHadir').innerText = hadir;
                document.getElementById('totalTidakHadir').innerText = tidakHadir;
            }

            // Highlight perubahan pada select
            document.querySelectorAll('.status-select').forEach(select => {
                select.addEventListener('change', function () {
                    const original = this.getAttribute('data-original');
                    if (original !== this.value) {
                        this.style.border = '2px solid black';
                        this.style.backgroundColor = 'lightgray';
                    } else {
                        this.style.border = '1px solid black';
                        this.style.backgroundColor = 'white';
                    }
                    updateStats();
                });
            });

            // Highlight perubahan pada catatan
            document.querySelectorAll('.catatan-input').forEach(input => {
                input.addEventListener('input', function () {
                    const original = this.getAttribute('data-original');
                    if (original !== this.value) {
                        this.style.border = '2px solid black';
                        this.style.backgroundColor = 'lightgray';
                    } else {
                        this.style.border = '1px solid black';
                        this.style.backgroundColor = 'white';
                    }
                });
            });

            // Sebelum submit, kumpul ID yang berubah sahaja
            document.getElementById('kehadiranForm').addEventListener('submit', function (e) {
                const changedIds = [];

                document.querySelectorAll('.status-select').forEach(select => {
                    const original = select.getAttribute('data-original');
                    const current = select.value;
                    if (original !== current) {
                        const nokad = select.getAttribute('data-nokad');
                        if (!changedIds.includes(nokad))
                            changedIds.push(nokad);
                    }
                });

                document.querySelectorAll('.catatan-input').forEach(input => {
                    const original = input.getAttribute('data-original');
                    const current = input.value;
                    if (original !== current) {
                        const nokad = input.getAttribute('data-nokad');
                        if (!changedIds.includes(nokad))
                            changedIds.push(nokad);
                    }
                });

                if (changedIds.length === 0) {
                    e.preventDefault();
                    showToast('Tiada perubahan untuk disimpan', 'info', 2000);
                    return;
                }

                const hiddenField = document.createElement('input');
                hiddenField.type = 'hidden';
                hiddenField.name = 'changedIds';
                hiddenField.value = changedIds.join(',');
                this.appendChild(hiddenField);

                showToast('Menyimpan ' + changedIds.length + ' rekod...', 'info', 1500);
            });

            document.addEventListener('DOMContentLoaded', function () {
                updateStats();

                document.getElementById('btnCari').addEventListener('click', function () {
                    let tarikh = document.getElementById('tarikhInput').value;
                    if (tarikh) {
                        window.location.href = '${pageContext.request.contextPath}/KehadiranHarianServlet?tarikh=' + tarikh;
                    }
                });
            });
        </script>
    </body>
</html>