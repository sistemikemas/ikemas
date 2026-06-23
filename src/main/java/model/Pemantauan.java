package model;

import java.sql.Date;

public class Pemantauan {

    private int idpemantauan;
    private String kodtadika;
    private int idpenyelia;
    private Date tarikhpemantauan;
    private String aspekdinilai;
    private String keputusanpemantauan;
    private String catatanpenyelia;
    private String tindakansusulan;

    public Pemantauan() {
    }

    public int getIdpemantauan() {
        return idpemantauan;
    }

    public void setIdpemantauan(int idpemantauan) {
        this.idpemantauan = idpemantauan;
    }

    public String getKodtadika() {
        return kodtadika;
    }

    public void setKodtadika(String kodtadika) {
        this.kodtadika = kodtadika;
    }

    public int getIdpenyelia() {
        return idpenyelia;
    }

    public void setIdpenyelia(int idpenyelia) {
        this.idpenyelia = idpenyelia;
    }

    public Date getTarikhpemantauan() {
        return tarikhpemantauan;
    }

    public void setTarikhpemantauan(Date tarikhpemantauan) {
        this.tarikhpemantauan = tarikhpemantauan;
    }

    public String getAspekdinilai() {
        return aspekdinilai;
    }

    public void setAspekdinilai(String aspekdinilai) {
        this.aspekdinilai = aspekdinilai;
    }

    public String getKeputusanpemantauan() {
        return keputusanpemantauan;
    }

    public void setKeputusanpemantauan(String keputusanpemantauan) {
        this.keputusanpemantauan = keputusanpemantauan;
    }

    public String getCatatanpenyelia() {
        return catatanpenyelia;
    }

    public void setCatatanpenyelia(String catatanpenyelia) {
        this.catatanpenyelia = catatanpenyelia;
    }

    public String getTindakansusulan() {
        return tindakansusulan;
    }

    public void setTindakansusulan(String tindakansusulan) {
        this.tindakansusulan = tindakansusulan;
    }
}
