<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Pengguna, model.Tadika, java.util.List" %>
<%
    Pengguna p = (Pengguna) session.getAttribute("pengguna");
    if (p == null || !p.getPeranan().equals("penyelia")) {
        response.sendRedirect("log_masuk.jsp");
        return;
    }
    List<Tadika> senaraiTadika = (List<Tadika>) request.getAttribute("senaraiTadika");
    String error = (String) request.getAttribute("error");
    Boolean success = (Boolean) request.getAttribute("success");
    String newPassword = (String) request.getAttribute("newPassword");
    String usernameBaru = (String) request.getAttribute("username");
    String namaBaru = (String) request.getAttribute("nama");

    // Format DUN untuk paparan
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
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/image/logo-sistem.png">
    </head>
    <body>
        <div id="toastContainer" class="toast-container"></div>

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
                    <a href="${pageContext.request.contextPath}/DashboardPenyeliaServlet" class="nav-item">
                        <span class="material-icons">dashboard</span>
                        <span>Dashboard</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/SenaraiTadikaPenyeliaServlet" class="nav-item">
                        <span class="material-icons">school</span>
                        <span>Senarai Tadika</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/TambahGuruAtauGuruBesarServlet" class="nav-item active">
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
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            Tambah Guru / Guru Besar
                        </h3>
                    </div>
                    <div class="card-body">
                        <% if (error != null && !error.isEmpty()) {%>
                        <div style="background: var(--danger-light); color: var(--danger-dark); padding: 14px 18px; margin-bottom: 24px; border-left: 4px solid var(--danger); display: flex; align-items: center; gap: 12px;">
                            <span class="material-icons" style="font-size: 20px;">error_outline</span>
                            <span><%= error%></span>
                        </div>
                        <% } %>

                        <% if (success != null && success) {%>
                        <div style="background: var(--success-light); padding: 20px; margin-bottom: 24px; border-left: 4px solid var(--success);">
                            <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 16px;">
                                <span class="material-icons" style="font-size: 28px; color: #059669;">check_circle</span>
                                <strong style="font-size: 16px;">Akaun berjaya dicipta!</strong>
                            </div>

                            <div style="display: grid; grid-template-columns: 130px 1fr; gap: 12px; margin-bottom: 16px;">
                                <div style="color: var(--gray-600);">Nama Penuh:</div>
                                <div style="color: var(--gray-800);"><%= namaBaru%></div>

                                <div style="color: var(--gray-600);">Username:</div>
                                <div style="color: var(--gray-800);"><%= usernameBaru%></div>

                                <div style="color: var(--gray-600);">Kata Laluan:</div>
                                <div>
                                    <span style="background: white; padding: 4px 12px; border: 1px solid var(--gray-300); font-family: monospace; letter-spacing: 0.5px;"><%= newPassword%></span>
                                    <button onclick="copyToClipboard('<%= newPassword%>')" style="background: none; border: none; cursor: pointer; margin-left: 8px; vertical-align: middle;">
                                        <span class="material-icons" style="font-size: 18px; color: var(--gray-600);">content_copy</span>
                                    </button>
                                </div>
                            </div>

                            <p style="font-size: 13px; color: var(--gray-600); margin-top: 12px;">
                                <span class="material-icons" style="font-size: 14px; vertical-align: middle;">info</span>
                                Sila berikan maklumat ini kepada pengguna.
                            </p>
                        </div>
                        <div style="text-align: center;">
                            <a href="${pageContext.request.contextPath}/TambahGuruAtauGuruBesarServlet" class="btn-primary" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none;">
                                Tambah Lagi
                            </a>
                        </div>
                        <% } else { %>
                        <form action="${pageContext.request.contextPath}/TambahGuruAtauGuruBesarServlet" method="post">
                            <div class="form-group">
                                <label style="display: block; font-weight: 600; color: var(--gray-800);">Nama Penuh</label>
                                <input type="text" name="nama" class="form-control" placeholder="cth: Ahmad Bin Abdullah" style="width: 100%; padding: 12px; border: 1px solid var(--gray-400);" required>
                            </div>

                            <div class="form-group">
                                <label style="display: block; margin-bottom: 8px; font-weight: 600; color: var(--gray-800);">Peranan</label>
                                <select name="peranan" class="form-control" style="width: 100%; padding: 12px; border: 1px solid var(--gray-400);" required>
                                    <option value="guru">Guru</option>
                                    <option value="gurubesar">Guru Besar</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label style="display: block; margin-bottom: 8px; font-weight: 600; color: var(--gray-800);">Tadika</label>
                                <select name="kodtadika" class="form-control" style="width: 100%; padding: 12px; border: 1px solid var(--gray-400);" required>
                                    <option value="">-- Pilih Tadika --</option>
                                    <% if (senaraiTadika != null && !senaraiTadika.isEmpty()) {
                                            for (Tadika t : senaraiTadika) {%>
                                    <option value="<%= t.getKodtadika()%>"><%= t.getNamatadika()%></option>
                                    <% }
                                    } else { %>
                                    <option value="" disabled>Tiada tadika</option>
                                    <% } %>
                                </select>
                            </div>

                            <div style="margin-top: 28px; text-align: center;">
                                <button type="submit" class="btn-primary" style="padding: 12px 32px; font-size: 15px; width: 100%; justify-content: center;">
                                    Daftar Akaun
                                </button>
                            </div>
                        </form>
                        <% } %>
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

            // ==================== COPY TO CLIPBOARD ====================
            function copyToClipboard(text) {
                navigator.clipboard.writeText(text).then(function () {
                    showToast('Kata laluan disalin ke papan keratan', 'success', 2000);
                }).catch(function () {
                    showToast('Gagal menyalin', 'error', 2000);
                });
            }

            // Show messages from server
            <% if (error != null && !error.isEmpty()) {%>
            showToast('<%= error.replace("'", "\\'")%>', 'error', 4000);
            <% } %>
            <% if (success != null && success) { %>
            showToast('Akaun berjaya dicipta', 'success', 4000);
            <% }%>
        </script>
    </body>
</html>