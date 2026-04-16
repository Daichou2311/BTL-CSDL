-- ============================================================
--  HỆ THỐNG QUẢN LÝ CẦU THỦ BÓNG ĐÁ
--  SQL Server Script
--  Môn: Cơ sở dữ liệu
-- ============================================================

USE master
GO

IF DB_ID('QuanLyCauThu') IS NOT NULL
BEGIN
ALTER DATABASE QuanLyCauThu SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DROP DATABASE QuanLyCauThu
END
GO

CREATE DATABASE QuanLyCauThu;
GO

USE QuanLyCauThu;
GO

-- ============================================================
-- 1. BẢNG QUỐC GIA
-- ============================================================
CREATE TABLE QuocGia (
    MaQuocGia   INT PRIMARY KEY IDENTITY(1,1),
    TenQuocGia  NVARCHAR(100) NOT NULL,
    MaISO       CHAR(3)       NOT NULL UNIQUE,  -- VIE, FRA, ENG...
    ChauLuc     NVARCHAR(50)
);

-- ============================================================
-- 2. BẢNG VỊ TRÍ THI ĐẤU
-- ============================================================
CREATE TABLE ViTri (
    MaViTri     INT PRIMARY KEY IDENTITY(1,1),
    TenViTri    NVARCHAR(50)  NOT NULL,          -- Thủ môn, Hậu vệ, Tiền vệ, Tiền đạo
    KyHieu      NVARCHAR(10)  NOT NULL UNIQUE,   -- GK, CB, LB, RB, CM, CAM, ST, ...
    MoTa        NVARCHAR(200)
);
GO

-- ============================================================
-- 3. BẢNG CÂU LẠC BỘ
-- ============================================================
CREATE TABLE CLB (
    MaCLB           INT PRIMARY KEY IDENTITY(1,1),
    TenCLB          NVARCHAR(150) NOT NULL,
    TenVietTat      NVARCHAR(20),
    ThanhPho        NVARCHAR(100),
    MaQuocGia       INT NOT NULL,
    NamThanhLap     INT,
    SanVanDong      NVARCHAR(150),
    SucChuaSan      INT,                          -- Số lượng khán giả
    Logo            NVARCHAR(255),                -- Đường dẫn ảnh logo
    CONSTRAINT FK_CLB_QuocGia FOREIGN KEY (MaQuocGia) REFERENCES QuocGia(MaQuocGia)
);
GO

-- ============================================================
-- 4. BẢNG CẦU THỦ
-- ============================================================
CREATE TABLE CauThu (
    MaCauThu        INT PRIMARY KEY IDENTITY(1,1),
    HoTen           NVARCHAR(150) NOT NULL,
    NgaySinh        DATE         NOT NULL,
    MaQuocTich      INT          NOT NULL,
    MaViTri         INT          NOT NULL,
    MaCLBHienTai    INT,
    ChieuCao        DECIMAL(5,2),               -- cm
    CanNang         DECIMAL(5,2),               -- kg
    SoAo            INT,
    GiaTriChuyenNhuong DECIMAL(15,2),           -- triệu EUR
    AnhDaiDien      NVARCHAR(255),
    GhiChu          NVARCHAR(500),
    CONSTRAINT FK_CauThu_QuocTich  FOREIGN KEY (MaQuocTich)     REFERENCES QuocGia(MaQuocGia),
    CONSTRAINT FK_CauThu_ViTri     FOREIGN KEY (MaViTri)        REFERENCES ViTri(MaViTri),
    CONSTRAINT FK_CauThu_CLB       FOREIGN KEY (MaCLBHienTai)   REFERENCES CLB(MaCLB)
);
GO

