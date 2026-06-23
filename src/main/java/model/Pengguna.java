package model;

public class Pengguna {

    private int idpengguna;
    private String username;
    private String katalaluan;
    private String nama;
    private String notelefon;
    private String peranan;
    private String kodtadika;
    private String dunseliaan;
    private String tarikhdicipta;
    private String gambarprofil;

    public Pengguna() {
    }

    // Getter Setter
    public int getIdpengguna() {
        return idpengguna;
    }

    public void setIdpengguna(int idpengguna) {
        this.idpengguna = idpengguna;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getKatalaluan() {
        return katalaluan;
    }

    public void setKatalaluan(String katalaluan) {
        this.katalaluan = katalaluan;
    }

    public String getNama() {
        return nama;
    }

    public void setNama(String nama) {
        this.nama = nama;
    }

    public String getNotelefon() {
        return notelefon;
    }

    public void setNotelefon(String notelefon) {
        this.notelefon = notelefon;
    }

    public String getPeranan() {
        return peranan;
    }

    public void setPeranan(String peranan) {
        this.peranan = peranan;
    }

    public String getKodtadika() {
        return kodtadika;
    }

    public void setKodtadika(String kodtadika) {
        this.kodtadika = kodtadika;
    }

    public String getDunseliaan() {
        return dunseliaan;
    }

    public void setDunseliaan(String dunseliaan) {
        this.dunseliaan = dunseliaan;
    }

    public String getTarikhdicipta() {
        return tarikhdicipta;
    }

    public void setTarikhdicipta(String tarikhdicipta) {
        this.tarikhdicipta = tarikhdicipta;
    }

    public String getGambarprofil() {
        return gambarprofil;
    }

    public void setGambarprofil(String gambarprofil) {
        this.gambarprofil = gambarprofil;
    }
}
