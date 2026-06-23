package model;

import java.sql.Date;

public class PrestasiMurid {

    private int idprestasi;
    private String nokadpengenalanmurid;
    private int idguru;
    private Date tarikh;
    private String jenisprestasi;
    private String subjek;
    private Double markahperatus;
    private String gred;
    private String catatan;
    private String statuskehadiran;

    // Constructors
    public PrestasiMurid() {
    }

    // Getters and Setters (all fields)
    public int getIdprestasi() {
        return idprestasi;
    }

    public void setIdprestasi(int idprestasi) {
        this.idprestasi = idprestasi;
    }

    public String getNokadpengenalanmurid() {
        return nokadpengenalanmurid;
    }

    public void setNokadpengenalanmurid(String nokadpengenalanmurid) {
        this.nokadpengenalanmurid = nokadpengenalanmurid;
    }

    public int getIdguru() {
        return idguru;
    }

    public void setIdguru(int idguru) {
        this.idguru = idguru;
    }

    public Date getTarikh() {
        return tarikh;
    }

    public void setTarikh(Date tarikh) {
        this.tarikh = tarikh;
    }

    public String getJenisprestasi() {
        return jenisprestasi;
    }

    public void setJenisprestasi(String jenisprestasi) {
        this.jenisprestasi = jenisprestasi;
    }

    public String getSubjek() {
        return subjek;
    }

    public void setSubjek(String subjek) {
        this.subjek = subjek;
    }

    public Double getMarkahperatus() {
        return markahperatus;
    }

    public void setMarkahperatus(Double markahperatus) {
        this.markahperatus = markahperatus;
    }

    public String getGred() {
        return gred;
    }

    public void setGred(String gred) {
        this.gred = gred;
    }

    public String getCatatan() {
        return catatan;
    }

    public void setCatatan(String catatan) {
        this.catatan = catatan;
    }

    public String getStatuskehadiran() {
        return statuskehadiran;
    }

    public void setStatuskehadiran(String statuskehadiran) {
        this.statuskehadiran = statuskehadiran;
    }
}