-- ============================================================
-- 5. BẢNG HỢP ĐỒNG
-- ============================================================
CREATE TABLE HopDong (
    MaHopDong       INT PRIMARY KEY IDENTITY(1,1),
    MaCauThu        INT          NOT NULL,
    MaCLB           INT          NOT NULL,
    NgayBatDau      DATE         NOT NULL,
    NgayKetThuc     DATE         NOT NULL,
    LuongThang      DECIMAL(15,2),              -- nghìn EUR/tháng
    PhiChuyenNhuong DECIMAL(15,2),              -- triệu EUR
    TrangThai       NVARCHAR(20) DEFAULT N'Hiệu lực'
                    CHECK (TrangThai IN (N'Hiệu lực', N'Hết hạn', N'Thanh lý')),
    GhiChu          NVARCHAR(500),
    CONSTRAINT FK_HopDong_CauThu FOREIGN KEY (MaCauThu) REFERENCES CauThu(MaCauThu),
    CONSTRAINT FK_HopDong_CLB    FOREIGN KEY (MaCLB)    REFERENCES CLB(MaCLB),
    CONSTRAINT CHK_HopDong_NgayThang CHECK (NgayKetThuc > NgayBatDau)
);
GO

-- ============================================================
-- 6. BẢNG GIẢI ĐẤU
-- ============================================================
CREATE TABLE GiaiDau (
    MaGiaiDau       INT PRIMARY KEY IDENTITY(1,1),
    TenGiaiDau      NVARCHAR(150) NOT NULL,
    MaQuocGia       INT,
    MuaGiai         NVARCHAR(20),               -- 2024-2025
    LoaiGiai        NVARCHAR(50)
                    CHECK (LoaiGiai IN (N'Vô địch quốc gia', N'Cúp quốc gia',
                                        N'Cúp châu lục',     N'Cúp thế giới', N'Khác')),
    GhiChu          NVARCHAR(300),
    CONSTRAINT FK_GiaiDau_QuocGia FOREIGN KEY (MaQuocGia) REFERENCES QuocGia(MaQuocGia)
);
GO

-- ============================================================
-- 7. BẢNG TRẬN ĐẤU
-- ============================================================
CREATE TABLE TranDau (
    MaTranDau       INT PRIMARY KEY IDENTITY(1,1),
    MaGiaiDau       INT         NOT NULL,
    MaCLBNha        INT         NOT NULL,
    MaCLBKhach      INT         NOT NULL,
    NgayThiDau      DATETIME    NOT NULL,
    SanDau          NVARCHAR(150),
    KetQuaNha       INT,
    KetQuaKhach     INT,
    VongDau         NVARCHAR(50),
    TrangThai       NVARCHAR(20) DEFAULT N'Chờ diễn ra'
                    CHECK (TrangThai IN (N'Chờ diễn ra', N'Đang diễn ra', N'Đã kết thúc', N'Hoãn')),
    CONSTRAINT FK_TranDau_GiaiDau    FOREIGN KEY (MaGiaiDau)  REFERENCES GiaiDau(MaGiaiDau),
    CONSTRAINT FK_TranDau_CLBNha     FOREIGN KEY (MaCLBNha)   REFERENCES CLB(MaCLB),
    CONSTRAINT FK_TranDau_CLBKhach   FOREIGN KEY (MaCLBKhach) REFERENCES CLB(MaCLB),
    CONSTRAINT CHK_TranDau_2CLB      CHECK (MaCLBNha <> MaCLBKhach)
);
GO

-- ============================================================
-- 8. BẢNG THỐNG KÊ CẦU THỦ THEO TRẬN
-- ============================================================
CREATE TABLE ThongKeCauThu (
    MaThongKe       INT PRIMARY KEY IDENTITY(1,1),
    MaCauThu        INT         NOT NULL,
    MaTranDau       INT         NOT NULL,
    SoPhutThiDau    INT         DEFAULT 0 CHECK (SoPhutThiDau BETWEEN 0 AND 120),
    SoBanThang      INT         DEFAULT 0 CHECK (SoBanThang >= 0),
    SoKienTao       INT         DEFAULT 0 CHECK (SoKienTao >= 0),
    TheVang         INT         DEFAULT 0 CHECK (TheVang IN (0, 1, 2)),
    TheDo           INT         DEFAULT 0 CHECK (TheDo IN (0, 1)),
    DanhGia         DECIMAL(3,1)            CHECK (DanhGia BETWEEN 1.0 AND 10.0),
    GhiChu          NVARCHAR(300),
    CONSTRAINT FK_ThongKe_CauThu  FOREIGN KEY (MaCauThu)  REFERENCES CauThu(MaCauThu),
    CONSTRAINT FK_ThongKe_TranDau FOREIGN KEY (MaTranDau) REFERENCES TranDau(MaTranDau),
    CONSTRAINT UQ_ThongKe UNIQUE (MaCauThu, MaTranDau)
);
GO

