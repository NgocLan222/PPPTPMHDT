/* =====================================================================
   BÀI 5 - QUẢN LÝ HỒ SƠ BỆNH ÁN CỦA BỆNH NHÂN (BỆNH VIỆN ĐA KHOA QUỐC TẾ)
   Script tạo CSDL QuanLyHoSoBenhAn (SQL Server / LocalDB)
   - Đã fix: ChiTietToaThuoc dùng MaCTT làm khóa chính (PRIMARY KEY).
   ===================================================================== */

IF DB_ID(N'QuanLyHoSoBenhAn') IS NULL CREATE DATABASE QuanLyHoSoBenhAn;
GO
USE QuanLyHoSoBenhAn;
GO

-- XÓA BẢNG CŨ THEO THỨ TỰ PHỤ THUỘC KHÓA NGOẠI
IF OBJECT_ID('TheoDoiSauKham','U') IS NOT NULL DROP TABLE TheoDoiSauKham;
IF OBJECT_ID('HoaDonVienPhi','U') IS NOT NULL DROP TABLE HoaDonVienPhi;
IF OBJECT_ID('ChiTietToaThuoc','U') IS NOT NULL DROP TABLE ChiTietToaThuoc;
IF OBJECT_ID('ToaThuoc','U') IS NOT NULL DROP TABLE ToaThuoc;
IF OBJECT_ID('PhieuXetNghiem','U') IS NOT NULL DROP TABLE PhieuXetNghiem;
IF OBJECT_ID('PhieuKhamBenh','U') IS NOT NULL DROP TABLE PhieuKhamBenh;
IF OBJECT_ID('LichKhamDinhKy','U') IS NOT NULL DROP TABLE LichKhamDinhKy;
IF OBJECT_ID('HoSoBenhAn','U') IS NOT NULL DROP TABLE HoSoBenhAn;
IF OBJECT_ID('BenhNhan','U') IS NOT NULL DROP TABLE BenhNhan;
IF OBJECT_ID('Thuoc','U') IS NOT NULL DROP TABLE Thuoc;
IF OBJECT_ID('LoaiXetNghiem','U') IS NOT NULL DROP TABLE LoaiXetNghiem;
IF OBJECT_ID('BacSi','U') IS NOT NULL DROP TABLE BacSi;
IF OBJECT_ID('KhoaDieuTri','U') IS NOT NULL DROP TABLE KhoaDieuTri;
GO

/* ---------------- 1. CÁC BẢNG DANH MỤC CƠ BẢN ---------------- */

-- Khoa điều trị
CREATE TABLE KhoaDieuTri(
    MaK varchar(20) NOT NULL PRIMARY KEY,
    TenKhoa nvarchar(120) NOT NULL UNIQUE
);

-- Bác sĩ điều trị
CREATE TABLE BacSi(
    MaBS varchar(20) NOT NULL PRIMARY KEY,
    HoTen nvarchar(120) NOT NULL,
    MaK varchar(20) NOT NULL,
    DienThoai varchar(20) NULL,
    TrangThai bit NOT NULL DEFAULT 1,
    CONSTRAINT FK_BacSi_Khoa FOREIGN KEY(MaK) REFERENCES KhoaDieuTri(MaK)
);

-- Danh mục loại xét nghiệm
CREATE TABLE LoaiXetNghiem(
    MaLXN varchar(20) NOT NULL PRIMARY KEY,
    TenLXN nvarchar(150) NOT NULL UNIQUE,
    DonGia decimal(18,2) NOT NULL CHECK(DonGia >= 0)
);

-- Danh mục thuốc
CREATE TABLE Thuoc(
    MaThuoc varchar(20) NOT NULL PRIMARY KEY,
    TenThuoc nvarchar(150) NOT NULL UNIQUE,
    DVT nvarchar(30) NOT NULL,
    DonGia decimal(18,2) NOT NULL CHECK(DonGia >= 0),
    CongDung nvarchar(500) NULL,
    ChongChiDinh nvarchar(500) NULL
);

