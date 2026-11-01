
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'QuanLyChoThueCaoOc')
BEGIN
    ALTER DATABASE QuanLyChoThueCaoOc SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QuanLyChoThueCaoOc;
END
GO

CREATE DATABASE QuanLyChoThueCaoOc;
GO

USE QuanLyChoThueCaoOc;
GO

-- 1. BẢNG PHÒNG (VĂN PHÒNG CHO THUÊ)
CREATE TABLE Phong (
    MaPhong VARCHAR(10) NOT NULL,
    TenPhong NVARCHAR(50) NOT NULL,
    SoTang INT NOT NULL,
    DoCao DECIMAL(10, 2) NOT NULL,
    DienTich DECIMAL(10, 2) NOT NULL,
    HuongPhong NVARCHAR(50) NOT NULL,
    DonGiaThue DECIMAL(18, 2) NOT NULL,
    TrangThai NVARCHAR(50) NOT NULL DEFAULT N'Trống',
    CONSTRAINT PK_Phong PRIMARY KEY (MaPhong),
    CONSTRAINT CK_Phong_DienTich CHECK (DienTich > 0),
    CONSTRAINT CK_Phong_GiaThue CHECK (DonGiaThue >= 0),
    CONSTRAINT CK_Phong_TrangThai CHECK (TrangThai IN (N'Trống', N'Đang thuê', N'Cần tu sửa', N'Đang sửa chữa'))
);
GO

-- 2. BẢNG KHÁCH HÀNG (DOANH NGHIỆP / CÔNG TY THUÊ)
CREATE TABLE KhachHang (
    MaKH VARCHAR(10) NOT NULL,
    TenCongTy NVARCHAR(150) NOT NULL,
    NguoiDaiDien NVARCHAR(100) NOT NULL,
    MaSoThue VARCHAR(20) NOT NULL,
    DienThoai VARCHAR(15) NOT NULL,
    Email VARCHAR(100) NULL,
    DiaChi NVARCHAR(255) NOT NULL,
    CONSTRAINT PK_KhachHang PRIMARY KEY (MaKH),
    CONSTRAINT UQ_KhachHang_MST UNIQUE (MaSoThue)
);
GO

-- 3. BẢNG HỢP ĐỒNG THUÊ
CREATE TABLE HopDongThue (
    MaHD VARCHAR(10) NOT NULL,
    NgayKy DATE NOT NULL,
    NgayBatDau DATE NOT NULL,
    NgayKetThuc DATE NOT NULL,
    ThoiHanThue INT NOT NULL, 
    TienCoc DECIMAL(18, 2) NOT NULL DEFAULT 0,
    TongTien6ThangDau DECIMAL(18, 2) NOT NULL DEFAULT 0, 
    TrangThai NVARCHAR(50) NOT NULL DEFAULT N'Hiệu lực',
    MaKH VARCHAR(10) NOT NULL,
    CONSTRAINT PK_HopDongThue PRIMARY KEY (MaHD),
    CONSTRAINT FK_HopDong_KhachHang FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH),
    CONSTRAINT CK_HopDong_ThoiHan CHECK (ThoiHanThue >= 6),
    CONSTRAINT CK_HopDong_Ngay CHECK (NgayKetThuc > NgayBatDau),
    CONSTRAINT CK_HopDong_TrangThai CHECK (TrangThai IN (N'Hiệu lực', N'Hết hạn', N'Đã thanh lý'))
);
GO

-- 4. BẢNG CHI TIẾT THUÊ PHÒNG 
CREATE TABLE ChiTietThuePhong (
    MaCTTP VARCHAR(10) NOT NULL,
    MaHD VARCHAR(10) NOT NULL,
    MaPhong VARCHAR(10) NOT NULL,
    DonGiaThue DECIMAL(18, 2) NOT NULL,
    TienThueThang DECIMAL(18, 2) NOT NULL,
    GhiChu NVARCHAR(255) NULL,
    CONSTRAINT PK_ChiTietThuePhong PRIMARY KEY (MaCTTP),
    CONSTRAINT FK_CTTP_HopDong FOREIGN KEY (MaHD) REFERENCES HopDongThue(MaHD) ON DELETE CASCADE,
    CONSTRAINT FK_CTTP_Phong FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong),
    CONSTRAINT UQ_HD_Phong UNIQUE (MaHD, MaPhong)
);
GO