-- ============================================================
-- 9. BẢNG CHẤN THƯƠNG
-- ============================================================
CREATE TABLE ChanThuong (
    MaChanThuong    INT PRIMARY KEY IDENTITY(1,1),
    MaCauThu        INT          NOT NULL,
    LoaiChanThuong  NVARCHAR(100) NOT NULL,      -- Gãy xương, căng cơ, chấn thương gân...
    NgayChanThuong  DATE         NOT NULL,
    NgayHoiPhuc    DATE,
    MoTa            NVARCHAR(500),
    CONSTRAINT FK_ChanThuong_CauThu FOREIGN KEY (MaCauThu) REFERENCES CauThu(MaCauThu),
    CONSTRAINT CHK_ChanThuong_Ngay  CHECK (NgayHoiPhuc IS NULL OR NgayHoiPhuc >= NgayChanThuong)
);
GO

-- ============================================================
-- DỮ LIỆU MẪU
-- ============================================================

-- Quốc gia
INSERT INTO QuocGia (TenQuocGia, MaISO, ChauLuc) VALUES
(N'Việt Nam',       'VIE', N'Châu Á'),
(N'Pháp',           'FRA', N'Châu Âu'),
(N'Anh',            'ENG', N'Châu Âu'),
(N'Tây Ban Nha',    'ESP', N'Châu Âu'),
(N'Brazil',         'BRA', N'Nam Mỹ'),
(N'Argentina',      'ARG', N'Nam Mỹ'),
(N'Đức',            'DEU', N'Châu Âu'),
(N'Bồ Đào Nha',     'PRT', N'Châu Âu'),
(N'Na Uy',          'NOR', N'Châu Âu');
GO

-- Vị trí
INSERT INTO ViTri (TenViTri, KyHieu, MoTa) VALUES
(N'Thủ môn',        'GK',  N'Người gác gôn'),
(N'Hậu vệ phải',    'RB',  N'Hậu vệ cánh phải'),
(N'Hậu vệ trái',    'LB',  N'Hậu vệ cánh trái'),
(N'Trung vệ',       'CB',  N'Hậu vệ trung tâm'),
(N'Tiền vệ trung tâm', 'CM', N'Tiền vệ tổ chức lối chơi'),
(N'Tiền vệ tấn công',  'CAM',N'Tiền vệ hỗ trợ tấn công'),
(N'Tiền đạo cánh',  'WF',  N'Tiền đạo tấn công cánh'),
(N'Tiền đạo trung tâm','ST', N'Tiền đạo trung phong');
GO

-- CLB
INSERT INTO CLB (TenCLB, TenVietTat, ThanhPho, MaQuocGia, NamThanhLap, SanVanDong, SucChuaSan) VALUES
(N'Hà Nội FC',              'HNFC',  N'Hà Nội',      1, 2010, N'Hàng Đẫy',         22500),
(N'Hoàng Anh Gia Lai',      'HAGL',  N'Pleiku',       1, 2001, N'Pleiku',           12000),
(N'Real Madrid CF',          'RMA',  N'Madrid',       4, 1902, N'Santiago Bernabéu', 81044),
(N'FC Barcelona',            'FCB',  N'Barcelona',    4, 1899, N'Camp Nou',          99354),
(N'Manchester City',         'MCI',  N'Manchester',   3, 1880, N'Etihad Stadium',   53400),
(N'Paris Saint-Germain',     'PSG',  N'Paris',        2, 1970, N'Parc des Princes',  47929),
(N'Bayern Munich',           'FCBM',  N'Munich',       7, 1900, N'Allianz Arena',    75024),
(N'Atletico de Madrid',      'ATM',  N'Madrid',       4, 1903, N'Metropolitano',    70000);
GO

