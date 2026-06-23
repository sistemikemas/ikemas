<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>i-KEMAS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/lupa_kata_laluan.css">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/image/logo-sistem.png">
    </head>
    <body>
        <div class="container">
            <div class="left-panel">
                <div class="overlay">
                    <div class="branding-top">
                        <h1>i-KEMAS</h1>
                        <h2>SISTEM PENGURUSAN KANAK-KANAK TABIKA KEMAS</h2>
                    </div>
                    <div class="branding-bottom">
                        <h1 class="slogan">Penggerak Kesejahteraan Masyarakat Luar Bandar</h1>
                        <p class="description">
                            Akses sistem pengurusan pendidikan awal kanak-kanak yang holistik dan bersepadu.
                        </p>
                    </div>
                </div>
            </div>

            <div class="right-panel">
                <div class="login-box">
                    <h2>Lupa Kata Laluan</h2>
                    <p>Masukkan username anda untuk menetapkan semula kata laluan.</p>

                    <%-- Mesej error di atas form --%>
                    <%
                        String error = (String) request.getAttribute("error");
                        if (error != null && !error.isEmpty()) {
                    %>
                    <div class="error-message"><%= error%></div>
                    <% } %>

                    <%-- Mesej success di atas form --%>
                    <%
                        Boolean success = (Boolean) request.getAttribute("success");
                        if (success != null && success) {
                            String newPass = (String) request.getAttribute("newPassword");
                            String uname = (String) request.getAttribute("username");
                    %>
                    <div class="success-message">
                        Kata laluan sementara untuk <strong><%= uname%></strong> telah dijana.<br>
                        <strong>Kata Laluan Sementara: <span class="new-password"><%= newPass%></span></strong><br>
                        <div class="message-line">Sila log masuk dan tukar kata laluan anda segera.</div>
                    </div>
                    <% }%>

                    <%-- Form sentiasa dipaparkan, walaupun ada success --%>
                    <form action="${pageContext.request.contextPath}/LupaKataLaluanServlet" method="post">
                        <label for="username">Username</label>
                        <input type="text" id="username" name="username" required autofocus>
                        <button type="submit">Reset Kata Laluan</button>
                    </form>

                    <p class="register">
                        <a href="${pageContext.request.contextPath}/jsp/log_masuk.jsp">Kembali ke Log Masuk</a>
                    </p>
                </div>
                <footer>
                    <small>© 2026 Jabatan Kemajuan Masyarakat (KEMAS)</small>
                </footer>
            </div>
        </div>
    </body>
</html>
