<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Pengguna, model.Tadika, model.Pemantauan, java.util.List" %>
<%@ page import="util.DewanUndanganNegeri" %>
<%
    Pengguna p = (Pengguna) session.getAttribute("pengguna");
    if (p == null || !p.getPeranan().equals("penyelia")) {
        response.sendRedirect("log_masuk.jsp");
        return;
    }

    List<Tadika> senaraiTadika = (List<Tadika>) request.getAttribute("senaraiTadika");
    List<Pemantauan> senaraiPemantauan = (List<Pemantauan>) request.getAttribute("senaraiPemantauan");

    String successMsg = request.getParameter("toast_success");
    String errorMsg = request.getParameter("toast_error");
    String searchValue = request.getParameter("search");
    String selectedTadika = (String) request.getAttribute("selectedTadika");
    Integer selectedTahun = (Integer) request.getAttribute("selectedTahun");

    if (senaraiTadika == null) {
        senaraiTadika = new java.util.ArrayList<>();
    }
    if (senaraiPemantauan == null) {
        senaraiPemantauan = new java.util.ArrayList<>();
    }
    if (searchValue == null) {
        searchValue = "";
    }
    if (selectedTahun == null) {
        selectedTahun = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
    }

    // Format DUN
    String dunSeliaan = p.getDunseliaan();
    String dunDisplay = dunSeliaan;
    if (dunSeliaan != null && dunSeliaan.contains(" ")) {
        int firstSpace = dunSeliaan.indexOf(" ");
        dunDisplay = dunSeliaan.substring(0, firstSpace) + ", " + dunSeliaan.substring(firstSpace + 1);
    }