-- 5. BẢNG PHIẾU GIA HẠN 
CREATE TABLE PhieuGiaHan (
    MaPGH VARCHAR(10) NOT NULL,
    NgayLap DATE NOT NULL,
    ThoiGianGiaHan INT NOT NULL, 
    NgayKetThucMoi DATE NOT NULL,
    TrangThaiDuyet NVARCHAR(50) NOT NULL DEFAULT N'Chờ duyệt',
    LyDo NVARCHAR(255) NULL,
    MaHD VARCHAR(10) NOT NULL,
    MaPhong VARCHAR(10) NOT NULL,
    CONSTRAINT PK_PhieuGiaHan PRIMARY KEY (MaPGH),
    CONSTRAINT FK_PGH_HopDong FOREIGN KEY (MaHD) REFERENCES HopDongThue(MaHD),
    CONSTRAINT FK_PGH_Phong FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong),
    CONSTRAINT CK_PGH_ThoiGian CHECK (ThoiGianGiaHan > 0),
    CONSTRAINT CK_PGH_TrangThai CHECK (TrangThaiDuyet IN (N'Chờ duyệt', N'Đã duyệt', N'Từ chối'))
);
GO

-- 6. BẢNG HÓA ĐƠN 
CREATE TABLE HoaDon (
    MaHoaDon VARCHAR(10) NOT NULL,
    LoaiHoaDon NVARCHAR(50) NOT NULL,
    TenDichVu NVARCHAR(50) NULL,      
    KyThang INT NOT NULL,
    KyNam INT NOT NULL,
    NgayLap DATE NOT NULL,
    HanThanhToan DATE NOT NULL,
    ChiSoDau DECIMAL(10, 2) NULL DEFAULT 0,
    ChiSoCuoi DECIMAL(10, 2) NULL DEFAULT 0,
    SoLuongTieuThu DECIMAL(10, 2) NULL DEFAULT 0,
    SoTien DECIMAL(18, 2) NOT NULL,
    NgayThanhToan DATE NULL,
    TrangThai NVARCHAR(50) NOT NULL DEFAULT N'Chưa thanh toán',
    MaHD VARCHAR(10) NULL,
    MaPhong VARCHAR(10) NOT NULL,
    CONSTRAINT PK_HoaDon PRIMARY KEY (MaHoaDon),
    CONSTRAINT FK_HoaDon_HopDong FOREIGN KEY (MaHD) REFERENCES HopDongThue(MaHD),
    CONSTRAINT FK_HoaDon_Phong FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong),
    CONSTRAINT CK_HoaDon_KyThang CHECK (KyThang BETWEEN 1 AND 12),
    CONSTRAINT CK_HoaDon_SoTien CHECK (SoTien >= 0),
    CONSTRAINT CK_HoaDon_TrangThai CHECK (TrangThai IN (N'Chưa thanh toán', N'Đã thanh toán'))
);
GO

-- 7. BẢNG NHÂN VIÊN VĂN PHÒNG (KHÁCH THUÊ BÁO CÁO NHÂN SỰ CHO CAO ỐC)
CREATE TABLE NhanVienVanPhong (
    MaNV VARCHAR(10) NOT NULL,
    HoTen NVARCHAR(100) NOT NULL,
    NgaySinh DATE NULL,
    Phai NVARCHAR(10) NOT NULL,
    DienThoai VARCHAR(15) NULL,
    ChucVu NVARCHAR(50) NOT NULL,
    HinhAnh NVARCHAR(255) NULL,
    NgayBaoCao DATE NOT NULL,
    TrangThaiLamViec NVARCHAR(50) NOT NULL DEFAULT N'Đang làm việc',
    MaKH VARCHAR(10) NOT NULL,
    MaPhong VARCHAR(10) NOT NULL,
    CONSTRAINT PK_NhanVienVanPhong PRIMARY KEY (MaNV),
    CONSTRAINT FK_NVVP_KhachHang FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH),
    CONSTRAINT FK_NVVP_Phong FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong),
    CONSTRAINT CK_NVVP_Phai CHECK (Phai IN (N'Nam', N'Nữ'))
);
GO

