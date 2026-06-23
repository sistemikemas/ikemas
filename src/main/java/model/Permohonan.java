package model;

import java.sql.Date;

public class Permohonan {

    private int idpermohonan;
    private String nokadpengenalanmurid;
    private String kodtadika;
    private Date tarikhpermohonan;
    private int tahunkemasukan;
    private String statuspermohonan;
    private Integer idgurubesaryanglulus;
    private String catatanpenolakan;

    // Getter Setter
    public int getIdpermohonan() {
        return idpermohonan;
    }

    public void setIdpermohonan(int idpermohonan) {
        this.idpermohonan = idpermohonan;
    }

    public String getNokadpengenalanmurid() {
        return nokadpengenalanmurid;
    }

    public void setNokadpengenalanmurid(String nokadpengenalanmurid) {
        this.nokadpengenalanmurid = nokadpengenalanmurid;
    }

    public String getKodtadika() {
        return kodtadika;
    }

    public void setKodtadika(String kodtadika) {
        this.kodtadika = kodtadika;
    }

    public Date getTarikhpermohonan() {
        return tarikhpermohonan;
    }

    public void setTarikhpermohonan(Date tarikhpermohonan) {
        this.tarikhpermohonan = tarikhpermohonan;
    }

    public int getTahunkemasukan() {
        return tahunkemasukan;
    }

    public void setTahunkemasukan(int tahunkemasukan) {
        this.tahunkemasukan = tahunkemasukan;
    }

    public String getStatuspermohonan() {
        return statuspermohonan;
    }

    public void setStatuspermohonan(String statuspermohonan) {
        this.statuspermohonan = statuspermohonan;
    }

    public Integer getIdgurubesaryanglulus() {
        return idgurubesaryanglulus;
    }

    public void setIdgurubesaryanglulus(Integer idgurubesaryanglulus) {
        this.idgurubesaryanglulus = idgurubesaryanglulus;
    }

    public String getCatatanpenolakan() {
        return catatanpenolakan;
    }

    public void setCatatanpenolakan(String catatanpenolakan) {
        this.catatanpenolakan = catatanpenolakan;
    }
}
