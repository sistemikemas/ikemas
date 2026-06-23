package model;

import java.sql.Date;

public class Guru {

    private int idguru;
    private int idpengguna;
    private String kodtadika;
    private String nokadpengenalan;
    private Date tarikhlantikan;
    private String kelayakanakademik;
    private String gredjawatan;

    // Constructors, Getters and Setters
    public Guru() {
    }

    public int getIdguru() {
        return idguru;
    }

    public void setIdguru(int idguru) {
        this.idguru = idguru;
    }

    public int getIdpengguna() {
        return idpengguna;
    }

    public void setIdpengguna(int idpengguna) {
        this.idpengguna = idpengguna;
    }

    public String getKodtadika() {
        return kodtadika;
    }

    public void setKodtadika(String kodtadika) {
        this.kodtadika = kodtadika;
    }

    public String getNokadpengenalan() {
        return nokadpengenalan;
    }

    public void setNokadpengenalan(String nokadpengenalan) {
        this.nokadpengenalan = nokadpengenalan;
    }

    public Date getTarikhlantikan() {
        return tarikhlantikan;
    }

    public void setTarikhlantikan(Date tarikhlantikan) {
        this.tarikhlantikan = tarikhlantikan;
    }

    public String getKelayakanakademik() {
        return kelayakanakademik;
    }

    public void setKelayakanakademik(String kelayakanakademik) {
        this.kelayakanakademik = kelayakanakademik;
    }

    public String getGredjawatan() {
        return gredjawatan;
    }

    public void setGredjawatan(String gredjawatan) {
        this.gredjawatan = gredjawatan;
    }
}
