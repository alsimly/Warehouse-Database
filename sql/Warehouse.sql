CREATE DATABASE gudang_dp;
use gudang_dp;

CREATE TABLE `Area` (
    id_area VARCHAR(50) PRIMARY KEY,
    nama_area VARCHAR(50) NOT NULL,
    code_area VARCHAR(10) NOT NULL UNIQUE,
    jenis_area ENUM('ELEKTRIK','NON_ELEKTRIK') NOT NULL
);



CREATE TABLE Pengangkut (
    id_pengangkut VARCHAR(50) PRIMARY KEY,
    nama_kurir VARCHAR(50) NOT NULL,
    plat_nomer VARCHAR(15) NOT NULL,
    status_pengangkut ENUM('MASUK','KELUAR') NOT NULL,
    khusus_area VARCHAR(10),
    FOREIGN KEY (khusus_area) REFERENCES Area(code_area)
);			

CREATE TABLE Petugas (
    id_petugas VARCHAR(50) PRIMARY KEY,
    nama_petugas VARCHAR(100) NOT NULL,
    code_area_tugas VARCHAR(10),
    FOREIGN KEY (code_area_tugas) REFERENCES Area(code_area)
);

CREATE TABLE Barang (
    id_barang VARCHAR(50) PRIMARY KEY,
    nama_barang VARCHAR(100) NOT NULL,
    nama_pemilik VARCHAR(100) NOT NULL,
    asal_barang VARCHAR(30) NOT NULL,
    tujuan_barang VARCHAR(20) NOT NULL,
    jumlah_barang INT NOT NULL,
    jenis_barang ENUM('ELEKTRIK','NON_ELEKTRIK') NOT NULL
);

CREATE TABLE Gudang_Transaksi (
    id_transaksi INT AUTO_INCREMENT PRIMARY KEY,
    id_barang VARCHAR(50) NOT NULL,

    id_pengangkut_masuk VARCHAR(50),
    waktu_masuk DATETIME,

    id_area VARCHAR(50),
    waktu_masuk_area DATETIME,

    id_pengangkut_keluar VARCHAR(50),
    waktu_keluar DATETIME,

    status_barang ENUM('MASUK_GUDANG','KELUAR_GUDANG') NOT NULL,

    FOREIGN KEY (id_barang) REFERENCES Barang(id_barang),
    FOREIGN KEY (id_pengangkut_masuk) REFERENCES Pengangkut(id_pengangkut),
    FOREIGN KEY (id_area) REFERENCES Area(id_area),
    FOREIGN KEY (id_pengangkut_keluar) REFERENCES Pengangkut(id_pengangkut)
);


-- Memasukan Nilai


INSERT INTO `Area` (`id_area`,`nama_area`,`code_area`,`jenis_area`) VALUES
('AR_1','A1','DB1','ELEKTRIK'),
('AR_2','A2','DB2','NON_ELEKTRIK'),
('AR_3','B1','DT1','ELEKTRIK'),
('AR_4','B2','DT2','NON_ELEKTRIK'),
('AR_5','C1','DU1','ELEKTRIK'),
('AR_6','C2','DU2','NON_ELEKTRIK'),
('AR_7','D1','DS1','ELEKTRIK'),
('AR_8','D2','DS2','NON_ELEKTRIK');


INSERT INTO `Pengangkut` (`id_pengangkut`,`nama_kurir`,`plat_nomer`,`status_pengangkut`,`khusus_area`) VALUES
('PGT_1','Ulrich','B_1111_UA','MASUK',NULL),
('PGT_2','Wildan','B_2222_AE','KELUAR','DB1'),
('PGT_3','Vino','B_3333_EU','KELUAR','DB2'),
('PGT_4','Yusuf','B_4444_AA','KELUAR','DT1'),
('PGT_5','Asep','B_5555_US','KELUAR','DT2'),
('PGT_6','Agan','B_6666_AB','KELUAR','DU1'),
('PGT_7','Sam','B_3333_AS','KELUAR','DU2'),
('PGT_8','Dima','B_4444_DM','KELUAR','DS1'),
('PGT_9','Guma','B_5555_KM','KELUAR','DS2');


INSERT INTO `Petugas` (`id_petugas`, `nama_petugas`, `code_area_tugas`) VALUES
('PTG_1','Andi','DB1'),
('PTG_2','Budi','DB2'),
('PTG_3','Citra','DT1'),
('PTG_4','Dewi','DT2'),
('PTG_5','Eka','DU1'),
('PTG_6','Fajar','DU2'),
('PTG_7','Gina','DS1'),
('PTG_8','Hadi','DS2');