/* ---------------- 2. BỆNH NHÂN & HỒ SƠ BỆNH ÁN ---------------- */

-- Bệnh nhân
CREATE TABLE BenhNhan(
    MaBN varchar(20) NOT NULL PRIMARY KEY,
    HoTen nvarchar(120) NOT NULL,
    DiaChi nvarchar(250) NOT NULL,
    NgaySinh date NOT NULL,
    GioiTinh nvarchar(10) NOT NULL CHECK(GioiTinh IN (N'Nam', N'Nữ')),
    DienThoai varchar(20) NOT NULL,
    Anh3x4 nvarchar(250) NULL
);

-- Hồ sơ bệnh án
CREATE TABLE HoSoBenhAn(
    MaHoSo varchar(20) NOT NULL PRIMARY KEY,
    MaBN varchar(20) NOT NULL UNIQUE,
    HoTen nvarchar(120) NOT NULL,
    DiaChi nvarchar(250) NOT NULL,
    NgaySinh date NOT NULL,
    GioiTinh nvarchar(10) NOT NULL CHECK(GioiTinh IN (N'Nam', N'Nữ')),
    DienThoai varchar(20) NOT NULL,
    Anh3x4 nvarchar(250) NULL,
    LePhiHangNam decimal(18,2) NOT NULL CHECK(LePhiHangNam >= 0),
    HanSuDung date NOT NULL,
    TrangThai nvarchar(50) NOT NULL DEFAULT N'Còn hiệu lực',
    CONSTRAINT FK_HSBA_BenhNhan FOREIGN KEY(MaBN) REFERENCES BenhNhan(MaBN),
    CONSTRAINT CK_HSBA_TrangThai CHECK(TrangThai IN (N'Còn hiệu lực', N'Hết hạn lệ phí', N'Đã khóa'))
);

-- Lịch hẹn khám định kỳ theo quý
CREATE TABLE LichKhamDinhKy(
    MaLK varchar(20) NOT NULL PRIMARY KEY,
    MaHoSo varchar(20) NOT NULL,
    NgayGioHen datetime2 NOT NULL,
    NgayKhamThucTe datetime2 NULL,
    GhiChu nvarchar(500) NULL,
    TrangThai nvarchar(50) NOT NULL DEFAULT N'Chờ khám',
    CONSTRAINT FK_LichKham_HSBA FOREIGN KEY(MaHoSo) REFERENCES HoSoBenhAn(MaHoSo),
    CONSTRAINT CK_LichKham_TrangThai CHECK(TrangThai IN (N'Chờ khám', N'Đã khám', N'Hủy hẹn'))
);

/* ---------------- 3. KHÁM BỆNH, XÉT NGHIỆM & KÊ TOA ---------------- */

-- Phiếu khám bệnh
CREATE TABLE PhieuKhamBenh(
    MaPK varchar(20) NOT NULL PRIMARY KEY,
    MaHoSo varchar(20) NOT NULL,
    MaBS varchar(20) NOT NULL,
    MaK varchar(20) NOT NULL,
    NgayGioKham datetime2 NOT NULL DEFAULT SYSDATETIME(),
    TrieuChung nvarchar(500) NOT NULL,
    ThanNhiet decimal(4,1) NULL CHECK(ThanNhiet BETWEEN 34.0 AND 43.0),
    HuyetAp varchar(20) NULL,
    LoaiKham nvarchar(50) NOT NULL DEFAULT N'Khám bệnh',
    KetLuan nvarchar(500) NULL,
    CONSTRAINT FK_PKB_HSBA FOREIGN KEY(MaHoSo) REFERENCES HoSoBenhAn(MaHoSo),
    CONSTRAINT FK_PKB_BacSi FOREIGN KEY(MaBS) REFERENCES BacSi(MaBS),
    CONSTRAINT FK_PKB_Khoa FOREIGN KEY(MaK) REFERENCES KhoaDieuTri(MaK),
    CONSTRAINT CK_PKB_LoaiKham CHECK(LoaiKham IN (N'Khám bệnh', N'Khám định kỳ'))
);

