<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Pengguna, model.Permohonan, dao.MuridDAO, java.util.List, dao.TadikaDAO, model.Tadika, java.text.SimpleDateFormat" %>
<%
    Pengguna p = (Pengguna) session.getAttribute("pengguna");
    if (p == null || !p.getPeranan().equals("gurubesar")) {
        response.sendRedirect("log_masuk.jsp");
        return;
    }
    List<Permohonan> list = (List<Permohonan>) request.getAttribute("senaraiPermohonan");
    MuridDAO muridDAO = new MuridDAO();

    TadikaDAO tadikaDAO = new TadikaDAO();
    Tadika tadika = tadikaDAO.getTadikaByKod(p.getKodtadika());
    String namaTadika = (tadika != null) ? tadika.getNamatadika() : "Tidak dikenal pasti";

    SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy");
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
                    <a href="#" class="nav-item active">
                        <span class="material-icons">approval</span><span>Kelulusan Permohonan</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/SenaraiGuruServlet" class="nav-item">
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
                <div class="kelulusan-stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon">
                            <span class="material-icons">assignment</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="statJumlah"><%= request.getAttribute("countJumlah") != null ? request.getAttribute("countJumlah") : 0%></div>
                            <div class="stat-label">Jumlah Permohonan</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon">
                            <span class="material-icons">pending_actions</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="statDalamProses"><%= request.getAttribute("countDalamProses") != null ? request.getAttribute("countDalamProses") : 0%></div>
                            <div class="stat-label">Dalam Proses</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon">
                            <span class="material-icons">check_circle</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="statLulus"><%= request.getAttribute("countLulus") != null ? request.getAttribute("countLulus") : 0%></div>
                            <div class="stat-label">Diluluskan</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon">
                            <span class="material-icons">cancel</span>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value" id="statTolak"><%= request.getAttribute("countTolak") != null ? request.getAttribute("countTolak") : 0%></div>
                            <div class="stat-label">Ditolak</div>
                        </div>
                    </div>
                </div>

                <!-- Permohonan Table -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Senarai Permohonan Pendaftaran</h3>
                        <div class="search-container">
                            <div class="search-box">
                                <span class="material-icons search-icon">search</span>
                                <input type="text" id="searchInput" placeholder="Cari... (Nama, MyKid, Tarikh, Status, Catatan)">
                            </div>
                        </div>
                    </div>

                    <div class="table-wrapper">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Tarikh Mohon</th>
                                    <th>No. MyKid</th>
                                    <th>Nama Murid</th>
                                    <th>Status</th>
                                    <th>Catatan</th>
                                    <th>Tindakan</th>
                                </tr>
                            </thead>
                            <tbody id="tableBody">
                                <%
                                    int countDalamProses = 0, countLulus = 0, countTolak = 0;
                                    if (list == null || list.isEmpty()) {
                                %>
                                <tr><td colspan="6" class="text-center">Tiada permohonan pendaftaran
                                        <% } else {
                                            for (Permohonan d : list) {
                                                String namaMurid = muridDAO.getNamaByNoKad(d.getNokadpengenalanmurid());
                                                String tarikhFormatted = sdf.format(d.getTarikhpermohonan());
                                                String status = d.getStatuspermohonan();

                                                if ("lulus".equals(status)) {
                                                    countLulus++;
                                                } else if ("tolak".equals(status)) {
                                                    countTolak++;
                                                } else {
                                                    countDalamProses++;
                                                }

                                                String statusClass = "";
                                                String statusText = "";
                                                if ("lulus".equals(status)) {
                                                    statusClass = "status-lulus";
                                                    statusText = "Lulus";
                                                } else if ("tolak".equals(status)) {
                                                    statusClass = "status-tolak";
                                                    statusText = "Ditolak";
                                                } else {
                                                    statusClass = "status-dalamproses";
                                                    statusText = "Dalam Proses";
                                                }
                                        %>
                                <tr>
                                    <td data-label="Tarikh Mohon"><%= tarikhFormatted%></td>
                                    <td data-label="No. MyKid"><%= d.getNokadpengenalanmurid()%></td>
                                    <td data-label="Nama Murid"><%= namaMurid%></td>
                                    <td data-label="Status"><span class="status-badge <%= statusClass%>"><%= statusText%></span></td>
                                    <td data-label="Catatan Penolakan">
                                        <% if ("tolak".equals(status) && d.getCatatanpenolakan() != null && !d.getCatatanpenolakan().isEmpty()) {%>
                                        <%= d.getCatatanpenolakan()%>
                                        <% } else { %>
                                        -
                                        <% } %>
                                    </td>
                                    <td data-label="Tindakan">
                                        <% if ("dalamproses".equals(status)) {%>
                                        <div class="action-buttons">
                                            <form id="lulusForm_<%= d.getIdpermohonan()%>" action="${pageContext.request.contextPath}/KelulusanServlet" method="post" style="display:none;">
                                                <input type="hidden" name="id" value="<%= d.getIdpermohonan()%>">
                                                <input type="hidden" name="action" value="lulus">
                                            </form>

                                            <!-- Butang Lulus -->
                                            <button type="button" class="btn-lulus" onclick="confirmLulus(<%= d.getIdpermohonan()%>)">
                                                <span class="material-icons">check</span> Lulus
                                            </button>

                                            <button type="button" class="btn-tolak" onclick="confirmTolak(<%= d.getIdpermohonan()%>)">
                                                <span class="material-icons">close</span> Tolak
                                            </button>
                                            <form id="tolakForm_<%= d.getIdpermohonan()%>" action="${pageContext.request.contextPath}/KelulusanServlet" method="post" class="tolak-form-hidden" style="display:none;">
                                                <input type="hidden" name="id" value="<%= d.getIdpermohonan()%>">
                                                <input type="hidden" name="action" value="tolak">
                                                <input type="text" name="catatan" placeholder="Sebab penolakan" required>
                                                <button type="submit" class="btn-confirm">Sahkan</button>
                                                <button type="button" class="btn-cancel" onclick="hideTolakForm('<%= d.getIdpermohonan()%>')">Batal</button>
                                            </form>
                                        </div>
                                        <% } else { %>
                                        <span class="text-muted">-</span>
                                        <% } %>
                                    </td>
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
        <div id="toastContainer" class="toast-container"></div>

        <!-- ==================== MODAL CONFIRMATION ==================== -->
        <div id="confirmModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Pengesahan</h3>
                    <button class="modal-close" onclick="closeModal()">&times;</button>
                </div>
                <div class="modal-body">
                    <p id="confirmMessage">Anda pasti untuk meluluskan permohonan ini?</p>
                    <!-- Input untuk sebab tolak (disembunyikan secara default) -->
                    <div id="sebabTolakField" style="display: none; margin-top: 15px;">
                        <label style="display: block; margin-bottom: 5px; font-size: 13px; font-weight: 600;">Sebab Penolakan:</label>
                        <input type="text" id="sebabTolak" class="form-control" placeholder="Sila nyatakan sebab penolakan" style="width: 100%; padding: 8px; border: 1px solid #dce1e8; border-radius: 8px;">
                        <div id="sebabError" style="color: #dc2626; font-size: 12px; margin-top: 5px; display: none;">*Sila isi sebab penolakan</div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button class="btn-primary" id="confirmActionBtn">Ya</button>
                    <button class="btn-secondary" onclick="closeModal()">Tidak</button>
                </div>
            </div>
        </div>

        <script>
            // ==================== TOAST NOTIFICATION (OVERLAY) ====================
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

                // Auto tutup
                setTimeout(function () {
                    if (toast.parentElement) {
                        toast.style.animation = 'fadeOut 0.3s ease-out forwards';
                        setTimeout(function () {
                            toast.remove();
                        }, 300);
                    }
                }, duration);
            }

            // ==================== MODAL CONFIRMATION UNTUK LULUS & TOLAK ====================
            let currentActionId = null;
            let currentActionType = null;

            function confirmLulus(id) {
                currentActionId = id;
                currentActionType = 'lulus';
                document.getElementById('confirmMessage').innerHTML = 'Anda pasti untuk meluluskan permohonan ini?';
                document.getElementById('sebabTolakField').style.display = 'none';
                document.getElementById('confirmModal').style.display = 'flex';
            }

            function confirmTolak(id) {
                currentActionId = id;
                currentActionType = 'tolak';
                document.getElementById('confirmMessage').innerHTML = 'Anda pasti untuk menolak permohonan ini?';
                document.getElementById('sebabTolakField').style.display = 'block';
                document.getElementById('sebabTolak').value = '';
                document.getElementById('confirmModal').style.display = 'flex';
            }

            // Tambah event untuk hilangkan error bila pengguna mula taip
            document.getElementById('sebabTolak').addEventListener('input', function () {
                document.getElementById('sebabError').style.display = 'none';
            });

            function closeModal() {
                document.getElementById('confirmModal').style.display = 'none';
                currentActionId = null;
                currentActionType = null;
                document.getElementById('sebabTolak').value = '';
            }

            // Confirm button action
            document.getElementById('confirmActionBtn').addEventListener('click', function () {
                if (currentActionId && currentActionType === 'lulus') {
                    document.getElementById('lulusForm_' + currentActionId).submit();
                } else if (currentActionId && currentActionType === 'tolak') {
                    var sebab = document.getElementById('sebabTolak').value;
                    var errorDiv = document.getElementById('sebabError');
                    if (!sebab.trim()) {
                        errorDiv.style.display = 'block';
                        return;
                    } else {
                        errorDiv.style.display = 'none';
                    }
                    // Set nilai sebab ke form tolak
                    var tolakForm = document.getElementById('tolakForm_' + currentActionId);
                    tolakForm.querySelector('input[name="catatan"]').value = sebab;
                    tolakForm.submit();
                }
                closeModal();
            });

            // Papar toast jika ada parameter success atau error
            window.addEventListener('load', function () {
                const urlParams = new URLSearchParams(window.location.search);
                if (urlParams.has('success')) {
                    showToast('Status permohonan berjaya dikemaskini.', 'success');
                    // Buang parameter dari URL tanpa reload
                    const newUrl = window.location.pathname;
                    window.history.replaceState({}, document.title, newUrl);
                } else if (urlParams.has('error')) {
                    showToast('Gagal mengemaskini status. Sila cuba lagi.', 'error');
                    // Buang parameter dari URL tanpa reload
                    const newUrl = window.location.pathname;
                    window.history.replaceState({}, document.title, newUrl);
                }
            });

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
                let visibleDalamProses = 0;
                let visibleLulus = 0;
                let visibleTolak = 0;

                for (let i = 0; i < rows.length; i++) {
                    const row = rows[i];
                    const cells = row.getElementsByTagName('td');

                    if (cells.length === 0)
                        continue;

                    let match = false;
                    let statusText = '';

                    for (let j = 0; j < cells.length - 1; j++) {
                        const cellText = cells[j].innerText || cells[j].textContent;
                        if (cellText.toLowerCase().indexOf(filter) > -1) {
                            match = true;
                        }

                        // Kolom Status adalah index ke-3
                        if (j === 3) {
                            statusText = cellText.trim().toLowerCase();
                        }
                    }

                    if (filter === '' || match) {
                        row.classList.remove('hidden-row');

                        // Kira stat berdasarkan status
                        if (statusText === 'dalam proses') {
                            visibleDalamProses++;
                        } else if (statusText === 'lulus') {
                            visibleLulus++;
                        } else if (statusText === 'ditolak') {
                            visibleTolak++;
                        }
                    } else {
                        row.classList.add('hidden-row');
                    }
                }

                // Kira jumlah permohonan yang kelihatan
                visibleJumlah = visibleDalamProses + visibleLulus + visibleTolak;

                // Update stat-value
                const statJumlah = document.getElementById('statJumlah');
                const statDalamProses = document.getElementById('statDalamProses');
                const statLulus = document.getElementById('statLulus');
                const statTolak = document.getElementById('statTolak');

                if (statJumlah)
                    statJumlah.innerText = visibleJumlah;
                if (statDalamProses)
                    statDalamProses.innerText = visibleDalamProses;
                if (statLulus)
                    statLulus.innerText = visibleLulus;
                if (statTolak)
                    statTolak.innerText = visibleTolak;
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