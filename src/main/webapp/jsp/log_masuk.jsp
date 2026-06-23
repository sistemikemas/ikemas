<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>i-KEMAS</title>
        <!-- Link ke CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/log_masuk.css">
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

            <!-- Bahagian kanan - Login form -->
            <div class="right-panel">
                <div class="login-box">
                    <h2>Selamat Kembali</h2>
                    <p>Sila masukkan butiran anda untuk akses akaun.</p>

                    <%-- Paparan mesej error jika log masuk gagal --%>
                    <%
                        String error = (String) request.getAttribute("error");
                        if (error != null && !error.isEmpty()) {
                    %>
                    <div class="error-message"><%= error%></div>
                    <% } %>

                    <%-- Paparan mesej kejayaan daftar akaun --%>
                    <%
                        String registerSuccess = request.getParameter("register");
                        if ("success".equals(registerSuccess)) {
                    %>
                    <div class="error-message" style="background:#e0f2e0; border-left-color:#2E7D32; color:#2E7D32;">
                        Pendaftaran berjaya! Sila log masuk.
                    </div>
                    <% }%>

                    <form action="${pageContext.request.contextPath}/LogMasukServlet" method="post">
                        <label for="username">Username</label>
                        <input type="text" id="username" name="username" required autofocus>

                        <label for="password">Kata Laluan</label>
                        <input type="password" id="password" name="password" required>

                        <a href="${pageContext.request.contextPath}/LupaKataLaluanServlet" class="forgot-link">Lupa Kata Laluan?</a>
                        <button type="submit">Log Masuk</button>
                    </form>
                    <p class="register">Belum mempunyai akaun? 
                        <a href="${pageContext.request.contextPath}/jsp/daftar_akaun_baru.jsp">Daftar Sekarang</a>
                    </p>
                </div>
                <footer>
                    <small>© 2026 Jabatan Kemajuan Masyarakat (KEMAS)</small>
                </footer>
            </div>
        </div>
    </body>
</html>