-- 8. BẢNG THẺ GIỮ XE (CẤP CHO NHÂN VIÊN, MỖI NV CÓ TỐI ĐA 1 THẺ)
CREATE TABLE TheGiuXe (
    MaThe VARCHAR(10) NOT NULL,
    NgayCap DATE NOT NULL,
    BienSoXe VARCHAR(20) NOT NULL,
    LoaiXe NVARCHAR(50) NOT NULL, -- Xe máy, Ô tô
    HieuXe NVARCHAR(50) NULL,     -- Honda, Toyota...
    MauXe NVARCHAR(50) NULL,
    TrangThaiThe NVARCHAR(50) NOT NULL DEFAULT N'Đang dùng',
    MaNV VARCHAR(10) NOT NULL,
    CONSTRAINT PK_TheGiuXe PRIMARY KEY (MaThe),
    CONSTRAINT FK_TheGiuXe_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVienVanPhong(MaNV) ON DELETE CASCADE,
    CONSTRAINT UQ_TheGiuXe_NhanVien UNIQUE (MaNV) -- Quan hệ 1 - 1
);
GO

-- 9. BẢNG KIỂM TRA ĐỊNH KỲ & XỬ PHẠT VI PHẠM KẾT CẤU
CREATE TABLE KiemTra_XuPhat (
    MaBB VARCHAR(10) NOT NULL,
    NgayLap DATE NOT NULL,
    LoaiBienBan NVARCHAR(50) NOT NULL, -- N'Kiểm tra định kỳ 1 năm' hoặc N'Phạt thay đổi kết cấu'
    MoTaKetQua NVARCHAR(255) NOT NULL,
    SoTienPhat DECIMAL(18, 2) NOT NULL DEFAULT 0,
    BienPhapKhacPhuc NVARCHAR(255) NULL,
    TrangThai NVARCHAR(50) NOT NULL DEFAULT N'Chờ xử lý',
    MaPhong VARCHAR(10) NOT NULL,
    CONSTRAINT PK_KiemTra_XuPhat PRIMARY KEY (MaBB),
    CONSTRAINT FK_KiemTra_Phong FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong),
    CONSTRAINT CK_KiemTra_Loai CHECK (LoaiBienBan IN (N'Kiểm tra định kỳ 1 năm', N'Phạt thay đổi kết cấu')),
    CONSTRAINT CK_KiemTra_Phat CHECK (SoTienPhat >= 0)
);
GO




INSERT INTO Phong (MaPhong, TenPhong, SoTang, DoCao, DienTich, HuongPhong, DonGiaThue, TrangThai) VALUES
('P0301', N'Phòng 301', 3, 12.5, 80.0, N'Đông Nam', 25000000, N'Đang thuê'),
('P0302', N'Phòng 302', 3, 12.5, 120.0, N'Nam', 35000000, N'Đang thuê'),
('P0501', N'Phòng 501', 5, 20.0, 150.0, N'Đông', 45000000, N'Trống'),
('P0801', N'Phòng 801', 8, 32.0, 200.0, N'Tây Nam', 65000000, N'Cần tu sửa');


INSERT INTO KhachHang (MaKH, TenCongTy, NguoiDaiDien, MaSoThue, DienThoai, Email, DiaChi) VALUES
('KH001', N'Công ty Cổ phần Công nghệ VNTech', N'Nguyễn Văn An', '0312456789', '0903123456', 'contact@vntech.com', N'Tầng 3, Cao ốc Landmark, Q.1, TP.HCM'),
('KH002', N'Tập đoàn Thiết kế & Truyền thông Á Châu', N'Trần Thị Bích', '0319876543', '0918654321', 'info@asiadesign.vn', N'Tầng 5, Tòa nhà Bitexco, Q.1, TP.HCM');


INSERT INTO HopDongThue (MaHD, NgayKy, NgayBatDau, NgayKetThuc, ThoiHanThue, TienCoc, TongTien6ThangDau, TrangThai, MaKH) VALUES
('HD2601', '2026-01-01', '2026-01-01', '2026-12-31', 12, 60000000, 360000000, N'Hiệu lực', 'KH001');


