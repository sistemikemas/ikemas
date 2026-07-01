<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Pengguna, model.Tadika, java.util.List" %>
<%
    Pengguna p = (Pengguna) session.getAttribute("pengguna");
    if (p == null || !p.getPeranan().equals("ibubapa")) {
        response.sendRedirect("log_masuk.jsp");
        return;
    }
    List<Tadika> senaraiTadika = (List<Tadika>) request.getAttribute("senaraiTadika");
    if (senaraiTadika == null) {
        response.sendRedirect(request.getContextPath() + "/PermohonanServlet");
        return;
    }

    // Untuk toast message dari servlet
    String toastMessage = (String) request.getAttribute("toastMessage");
    String toastType = (String) request.getAttribute("toastType");
    if (toastType == null)
        toastType = "info";
%>
<!DOCTYPE html>
<html lang="ms">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>i-KEMAS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/permohonan.css">
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/image/logo-sistem.png">
    </head>
    <body>
        <!-- ==================== TOAST CONTAINER (OVERLAY) ==================== -->
        <div id="toastContainer" class="toast-container"></div>

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
                    <a href="#" class="nav-item active">
                        <span class="material-icons">person_add</span>
                        <span>Permohonan</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/jsp/status_permohonan.jsp" class="nav-item">
                        <span class="material-icons">assignment</span>
                        <span>Status Permohonan</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/jsp/prestasi_anak.jsp" class="nav-item">
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

            <!-- MAIN CONTENT - GUNA CLASS CARD DARI DASHBOARD -->
            <main class="main-content">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Borang Permohonan Pendaftaran</h3>
                    </div>
                    <div class="card-body">
                        <!-- Wizard Progress -->
                        <div class="wizard-progress" id="wizardProgress">
                            <div class="progress-step" data-step="1"><span class="step-circle" id="circle1">1</span> Anak</div>
                            <div class="progress-step" data-step="2"><span class="step-circle" id="circle2">2</span> Waris</div>
                            <div class="progress-step" data-step="3"><span class="step-circle" id="circle3">3</span> Bapa</div>
                            <div class="progress-step" data-step="4"><span class="step-circle" id="circle4">4</span> Ibu</div>
                            <div class="progress-step" data-step="5"><span class="step-circle" id="circle5">5</span> Tanggungan</div>
                            <div class="progress-step" data-step="6"><span class="step-circle" id="circle6">6</span> Dokumen</div>
                            <div class="progress-step" data-step="7"><span class="step-circle" id="circle7">7</span> Pengesahan</div>
                        </div>

                        <form action="${pageContext.request.contextPath}/PermohonanServlet" method="post" id="daftarForm" enctype="multipart/form-data">
                            <!-- STEP 1 -->
                            <div id="step1" class="step active">
                                <div class="section-title">MAKLUMAT ANAK</div>
                                <div class="form-group">
                                    <label>Gambar Passport</label>
                                    <input type="file" name="gambarpassport" id="gambarPassport" accept="image/png, image/jpeg, image/jpg" required>
                                    <small>Saiz maksimum 2MB. Format PNG, JPG, JPEG</small>
                                    <div id="gambarPreview" class="gambar-preview"></div>
                                </div>
                                <div class="form-row">
                                    <div class="form-group"><label>Nama Penuh</label><input type="text" name="namamurid" required></div>
                                    <div class="form-group"><label>No. MyKid</label><input type="text" name="nokad" id="nokad" onblur="autoFillTarikhLahir()" required></div>
                                </div>
                                <div class="form-row">
                                    <div class="form-group"><label>Tarikh Lahir</label><input type="date" name="tarikhlahir" id="tarikhlahir" required></div>
                                    <div class="form-group"><label>Jantina</label>
                                        <div class="radio-group">
                                            <label><input type="radio" name="jantina" value="Lelaki"> Lelaki</label>
                                            <label><input type="radio" name="jantina" value="Perempuan"> Perempuan</label>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label>Bangsa</label>
                                    <div class="radio-group">
                                        <label><input type="radio" name="bangsa" value="Melayu"> Melayu</label>
                                        <label><input type="radio" name="bangsa" value="Cina"> Cina</label>
                                        <label><input type="radio" name="bangsa" value="India"> India</label>
                                        <label><input type="radio" name="bangsa" value="Lain-lain" id="bangsaLainRadio"> Lain-lain</label>
                                    </div>
                                    <div id="bangsaLainField" style="display:none; margin-top:10px;">
                                        <input type="text" name="bangsaLain" placeholder="Sila nyatakan bangsa">
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="form-group"><label>Alamat</label><textarea name="alamat" rows="2" required></textarea></div>
                                    <div class="form-group"><label>Poskod</label><input type="text" name="poskod" required></div>
                                </div>
                                <div class="form-group">
                                    <label>Dewan Undangan Negeri (DUN)</label>
                                    <div class="radio-group">
                                        <label><input type="radio" name="dun" value="Tepoh" class="dunRadio"> Tepoh</label>
                                        <label><input type="radio" name="dun" value="Bukit Tunggal" class="dunRadio"> Bukit Tunggal</label>
                                        <label><input type="radio" name="dun" value="Seberang Takir" class="dunRadio"> Seberang Takir</label>
                                        <label><input type="radio" name="dun" value="Buluh Gading" class="dunRadio"> Buluh Gading</label>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label>Tadika</label>
                                    <select name="kodtadika" id="tadikaSelect" required disabled>
                                        <option value="">Pilih DUN terlebih dahulu</option>
                                    </select>
                                </div>
                            </div>

                            <!-- STEP 2 -->
                            <div id="step2" class="step">
                                <div class="section-title">MAKLUMAT WARIS TERDEKAT</div>
                                <div class="form-row">
                                    <div class="form-group"><label>Nama Waris</label><input type="text" name="waris_nama" required></div>
                                    <div class="form-group"><label>No. Telefon</label><input type="text" name="waris_telefon" required></div>
                                </div>
                                <div class="form-group"><label>Alamat Waris</label><textarea name="waris_alamat" rows="2" required></textarea></div>
                                <div class="form-group"><label>Hubungan dengan Murid</label><input type="text" name="waris_hubungan" required></div>
                            </div>

                            <!-- STEP 3 -->
                            <div id="step3" class="step">
                                <div class="section-title">MAKLUMAT BAPA</div>
                                <div class="form-row">
                                    <div class="form-group"><label>Nama Bapa</label><input type="text" name="namabapa" required></div>
                                    <div class="form-group"><label>No. Kad Pengenalan</label><input type="text" name="nokadpengenalanbapa" required></div>
                                </div>
                                <div class="form-group">
                                    <label>Bangsa</label>
                                    <div class="radio-group">
                                        <label><input type="radio" name="bangsabapa" value="Melayu"> Melayu</label>
                                        <label><input type="radio" name="bangsabapa" value="Cina"> Cina</label>
                                        <label><input type="radio" name="bangsabapa" value="India"> India</label>
                                        <label><input type="radio" name="bangsabapa" value="Lain-lain" id="bangsaBapaLainRadio"> Lain-lain</label>
                                    </div>
                                    <div id="bangsaBapaLainField" style="display:none; margin-top:10px;">
                                        <input type="text" name="bangsabapa_lain" placeholder="Sila nyatakan bangsa">
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="form-group"><label>No. Telefon</label><input type="text" name="notelefonbapa" required></div>
                                    <div class="form-group">
                                        <label>Status</label>
                                        <select name="statusbapa">
                                            <option value="Kahwin">Kahwin</option>
                                            <option value="Duda">Duda</option>
                                            <option value="Bujang">Bujang</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="form-group"><label>Pekerjaan</label><input type="text" name="pekerjaanbapa" required></div>
                                    <div class="form-group"><label>Pendapatan (RM)</label><input type="number" name="pendapatanbapa" step="0.01"></div>
                                </div>
                                <div class="form-group"><label>Majikan</label><input type="text" name="majikanbapa" required></div>
                            </div>

                            <!-- STEP 4 -->
                            <div id="step4" class="step">
                                <div class="section-title">MAKLUMAT IBU</div>
                                <div class="form-row">
                                    <div class="form-group"><label>Nama Ibu</label><input type="text" name="namaibu" required></div>
                                    <div class="form-group"><label>No. Kad Pengenalan</label><input type="text" name="nokadpengenalanibu" required></div>
                                </div>
                                <div class="form-group">
                                    <label>Bangsa</label>
                                    <div class="radio-group">
                                        <label><input type="radio" name="bangsaibu" value="Melayu"> Melayu</label>
                                        <label><input type="radio" name="bangsaibu" value="Cina"> Cina</label>
                                        <label><input type="radio" name="bangsaibu" value="India"> India</label>
                                        <label><input type="radio" name="bangsaibu" value="Lain-lain" id="bangsaIbuLainRadio"> Lain-lain</label>
                                    </div>
                                    <div id="bangsaIbuLainField" style="display:none; margin-top:10px;">
                                        <input type="text" name="bangsaibu_lain" placeholder="Sila nyatakan bangsa">
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="form-group"><label>No. Telefon</label><input type="text" name="notelefonibu" required></div>
                                    <div class="form-group">
                                        <label>Status</label>
                                        <select name="statusibu">
                                            <option value="Kahwin">Kahwin</option>
                                            <option value="Ibu tunggal">Ibu tunggal</option>
                                            <option value="Bujang">Bujang</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="form-group"><label>Pekerjaan</label><input type="text" name="pekerjaanibu" required></div>
                                    <div class="form-group"><label>Pendapatan (RM)</label><input type="number" name="pendapatanibu" step="0.01"></div>
                                </div>
                                <div class="form-group"><label>Majikan</label><input type="text" name="majikanibu" required></div>
                            </div>

                            <!-- STEP 5 -->
                            <div id="step5" class="step">
                                <div class="section-title">MAKLUMAT TANGGUNGAN</div>
                                <div id="tanggunganList"></div>
                                <button type="button" class="btn-secondary" id="tambahTanggunganBtn" style="background: var(--gray-600); color: white; border: none; padding: 10px 20px; border-radius: 40px; cursor: pointer;">+ Tambah Tanggungan</button>
                                <div style="margin-top:15px;">
                                    <label>Jumlah Tanggungan: <span id="jumlahTanggungan">0</span></label>
                                </div>
                                <input type="hidden" name="bilangantanggungan" id="bilanganTanggungan" value="0">
                            </div>

                            <!-- STEP 6 -->
                            <div id="step6" class="step">
                                <div class="section-title">MUAT NAIK DOKUMEN</div>
                                <div class="form-group"><label>Sijil Lahir Anak</label><input type="file" name="dokumen_sijil_lahir" accept=".pdf,.jpg,.jpeg,.png"></div>
                                <div class="form-group"><label>MyKid Anak</label><input type="file" name="dokumen_mykid" accept=".pdf,.jpg,.jpeg,.png"></div>
                                <div class="form-group"><label>Kad Pengenalan Ibu</label><input type="file" name="dokumen_ic_ibu" accept=".pdf,.jpg,.jpeg,.png"></div>
                                <div class="form-group"><label>Kad Pengenalan Bapa</label><input type="file" name="dokumen_ic_bapa" accept=".pdf,.jpg,.jpeg,.png"></div>
                                <div class="form-group"><label>Slip Gaji / Akuan Pendapatan</label><input type="file" name="dokumen_slip_gaji" accept=".pdf,.jpg,.jpeg,.png"></div>
                                <small>Format PDF, JPG, JPEG, PNG. Saiz maksimum 5MB setiap fail.</small>
                            </div>

                            <!-- STEP 7 -->
                            <div id="step7" class="step">
                                <div class="section-title">PERAKUAN & PENGESAHAN</div>
                                <div class="perakuan-box">
                                    <p>Saya mengaku bahawa semua maklumat yang diberikan adalah benar.</p>
                                    <p>Saya memahami bahawa sebarang maklumat palsu akan menyebabkan permohonan ini ditolak.</p>
                                    <label><input type="checkbox" id="sahkanCheckbox" required> Saya mengesahkan maklumat di atas adalah benar.</label>
                                </div>
                            </div>

                            <!-- Butang Wizard -->
                            <div class="wizard-buttons">
                                <button type="button" class="btn-secondary" id="prevBtn" style="display:none;">Sebelum</button>
                                <button type="button" class="btn-secondary" id="saveDrafBtn">Simpan</button>
                                <button type="button" class="btn-primary" id="nextBtn">Seterusnya</button>
                                <button type="submit" class="btn-primary" id="submitBtn" style="display:none;">Hantar Permohonan</button>
                            </div>
                        </form>
                    </div>
                </div>
            </main>
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

            // Papar toast dari servlet jika ada
            <% if (toastMessage != null && !toastMessage.isEmpty()) {%>
            showToast('<%= toastMessage%>', '<%= toastType%>', 4000);
            <% }%>

            let currentStep = 1;
            const totalSteps = 7;
            let tanggunganCount = 0;
            let tanggunganCounter = 0;

            function showStep(step) {
                for (let i = 1; i <= totalSteps; i++) {
                    const stepDiv = document.getElementById('step' + i);
                    if (stepDiv)
                        stepDiv.classList.remove('active');
                    const circle = document.getElementById('circle' + i);
                    if (circle)
                        circle.classList.remove('active');
                }
                const currentStepDiv = document.getElementById('step' + step);
                if (currentStepDiv)
                    currentStepDiv.classList.add('active');
                const currentCircle = document.getElementById('circle' + step);
                if (currentCircle)
                    currentCircle.classList.add('active');

                const prevBtn = document.getElementById('prevBtn');
                const nextBtn = document.getElementById('nextBtn');
                const submitBtn = document.getElementById('submitBtn');

                if (prevBtn)
                    prevBtn.style.display = step > 1 ? 'inline-block' : 'none';
                if (nextBtn)
                    nextBtn.style.display = step < totalSteps ? 'inline-block' : 'none';
                if (submitBtn)
                    submitBtn.style.display = step === totalSteps ? 'inline-block' : 'none';
            }

            function validateStep() {
                const stepDiv = document.getElementById('step' + currentStep);
                if (!stepDiv)
                    return true;
                const required = stepDiv.querySelectorAll('[required]');
                for (let i = 0; i < required.length; i++) {
                    if (!required[i].value.trim()) {
                        showToast('Sila lengkapkan semua maklumat yang diperlukan', 'warning', 5000);
                        required[i].focus();
                        return false;
                    }
                }
                if (currentStep === 1) {
                    const tarikh = document.getElementById('tarikhlahir').value;
                    if (tarikh) {
                        const birth = new Date(tarikh);
                        const tahunLahir = birth.getFullYear();

                        // Dapatkan tahun kemasukan dari hidden field
                        const tahunKemasukanInput = document.getElementById('tahunKemasukan');
                        if (!tahunKemasukanInput || !tahunKemasukanInput.value) {
                            showToast('Sila pilih DUN yang sesi permohonannya dibuka terlebih dahulu.', 'warning', 5000);
                            return false;
                        }

                        const tahunKemasukan = parseInt(tahunKemasukanInput.value);
                        const umurKetikaMasuk = tahunKemasukan - tahunLahir;

                        if (umurKetikaMasuk < 5 || umurKetikaMasuk > 6) {
                            showToast('Permohonan hanya untuk kanak-kanak yang berumur 5 atau 6 tahun pada tahun kemasukan ' + tahunKemasukan, 'warning', 5000);
                            return false;
                        }
                    }
                }
                if (currentStep === 7) {
                    const check = document.getElementById('sahkanCheckbox');
                    if (check && !check.checked) {
                        showToast('Sila sahkan maklumat anda.', 'warning', 5000);
                        return false;
                    }
                }
                return true;
            }

            document.getElementById('nextBtn').addEventListener('click', function () {
                if (validateStep() && currentStep < totalSteps) {
                    currentStep++;
                    showStep(currentStep);
                }
            });

            document.getElementById('prevBtn').addEventListener('click', function () {
                if (currentStep > 1) {
                    currentStep--;
                    showStep(currentStep);
                }
            });

            window.autoFillTarikhLahir = function () {
                let nokad = document.getElementById('nokad').value;
                if (nokad.length >= 6) {
                    let tahun = nokad.substring(0, 2);
                    let bulan = nokad.substring(2, 4);
                    let hari = nokad.substring(4, 6);
                    let fullYear = (parseInt(tahun) >= 0 && parseInt(tahun) <= 30) ? 2000 + parseInt(tahun) : 1900 + parseInt(tahun);
                    let tarikh = fullYear + '-' + bulan + '-' + hari;
                    let dateObj = new Date(tarikh);
                    if (!isNaN(dateObj.getTime()))
                        document.getElementById('tarikhlahir').value = tarikh;
                }
            };

            // ==================== SEMAK STATUS SESI APABILA PILIH DUN ====================

            // Fungsi untuk semak status sesi dari pangkalan data
            function checkSesiStatus(dun) {
                return fetch('${pageContext.request.contextPath}/SesiPermohonanServlet?dun=' + encodeURIComponent(dun) + '&_=' + new Date().getTime())
                        .then(response => {
                            if (!response.ok) {
                                throw new Error('HTTP error ' + response.status);
                            }
                            return response.json();
                        })
                        .then(data => {
                            console.log('Sesi status:', data);
                            return data;
                        })
                        .catch(error => {
                            console.error('Error checking session:', error);
                            return {status: 'tutup', tahun: null};
                        });
            }

            // Dapatkan semua radio button DUN dan dropdown tadika
            const dunRadios = document.querySelectorAll('.dunRadio');
            const tadikaSelect = document.getElementById('tadikaSelect');

            if (dunRadios.length > 0 && tadikaSelect) {
                dunRadios.forEach(radio => {
                    // Apabila radio button DUN dipilih
                    radio.addEventListener('change', async function () {
                        const dun = this.value;

                        // Langkah 1: Semak sama ada sesi permohonan dibuka untuk DUN ini
                        const sesiStatus = await checkSesiStatus(dun);

                        // Langkah 2: Jika sesi TUTUP, tolak permohonan
                        if (sesiStatus.status !== 'buka') {
                            showToast('Maaf, tiada sesi permohonan dibuka untuk Dewan Undangan Negeri (DUN) ' + dun + '.', 'error', 5000);
                            this.checked = false;  // Batalkan pilihan radio
                            tadikaSelect.disabled = true;
                            tadikaSelect.innerHTML = '<option value="">Pilih DUN terlebih dahulu</option>';
                            return;  // Hentikan proses
                        }

                        // Langkah 3: Jika sesi BUKA, tunjuk toast dengan tahun
                        if (sesiStatus.tahun) {
                            showToast('Sesi permohonan tahun ' + sesiStatus.tahun + ' untuk Dewan Undangan Negeri (DUN) ' + dun + ' dibuka.', 'success', 5000);

                            // Simpan tahun ke hidden field untuk dihantar ke servlet
                            if (!document.getElementById('tahunKemasukan')) {
                                const hiddenTahun = document.createElement('input');
                                hiddenTahun.type = 'hidden';
                                hiddenTahun.name = 'tahunKemasukan';
                                hiddenTahun.id = 'tahunKemasukan';
                                hiddenTahun.value = sesiStatus.tahun;
                                document.getElementById('daftarForm').appendChild(hiddenTahun);
                            } else {
                                document.getElementById('tahunKemasukan').value = sesiStatus.tahun;
                            }
                        }

                        // Langkah 4: Muat naik senarai tadika untuk DUN yang dipilih
                        tadikaSelect.disabled = true;
                        tadikaSelect.innerHTML = '<option value="">Loading...</option>';
                        fetch('${pageContext.request.contextPath}/GetTadikaByDunServlet?dun=' + encodeURIComponent(dun))
                                .then(response => response.text())
                                .then(data => {
                                    tadikaSelect.innerHTML = data;
                                    tadikaSelect.disabled = false;
                                })
                                .catch(() => {
                                    tadikaSelect.innerHTML = '<option value="">Ralat</option>';
                                    tadikaSelect.disabled = false;
                                    showToast('Gagal memuatkan senarai tadika. Sila cuba lagi.', 'error', 5000);
                                });
                    });
                });
            }

            document.getElementById('gambarPassport')?.addEventListener('change', function (e) {
                const file = e.target.files[0];
                if (file) {
                    const reader = new FileReader();
                    reader.onload = function (ev) {
                        const preview = document.getElementById('gambarPreview');
                        if (preview)
                            preview.innerHTML = '<img src="' + ev.target.result + '" class="preview-img">';
                    };
                    reader.readAsDataURL(file);
                }
            });

            function updateTanggunganCount() {
                const items = document.querySelectorAll('.tanggungan-item');
                tanggunganCount = items.length;
                document.getElementById('jumlahTanggungan').innerText = tanggunganCount;
                document.getElementById('bilanganTanggungan').value = tanggunganCount;
            }

            function addTanggungan() {
                const container = document.getElementById('tanggunganList');
                if (!container)
                    return;
                const idx = tanggunganCounter;
                tanggunganCounter++;
                const div = document.createElement('div');
                div.className = 'tanggungan-item';
                div.innerHTML = '<div class="form-row">' +
                        '<div class="form-group"><label>Nama</label><input type="text" name="tanggungan_nama_' + idx + '" required></div>' +
                        '<div class="form-group"><label>Umur</label><input type="number" name="tanggungan_umur_' + idx + '" required min="0"></div>' +
                        '<div class="form-group"><label>Hubungan</label><select name="tanggungan_hubungan_' + idx + '"><option value="Anak">Anak</option><option value="Isteri">Isteri</option><option value="Suami">Suami</option><option value="Lain-lain">Lain-lain</option></select></div>' +
                        '</div><button type="button" class="btn-secondary" onclick="removeTanggungan(this)" style="margin-top:5px; background:var(--gray-600); padding:6px 15px;">Padam</button>';
                container.appendChild(div);
                updateTanggunganCount();
            }

            window.removeTanggungan = function (btn) {
                btn.parentElement.remove();
                updateTanggunganCount();
            };

            document.getElementById('tambahTanggunganBtn')?.addEventListener('click', addTanggungan);

            document.getElementById('bangsaLainRadio')?.addEventListener('change', function () {
                document.getElementById('bangsaLainField').style.display = this.checked ? 'block' : 'none';
            });
            document.getElementById('bangsaBapaLainRadio')?.addEventListener('change', function () {
                document.getElementById('bangsaBapaLainField').style.display = this.checked ? 'block' : 'none';
            });
            document.getElementById('bangsaIbuLainRadio')?.addEventListener('change', function () {
                document.getElementById('bangsaIbuLainField').style.display = this.checked ? 'block' : 'none';
            });

            // ==================== SIMPAN DRAF ====================
            document.getElementById('saveDrafBtn').addEventListener('click', function () {
                // Kumpul data dari step semasa
                const formData = new FormData(document.getElementById('daftarForm'));
                formData.append('action', 'draf');
                formData.append('currentStep', currentStep);

                fetch('${pageContext.request.contextPath}/PermohonanServlet', {
                    method: 'POST',
                    body: formData
                })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                showToast('Permohonan disimpan.', 'success', 5000);
                            } else {
                                showToast('Gagal menyimpan permohonan', 'error', 5000);
                            }
                        });
            });

            showStep(1);

            // ==================== REDIRECT SELEPAS TOAST DI STEP 7 ====================
            <% if (request.getAttribute("redirectAfterToast") != null) {%>
            // Pastikan step 7 aktif
            showStep(7);

            // Papar toast di step 7
            showToast('<%= request.getAttribute("toastMessag")%>', '<%= request.getAttribute("toastType")%>', 5000);

            // Selepas 5 saat, redirect ke status permohonan
            setTimeout(function () {
                window.location.href = '${pageContext.request.contextPath}/jsp/status_permohonan.jsp';
            }, 5000);
            <% }%>
        </script>
    </body>
</html>