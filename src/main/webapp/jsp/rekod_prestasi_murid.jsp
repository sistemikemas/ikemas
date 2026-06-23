<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Pengguna, dao.TadikaDAO, model.Tadika" %>
<%@ page import="java.util.*, model.Murid, model.PrestasiMurid" %>
<%
    Pengguna p = (Pengguna) session.getAttribute("pengguna");
    if (p == null || !p.getPeranan().equals("guru")) {
        response.sendRedirect("log_masuk.jsp");
        return;
    }
    TadikaDAO tadikaDAO = new TadikaDAO();
    Tadika tadika = tadikaDAO.getTadikaByKod(p.getKodtadika());
    String namaTadika = (tadika != null) ? tadika.getNamatadika() : "Tidak dikenal pasti";

    // Get data from request attributes
    List<Murid> senaraiMurid = (List<Murid>) request.getAttribute("senaraiMurid");
    if (senaraiMurid == null) {
        senaraiMurid = new ArrayList<>();
    }

    Map<String, List<PrestasiMurid>> prestasiMap = (Map<String, List<PrestasiMurid>>) request.getAttribute("prestasiMap");
    if (prestasiMap == null) {
        prestasiMap = new HashMap<>();
    }

    String successMsg = (String) request.getAttribute("success");
    String errorMsg = (String) request.getAttribute("error");
    String searchValue = (String) request.getAttribute("selectedMurid");
    String jenisValue = (String) request.getAttribute("selectedJenis");

    if (searchValue == null) {
        searchValue = "";
    }
    if (jenisValue == null)
        jenisValue = "";
