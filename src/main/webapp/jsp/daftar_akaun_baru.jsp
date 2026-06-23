<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>i-KEMAS</title>
        <!-- Link ke CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/daftar_akaun_baru.css">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/image/logo-sistem.png">
    </head>

    <body>
        <div class="container">
            <!-- Bahagian kiri -->
            <div class="left-panel">
                <div class="overlay">
                    <!-- Branding top -->
                    <div class="branding-top">
                        <h1>i-KEMAS</h1>
                        <h2>SISTEM PENGURUSAN KANAK-KANAK TABIKA KEMAS</h2>
                    </div>

                    <!-- Branding bottom -->
                    <div class="branding-bottom">
                        <h1 class="slogan">
                            Penggerak Kesejahteraan Masyarakat Luar Bandar
                        </h1>
                        <p class="description">
                            Akses sistem pengurusan pendidikan awal kanak-kanak yang holistik dan bersepadu.
                        </p>
                    </div>
                </div>
            </div>

            <!-- Bahagian kanan - Register form -->
            <div class="right-panel">
                <div class="login-box">
                    <h2>Daftar Akaun Baru</h2>
                    <p>Mohon ibu bapa lengkapkan maklumat di bawah untuk mendaftar akaun.</p>

                    <%-- Paparan mesej error dari server --%>
                    <%
                        String error = (String) request.getAttribute("error");
                        if (error != null && !error.isEmpty()) {
                    %>
                    <div class="error-message"><%= error%></div>
                    <% }%>

                    <%-- Paparan mesej error dari client-side (JS) --%>
                    <div id="errorBox" class="error-message" style="display:none;"></div>

                    <form action="${pageContext.request.contextPath}/DaftarAkaunBaruServlet" method="post" onsubmit="return validatePassword();">
                        <label for="nama">Nama Penuh</label>
                        <input type="text" id="nama" name="nama" required>

                        <label for="username">Username</label>
                        <input type="text" id="username" name="username" required>

                        <label for="katalaluan">Kata Laluan</label>
                        <input type="password" id="katalaluan" name="katalaluan" required>

                        <label for="confirmPassword">Sahkan Kata Laluan</label>
                        <input type="password" id="confirmPassword" name="confirmPassword" required>

                        <button type="submit">Daftar</button>
                    </form>
                    <p class="register">Sudah mempunyai akaun? 
                        <a href="${pageContext.request.contextPath}/jsp/log_masuk.jsp">Log Masuk</a>
                    </p>
                </div>
                <footer>
                    <small>© 2026 Jabatan Kemajuan Masyarakat (KEMAS)</small>
                </footer>
            </div>
        </div>

        <!-- Script untuk validasi -->
        <script>
            // Pastikan hanya nombor dan maksimum 11 digit untuk telefon
            document.getElementById('notelefon').addEventListener('input', function () {
                this.value = this.value.replace(/[^0-9]/g, '');
                if (this.value.length > 11) {
                    this.value = this.value.slice(0, 11);
                }
            });

            // Semakan kata laluan dan sahkan kata laluan
            function validatePassword() {
                var password = document.getElementById("katalaluan").value;
                var confirmPassword = document.getElementById("confirmPassword").value;
                var errorBox = document.getElementById("errorBox");

                if (password !== confirmPassword) {
                    errorBox.style.display = "block";
                    errorBox.innerText = "Kata laluan dan pengesahan tidak sepadan.";
                    return false; // hentikan submit
                } else {
                    errorBox.style.display = "none";
                }
                return true;
            }
        </script>
    </body>
</html>