-- Cầu thủ
INSERT INTO CauThu (HoTen, NgaySinh, MaQuocTich, MaViTri, MaCLBHienTai, ChieuCao, CanNang, SoAo, GiaTriChuyenNhuong) VALUES
(N'Nguyễn Quang Hải',       '1997-04-12', 1, 6, 1,  170.0, 63.0, 19,   2.50),
(N'Đoàn Văn Hậu',           '1999-04-19', 1, 3, 1,  183.0, 72.0,  5,   1.80),
(N'Bùi Tiến Dũng',          '1997-11-25', 1, 1, 1,  186.0, 80.0,  1,   1.20),
(N'Kylian Mbappé',           '1998-12-20', 2, 7, 3,  178.0, 73.0, 29, 180.00),
(N'Erling Haaland',          '2000-07-21', 9, 8, 5,  194.0, 88.0,  9, 200.00),
(N'Lamine Yamal',            '2007-07-13', 4, 7, 4,  180.0, 67.0, 19, 120.00),
(N'Vinicius Junior',         '2000-07-12', 5, 7, 3,  176.0, 73.0,  7, 150.00),
(N'Jude Bellingham',         '2003-06-29', 3, 6, 3,  186.0, 75.0,  5, 180.00),
(N'Jamal Musiala',           '2003-02-26', 7, 6, 7,  184.0, 72.0, 10, 130.00),
(N'Harry Kane',              '1993-07-28', 3, 8, 7,  188.0, 86.0,  9,  90.00);
GO

-- Hợp đồng
INSERT INTO HopDong (MaCauThu, MaCLB, NgayBatDau, NgayKetThuc, LuongThang, PhiChuyenNhuong, TrangThai) VALUES
(1,  1, '2023-01-01', '2025-12-31',   80.0,    0.0,   N'Hiệu lực'),
(2,  1, '2023-07-01', '2026-06-30',   70.0,    0.0,   N'Hiệu lực'),
(3,  1, '2022-01-01', '2025-06-30',   50.0,    0.0,   N'Hiệu lực'),
(4,  5, '2024-07-01', '2029-06-30', 1500.0, 180.0,   N'Hiệu lực'),
(5,  5, '2022-07-01', '2027-06-30', 2000.0, 200.0,   N'Hiệu lực'),
(6,  4, '2023-07-01', '2026-06-30', 1200.0,   0.0,   N'Hiệu lực'),
(7,  3, '2023-07-01', '2027-06-30', 1800.0, 100.0,   N'Hiệu lực'),
(8,  3, '2023-07-01', '2029-06-30', 1600.0, 103.0,   N'Hiệu lực'),
(9,  7, '2020-07-01', '2027-06-30', 1300.0,   0.0,   N'Hiệu lực'),
(10, 7, '2023-07-01', '2027-06-30',  900.0, 100.0,   N'Hiệu lực');
GO

-- Giải đấu
INSERT INTO GiaiDau (TenGiaiDau, MaQuocGia, MuaGiai, LoaiGiai) VALUES
(N'V.League 1',           1, '2024-2025', N'Vô địch quốc gia'),
(N'Premier League',       3, '2024-2025', N'Vô địch quốc gia'),
(N'La Liga',              4, '2024-2025', N'Vô địch quốc gia'),
(N'Bundesliga',           7, '2024-2025', N'Vô địch quốc gia'),
(N'UEFA Champions League',NULL,'2024-2025',N'Cúp châu lục');
GO

-- Trận đấu
INSERT INTO TranDau (MaGiaiDau, MaCLBNha, MaCLBKhach, NgayThiDau, SanDau, KetQuaNha, KetQuaKhach, VongDau, TrangThai) VALUES
(1, 1, 2, '2025-03-15 19:00', N'Hàng Đẫy',         2, 1, N'Vòng 10',   N'Đã kết thúc'),
(1, 2, 1, '2025-01-20 18:00', N'Pleiku',            1, 2, N'Vòng 3',    N'Đã kết thúc'),
(2, 5, 6, '2025-04-01 21:00', N'Etihad Stadium',    3, 1, N'Vòng 31',   N'Đã kết thúc'),
(3, 3, 4, '2025-03-30 20:00', N'Santiago Bernabéu', 4, 0, N'El Clasico', N'Đã kết thúc'),
(4, 7, 5, '2025-03-22 20:30', N'Allianz Arena',     5, 1, N'Vòng 27',   N'Đã kết thúc'),
(5, 3, 5, '2025-04-08 21:00', N'Santiago Bernabéu', 2, 2, N'Tứ kết',    N'Đã kết thúc');
GO

