<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Pengguna, model.Tadika, java.util.List, java.util.ArrayList" %>
<%@ page import="util.DewanUndanganNegeri" %>
<%
    Pengguna p = (Pengguna) session.getAttribute("pengguna");
    if (p == null || !p.getPeranan().equals("penyelia")) {
        response.sendRedirect("log_masuk.jsp");
        return;
    }

    List<Tadika> senaraiTadika = (List<Tadika>) request.getAttribute("senaraiTadika");
    if (senaraiTadika == null) {
        senaraiTadika = new ArrayList<>();
    }

    // READ TOAST MESSAGES FROM URL PARAMETERS (because servlet uses redirect)
    String successMsg = request.getParameter("toast_success");
    String errorMsg = request.getParameter("toast_error");

    // If not from URL, try from request attribute
    if (successMsg == null) {
        successMsg = (String) request.getAttribute("success");
    }
    if (errorMsg == null) {
        errorMsg = (String) request.getAttribute("error");
    }

    String searchValue = request.getParameter("search");
    if (searchValue == null) {
        searchValue = (String) request.getAttribute("searchValue");
    }
    if (searchValue == null) {
        searchValue = "";
    }

    // Format DUN untuk paparan
    String dunSeliaan = p.getDunseliaan();
    String dunDisplay = dunSeliaan;
    if (dunSeliaan != null && dunSeliaan.contains(" ")) {
        int firstSpace = dunSeliaan.indexOf(" ");
        dunDisplay = dunSeliaan.substring(0, firstSpace) + ", " + dunSeliaan.substring(firstSpace + 1);
    }

    // Dapatkan senarai DUN untuk dropdown
    String[] dunList = {};
    if (dunSeliaan != null) {
        dunList = DewanUndanganNegeri.pecahkanDUN(dunSeliaan);
    }