-- Phiếu xét nghiệm
CREATE TABLE PhieuXetNghiem(
    MaPXN varchar(20) NOT NULL PRIMARY KEY,
    MaPK varchar(20) NOT NULL,
    MaLXN varchar(20) NOT NULL,
    NgayGioChiDinh datetime2 NOT NULL DEFAULT SYSDATETIME(),
    KetQua nvarchar(1000) NULL,
    NgayGioCoKetQua datetime2 NULL,
    TrangThai nvarchar(50) NOT NULL DEFAULT N'Chờ xét nghiệm',
    CONSTRAINT FK_PXN_PKB FOREIGN KEY(MaPK) REFERENCES PhieuKhamBenh(MaPK),
    CONSTRAINT FK_PXN_LXN FOREIGN KEY(MaLXN) REFERENCES LoaiXetNghiem(MaLXN),
    CONSTRAINT CK_PXN_TrangThai CHECK(TrangThai IN (N'Chờ xét nghiệm', N'Đã có kết quả', N'Hủy'))
);

-- Toa thuốc
CREATE TABLE ToaThuoc(
    MaToa varchar(20) NOT NULL PRIMARY KEY,
    MaPK varchar(20) NOT NULL UNIQUE,
    NgayKe datetime2 NOT NULL DEFAULT SYSDATETIME(),
    LoiDan nvarchar(500) NULL,
    TongTien decimal(18,2) NOT NULL DEFAULT 0 CHECK(TongTien >= 0),
    CONSTRAINT FK_ToaThuoc_PKB FOREIGN KEY(MaPK) REFERENCES PhieuKhamBenh(MaPK)
);

-- Chi tiết toa thuốc (MaCTT là Khóa chính)
CREATE TABLE ChiTietToaThuoc(
    MaCTT varchar(20) NOT NULL PRIMARY KEY,
    MaToa varchar(20) NOT NULL,
    MaThuoc varchar(20) NOT NULL,
    SoLuong int NOT NULL CHECK(SoLuong > 0),
    LieuLuong nvarchar(100) NOT NULL,
    CachDung nvarchar(250) NOT NULL,
    DonGia decimal(18,2) NOT NULL CHECK(DonGia >= 0),
    CONSTRAINT FK_CTToa_Toa FOREIGN KEY(MaToa) REFERENCES ToaThuoc(MaToa),
    CONSTRAINT FK_CTToa_Thuoc FOREIGN KEY(MaThuoc) REFERENCES Thuoc(MaThuoc)
);

/* ---------------- 4. VIỆN PHÍ & THEO DÕI SAU KHÁM ---------------- */

-- Hóa đơn viện phí
CREATE TABLE HoaDonVienPhi(
    MaHD varchar(20) NOT NULL PRIMARY KEY,
    MaPK varchar(20) NOT NULL UNIQUE,
    NgayThanhToan datetime2 NOT NULL DEFAULT SYSDATETIME(),
    TienKham decimal(18,2) NOT NULL DEFAULT 0 CHECK(TienKham >= 0),
    TienXetNghiem decimal(18,2) NOT NULL DEFAULT 0 CHECK(TienXetNghiem >= 0),
    TienThuoc decimal(18,2) NOT NULL DEFAULT 0 CHECK(TienThuoc >= 0),
    TongTien decimal(18,2) NOT NULL CHECK(TongTien >= 0),
    TrangThai nvarchar(50) NOT NULL DEFAULT N'Đã thanh toán',
    CONSTRAINT FK_HoaDon_PKB FOREIGN KEY(MaPK) REFERENCES PhieuKhamBenh(MaPK),
    CONSTRAINT CK_HD_TrangThai CHECK(TrangThai IN (N'Chờ thanh toán', N'Đã thanh toán', N'Hủy'))
);

