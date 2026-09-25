-- 1. T?o Database m?i
CREATE DATABASE QuanLyKhachSan;
GO

USE QuanLyKhachSan;
GO

-- 2. B?ng Khu v?c (BR01)
CREATE TABLE KhuVuc (
    MaKhuVuc VARCHAR(20) PRIMARY KEY,
    TenKhuVuc NVARCHAR(100) NOT NULL
);

-- 3. B?ng Ph?ng (BR01, BR02)
CREATE TABLE Phong (
    SoPhong VARCHAR(20) PRIMARY KEY,
    MaKhuVuc VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES KhuVuc(MaKhuVuc),
    SoNguoiToiDa INT NOT NULL CHECK (SoNguoiToiDa > 0),
    DonGiaNgay DECIMAL(18, 0) NOT NULL CHECK (DonGiaNgay >= 0),
    TrangThaiPhong NVARCHAR(50) DEFAULT N'Tr?ng'
);

-- 4. B?ng Lo?i ti?n nghi (BR03)
CREATE TABLE LoaiTienNghi (
    MaLoaiTienNghi VARCHAR(20) PRIMARY KEY,
    TenLoaiTienNghi NVARCHAR(100) NOT NULL
);

-- 5. B?ng Ti?n nghi c? th? (BR03)
CREATE TABLE TienNghi (
    MaTienNghi VARCHAR(20) PRIMARY KEY,
    MaLoaiTienNghi VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES LoaiTienNghi(MaLoaiTienNghi),
    SoThuTu INT NOT NULL,
    TrangThai NVARCHAR(50) DEFAULT N'T?t'
);

-- 6. B?ng Phi?u l?p ð?t luân chuy?n (BR04: 1 thi?t b? ch? l?p 1 ph?ng trong 1 ngày)
CREATE TABLE PhieuLapDat (
    MaPhieuLapDat VARCHAR(20) PRIMARY KEY,
    SoPhong VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES Phong(SoPhong),
    MaTienNghi VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES TienNghi(MaTienNghi),
    NgayLap DATE NOT NULL,
    TinhTrang NVARCHAR(100) DEFAULT N'Ho?t ð?ng t?t',
    CONSTRAINT UQ_TienNghi_NgayLap UNIQUE (MaTienNghi, NgayLap)
);

-- 7. B?ng Khách hàng
CREATE TABLE KhachHang (
    MaKhach VARCHAR(20) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    SoDienThoai VARCHAR(20),
    Email VARCHAR(100),
    CCCD VARCHAR(20)
);

-- 8. B?ng Nhân viên
CREATE TABLE NhanVien (
    MaNV VARCHAR(20) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    ChucVu NVARCHAR(50),
    SoDienThoai VARCHAR(20)
);

-- 9. B?ng Phi?u ð?t ph?ng (BR05)
CREATE TABLE PhieuDatPhong (
    MaPhieuDat VARCHAR(20) PRIMARY KEY,
    SoPhong VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES Phong(SoPhong),
    MaKhach VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES KhachHang(MaKhach),
    MaNV VARCHAR(20) FOREIGN KEY REFERENCES NhanVien(MaNV),
    NgayDat DATETIME DEFAULT GETDATE(),
    NgayNhan DATETIME NOT NULL,
    NgayTraDuKien DATETIME NOT NULL,
    TienCoc DECIMAL(18, 0) DEFAULT 0 CHECK (TienCoc >= 0),
    TrangThai NVARCHAR(50) DEFAULT N'Ð? ð?t' -- 'Ð? ð?t', 'Ðang ?', 'Ð? tr? ph?ng', 'Ð? h?y'
);

-- 10. B?ng Ngý?i lýu trú (BR06)
CREATE TABLE NguoiLuuTru (
    MaLuuTru INT IDENTITY(1,1) PRIMARY KEY,
    MaPhieuDat VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES PhieuDatPhong(MaPhieuDat),
    CCCD VARCHAR(20) NOT NULL,
    HoTen NVARCHAR(100) NOT NULL,
    QuocTich NVARCHAR(50) NOT NULL
);

-- 11. B?ng D?ch v?
CREATE TABLE DichVu (
    MaDichVu VARCHAR(20) PRIMARY KEY,
    TenDichVu NVARCHAR(100) NOT NULL,
    DonGia DECIMAL(18, 0) NOT NULL CHECK (DonGia >= 0)
);