-- Thống kê cầu thủ theo trận
INSERT INTO ThongKeCauThu (MaCauThu, MaTranDau, SoPhutThiDau, SoBanThang, SoKienTao, TheVang, TheDo, DanhGia) VALUES
(1, 1, 90, 1, 1, 0, 0, 8.5),
(2, 1, 90, 0, 0, 0, 0, 7.0),
(3, 1, 90, 0, 0, 0, 0, 7.5),
(4, 3, 90, 2, 0, 0, 0, 9.2),
(5, 3, 88, 1, 1, 1, 0, 8.8),
(7, 4, 90, 2, 1, 0, 0, 9.5),
(8, 4, 90, 1, 2, 0, 0, 9.1),
(9, 5, 90, 1, 2, 0, 0, 8.9),
(10,5, 90, 2, 0, 0, 0, 8.7),
(4, 6, 90, 1, 0, 1, 0, 7.8),
(5, 6, 82, 0, 1, 0, 0, 7.5);
GO

-- Chấn thương
INSERT INTO ChanThuong (MaCauThu, LoaiChanThuong, NgayChanThuong, NgayHoiPhuc, MoTa) VALUES
(1, N'Căng cơ đùi',         '2024-08-10', '2024-09-05', N'Nghỉ 4 tuần'),
(4, N'Chấn thương gân khoeo','2024-11-01', '2024-12-15', N'Nghỉ 6 tuần'),
(5, N'Gãy xương bàn chân',  '2023-03-20', '2023-06-01', N'Nghỉ 10 tuần');
GO

-- ============================================================
-- CÁC CÂU TRUY VẤN TIÊU BIỂU
-- ============================================================

-- 1. Danh sách cầu thủ và thông tin đầy đủ
SELECT 
    ct.MaCauThu,
    ct.HoTen,
    ct.NgaySinh,
    DATEDIFF(YEAR, ct.NgaySinh, GETDATE()) AS Tuoi,
    qg.TenQuocGia        AS QuocTich,
    vt.KyHieu            AS ViTri,
    clb.TenCLB           AS CLBHienTai,
    ct.ChieuCao,
    ct.CanNang,
    ct.SoAo,
    ct.GiaTriChuyenNhuong
FROM CauThu ct
JOIN QuocGia qg  ON ct.MaQuocTich    = qg.MaQuocGia
JOIN ViTri   vt  ON ct.MaViTri       = vt.MaViTri
LEFT JOIN CLB clb ON ct.MaCLBHienTai = clb.MaCLB
ORDER BY ct.GiaTriChuyenNhuong DESC;
GO

-- 2. Thống kê tổng bàn thắng & kiến tạo mỗi cầu thủ
SELECT 
    ct.HoTen,
    clb.TenCLB,
    vt.KyHieu                 AS ViTri,
    COUNT(tk.MaTranDau)       AS SoTranDaDau,
    SUM(tk.SoBanThang)        AS TongBanThang,
    SUM(tk.SoKienTao)         AS TongKienTao,
    SUM(tk.TheVang)           AS TongTheVang,
    ROUND(AVG(tk.DanhGia),2)  AS DanhGiaTB
FROM CauThu ct
JOIN ViTri  vt  ON ct.MaViTri       = vt.MaViTri
LEFT JOIN CLB clb ON ct.MaCLBHienTai = clb.MaCLB
LEFT JOIN ThongKeCauThu tk ON ct.MaCauThu = tk.MaCauThu
GROUP BY ct.MaCauThu, ct.HoTen, clb.TenCLB, vt.KyHieu
ORDER BY TongBanThang DESC, TongKienTao DESC;
GO