-- Theo dõi sau khám
CREATE TABLE TheoDoiSauKham(
    MaTD varchar(20) NOT NULL PRIMARY KEY,
    MaPK varchar(20) NOT NULL,
    MaHoSo varchar(20) NOT NULL,
    NgayTheoDoi date NOT NULL DEFAULT CAST(GETDATE() AS date),
    DienBienBenh nvarchar(500) NULL,
    PhanUngPhu nvarchar(500) NULL,
    HieuQuaDieuTri nvarchar(500) NULL,
    CONSTRAINT FK_TheoDoi_PKB FOREIGN KEY(MaPK) REFERENCES PhieuKhamBenh(MaPK),
    CONSTRAINT FK_TheoDoi_HSBA FOREIGN KEY(MaHoSo) REFERENCES HoSoBenhAn(MaHoSo)
);

-- TẠO INDEX TĂNG TỐC TÌM KIẾM
CREATE INDEX IX_HSBA_DienThoai ON HoSoBenhAn(DienThoai);
CREATE INDEX IX_PKB_HoSo ON PhieuKhamBenh(MaHoSo, NgayGioKham);
CREATE INDEX IX_LichKham_NgayHen ON LichKhamDinhKy(NgayGioHen);
GO

/* ---------------- 5. DỮ LIỆU MẪU KIỂM THỬ ---------------- */

INSERT INTO KhoaDieuTri(MaK, TenKhoa) VALUES
('K01', N'Khoa Nội tổng quát'),
('K02', N'Khoa Tim mạch'),
('K03', N'Khoa Tai Mũi Họng'),
('K04', N'Khoa Tiêu hóa');

INSERT INTO BacSi(MaBS, HoTen, MaK, DienThoai, TrangThai) VALUES
('BS01', N'BS. Nguyễn Văn Hùng', 'K01', '0903111222', 1),
('BS02', N'BS. Trần Thị Thanh Mai', 'K02', '0903333444', 1),
('BS03', N'BS. Lê Hoàng Nam', 'K03', '0903555666', 1);

INSERT INTO LoaiXetNghiem(MaLXN, TenLXN, DonGia) VALUES
('XN01', N'Tổng phân tích tế bào máu', 120000),
('XN02', N'Đo điện tim (ECG)', 150000),
('XN03', N'Nội soi Tai Mũi Họng', 250000),
('XN04', N'Đường huyết (Glucose)', 80000);

INSERT INTO Thuoc(MaThuoc, TenThuoc, DVT, DonGia, CongDung, ChongChiDinh) VALUES
('TH01', N'Paracetamol 500mg', N'Viên', 2500, N'Hạ sốt, giảm đau nhanh', N'Suy gan nặng'),
('TH02', N'Amlodipine 5mg', N'Viên', 6000, N'Điều trị cao huyết áp', N'Hạ huyết áp nghiêm trọng'),
('TH03', N'Augmentin 1g', N'Viên', 18000, N'Kháng sinh điều trị nhiễm khuẩn', N'Dị ứng Penicillin'),
('TH04', N'Omeprazole 20mg', N'Viên', 5000, N'Giảm tiết axit dạ dày', N'Quá mẫn thành phần thuốc');

INSERT INTO BenhNhan(MaBN, HoTen, DiaChi, NgaySinh, GioiTinh, DienThoai, Anh3x4) VALUES
('BN01', N'Cao Vũ Ngọc Lan', N'123 Nguyễn Thị Minh Khai, Q.3, TP.HCM', '2004-05-15', N'Nữ', '0912345678', 'lan_anh.jpg'),
('BN02', N'Trần Quốc Bảo', N'45 Lê Lợi, Q.1, TP.HCM', '1995-10-20', N'Nam', '0987654321', 'bao_anh.jpg');

INSERT INTO HoSoBenhAn(MaHoSo, MaBN, HoTen, DiaChi, NgaySinh, GioiTinh, DienThoai, Anh3x4, LePhiHangNam, HanSuDung, TrangThai) VALUES
('HS001', 'BN01', N'Cao Vũ Ngọc Lan', N'123 Nguyễn Thị Minh Khai, Q.3, TP.HCM', '2004-05-15', N'Nữ', '0912345678', 'lan_anh.jpg', 1200000, '2027-01-10', N'Còn hiệu lực'),
('HS002', 'BN02', N'Trần Quốc Bảo', N'45 Lê Lợi, Q.1, TP.HCM', '1995-10-20', N'Nam', '0987654321', 'bao_anh.jpg', 1200000, '2027-02-15', N'Còn hiệu lực');