INSERT INTO ChiTietThuePhong (MaCTTP, MaHD, MaPhong, DonGiaThue, TienThueThang, GhiChu) VALUES
('CT001', 'HD2601', 'P0301', 25000000, 25000000, N'Văn phòng bộ phận IT & Phần mềm'),
('CT002', 'HD2601', 'P0302', 35000000, 35000000, N'Văn phòng Ban Giám đốc & Kế toán');


INSERT INTO NhanVienVanPhong (MaNV, HoTen, NgaySinh, Phai, DienThoai, ChucVu, HinhAnh, NgayBaoCao, TrangThaiLamViec, MaKH, MaPhong) VALUES
('NV001', N'Lê Minh Trí', '1995-04-12', N'Nam', '0987111222', N'Trưởng phòng IT', 'tri_lm.png', '2026-01-05', N'Đang làm việc', 'KH001', 'P0301'),
('NV002', N'Phạm Ngọc Lan', '1998-08-20', N'Nữ', '0978333444', N'Kế toán trưởng', 'lan_pn.png', '2026-01-05', N'Đang làm việc', 'KH001', 'P0302');


INSERT INTO TheGiuXe (MaThe, NgayCap, BienSoXe, LoaiXe, HieuXe, MauXe, TrangThaiThe, MaNV) VALUES
('TX001', '2026-01-06', '59-B1 123.45', N'Xe máy', 'Honda SH', N'Đen', N'Đang dùng', 'NV001'),
('TX002', '2026-01-06', '51-A 987.65', N'Ô tô', 'Mazda 3', N'Trắng', N'Đang dùng', 'NV002');


INSERT INTO HoaDon (MaHoaDon, LoaiHoaDon, TenDichVu, KyThang, KyNam, NgayLap, HanThanhToan, ChiSoDau, ChiSoCuoi, SoLuongTieuThu, SoTien, NgayThanhToan, TrangThai, MaHD, MaPhong) VALUES
('HDT0701', N'Tiền phòng', NULL, 7, 2026, '2026-07-01', '2026-07-05', 0, 0, 0, 60000000, '2026-07-03', N'Đã thanh toán', 'HD2601', 'P0301'),
('HDDV0701', N'Tiền dịch vụ', N'Điện', 7, 2026, '2026-07-31', '2026-08-05', 1250, 1850, 600, 2100000, '2026-08-02', N'Đã thanh toán', 'HD2601', 'P0301'),
('HDDV0702', N'Tiền dịch vụ', N'Nước', 7, 2026, '2026-07-31', '2026-08-05', 45, 65, 20, 300000, '2026-08-02', N'Đã thanh toán', 'HD2601', 'P0301');


INSERT INTO PhieuGiaHan (MaPGH, NgayLap, ThoiGianGiaHan, NgayKetThucMoi, TrangThaiDuyet, LyDo, MaHD, MaPhong) VALUES
('PGH01', '2026-11-15', 4, '2027-04-30', N'Đã duyệt', N'Gia hạn hợp đồng phòng 301 thêm 4 tháng', 'HD2601', 'P0301');


INSERT INTO KiemTra_XuPhat (MaBB, NgayLap, LoaiBienBan, MoTaKetQua, SoTienPhat, BienPhapKhacPhuc, TrangThai, MaPhong) VALUES
('BBKT01', '2026-06-15', N'Kiểm tra định kỳ 1 năm', N'Hệ thống điều hòa và phòng cháy chữa cháy hoạt động tốt', 0, NULL, N'Đã kiểm tra', 'P0301'),
('BBP001', '2026-08-10', N'Phạt thay đổi kết cấu', N'Tự ý đập bỏ vách ngăn thạch cao thông sang hành lang không báo trước', 10000000, N'Buộc khôi phục nguyên trạng vách ngăn trong 7 ngày', N'Chờ xử lý', 'P0302');
GO


SELECT * FROM Phong;
SELECT * FROM KhachHang;
SELECT * FROM HopDongThue;
SELECT * FROM ChiTietThuePhong;
SELECT * FROM HoaDon;
SELECT * FROM PhieuGiaHan;
SELECT * FROM NhanVienVanPhong;
SELECT * FROM TheGiuXe;
SELECT * FROM KiemTra_XuPhat;
GO