-- 3. Kết quả các trận đấu
SELECT 
    gd.TenGiaiDau,
    td.VongDau,
    td.NgayThiDau,
    clbN.TenCLB     AS DoiNha,
    td.KetQuaNha,
    td.KetQuaKhach,
    clbK.TenCLB     AS DoiKhach,
    td.TrangThai
FROM TranDau td
JOIN GiaiDau gd ON td.MaGiaiDau  = gd.MaGiaiDau
JOIN CLB clbN   ON td.MaCLBNha   = clbN.MaCLB
JOIN CLB clbK   ON td.MaCLBKhach = clbK.MaCLB
ORDER BY td.NgayThiDau DESC;
GO

-- 4. Hợp đồng đang hiệu lực
SELECT 
    ct.HoTen,
    clb.TenCLB,
    hd.NgayBatDau,
    hd.NgayKetThuc,
    DATEDIFF(MONTH, GETDATE(), hd.NgayKetThuc) AS ConLaiThang,
    hd.LuongThang,
    hd.PhiChuyenNhuong
FROM HopDong hd
JOIN CauThu ct ON hd.MaCauThu = ct.MaCauThu
JOIN CLB    clb ON hd.MaCLB   = clb.MaCLB
WHERE hd.TrangThai = N'Hiệu lực'
ORDER BY hd.NgayKetThuc ASC;
GO

-- 5. Cầu thủ top ghi bàn mỗi giải đấu
SELECT 
    gd.TenGiaiDau,
    ct.HoTen,
    SUM(tk.SoBanThang) AS TongBanThang
FROM ThongKeCauThu tk
JOIN CauThu  ct ON tk.MaCauThu  = ct.MaCauThu
JOIN TranDau td ON tk.MaTranDau = td.MaTranDau
JOIN GiaiDau gd ON td.MaGiaiDau = gd.MaGiaiDau
GROUP BY gd.TenGiaiDau, ct.HoTen
ORDER BY gd.TenGiaiDau, TongBanThang DESC;
GO

-- 6. Lịch sử chấn thương cầu thủ
SELECT 
    ct.HoTen,
    clb.TenCLB,
    chan.LoaiChanThuong,
    chan.NgayChanThuong,
    chan.NgayHoiPhuc,
    DATEDIFF(DAY, chan.NgayChanThuong, ISNULL(chan.NgayHoiPhuc, GETDATE())) AS SoNgayNghi
FROM ChanThuong chan
JOIN CauThu ct ON chan.MaCauThu = ct.MaCauThu
LEFT JOIN CLB clb ON ct.MaCLBHienTai = clb.MaCLB
ORDER BY chan.NgayChanThuong DESC;
GO

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

