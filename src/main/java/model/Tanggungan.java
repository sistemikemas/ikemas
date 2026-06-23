package model;

public class Tanggungan {

    private int idtanggungan;
    private int idpermohonan;
    private String nama;
    private int umur;
    private String hubungan;

    // Constructors
    public Tanggungan() {
    }

    public Tanggungan(int idpermohonan, String nama, int umur, String hubungan) {
        this.idpermohonan = idpermohonan;
        this.nama = nama;
        this.umur = umur;
        this.hubungan = hubungan;
    }

    // Getters and Setters
    public int getIdtanggungan() {
        return idtanggungan;
    }

    public void setIdtanggungan(int idtanggungan) {
        this.idtanggungan = idtanggungan;
    }

    public int getIdpermohonan() {
        return idpermohonan;
    }

    public void setIdpermohonan(int idpermohonan) {
        this.idpermohonan = idpermohonan;
    }

    public String getNama() {
        return nama;
    }

    public void setNama(String nama) {
        this.nama = nama;
    }

    public int getUmur() {
        return umur;
    }

    public void setUmur(int umur) {
        this.umur = umur;
    }

    public String getHubungan() {
        return hubungan;
    }

    public void setHubungan(String hubungan) {
        this.hubungan = hubungan;
    }
}