%>
<!DOCTYPE html>
<html lang="ms">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>i-KEMAS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/senarai_tadika_penyelia.css">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/image/logo-sistem.png">
    </head>
    <body>
        <div id="toastContainer" class="toast-container"></div>

        <div class="dashboard">
            <!-- SIDEBAR -->
            <aside class="sidebar">
                <div class="sidebar-header">
                    <div class="logo"><h2>i-KEMAS</h2></div>
                    <p>SISTEM PENGURUSAN KANAK-KANAK<br>TABIKA KEMAS</p>
                </div>
                <nav class="nav-menu">
                    <a href="${pageContext.request.contextPath}/DashboardPenyeliaServlet" class="nav-item">
                        <span class="material-icons">dashboard</span><span>Dashboard</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/SenaraiTadikaPenyeliaServlet" class="nav-item active">
                        <span class="material-icons">school</span><span>Senarai Tadika</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/TambahGuruAtauGuruBesarServlet" class="nav-item">
                        <span class="material-icons">person_add</span><span>Tambah Guru/Guru Besar</span>
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
                        <span class="material-icons">person</span><span>Profil Saya</span>
                    </a>
                </nav>
                <div class="sidebar-footer">
                    <a href="${pageContext.request.contextPath}/LogKeluarServlet" class="nav-item logout">
                        <span class="material-icons">logout</span><span>Log Keluar</span>
                    </a>
                </div>
            </aside>

            <!-- TOP BAR -->
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

            <!-- MAIN CONTENT -->
            <main class="main-content">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            Senarai Tadika
                        </h3>
                        <div class="search-container">
                            <div class="search-box">
                                <span class="material-icons search-icon">search</span>
                                <input type="text" id="searchInput" placeholder="Cari kod atau nama tadika..." value="<%= searchValue%>">
                            </div>
                            <button class="btn-primary" onclick="openAddModal()"> Tambah Tadika
                            </button>
                        </div>
                    </div>
                    <div class="table-wrapper">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Kod Tadika</th>
                                    <th>Nama Tadika</th>
                                    <th>Alamat</th>
                                    <th>Bilangan Kelas</th>
                                    <th>Sesi</th>
                                    <th>DUN</th>
                                    <th>Tindakan</th>
                                </tr>
                            </thead>
                            <tbody id="tableBody">
                                <% if (senaraiTadika.isEmpty()) { %>
                                <tr><td colspan="7" class="text-center">Tiada tadika dijumpai</td></tr>
                                <% } else {
                                    for (Tadika t : senaraiTadika) {
                                %>
                                <tr>
                                    <td data-label="Kod Tadika"><%= t.getKodtadika()%></td>
                                    <td data-label="Nama Tadika"><%= t.getNamatadika()%></td>
                                    <td data-label="Alamat"><%= t.getAlamat() != null ? t.getAlamat() : "-"%></td>
                                    <td data-label="Bilangan Kelas"><%= t.getBilangankelas()%></td>
                                    <td data-label="Sesi"><%= t.getSesipersekolahan() != null ? t.getSesipersekolahan() : "Pagi"%></td>
                                    <td data-label="DUN"><%= t.getDun()%></td>
                                    <td data-label="Tindakan">
                                        <button class="btn-edit" onclick="openEditModal('<%= t.getKodtadika()%>', '<%= t.getNamatadika()%>', '<%= t.getAlamat() != null ? t.getAlamat().replace("'", "\\'") : ""%>', '<%= t.getBilangankelas()%>', '<%= t.getSesipersekolahan() != null ? t.getSesipersekolahan() : ""%>', '<%= t.getDun()%>')">
                                            <span class="material-icons">edit</span>
                                        </button>
                                        <button class="btn-delete" onclick="confirmDelete('<%= t.getKodtadika()%>', '<%= t.getNamatadika()%>')">
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
            </main>
        </div>

        <!-- ADD MODAL -->
        <div id="tadikaModal" class="modal">
            <div class="modal-content">
                <form id="tadikaForm" action="${pageContext.request.contextPath}/SenaraiTadikaPenyeliaServlet" method="post">
                    <div class="modal-header">
                        <h3 id="modalTitle">Tambah Tadika</h3>
                        <span class="material-icons modal-close" onclick="closeModal()">close</span>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="action" id="formAction" value="add">
                        <input type="hidden" name="search" value="<%= searchValue%>">

                        <div class="form-group">
                            <label>Nama Tadika <span class="required">*</span></label>
                            <input type="text" name="namatadika" id="namatadika" required>
                        </div>
                        <div class="form-group">
                            <label>Alamat</label>
                            <textarea name="alamat" id="alamat" rows="3" placeholder="Masukkan alamat lengkap tadika"></textarea>
                        </div>
                        <div class="form-group">
                            <label>Bilangan Kelas <span class="required">*</span></label>
                            <input type="number" name="bilangankelas" id="bilangankelas" min="1" value="1" required>
                        </div>
                        <div class="form-group">
                            <label>Sesi Persekolahan</label>
                            <select name="sesipersekolahan" id="sesipersekolahan">
                                <option value="Pagi">Pagi</option>
                                <option value="Petang">Petang</option>
                                <option value="Pagi & Petang">Pagi & Petang</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Dewan Undangan Negeri (DUN) <span class="required">*</span></label>
                            <select name="dun" id="dun" required>
                                <option value="">-- Pilih DUN --</option>
                                <% for (String dun : dunList) {%>
                                <option value="<%= dun%>"><%= dun%></option>
                                <% }%>
                            </select>
                            <small class="form-text">Kod tadika akan dijana secara automatik berdasarkan DUN yang dipilih</small>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn-secondary" onclick="closeModal()">Batal</button>
                        <button type="submit" class="btn-primary">Simpan</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- EDIT MODAL -->
        <div id="editModal" class="modal">
            <div class="modal-content">
                <form id="editForm" action="${pageContext.request.contextPath}/SenaraiTadikaPenyeliaServlet" method="post">
                    <div class="modal-header">
                        <h3>Edit Tadika</h3>
                        <span class="material-icons modal-close" onclick="closeEditModal()">close</span>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="action" value="edit">
                        <input type="hidden" name="search" value="<%= searchValue%>">
                        <input type="hidden" name="kodtadika" id="edit_kodtadika">

                        <div class="form-group">
                            <label>Nama Tadika <span class="required">*</span></label>
                            <input type="text" name="namatadika" id="edit_namatadika" required>
                        </div>
                        <div class="form-group">
                            <label>Alamat</label>
                            <textarea name="alamat" id="edit_alamat" rows="3"></textarea>
                        </div>
                        <div class="form-group">
                            <label>Bilangan Kelas <span class="required">*</span></label>
                            <input type="number" name="bilangankelas" id="edit_bilangankelas" min="1" required>
                        </div>
                        <div class="form-group">
                            <label>Sesi Persekolahan</label>
                            <select name="sesipersekolahan" id="edit_sesipersekolahan">
                                <option value="Pagi">Pagi</option>
                                <option value="Petang">Petang</option>
                                <option value="Pagi & Petang">Pagi & Petang</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Dewan Undangan Negeri (DUN) <span class="required">*</span></label>
                            <select name="dun" id="edit_dun" required>
                                <% for (String dun : dunList) {%>
                                <option value="<%= dun%>"><%= dun%></option>
                                <% }%>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn-secondary" onclick="closeEditModal()">Batal</button>
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
                    <p>Adakah anda pasti ingin menghapuskan <strong id="deleteNama"></strong>?</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-secondary" onclick="closeDeleteModal()">Batal</button>
                    <button type="button" class="btn-primary" id="confirmDeleteBtn">Hapus</button>
                </div>
            </div>
        </div>

        <script>
            let deleteKod = null;

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
                document.getElementById('tadikaForm').reset();
                document.getElementById('alamat').value = '';
                document.getElementById('tadikaModal').classList.add('active');
            }

            function openEditModal(kod, nama, alamat, bilKelas, sesi, dun) {
                document.getElementById('edit_kodtadika').value = kod;
                document.getElementById('edit_namatadika').value = nama;
                document.getElementById('edit_alamat').value = alamat;
                document.getElementById('edit_bilangankelas').value = bilKelas;
                document.getElementById('edit_sesipersekolahan').value = sesi;
                document.getElementById('edit_dun').value = dun;
                document.getElementById('editModal').classList.add('active');
            }

            function confirmDelete(kod, nama) {
                deleteKod = kod;
                document.getElementById('deleteNama').innerText = nama;
                document.getElementById('deleteModal').classList.add('active');
            }

            document.getElementById('confirmDeleteBtn')?.addEventListener('click', function () {
                if (deleteKod) {
                    window.location.href = '${pageContext.request.contextPath}/SenaraiTadikaPenyeliaServlet?action=delete&id=' + deleteKod + '&search=<%= searchValue%>';
                }
            });

            function closeModal() {
                document.getElementById('tadikaModal').classList.remove('active');
            }

            function closeEditModal() {
                document.getElementById('editModal').classList.remove('active');
            }

            function closeDeleteModal() {
                document.getElementById('deleteModal').classList.remove('active');
                deleteKod = null;
            }

            // Search functionality
            document.getElementById('searchInput')?.addEventListener('keyup', function (e) {
                let search = this.value;
                window.location.href = '${pageContext.request.contextPath}/SenaraiTadikaPenyeliaServlet?search=' + encodeURIComponent(search);
            });

            // Close modals when clicking outside
            window.onclick = function (event) {
                const addModal = document.getElementById('tadikaModal');
                const editModal = document.getElementById('editModal');
                const deleteModal = document.getElementById('deleteModal');
                if (event.target === addModal)
                    closeModal();
                if (event.target === editModal)
                    closeEditModal();
                if (event.target === deleteModal)
                    closeDeleteModal();
            }

            // Show toast messages
            <% if (successMsg != null && !successMsg.isEmpty()) {%>
            showToast('<%= successMsg.replace("'", "\\'")%>', 'success', 4000);
            <% } %>
            <% if (errorMsg != null && !errorMsg.isEmpty()) {%>
            showToast('<%= errorMsg.replace("'", "\\'")%>', 'error', 4000);
            <% }%>
        </script>
    </body>
</html>