-- 12. B?ng Chi ti?t s? d?ng d?ch v? (BR07: c?ng d?n theo ngày)
CREATE TABLE ChiTietSuDungDichVu (
    MaChiTiet INT IDENTITY(1,1) PRIMARY KEY,
    MaPhieuDat VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES PhieuDatPhong(MaPhieuDat),
    MaDichVu VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES DichVu(MaDichVu),
    NgaySuDung DATE NOT NULL,
    SoLuong INT NOT NULL CHECK (SoLuong > 0),
    DonGia DECIMAL(18, 0) NOT NULL,
    ThanhTien DECIMAL(18, 0) NOT NULL
);

-- 13. B?ng Quy ð?nh ð?n bù (BR08)
CREATE TABLE QuyDinhDenBu (
    MaQuyDinh VARCHAR(20) PRIMARY KEY,
    MaLoaiTienNghi VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES LoaiTienNghi(MaLoaiTienNghi),
    MucDoHuHong NVARCHAR(100) NOT NULL,
    GiaDenBu DECIMAL(18, 0) NOT NULL CHECK (GiaDenBu >= 0)
);

-- 14. B?ng Phi?u ð?n bù (BR08)
CREATE TABLE PhieuDenBu (
    MaPhieuDenBu VARCHAR(20) PRIMARY KEY,
    MaPhieuDat VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES PhieuDatPhong(MaPhieuDat),
    MaTienNghi VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES TienNghi(MaTienNghi),
    MucDoHuHong NVARCHAR(100) NOT NULL,
    GiaDenBu DECIMAL(18, 0) NOT NULL CHECK (GiaDenBu >= 0),
    LyDo NVARCHAR(255),
    NgayLap DATETIME DEFAULT GETDATE()
);

-- 15. B?ng Hóa ðõn (BR09)
CREATE TABLE HoaDon (
    MaHoaDon VARCHAR(20) PRIMARY KEY,
    MaPhieuDat VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES PhieuDatPhong(MaPhieuDat),
    MaNV VARCHAR(20) FOREIGN KEY REFERENCES NhanVien(MaNV),
    NgayLap DATETIME DEFAULT GETDATE(),
    TongTien DECIMAL(18, 0) NOT NULL CHECK (TongTien >= 0),
    TrangThai NVARCHAR(50) DEFAULT N'Chýa thanh toán'
);

-- 16. B?ng Thanh toán (BR10: Ti?n m?t, Chuy?n kho?n, Th?, Ví ði?n t?)
CREATE TABLE ThanhToan (
    MaThanhToan INT IDENTITY(1,1) PRIMARY KEY,
    MaHoaDon VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES HoaDon(MaHoaDon),
    NgayThanhToan DATETIME DEFAULT GETDATE(),
    PhuongThuc NVARCHAR(50) NOT NULL,
    SoTien DECIMAL(18, 0) NOT NULL CHECK (SoTien > 0)
);
GO

-- 17. Chèn d? li?u kh?i t?o m?u
INSERT INTO KhuVuc VALUES ('KV01', N'Khu T?a Nhà A'), ('KV02', N'Khu Villa Bi?t Th?');
INSERT INTO Phong VALUES 
('P101', 'KV01', 2, 500000, N'Tr?ng'),
('P102', 'KV01', 4, 900000, N'Tr?ng'),
('V201', 'KV02', 6, 2500000, N'Tr?ng');

INSERT INTO LoaiTienNghi VALUES 
('TN_TV', N'Tivi Samsung 55 inch'),
('TN_TL', N'T? l?nh mini Toshiba'),
('TN_DT', N'Ði?n tho?i bàn');

INSERT INTO TienNghi VALUES 
('TN001', 'TN_TV', 1, N'T?t'),
('TN002', 'TN_TL', 1, N'T?t'),
('TN003', 'TN_DT', 1, N'T?t');

INSERT INTO DichVu VALUES 
('DV01', N'Ný?c su?i Aquafina', 15000),
('DV02', N'Gi?t ?i qu?n áo', 50000),
('DV03', N'Buffet sáng', 120000);

INSERT INTO QuyDinhDenBu VALUES 
('QD01', 'TN_TV', N'B? màn h?nh', 3000000),
('QD02', 'TN_TL', N'Hý block l?nh', 1500000),
('QD03', 'TN_DT', N'M?t / Ð?t dây', 200000);

INSERT INTO NhanVien VALUES 
('NV01', N'Tr?n Vãn L?', N'L? tân', '0901112223'),
('NV02', N'Nguy?n Th? Ph?c', N'Ph?c v?', '0902223334');

INSERT INTO KhachHang VALUES 
('KH01', N'Lê Minh Tu?n', '0912345678', 'tuan@gmail.com', '079201001234');
GO