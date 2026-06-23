package util;

import java.util.HashMap;
import java.util.Map;

/**
 * Kelas utiliti untuk memetakan nama Dewan Undangan Negeri (DUN)
 */
public class DewanUndanganNegeri {

    // Peta pemetaan nama DUN kepada nama piawai
    private static final Map<String, String> PEMETAAN_DUN = new HashMap<>();

    static {
        // ==================== DUN INDIVIDU ====================
        // Tepoh
        PEMETAAN_DUN.put("TEPOH", "TEPOH");
        PEMETAAN_DUN.put("Tepoh", "TEPOH");
        PEMETAAN_DUN.put("tepoh", "TEPOH");

        // Bukit Tunggal
        PEMETAAN_DUN.put("BUKIT TUNGGAL", "BUKIT TUNGGAL");
        PEMETAAN_DUN.put("Bukit Tunggal", "BUKIT TUNGGAL");
        PEMETAAN_DUN.put("bukit tunggal", "BUKIT TUNGGAL");

        // Seberang Takir
        PEMETAAN_DUN.put("SEBERANG TAKIR", "SEBERANG TAKIR");
        PEMETAAN_DUN.put("Seberang Takir", "SEBERANG TAKIR");
        PEMETAAN_DUN.put("seberang takir", "SEBERANG TAKIR");

        // Buluh Gading
        PEMETAAN_DUN.put("BULUH GADING", "BULUH GADING");
        PEMETAAN_DUN.put("Buluh Gading", "BULUH GADING");
        PEMETAAN_DUN.put("buluh gading", "BULUH GADING");

        // ==================== GABUNGAN UNTUK PENYELIA ====================
        PEMETAAN_DUN.put("Tepoh Bukit Tunggal", null);
        PEMETAAN_DUN.put("Seberang Takir Buluh Gading", null);
    }

    /**
     * Dapatkan nama DUN piawai untuk DUN individu
     */
    public static String getStandardDUN(String dunInput) {
        if (dunInput == null || dunInput.trim().isEmpty()) {
            return null;
        }

        if (PEMETAAN_DUN.containsKey(dunInput)) {
            return PEMETAAN_DUN.get(dunInput);
        }

        return dunInput.toUpperCase();
    }

    // Untuk penyelia: pecahkan gabungan DUN kepada DUN individu
    public static String[] pecahkanDUN(String dunInput) {
        if ("Tepoh Bukit Tunggal".equalsIgnoreCase(dunInput)) {
            return new String[]{"TEPOH", "BUKIT TUNGGAL"};
        }
        if ("Seberang Takir Buluh Gading".equalsIgnoreCase(dunInput)) {
            return new String[]{"SEBERANG TAKIR", "BULUH GADING"};
        }
        // Jika DUN individu, kembalikan standard DUN
        String standard = getStandardDUN(dunInput);
        if (standard != null) {
            return new String[]{standard};
        }
        return new String[]{dunInput.toUpperCase()};
    }
}
