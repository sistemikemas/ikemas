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
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/status_permohonan.css">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/image/logo-sistem.png">
    </head>
    <body>
        <div class="dashboard">
            <!-- SIDEBAR -->
            <aside class="sidebar">
                <div class="sidebar-header">
                    <div class="logo"><h2>i-KEMAS</h2></div>
                    <p>SISTEM PENGURUSAN KANAK-KANAK<br>TABIKA KEMAS</p>
                </div>
                <nav class="nav-menu">
                    <a href="${pageContext.request.contextPath}/jsp/dashboard_ibubapa.jsp" class="nav-item"><span class="material-icons">dashboard</span><span>Dashboard</span></a>
                    <a href="${pageContext.request.contextPath}/jsp/permohonan.jsp" class="nav-item"><span class="material-icons">person_add</span><span>Permohonan</span></a>
                    <a href="#" class="nav-item active"><span class="material-icons">assignment</span><span>Status Permohonan</span></a>
                    <a href="${pageContext.request.contextPath}/jsp/prestasi_anak.jsp" class="nav-item"><span class="material-icons">bar_chart</span><span>Prestasi Anak</span></a>
                    <a href="${pageContext.request.contextPath}/ProfilIbuBapaServlet" class="nav-item"><span class="material-icons">person</span><span>Profil Saya</span></a>
                </nav>
                <div class="sidebar-footer">
                    <a href="${pageContext.request.contextPath}/LogKeluarServlet" class="nav-item logout"><span class="material-icons">logout</span><span>Log Keluar</span></a>
                </div>
            </aside>

            <!-- TOP BAR -->
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

            <!-- MAIN CONTENT -->
            <main class="main-content">
                <div id="loadingState" class="loading-state">
                    <div class="spinner"></div>
                    <p>Memuatkan data...</p>
                </div>
                <div id="contentState" style="display: none;">
                    <!-- Draf Permohonan -->
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">Permohonan Belum Lengkap</h3>
                            <span class="status-badge status-draf" id="drafCount">0</span>
                        </div>
                        <div class="table-wrapper">
                            <table class="data-table">
                                <thead><tr><th>Tarikh Mohon</th><th>No. MyKid</th><th>Nama Murid</th><th>Tadika</th><th>Status</th><th>Tindakan</th></tr></thead>
                                <tbody id="drafBody"><tr><td colspan="6" class="text-center">Tiada permohonan</td></tr></tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Permohonan Dalam Proses -->
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">Permohonan Dalam Proses</h3>
                            <span class="status-badge status-dalamproses" id="dalamProsesCount">0</span>
                        </div>
                        <div class="table-wrapper">
                            <table class="data-table">
                                <thead><tr><th>Tarikh Mohon</th><th>No. MyKid</th><th>Nama Murid</th><th>Tadika</th><th>Status</th><th>Tindakan</th></tr></thead>
                                <tbody id="dalamProsesBody"><tr><td colspan="6" class="text-center">Tiada permohonan</td></tr></tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Sejarah Permohonan -->
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">Sejarah Permohonan</h3>
                            <div class="badge-group">
                                <span class="status-badge status-lulus" id="sejarahLulusCount">0</span>
                                <span class="status-badge status-tolak" id="sejarahTolakCount">0</span>
                                <span class="status-badge status-sejarah" id="sejarahCount">0</span>
                            </div>
                        </div>
                        <div class="table-wrapper">
                            <table class="data-table">
                                <thead><tr><th>Tarikh Mohon</th><th>No. MyKid</th><th>Nama Murid</th><th>Tadika</th><th>Status</th><th>Catatan</th></tr></thead>
                                <tbody id="sejarahBody"><tr><td colspan="6" class="text-center">Tiada permohonan</td></tr></tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </main>
        </div>

        <!-- ==================== MODAL CONFIRMATION ==================== -->
        <div id="deleteModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Pengesahan</h3>
                    <button class="modal-close" onclick="closeModal()">&times;</button>
                </div>
                <div class="modal-body">
                    <p>Anda pasti mahu memadam permohonan ini?</p>
                </div>
                <div class="modal-footer">
                    <button class="btn-primary" id="confirmDeleteBtn">Padam</button>
                    <button class="btn-secondary" onclick="closeModal()">Batal</button>

                </div>
            </div>
        </div>

        <!-- TOAST CONTAINER (OVERLAY) - SAMA DENGAN PERMOHONAN.JSP -->
        <div id="toastContainer" class="toast-container"></div>

        <script>
            // ==================== TOAST NOTIFICATION (OVERLAY) ====================
            function showToast(message, type, duration) {
                type = type || 'info';
                duration = duration || 5000;
                var container = document.getElementById('toastContainer');
                if (!container)
                    return;

                var toast = document.createElement('div');
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

            function formatDate(dateString) {
                if (!dateString)
                    return '-';
                var parts = dateString.split('-');
                return parts.length === 3 ? parts[2] + '-' + parts[1] + '-' + parts[0] : dateString;
            }

            function formatStatus(status) {
                if (!status)
                    return '-';
                var s = status.toLowerCase();
                if (s === 'draf')
                    return '<span class="status-badge status-draf">Draf</span>';
                if (s === 'dalamproses')
                    return '<span class="status-badge status-dalamproses">Dalam Proses</span>';
                if (s === 'lulus')
                    return '<span class="status-badge status-lulus">Lulus</span>';
                if (s === 'tolak')
                    return '<span class="status-badge status-tolak">Ditolak</span>';
                return '<span class="status-badge">' + status + '</span>';
            }

            function capitalizeEachWord(str) {
                if (!str)
                    return '-';
                return str.toLowerCase().split(' ').map(function (word) {
                    return word.charAt(0).toUpperCase() + word.slice(1);
                }).join(' ');
            }

            function loadData() {
                document.getElementById('loadingState').style.display = 'flex';
                document.getElementById('contentState').style.display = 'none';

                fetch('${pageContext.request.contextPath}/StatusPermohonanServlet')
                        .then(function (response) {
                            return response.json();
                        })
                        .then(function (data) {
                            document.getElementById('drafCount').innerText = data.draf ? data.draf.length : 0;
                            document.getElementById('dalamProsesCount').innerText = data.dalamProses ? data.dalamProses.length : 0;
                            document.getElementById('sejarahCount').innerText = data.sejarah ? data.sejarah.length : 0;

                            // Draf Table
                            var drafBody = document.getElementById('drafBody');
                            if (data.draf && data.draf.length > 0) {
                                var rows = '';
                                for (var i = 0; i < data.draf.length; i++) {
                                    var item = data.draf[i];
                                    rows += '<tr>' +
                                            '<td>' + formatDate(item.tarikh) + '</td>' +
                                            '<td>' + (item.nokad || '-') + '</td>' +
                                            '<td>' + capitalizeEachWord(item.namamurid || '-') + '</td>' +
                                            '<td>' + capitalizeEachWord(item.tadika || '-') + '</td>' +
                                            '<td>' + formatStatus(item.status) + '</td>' +
                                            '<td class="action-buttons">' +
                                            '<button class="btn-icon btn-edit" onclick="editPermohonan(' + item.idpermohonan + ')" title="Edit"><span class="material-icons">edit</span></button>' +
                                            '<button class="btn-icon btn-delete" onclick="deletePermohonan(' + item.idpermohonan + ')" title="Padam"><span class="material-icons">delete</span></button>' +
                                            '</td>' +
                                            '</tr>';
                                }
                                drafBody.innerHTML = rows;
                            } else {
                                drafBody.innerHTML = '<tr><td colspan="6" class="text-center">Tiada permohonan</td></tr>';
                            }

                            // Dalam Proses Table
                            var dalamProsesBody = document.getElementById('dalamProsesBody');
                            if (data.dalamProses && data.dalamProses.length > 0) {
                                var rows2 = '';
                                for (var j = 0; j < data.dalamProses.length; j++) {
                                    var item2 = data.dalamProses[j];
                                    rows2 += '<tr>' +
                                            '<td>' + formatDate(item2.tarikh) + '</td>' +
                                            '<td>' + (item2.nokad || '-') + '</td>' +
                                            '<td>' + capitalizeEachWord(item2.namamurid || '-') + '</td>' +
                                            '<td>' + capitalizeEachWord(item2.tadika || '-') + '</td>' +
                                            '<td>' + formatStatus(item2.status) + '</td>' +
                                            '<td><button class="btn-icon" onclick="showToast(\'Permohonan sedang diproses oleh pihak tadika\', \'info\')" title="Detail"><span class="material-icons">info</span></button></td>' +
                                            '</tr>';
                                }
                                dalamProsesBody.innerHTML = rows2;
                            } else {
                                dalamProsesBody.innerHTML = '<tr><td colspan="6" class="text-center">Tiada permohonan</td></tr>';
                            }

                            // Sejarah Table - GUNA catatanpenolakan dari database
                            var sejarahBody = document.getElementById('sejarahBody');
                            var sejarahData = data.sejarah || [];

// DEBUG: Semak data yang diterima
                            console.log('Sejarah Data:', sejarahData);

// Kira jumlah LULUS dan TOLAK
                            var lulusCount = 0;
                            var tolakCount = 0;

                            for (var k = 0; k < sejarahData.length; k++) {
                                var status = sejarahData[k].status;
                                console.log('Item ' + k + ' - Status:', status, 'Catatan:', sejarahData[k].catatanpenolakan);

                                if (status && status.toLowerCase() === 'lulus') {
                                    lulusCount++;
                                } else if (status && status.toLowerCase() === 'tolak') {
                                    tolakCount++;
                                }
                            }

// Set badge counts
                            document.getElementById('sejarahLulusCount').innerText = lulusCount;
                            document.getElementById('sejarahTolakCount').innerText = tolakCount;
                            document.getElementById('sejarahCount').innerText = sejarahData.length;

// Populate table
                            if (sejarahData.length > 0) {
                                var rows3 = '';
                                for (var k = 0; k < sejarahData.length; k++) {
                                    var item3 = sejarahData[k];

                                    // LOGIK YANG BETUL:
                                    // Jika status TOLAK -> papar catatanpenolakan
                                    // Jika status LULUS -> papar "-"
                                    var catatan = '-';
                                    var statusLower = item3.status ? item3.status.toLowerCase() : '';

                                    if (statusLower === 'tolak') {
                                        // Untuk status TOLAK, ambil dari database
                                        catatan = item3.catatanpenolakan || 'Tiada catatan. Sila hubungi pihak tadika.';
                                        catatan = '<span class="catatan-tolak">' + catatan + '</span>';
                                    } else if (statusLower === 'lulus') {
                                        // Untuk status LULUS, sentiasa "-"
                                        catatan = '-';
                                    } else {
                                        catatan = item3.catatan || '-';
                                    }

                                    console.log('Row ' + k + ' - Status:', statusLower, 'Catatan yg dipapar:', catatan);

                                    rows3 += '<tr>' +
                                            '<td>' + formatDate(item3.tarikh) + '</td>' +
                                            '<td>' + (item3.nokad || '-') + '</td>' +
                                            '<td>' + capitalizeEachWord(item3.namamurid || '-') + '</td>' +
                                            '<td>' + capitalizeEachWord(item3.tadika || '-') + '</td>' +
                                            '<td>' + formatStatus(item3.status) + '</td>' +
                                            '<td>' + catatan + '</td>' +
                                            '</tr>';
                                }
                                sejarahBody.innerHTML = rows3;
                            } else {
                                sejarahBody.innerHTML = '<tr><td colspan="6" class="text-center">Tiada permohonan</td></tr>';
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

            document.addEventListener('DOMContentLoaded', loadData);

            // ==================== EDIT DRAF ====================
            function editPermohonan(idPermohonan) {
                // Redirect ke halaman permohonan dengan parameter id
                window.location.href = '${pageContext.request.contextPath}/jsp/permohonan.jsp?edit=' + idPermohonan;
            }

            // ==================== DELETE DRAF DENGAN MODAL ====================
            let currentDeleteId = null;

            function deletePermohonan(idPermohonan) {
                currentDeleteId = idPermohonan;
                document.getElementById('deleteModal').style.display = 'flex';
            }

            function closeModal() {
                document.getElementById('deleteModal').style.display = 'none';
                currentDeleteId = null;
            }

            // Confirm delete button
            document.getElementById('confirmDeleteBtn').addEventListener('click', function () {
                if (currentDeleteId) {
                    fetch('${pageContext.request.contextPath}/PermohonanServlet?action=delete&id=' + currentDeleteId, {
                        method: 'GET'
                    })
                            .then(response => response.json())
                            .then(data => {
                                closeModal();
                                if (data.success) {
                                    showToast('Draf permohonan berjaya dipadam.', 'success');
                                    loadData(); // Refresh senarai
                                } else {
                                    showToast('Gagal memadam draf: ' + (data.message || 'Sila cuba lagi'), 'error');
                                }
                            })
                            .catch(error => {
                                closeModal();
                                console.error('Error:', error);
                                showToast('Ralat semasa memadam draf. Sila cuba lagi.', 'error');
                            });
                }
            });
        </script>
    </body>
</html>