INSERT INTO `Barang` (
    `id_barang`, `nama_barang`, `nama_pemilik`,
    `jumlah_barang`, `jenis_barang`, `asal_barang`, `tujuan_barang`
) VALUES
('BRG_1','TV Samsung','Alia',10,'ELEKTRIK','Jakarta','Depok_Barat'),
('BRG_2','Laptop Asus','Rizky',5,'ELEKTRIK','Balikpapan','Depok_Timur'),
('BRG_3','Kulkas LG','Nina',3,'ELEKTRIK','Surabaya','Depok_Utara'),
('BRG_4','Mesin Cuci','Doni',4,'ELEKTRIK','Palembang','Depok_Selatan'),
('BRG_5','AC Sharp','Sinta',6,'ELEKTRIK','Bendung','Depok_Selatan'),
('BRG_6','Meja Kayu','Bayu',8,'NON_ELEKTRIK','Makasar','Depok_Barat'),
('BRG_7','Kursi Plastik','Rani',12,'NON_ELEKTRIK','Denpasar','Depok_Timur'),
('BRG_8','Rak Besi','Fahmi',7,'NON_ELEKTRIK','Medan','Depok_Utara'),
('BRG_9','Lemari','Putri',2,'NON_ELEKTRIK','Semarang','Depok_Selatan'),
('BRG_10','Karpet','Agus',15,'NON_ELEKTRIK','Yogyakarta','Depok_Selatan');


-- Trigger
-- barang masuk
DELIMITER $$

CREATE TRIGGER trg_barang_masuk
BEFORE INSERT ON Gudang_Transaksi
FOR EACH ROW
BEGIN
    SET NEW.waktu_masuk = NOW();
    SET NEW.status_barang = 'MASUK_GUDANG';
END$$

DELIMITER ;

-- barang keluar
DELIMITER $$

CREATE TRIGGER trg_barang_keluar
BEFORE UPDATE ON Gudang_Transaksi
FOR EACH ROW
BEGIN
    IF NEW.id_pengangkut_keluar IS NOT NULL
       AND OLD.id_pengangkut_keluar IS NULL THEN
        SET NEW.waktu_keluar = NOW();
        SET NEW.status_barang = 'KELUAR_GUDANG';
    END IF;
END$$

DELIMITER ;

-- procedure

-- barang masuk
DELIMITER $$

CREATE PROCEDURE barang_masuk (
    IN p_id_barang VARCHAR(50),
    IN p_pengangkut_masuk VARCHAR(50)
)
BEGIN
    INSERT INTO Gudang_Transaksi (
        id_barang,
        id_pengangkut_masuk,
        status_barang
    ) VALUES (
        p_id_barang,
        p_pengangkut_masuk,
        'MASUK_GUDANG'
    );
END$$

DELIMITER ;

-- Area

DELIMITER $$

CREATE PROCEDURE pindah_ke_area (
    IN p_id_barang VARCHAR(50),
    IN p_id_area VARCHAR(50)
)
BEGIN
    UPDATE Gudang_Transaksi
    SET id_area = p_id_area,
        waktu_masuk_area = NOW()
    WHERE id_barang = p_id_barang
      AND status_barang = 'MASUK_GUDANG';
END$$

DELIMITER ;

-- barang keluar

DELIMITER $$

CREATE PROCEDURE barang_keluar (
    IN p_id_barang VARCHAR(50),
    IN p_pengangkut_keluar VARCHAR(50)
)
BEGIN
    UPDATE Gudang_Transaksi
    SET id_pengangkut_keluar = p_pengangkut_keluar
    WHERE id_barang = p_id_barang
      AND status_barang = 'MASUK_GUDANG';
END$$

DELIMITER ;


-- View

CREATE VIEW v_monitor_barang AS
SELECT
    b.nama_barang,
    gt.waktu_masuk,
    gt.waktu_masuk_area,
    gt.waktu_keluar,
    gt.status_barang
FROM Gudang_Transaksi gt
JOIN Barang b ON gt.id_barang = b.id_barang;


-- Search
ALTER TABLE Barang
ADD FULLTEXT (nama_barang, nama_pemilik);

SELECT * FROM Barang
WHERE MATCH(nama_barang, nama_pemilik)
AGAINST ('laptop Asus');


