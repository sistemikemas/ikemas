package model;

import java.sql.Timestamp;

public class DokumenPermohonan {

    private int iddokumen;
    private int idpermohonan;
    private String jenisdokumen;
    private String namafail;
    private Timestamp tarikhupload;

    // Constructors
    public DokumenPermohonan() {
    }

    public DokumenPermohonan(int idpermohonan, String jenisdokumen, String namafail) {
        this.idpermohonan = idpermohonan;
        this.jenisdokumen = jenisdokumen;
        this.namafail = namafail;
    }

    // Getters and Setters
    public int getIddokumen() {
        return iddokumen;
    }

    public void setIddokumen(int iddokumen) {
        this.iddokumen = iddokumen;
    }

    public int getIdpermohonan() {
        return idpermohonan;
    }

    public void setIdpermohonan(int idpermohonan) {
        this.idpermohonan = idpermohonan;
    }

    public String getJenisdokumen() {
        return jenisdokumen;
    }

    public void setJenisdokumen(String jenisdokumen) {
        this.jenisdokumen = jenisdokumen;
    }

    public String getNamafail() {
        return namafail;
    }

    public void setNamafail(String namafail) {
        this.namafail = namafail;
    }

    public Timestamp getTarikhupload() {
        return tarikhupload;
    }

    public void setTarikhupload(Timestamp tarikhupload) {
        this.tarikhupload = tarikhupload;
    }
}
