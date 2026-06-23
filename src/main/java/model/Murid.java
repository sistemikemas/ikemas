package model;

import java.sql.Date;

public class Murid {

    private String nokadpengenalan;
    private int idibubapa;
    private String namamurid;
    private Date tarikhlahir;
    private int umur;
    private String jantina;
    private String bangsa;
    private String alamat;
    private String poskod;
    private String kodtadika;
    private int tahunmasuk;
    private String gambarpassport;

    // Getter Setter
    public String getNokadpengenalan() {
        return nokadpengenalan;
    }

    public void setNokadpengenalan(String nokadpengenalan) {
        this.nokadpengenalan = nokadpengenalan;
    }

    public int getIdibubapa() {
        return idibubapa;
    }

    public void setIdibubapa(int idibubapa) {
        this.idibubapa = idibubapa;
    }

    public String getNamamurid() {
        return namamurid;
    }

    public void setNamamurid(String namamurid) {
        this.namamurid = namamurid;
    }

    public Date getTarikhlahir() {
        return tarikhlahir;
    }

    public void setTarikhlahir(Date tarikhlahir) {
        this.tarikhlahir = tarikhlahir;
    }

    public int getUmur() {
        return umur;
    }

    public void setUmur(int umur) {
        this.umur = umur;
    }

    public String getJantina() {
        return jantina;
    }

    public void setJantina(String jantina) {
        this.jantina = jantina;
    }

    public String getBangsa() {
        return bangsa;
    }

    public void setBangsa(String bangsa) {
        this.bangsa = bangsa;
    }

    public String getAlamat() {
        return alamat;
    }

    public void setAlamat(String alamat) {
        this.alamat = alamat;
    }

    public String getPoskod() {
        return poskod;
    }

    public void setPoskod(String poskod) {
        this.poskod = poskod;
    }

    public String getKodtadika() {
        return kodtadika;
    }

    public void setKodtadika(String kodtadika) {
        this.kodtadika = kodtadika;
    }

    public int getTahunmasuk() {
        return tahunmasuk;
    }

    public void setTahunmasuk(int tahunmasuk) {
        this.tahunmasuk = tahunmasuk;
    }

    public String getGambarpassport() {
        return gambarpassport;
    }

    public void setGambarpassport(String gambarpassport) {
        this.gambarpassport = gambarpassport;
    }
}