%>
<!DOCTYPE html>
<html lang="ms">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>i-KEMAS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/rekod_prestasi_murid.css">
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
                    <a href="${pageContext.request.contextPath}/RekodPrestasiMuridServlet" class="nav-item active">
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
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Rekod Prestasi Murid</h3>
                        <button class="btn-add" onclick="openAddModal()">Tambah Prestasi</button>
                    </div>

                    <!-- Search and Filter Section -->
                    <form action="${pageContext.request.contextPath}/RekodPrestasiMuridServlet" method="get" class="search-filter-section">
                        <div class="search-box">
                            <div class="search-input-wrapper">
                                <span class="material-icons">search</span>
                                <input type="text" name="search" placeholder="Nama murid atau no. MyKid..." 
                                       value="<%= searchValue%>">
                            </div>
                        </div>
                        <div class="filter-group">
                            <label>Jenis Prestasi</label>
                            <select name="jenis" class="form-select">
                                <option value="">Semua</option>
                                <option value="kesediaantahun1" <%= "kesediaantahun1".equals(jenisValue) ? "selected" : ""%>>Kesediaan Tahun 1</option>
                                <option value="pentaksiranbulanan" <%= "pentaksiranbulanan".equals(jenisValue) ? "selected" : ""%>>Pentaksiran Bulanan</option>
                                <!-- Kehadiran telah dibuang -->
                            </select>
                        </div>
                        <button type="submit" class="btn-search"><span class="material-icons">search</span>Cari</button>
                    </form>

                    <!-- Prestasi Table -->
                    <div class="table-wrapper">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>No. MyKid</th>
                                    <th>Nama Murid</th>
                                    <th>Jenis Prestasi</th>
                                    <th>Subjek</th>
                                    <th>Markah (%)</th>
                                    <th>Gred</th>
                                    <th>Tarikh</th>
                                    <th>Tindakan</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    boolean hasData = false;
                                    for (Murid murid : senaraiMurid) {
                                        List<PrestasiMurid> prestasiList = prestasiMap.get(murid.getNokadpengenalan());
                                        if (prestasiList != null && !prestasiList.isEmpty()) {
                                            hasData = true;
                                            for (PrestasiMurid prestasi : prestasiList) {
                                                // Skip kehadiran - jangan papar
                                                if ("kehadiran".equals(prestasi.getJenisprestasi())) {
                                                    continue;
                                                }
                                %>
                                <tr>
                                    <td><%= murid.getNokadpengenalan()%></td>
                                    <td><%= murid.getNamamurid()%></td>
                                    <td>
                                        <%
                                            String jenis = prestasi.getJenisprestasi();
                                            if ("kesediaantahun1".equals(jenis))
                                                out.print("Kesediaan Tahun 1");
                                            else if ("pentaksiranbulanan".equals(jenis))
                                                out.print("Pentaksiran Bulanan");
                                            else
                                                out.print("-");
                                        %>
                                    </td>
                                    <td><%= prestasi.getSubjek() != null && !prestasi.getSubjek().isEmpty() ? prestasi.getSubjek() : "-"%></td>
                                    <td>
                                        <%
                                            Double markah = prestasi.getMarkahperatus();
                                            if (markah != null && markah > 0) {
                                                out.print(String.format("%.2f", markah));
                                            } else {
                                                out.print("-");
                                            }
                                        %>
                                    </td>
                                    <td><%= prestasi.getGred() != null && !prestasi.getGred().isEmpty() ? prestasi.getGred() : "-"%></td>
                                    <td><%= prestasi.getTarikh()%></td>
                                    <td>
                                        <button class="btn-edit" onclick="editPrestasi(
                                                        '<%= prestasi.getIdprestasi()%>',
                                                        '<%= murid.getNokadpengenalan()%>',
                                                        '<%= prestasi.getJenisprestasi()%>',
                                                        '<%= prestasi.getSubjek() != null ? prestasi.getSubjek().replace("'", "\\'") : ""%>',
                                                        '<%= prestasi.getMarkahperatus() != null ? prestasi.getMarkahperatus() : ""%>',
                                                        '<%= prestasi.getGred() != null ? prestasi.getGred() : ""%>',
                                                        '<%= prestasi.getStatuskehadiran() != null ? prestasi.getStatuskehadiran() : ""%>',
                                                        '<%= prestasi.getCatatan() != null ? prestasi.getCatatan().replace("'", "\\'").replace("\n", "\\n") : ""%>',
                                                        '<%= prestasi.getTarikh()%>'
                                                        )">
                                            <span class="material-icons">edit</span>
                                        </button>
                                        <button class="btn-delete" onclick="deletePrestasi('<%= prestasi.getIdprestasi()%>', '<%= murid.getNamamurid().replace("'", "\\'")%>')">
                                            <span class="material-icons">delete</span>
                                        </button>
                                    </td>
                                </tr>
                                <%
                                            }
                                        }
                                    }
                                    if (!hasData) {
                                %>
                                <tr>
                                    <td colspan="8" class="text-center">
                                        <div class="empty-state">
                                            <p>Tiada rekod prestasi dijumpai</p>
                                            <% if (!searchValue.isEmpty() || !jenisValue.isEmpty()) { %>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>

                </div>
            </main>
        </div>

        <!-- Add/Edit Modal -->
        <div id="prestasiModal" class="modal">
            <div class="modal-content">
                <form id="prestasiForm" action="${pageContext.request.contextPath}/RekodPrestasiMuridServlet" method="post">
                    <div class="modal-header">
                        <h3 id="modalTitle">Tambah Rekod Prestasi</h3>
                        <span class="material-icons modal-close" onclick="closeModal()">close</span>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="action" id="formAction" value="add">
                        <input type="hidden" name="idprestasi" id="idprestasi">
                        <input type="hidden" name="search" value="<%= searchValue%>">
                        <input type="hidden" name="jenis" value="<%= jenisValue%>">

                        <div class="form-group">
                            <label class="required">Murid</label>
                            <select name="nokadpengenalan" id="nokadpengenalan" class="form-select" required>
                                <option value="">Pilih Murid</option>
                                <%
                                    for (Murid murid : senaraiMurid) {
                                %>
                                <option value="<%= murid.getNokadpengenalan()%>"><%= murid.getNamamurid()%> - <%= murid.getNokadpengenalan()%></option>
                                <%
                                    }
                                %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="required">Jenis Prestasi</label>
                            <select name="jenisprestasi" id="jenisprestasi" class="form-select" required onchange="toggleFields()">
                                <option value="">Pilih Jenis Prestasi</option>
                                <option value="kesediaantahun1">Kesediaan Tahun 1</option>
                                <option value="pentaksiranbulanan">Pentaksiran Bulanan</option>
                                <!-- Kehadiran telah dibuang -->
                            </select>
                        </div>

                        <div class="form-row" id="subjectField" style="display: none;">
                            <div class="form-group">
                                <label>Subjek</label>
                                <select name="subjek" id="subjek" class="form-select">
                                    <option value="">Pilih Subjek</option>
                                    <option value="Bahasa Melayu">Bahasa Melayu</option>
                                    <option value="Bahasa Inggeris">Bahasa Inggeris</option>
                                    <option value="Matematik">Matematik</option>
                                    <option value="Sains">Sains</option>
                                    <option value="Pendidikan Islam">Pendidikan Islam</option>
                                    <option value="Pendidikan Moral">Pendidikan Moral</option>
                                    <option value="Pendidikan Jasmani">Pendidikan Jasmani</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Markah (%)</label>
                                <input type="number" name="markahperatus" id="markahperatus" class="form-control" step="0.01" min="0" max="100">
                            </div>
                        </div>

                        <div class="form-group" id="gredField" style="display: none;">
                            <label>Gred</label>
                            <select name="gred" id="gred" class="form-select">
                                <option value="">Pilih Gred</option>
                                <option value="CEMERLANG">CEMERLANG (80-100)</option>
                                <option value="SANGAT BAIK">SANGAT BAIK (60-79)</option>
                                <option value="BAIK">BAIK (40-59)</option>
                                <option value="MEMUASKAN">MEMUASKAN (20-39)</option>
                                <option value="PERLU BIMBINGAN">PERLU BIMBINGAN (0-19)</option>
                            </select>
                        </div>

                        <!-- Status Kehadiran telah dibuang -->

                        <div class="form-group" id="catatanField">
                            <label>Catatan</label>
                            <textarea name="catatan" id="catatan" class="form-control" rows="3" placeholder="Catatan tambahan (jika ada)..."></textarea>
                        </div>

                        <div class="form-group">
                            <label class="required">Tarikh</label>
                            <input type="date" name="tarikh" id="tarikh" class="form-control" required>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn-cancel" onclick="closeModal()">Batal</button>
                        <button type="submit" class="btn-save">Simpan</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Delete Confirmation Modal -->
        <div id="deleteModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Pengesahan</h3>
                    <span class="material-icons modal-close" onclick="closeDeleteModal()">close</span>
                </div>
                <div class="modal-body">
                    <p>Adakah anda pasti ingin menghapuskan rekod prestasi untuk <strong id="deleteMuridName"></strong>?</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-delete-sah" onclick="confirmDelete()">Hapus</button>
                    <button type="button" class="btn-secondary" onclick="closeDeleteModal()">Batal</button>
                </div>
            </div>
        </div>

        <script>
            let deleteId = null;

            // Toast notification function
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

            // Show messages from server
            <% if (successMsg != null && !successMsg.isEmpty()) {%>
            showToast('<%= successMsg.replace("'", "\\'")%>', 'success', 4000);
            <% } %>
            <% if (errorMsg != null && !errorMsg.isEmpty()) {%>
            showToast('<%= errorMsg.replace("'", "\\'")%>', 'error', 4000);
            <% }%>

            function toggleFields() {
                const jenis = document.getElementById('jenisprestasi').value;
                const subjectField = document.getElementById('subjectField');
                const gredField = document.getElementById('gredField');

                if (jenis === 'kesediaantahun1' || jenis === 'pentaksiranbulanan') {
                    subjectField.style.display = 'grid';
                    gredField.style.display = 'block';
                    document.getElementById('subjek').required = false;
                    document.getElementById('markahperatus').required = false;
                    document.getElementById('gred').required = false;
                } else {
                    subjectField.style.display = 'none';
                    gredField.style.display = 'none';
                }
            }

            function openAddModal() {
                document.getElementById('modalTitle').innerText = 'Tambah Rekod Prestasi';
                document.getElementById('formAction').value = 'add';
                document.getElementById('prestasiForm').reset();
                document.getElementById('idprestasi').value = '';
                document.getElementById('subjectField').style.display = 'none';
                document.getElementById('gredField').style.display = 'none';

                // Set today's date as default
                const today = new Date();
                const year = today.getFullYear();
                const month = String(today.getMonth() + 1).padStart(2, '0');
                const day = String(today.getDate()).padStart(2, '0');
                document.getElementById('tarikh').value = year + '-' + month + '-' + day;

                document.getElementById('prestasiModal').classList.add('active');
            }

            function editPrestasi(id, nokadpengenalan, jenis, subjek, markah, gred, status, catatan, tarikh) {
                document.getElementById('modalTitle').innerText = 'Edit Rekod Prestasi';
                document.getElementById('formAction').value = 'edit';
                document.getElementById('idprestasi').value = id;
                document.getElementById('nokadpengenalan').value = nokadpengenalan;
                document.getElementById('jenisprestasi').value = jenis;
                document.getElementById('tarikh').value = tarikh;

                if (subjek && subjek !== 'null') {
                    document.getElementById('subjek').value = subjek;
                }
                if (markah && markah !== 'null' && markah > 0) {
                    document.getElementById('markahperatus').value = markah;
                }
                if (gred && gred !== 'null') {
                    document.getElementById('gred').value = gred;
                }
                if (catatan && catatan !== 'null') {
                    document.getElementById('catatan').value = catatan;
                }

                toggleFields();
                document.getElementById('prestasiModal').classList.add('active');
            }

            function deletePrestasi(id, namaMurid) {
                deleteId = id;
                document.getElementById('deleteMuridName').innerText = namaMurid;
                document.getElementById('deleteModal').classList.add('active');
            }

            function confirmDelete() {
                if (deleteId) {
                    const form = document.createElement('form');
                    form.method = 'post';
                    form.action = '${pageContext.request.contextPath}/RekodPrestasiMuridServlet';

                    const actionInput = document.createElement('input');
                    actionInput.type = 'hidden';
                    actionInput.name = 'action';
                    actionInput.value = 'delete';
                    form.appendChild(actionInput);

                    const idInput = document.createElement('input');
                    idInput.type = 'hidden';
                    idInput.name = 'idprestasi';
                    idInput.value = deleteId;
                    form.appendChild(idInput);

                    // Preserve search parameters
                    const searchInput = document.createElement('input');
                    searchInput.type = 'hidden';
                    searchInput.name = 'search';
                    searchInput.value = '<%= searchValue%>';
                    form.appendChild(searchInput);

                    const jenisInput = document.createElement('input');
                    jenisInput.type = 'hidden';
                    jenisInput.name = 'jenis';
                    jenisInput.value = '<%= jenisValue%>';
                    form.appendChild(jenisInput);

                    document.body.appendChild(form);
                    form.submit();
                }
            }

            function closeModal() {
                document.getElementById('prestasiModal').classList.remove('active');
            }

            function closeDeleteModal() {
                document.getElementById('deleteModal').classList.remove('active');
                deleteId = null;
            }

            // Close modals when clicking outside
            window.onclick = function (event) {
                const modal = document.getElementById('prestasiModal');
                const deleteModal = document.getElementById('deleteModal');
                if (event.target === modal)
                    closeModal();
                if (event.target === deleteModal)
                    closeDeleteModal();
            }

            // Auto-hide toast messages after duration
            setTimeout(function () {
                const toasts = document.querySelectorAll('.toast');
                toasts.forEach(function (toast) {
                    setTimeout(function () {
                        if (toast.parentElement) {
                            toast.style.animation = 'fadeOut 0.3s ease-out forwards';
                            setTimeout(function () {
                                toast.remove();
                            }, 300);
                        }
                    }, 4000);
                });
            }, 100);
        </script>
    </body>
</html>