INSERT INTO LichKhamDinhKy(MaLK, MaHoSo, NgayGioHen, NgayKhamThucTe, GhiChu, TrangThai) VALUES
('LK001', 'HS001', '2026-11-20 08:30:00', NULL, N'Khám sức khỏe định kỳ quý 4/2026', N'Chờ khám'),
('LK002', 'HS002', '2026-09-10 09:00:00', '2026-09-10 09:15:00', N'Khám định kỳ quý 3/2026', N'Đã khám');

INSERT INTO PhieuKhamBenh(MaPK, MaHoSo, MaBS, MaK, NgayGioKham, TrieuChung, ThanNhiet, HuyetAp, LoaiKham, KetLuan) VALUES
('PK001', 'HS001', 'BS03', 'K03', '2026-09-05 08:30:00', N'Đau rát họng, ho kèm sốt nhẹ', 38.2, '120/80', N'Khám bệnh', N'Viêm họng hạt cấp tính'),
('PK002', 'HS002', 'BS01', 'K01', '2026-09-10 09:15:00', N'Không có triệu chứng bất thường, kiểm tra tổng quát', 36.8, '115/75', N'Khám định kỳ', N'Sức khỏe bình thường, không phát hiện mầm bệnh');

INSERT INTO PhieuXetNghiem(MaPXN, MaPK, MaLXN, NgayGioChiDinh, KetQua, NgayGioCoKetQua, TrangThai) VALUES
('PXN001', 'PK001', 'XN01', '2026-09-05 08:45:00', N'Bạch cầu tăng nhẹ (WBC 11.2 K/uL)', '2026-09-05 09:30:00', N'Đã có kết quả'),
('PXN002', 'PK001', 'XN03', '2026-09-05 08:45:00', N'Niêm mạc họng đỏ, có giả mạc mủ nhẹ', '2026-09-05 09:15:00', N'Đã có kết quả');

INSERT INTO ToaThuoc(MaToa, MaPK, NgayKe, LoiDan, TongTien) VALUES
('TOA001', 'PK001', '2026-09-05 09:45:00', N'Uống sau ăn no, uống nhiều nước ấm, súc họng bằng nước muối', 205000);

-- Nạp chi tiết toa thuốc (MaCTT làm khóa chính)
INSERT INTO ChiTietToaThuoc(MaCTT, MaToa, MaThuoc, SoLuong, LieuLuong, CachDung, DonGia) VALUES
('CTT01', 'TOA001', 'TH01', 10, N'Ngày uống 2 lần, mỗi lần 1 viên', N'Uống khi sốt > 38.5 độ C hoặc đau đầu', 2500),
('CTT02', 'TOA001', 'TH03', 10, N'Ngày uống 2 lần, mỗi lần 1 viên', N'Uống sáng 1 viên, chiều 1 viên sau ăn', 18000);

INSERT INTO HoaDonVienPhi(MaHD, MaPK, NgayThanhToan, TienKham, TienXetNghiem, TienThuoc, TongTien, TrangThai) VALUES
('HD001', 'PK001', '2026-09-05 10:15:00', 150000, 370000, 205000, 725000, N'Đã thanh toán'),
('HD002', 'PK002', '2026-09-10 10:00:00', 0, 0, 0, 0, N'Đã thanh toán');

INSERT INTO TheoDoiSauKham(MaTD, MaPK, MaHoSo, NgayTheoDoi, DienBienBenh, PhanUngPhu, HieuQuaDieuTri) VALUES
('TD001', 'PK001', 'HS001', '2026-09-08', N'Bệnh nhân hết sốt sau 2 ngày, họng bớt đau rát', N'Không có phản ứng phụ với kháng sinh', N'Đạt hiệu quả điều trị tốt');
GO