-- SP1: Thêm mới cầu thủ
CREATE OR ALTER PROCEDURE sp_ThemCauThu
    @HoTen              NVARCHAR(150),
    @NgaySinh           DATE,
    @MaQuocTich         INT,
    @MaViTri            INT,
    @MaCLB              INT = NULL,
    @ChieuCao           DECIMAL(5,2) = NULL,
    @CanNang            DECIMAL(5,2) = NULL,
    @SoAo               INT = NULL,
    @GiaTriChuyenNhuong DECIMAL(15,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO CauThu (HoTen, NgaySinh, MaQuocTich, MaViTri, MaCLBHienTai, ChieuCao, CanNang, SoAo, GiaTriChuyenNhuong)
    VALUES (@HoTen, @NgaySinh, @MaQuocTich, @MaViTri, @MaCLB, @ChieuCao, @CanNang, @SoAo, @GiaTriChuyenNhuong);
    SELECT SCOPE_IDENTITY() AS MaCauThuMoi;
END;
GO

-- SP2: Tìm kiếm cầu thủ
CREATE OR ALTER PROCEDURE sp_TimKiemCauThu
    @TenTimKiem NVARCHAR(150) = NULL,
    @MaViTri    INT = NULL,
    @MaQuocTich INT = NULL,
    @MaCLB      INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ct.MaCauThu, ct.HoTen,
        DATEDIFF(YEAR, ct.NgaySinh, GETDATE()) AS Tuoi,
        qg.TenQuocGia, vt.KyHieu, clb.TenCLB,
        ct.GiaTriChuyenNhuong
    FROM CauThu ct
    JOIN QuocGia qg   ON ct.MaQuocTich    = qg.MaQuocGia
    JOIN ViTri   vt   ON ct.MaViTri       = vt.MaViTri
    LEFT JOIN CLB clb ON ct.MaCLBHienTai  = clb.MaCLB
    WHERE
        (@TenTimKiem IS NULL OR ct.HoTen      LIKE '%' + @TenTimKiem + '%')
    AND (@MaViTri    IS NULL OR ct.MaViTri    = @MaViTri)
    AND (@MaQuocTich IS NULL OR ct.MaQuocTich = @MaQuocTich)
    AND (@MaCLB      IS NULL OR ct.MaCLBHienTai = @MaCLB)
    ORDER BY ct.HoTen;
END;
GO

-- SP3: Cập nhật CLB cho cầu thủ (chuyển nhượng)
CREATE OR ALTER PROCEDURE sp_ChuyenNhuong
    @MaCauThu   INT,
    @MaCLBMoi   INT,
    @NgayHieuLuc DATE,
    @NgayKetThuc DATE,
    @LuongThang  DECIMAL(15,2),
    @PhiCN       DECIMAL(15,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Cập nhật CLB hiện tại
        UPDATE CauThu SET MaCLBHienTai = @MaCLBMoi WHERE MaCauThu = @MaCauThu;
        -- Hết hạn hợp đồng cũ
        UPDATE HopDong SET TrangThai = N'Hết hạn'
        WHERE MaCauThu = @MaCauThu AND TrangThai = N'Hiệu lực';
        -- Thêm hợp đồng mới
        INSERT INTO HopDong (MaCauThu, MaCLB, NgayBatDau, NgayKetThuc, LuongThang, PhiChuyenNhuong, TrangThai)
        VALUES (@MaCauThu, @MaCLBMoi, @NgayHieuLuc, @NgayKetThuc, @LuongThang, @PhiCN, N'Hiệu lực');
        COMMIT TRANSACTION;
        PRINT N'Chuyển nhượng thành công.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT N'Lỗi: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

-- ============================================================
-- VIEW
-- ============================================================

-- View tổng quan cầu thủ
CREATE OR ALTER VIEW vw_TongQuanCauThu AS
SELECT 
    ct.MaCauThu,
    ct.HoTen,
    DATEDIFF(YEAR, ct.NgaySinh, GETDATE()) AS Tuoi,
    qg.TenQuocGia       AS QuocTich,
    vt.TenViTri         AS ViTri,
    vt.KyHieu,
    clb.TenCLB          AS CLBHienTai,
    ct.ChieuCao,
    ct.CanNang,
    ct.SoAo,
    ct.GiaTriChuyenNhuong,
    COUNT(DISTINCT tk.MaTranDau)  AS SoTranDaDau,
    SUM(tk.SoBanThang)            AS TongBanThang,
    SUM(tk.SoKienTao)             AS TongKienTao
FROM CauThu ct
JOIN QuocGia qg   ON ct.MaQuocTich    = qg.MaQuocGia
JOIN ViTri   vt   ON ct.MaViTri       = vt.MaViTri
LEFT JOIN CLB clb ON ct.MaCLBHienTai  = clb.MaCLB
LEFT JOIN ThongKeCauThu tk ON ct.MaCauThu = tk.MaCauThu
GROUP BY ct.MaCauThu, ct.HoTen, ct.NgaySinh,
         qg.TenQuocGia, vt.TenViTri, vt.KyHieu,
         clb.TenCLB, ct.ChieuCao, ct.CanNang, ct.SoAo, ct.GiaTriChuyenNhuong;
GO

-- Thử view
SELECT * FROM vw_TongQuanCauThu ORDER BY TongBanThang DESC;
GO

PRINT N'✅ HOÀN THÀNH: Database QuanLyCauThu đã được tạo thành công!';
GO
