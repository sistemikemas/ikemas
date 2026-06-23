package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;
import javax.servlet.http.HttpSession;

@WebFilter("/*") // Apply to all requests
public class SecurityFilter implements Filter {

    private static final String ANTI_BACK_SCRIPT
            = "<script type=\"text/javascript\">\n"
            + "    history.pushState(null, null, location.href);\n"
            + "    window.onpopstate = function () {\n"
            + "        history.go(1);\n"
            + "    };\n"
            + "</script>\n";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        // Set no-cache headers
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setHeader("Expires", "0");

        String path = req.getServletPath();

        // Public paths (no session check, no script injection)
        boolean isPublicPath = path.startsWith("/jsp/log_masuk.jsp")
                || path.startsWith("/jsp/daftar_akaun_baru.jsp")
                || path.startsWith("/jsp/lupa_kata_laluan.jsp")
                || path.equals("/LogMasukServlet")
                || path.equals("/DaftarAkaunBaruServlet")
                || path.equals("/LupaKataLaluanServlet") 
                || path.startsWith("/css/")
                || path.startsWith("/image/");

        if (isPublicPath) {
            chain.doFilter(request, response);
            return;
        }

        // Check session for protected paths
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("pengguna") == null) {
            res.sendRedirect(req.getContextPath() + "/jsp/log_masuk.jsp");
            return;
        }

        // Wrap response to inject script
        CharResponseWrapper wrapper = new CharResponseWrapper((HttpServletResponse) response);
        chain.doFilter(request, wrapper);

        // Get the original content
        String originalContent = wrapper.toString();

        // Inject script before </head> or before <body>
        String modifiedContent = originalContent;
        if (originalContent.contains("</head>")) {
            modifiedContent = originalContent.replace("</head>", ANTI_BACK_SCRIPT + "</head>");
        } else if (originalContent.contains("<body")) {
            modifiedContent = originalContent.replace("<body", ANTI_BACK_SCRIPT + "<body");
        }

        // Write modified content
        response.setContentType("text/html;charset=UTF-8");
        response.setContentLength(modifiedContent.length());
        PrintWriter out = response.getWriter();
        out.write(modifiedContent);
        out.close();
    }

    @Override
    public void destroy() {
    }

    // Helper class to capture response content
    static class CharResponseWrapper extends HttpServletResponseWrapper {

        private StringWriter sw = new StringWriter();

        public CharResponseWrapper(HttpServletResponse response) {
            super(response);
        }

        @Override
        public PrintWriter getWriter() throws IOException {
            return new PrintWriter(sw);
        }

        @Override
        public String toString() {
            return sw.toString();
        }
    }
}
