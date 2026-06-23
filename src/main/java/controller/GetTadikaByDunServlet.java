package controller;

import dao.TadikaDAO;
import model.Tadika;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/GetTadikaByDunServlet")
public class GetTadikaByDunServlet extends HttpServlet {

    private TadikaDAO tadikaDAO = new TadikaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String dun = request.getParameter("dun");
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        List<Tadika> list = tadikaDAO.getTadikaByDun(dun);
        
        // Keluarkan option pertama
        out.println("<option value=''>Pilih Tadika</option>");
        
        // Loop setiap tadika dan tukar nama kepada capital each word
        for (Tadika t : list) {
            String namaTadikaCapitalized = capitalizeEachWord(t.getNamatadika());
            out.println("<option value='" + t.getKodtadika() + "'>" + namaTadikaCapitalized + "</option>");
        }
    }
    
    /**
     * FUNGSI: Tukar setiap perkataan kepada Capital Each Word
     * TAPI kekalkan huruf besar untuk singkatan tertentu
     * 
     * CONTOH: 
     * - "TABIKA KEMAS (NKRA)" -> "Tabika Kemas (NKRA)"
     * - "TABIKA KEMAS AN-NUR" -> "Tabika Kemas An-Nur"
     * - "TABIKA KEMAS BESTARI PIBG" -> "Tabika Kemas Bestari PIBG"
     */
    private String capitalizeEachWord(String str) {
        // Jika string kosong, return empty
        if (str == null || str.trim().isEmpty()) {
            return "";
        }
        
        // SENARAI SINGKATAN YANG PERLU KEKAL HURUF BESAR
        // Boleh tambah singkatan lain mengikut keperluan
        Set<String> uppercaseExceptions = new HashSet<>(Arrays.asList(
            "NKRA"
        ));
        
        // Tukar kepada huruf kecil dahulu
        String[] words = str.toLowerCase().split(" ");
        StringBuilder result = new StringBuilder();
        
        for (String word : words) {
            if (word.length() > 0) {
                
                // HANDLE PERKATAAN DENGAN TANDA SEMPANG (contoh: an-nur)
                if (word.contains("-")) {
                    String[] parts = word.split("-");
                    StringBuilder hyphenWord = new StringBuilder();
                    
                    for (String part : parts) {
                        if (part.length() > 0) {
                            // Semak jika part adalah singkatan
                            if (uppercaseExceptions.contains(part.toUpperCase())) {
                                hyphenWord.append(part.toUpperCase());
                            } else {
                                hyphenWord.append(Character.toUpperCase(part.charAt(0)))
                                          .append(part.substring(1));
                            }
                        }
                        hyphenWord.append("-");
                    }
                    
                    // Buang hyphen terakhir
                    if (hyphenWord.length() > 0) {
                        result.append(hyphenWord.substring(0, hyphenWord.length() - 1));
                    }
                    
                } 
                // HANDLE PERKATAAN DALAM KURUNGAN (contoh: (nkra))
                else if (word.startsWith("(") && word.endsWith(")")) {
                    String inner = word.substring(1, word.length() - 1);
                    if (uppercaseExceptions.contains(inner.toUpperCase())) {
                        result.append("(").append(inner.toUpperCase()).append(")");
                    } else {
                        String capitalized = Character.toUpperCase(inner.charAt(0)) + inner.substring(1);
                        result.append("(").append(capitalized).append(")");
                    }
                }
                // HANDLE PERKATAAN BIASA
                else {
                    // Semak jika perkataan adalah singkatan yang perlu kekal besar
                    if (uppercaseExceptions.contains(word.toUpperCase())) {
                        result.append(word.toUpperCase());
                    } else {
                        result.append(Character.toUpperCase(word.charAt(0)))
                              .append(word.substring(1));
                    }
                }
                
                result.append(" ");
            }
        }
        
        // Buang space di hujung dan return
        return result.toString().trim();
    }
}