%>
<!DOCTYPE html>
<html lang="ms">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>i-KEMAS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/pemantauan_tadika_penyelia.css">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/image/logo-sistem.png">
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
                    <a href="${pageContext.request.contextPath}/PemantauanTadikaPenyeliaServlet" class="nav-item active">
                        <span class="material-icons">assignment</span><span>Pemantauan Tadika</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/LaporanPrestasiPenyeliaServlet" class="nav-item">
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
                            Pemantauan Tadika
                        </h3>
                        <button class="btn-primary" onclick="openAddModal()">Tambah Pemantauan
                        </button>
                    </div>
                    <div class="card-body">
                        <!-- Filter Section -->
                        <form action="${pageContext.request.contextPath}/PemantauanTadikaPenyeliaServlet" method="get" class="filter-section">
                            <div class="filter-group">
                                <label>Cari Tadika</label>
                                <div class="search-box" style="margin:0">
                                    <span class="material-icons search-icon">search</span>
                                    <input type="text" name="search" placeholder="Kod atau nama tadika..." value="<%= searchValue%>" style="padding-left:35px">
                                </div>
                            </div>
                            <div class="filter-group">
                                <label>Tahun</label>
                                <select name="tahun">
                                    <option value="2025" <%= selectedTahun == 2025 ? "selected" : ""%>>2025</option>
                                    <option value="2026" <%= selectedTahun == 2026 ? "selected" : ""%>>2026</option>
                                    <option value="2027" <%= selectedTahun == 2027 ? "selected" : ""%>>2027</option>
                                </select>
                            </div>
                            <div class="filter-group">
                                <label>Tadika</label>
                                <select name="kodtadika">
                                    <option value="">-- Semua Tadika --</option>
                                    <% for (Tadika t : senaraiTadika) {%>
                                    <option value="<%= t.getKodtadika()%>" <%= selectedTadika != null && selectedTadika.equals(t.getKodtadika()) ? "selected" : ""%>><%= t.getNamatadika()%></option>
                                    <% } %>
                                </select>
                            </div>
                            <button type="submit" class="btn-filter">Papar
                            </button>
                        </form>

                        <!-- Pemantauan Table -->
                        <div class="table-wrapper">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Tarikh</th>
                                        <th>Tadika</th>
                                        <th>Aspek Dinilai</th>
                                        <th>Keputusan</th>
                                        <th>Catatan</th>
                                        <th>Tindakan Susulan</th>
                                        <th>Tindakan</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (senaraiPemantauan.isEmpty()) { %>
                                    <tr><td colspan="7" class="text-center">
                                            <% if (selectedTadika != null && !selectedTadika.isEmpty()) { %>
                                            Tiada rekod pemantauan untuk tadika ini
                                            <% } else { %>
                                            Sila pilih tadika untuk melihat rekod pemantauan
                                            <% } %>
                                        </td></tr>
                                        <% } else {
                                            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MM-yyyy");
                                            for (Pemantauan pm : senaraiPemantauan) {
                                                String badgeClass = "";
                                                if ("cemerlang".equals(pm.getKeputusanpemantauan())) {
                                                    badgeClass = "badge-cemerlang";
                                                } else if ("baik".equals(pm.getKeputusanpemantauan())) {
                                                    badgeClass = "badge-baik";
                                                } else if ("memuaskan".equals(pm.getKeputusanpemantauan())) {
                                                    badgeClass = "badge-memuaskan";
                                                } else {
                                                    badgeClass = "badge-perlupenambahbaikan";
                                                }

                                                String keputusanText = "";
                                                if ("cemerlang".equals(pm.getKeputusanpemantauan()))
                                                    keputusanText = "Cemerlang";
                                                else if ("baik".equals(pm.getKeputusanpemantauan()))
                                                    keputusanText = "Baik";
                                                else if ("memuaskan".equals(pm.getKeputusanpemantauan()))
                                                    keputusanText = "Memuaskan";
                                                else
                                                    keputusanText = "Perlu Penambahbaikan";
                                        %>
                                    <tr>
                                        <td data-label="Tarikh"><%= sdf.format(pm.getTarikhpemantauan())%></td>
                                        <td data-label="Tadika"><%= getNamaTadika(senaraiTadika, pm.getKodtadika())%> </td>
                                        <td data-label="Aspek Dinilai"><%= pm.getAspekdinilai()%> </td>
                                        <td data-label="Keputusan"><span class="<%= badgeClass%>"><%= keputusanText%></span></td>
                                        <td data-label="Catatan"><%= pm.getCatatanpenyelia() != null ? pm.getCatatanpenyelia() : "-"%> </td>
                                        <td data-label="Tindakan Susulan"><%= pm.getTindakansusulan() != null ? pm.getTindakansusulan() : "-"%> </td>
                                        <td data-label="Tindakan">
                                            <button class="btn-edit" onclick="openEditModal('<%= pm.getIdpemantauan()%>', '<%= pm.getKodtadika()%>', '<%= pm.getTarikhpemantauan()%>', '<%= pm.getAspekdinilai()%>', '<%= pm.getKeputusanpemantauan()%>', '<%= pm.getCatatanpenyelia() != null ? pm.getCatatanpenyelia().replace("'", "\\'") : ""%>', '<%= pm.getTindakansusulan() != null ? pm.getTindakansusulan().replace("'", "\\'") : ""%>')">
                                                <span class="material-icons">edit</span>
                                            </button>
                                            <button class="btn-delete" onclick="confirmDelete('<%= pm.getIdpemantauan()%>')">
                                                <span class="material-icons">delete</span>
                                            </button>
                                        </td>
                                    </tr>
                                    <% }
                                    }%>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </main>
        </div>

        <!-- ADD/EDIT MODAL -->
        <div id="pemantauanModal" class="modal">
            <div class="modal-content">
                <form id="pemantauanForm" action="${pageContext.request.contextPath}/PemantauanTadikaPenyeliaServlet" method="post">
                    <div class="modal-header">
                        <h3 id="modalTitle">Tambah Pemantauan</h3>
                        <span class="material-icons modal-close" onclick="closeModal()">close</span>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="action" id="formAction" value="add">
                        <input type="hidden" name="id" id="pemantauanId">
                        <input type="hidden" name="search" value="<%= searchValue%>">
                        <input type="hidden" name="tahun" value="<%= selectedTahun%>">

                        <div class="form-group">
                            <label>Tadika</label>
                            <select name="kodtadika" id="kodtadika" required>
                                <option value="">Pilih Tadika</option>
                                <% for (Tadika t : senaraiTadika) {%>
                                <option value="<%= t.getKodtadika()%>"><%= t.getNamatadika()%></option>
                                <% }%>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Tarikh Pemantauan</label>
                            <input type="date" name="tarikhpemantauan" id="tarikhpemantauan" required>
                        </div>
                        <div class="form-group">
                            <label>Aspek Dinilai</label>
                            <textarea name="aspekdinilai" id="aspekdinilai" rows="3" placeholder="Pengurusan kelas, kebersihan, keselamatan, KSPK, dll" required></textarea>
                        </div>
                        <div class="form-group">
                            <label>Keputusan Pemantauan</label>
                            <select name="keputusan" id="keputusan" required>
                                <option value="cemerlang">Cemerlang</option>
                                <option value="baik">Baik</option>
                                <option value="memuaskan">Memuaskan</option>
                                <option value="perlupenambahbaikan">Perlu Penambahbaikan</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Catatan Penyelia</label>
                            <textarea name="catatan" id="catatan" rows="2" placeholder="Catatan tambahan..."></textarea>
                        </div>
                        <div class="form-group">
                            <label>Tindakan Susulan</label>
                            <textarea name="tindakansusulan" id="tindakansusulan" rows="2" placeholder="Tindakan yang perlu diambil..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn-secondary" onclick="closeModal()">Batal</button>
                        <button type="submit" class="btn-primary">Simpan</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- DELETE MODAL -->
        <div id="deleteModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Pengesahan</h3>
                    <span class="material-icons modal-close" onclick="closeDeleteModal()">close</span>
                </div>
                <div class="modal-body">
                    <p>Adakah anda pasti ingin menghapuskan rekod pemantauan ini?</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-secondary" onclick="closeDeleteModal()">Batal</button>
                    <button type="button" class="btn-primary" id="confirmDeleteBtn">Hapus</button>
                </div>
            </div>
        </div>

        <script>
            let deleteId = null;

            function showToast(message, type, duration) {
                type = type || 'info';
                duration = duration || 5000;
                const container = document.getElementById('toastContainer');
                if (!container)
                    return;
                const toast = document.createElement('div');
                toast.className = 'toast ' + type;
                toast.innerHTML = '<div class="toast-content">' + message + '</div><div class="toast-progress"></div>';
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

            function openAddModal() {
                document.getElementById('modalTitle').innerText = 'Tambah Pemantauan';
                document.getElementById('formAction').value = 'add';
                document.getElementById('pemantauanForm').reset();
                document.getElementById('pemantauanId').value = '';
                document.getElementById('tarikhpemantauan').valueAsDate = new Date();
                document.getElementById('pemantauanModal').classList.add('active');
            }

            function openEditModal(id, kodtadika, tarikh, aspek, keputusan, catatan, tindakan) {
                document.getElementById('modalTitle').innerText = 'Edit Pemantauan';
                document.getElementById('formAction').value = 'edit';
                document.getElementById('pemantauanId').value = id;
                document.getElementById('kodtadika').value = kodtadika;
                document.getElementById('tarikhpemantauan').value = tarikh;
                document.getElementById('aspekdinilai').value = aspek;
                document.getElementById('keputusan').value = keputusan;
                document.getElementById('catatan').value = catatan;
                document.getElementById('tindakansusulan').value = tindakan;
                document.getElementById('pemantauanModal').classList.add('active');
            }

            function confirmDelete(id) {
                deleteId = id;
                document.getElementById('deleteModal').classList.add('active');
            }

            document.getElementById('confirmDeleteBtn')?.addEventListener('click', function () {
                if (deleteId) {
                    window.location.href = '${pageContext.request.contextPath}/PemantauanTadikaPenyeliaServlet?action=delete&id=' + deleteId + '&search=<%= searchValue%>&tahun=<%= selectedTahun%>';
                }
            });

            function closeModal() {
                document.getElementById('pemantauanModal').classList.remove('active');
            }
            function closeDeleteModal() {
                document.getElementById('deleteModal').classList.remove('active');
                deleteId = null;
            }

            window.onclick = function (event) {
                if (event.target === document.getElementById('pemantauanModal'))
                    closeModal();
                if (event.target === document.getElementById('deleteModal'))
                    closeDeleteModal();
            }

            // Helper function to get tadika name
            function getNamaTadika(tadikaList, kod) {
                for (var i = 0; i < tadikaList.length; i++) {
                    if (tadikaList[i].getKodtadika() === kod)
                        return tadikaList[i].getNamatadika();
                }
                return kod;
            }

            <% if (successMsg != null && !successMsg.isEmpty()) {%>
            showToast('<%= successMsg.replace("'", "\\'")%>', 'success', 4000);
            <% } %>
            <% if (errorMsg != null && !errorMsg.isEmpty()) {%>
            showToast('<%= errorMsg.replace("'", "\\'")%>', 'error', 4000);
            <% }%>
        </script>
    </body>
</html>

<%!
    // Helper function to get tadika name
    private String getNamaTadika(List<Tadika> list, String kod) {
        for (Tadika t : list) {
            if (t.getKodtadika().equals(kod)) {
                return t.getNamatadika();
            }
        }
        return kod;
    }
%>