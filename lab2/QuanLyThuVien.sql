-- 1. Tạo cơ sở dữ liệu
CREATE DATABASE QuanLyThuVienDB;
GO

USE QuanLyThuVienDB;
GO

-- 2. Tạo bảng NhanVien
CREATE TABLE NhanVien (
    MaNhanVien NVARCHAR(20) PRIMARY KEY,
    Ho NVARCHAR(50) NOT NULL,
    Ten NVARCHAR(20) NOT NULL,
    Phai NVARCHAR(10) NULL,
    NgaySinh DATE NULL,
    ChucVu NVARCHAR(50) NULL,
    SoDienThoai NVARCHAR(20) NULL
);
GO

-- 3. Tạo bảng TheLoai
CREATE TABLE TheLoai (
    MaTheLoai NVARCHAR(20) PRIMARY KEY,
    TenTheLoai NVARCHAR(100) NOT NULL
);
GO

-- 4. Tạo bảng NhaXuatBan
CREATE TABLE NhaXuatBan (
    MaNhaXuatBan NVARCHAR(20) PRIMARY KEY,
    DiaChi NVARCHAR(200) NULL,
    SoDienThoai NVARCHAR(20) NULL
);
GO

-- 5. Tạo bảng DauSach
CREATE TABLE DauSach (
    MaDauSach NVARCHAR(20) PRIMARY KEY,
    TenSach NVARCHAR(200) NOT NULL,
    NamXuatBan INT NULL,
    SoLuongHienCo INT NOT NULL CONSTRAINT DF_DauSach_SoLuong DEFAULT 0,
    MaTheLoai NVARCHAR(20) NOT NULL,
    MaNhaXuatBan NVARCHAR(20) NOT NULL,
    CONSTRAINT CK_DauSach_SoLuong CHECK (SoLuongHienCo >= 0),
    CONSTRAINT FK_DauSach_TheLoai FOREIGN KEY (MaTheLoai) REFERENCES TheLoai(MaTheLoai),
    CONSTRAINT FK_DauSach_NhaXuatBan FOREIGN KEY (MaNhaXuatBan) REFERENCES NhaXuatBan(MaNhaXuatBan)
);
GO

-- 6. Tạo bảng DocGia
CREATE TABLE DocGia (
    MaDocGia NVARCHAR(20) PRIMARY KEY,
    Ho NVARCHAR(50) NOT NULL,
    Ten NVARCHAR(20) NOT NULL,
    NgaySinh DATE NULL,
    Phai NVARCHAR(10) NULL,
    SoDienThoai NVARCHAR(20) NULL,
    DiaChi NVARCHAR(200) NULL,
    Email NVARCHAR(100) NULL,
    Anh3x4 NVARCHAR(255) NULL
);
GO

-- 7. Tạo bảng TheDocGia (Ràng buộc mỗi độc giả chỉ có 1 thẻ hoạt động tại 1 thời điểm)
CREATE TABLE TheDocGia (
    MaThe NVARCHAR(20) PRIMARY KEY,
    MaDocGia NVARCHAR(20) NOT NULL,
    NgayCap DATE NOT NULL,
    HanSuDung DATE NOT NULL,
    DaDongLePhi BIT NOT NULL CONSTRAINT DF_TheDocGia_LePhi DEFAULT 0,
    TrangThai BIT NOT NULL CONSTRAINT DF_TheDocGia_TrangThai DEFAULT 1,
    CONSTRAINT CK_TheDocGia_Han CHECK (HanSuDung >= NgayCap),
    CONSTRAINT FK_TheDocGia_DocGia FOREIGN KEY (MaDocGia) REFERENCES DocGia(MaDocGia)
);
GO

-- Filtered Index đảm bảo tại một thời điểm chỉ có duy nhất 1 thẻ có TrangThai = 1
CREATE UNIQUE INDEX UX_TheDocGia_MotTheHoatDong 
ON TheDocGia(MaDocGia) 
WHERE TrangThai = 1;
GO

-- 8. Tạo bảng PhieuMuon
CREATE TABLE PhieuMuon (
    MaPhieuMuon NVARCHAR(20) PRIMARY KEY,
    MaDocGia NVARCHAR(20) NOT NULL,
    MaNhanVien NVARCHAR(20) NOT NULL,
    NgayMuon DATE NOT NULL,
    NgayHenTra DATE NOT NULL,
    CONSTRAINT CK_PhieuMuon_Ngay CHECK (NgayHenTra >= NgayMuon),
    CONSTRAINT FK_PhieuMuon_DocGia FOREIGN KEY (MaDocGia) REFERENCES DocGia(MaDocGia),
    CONSTRAINT FK_PhieuMuon_NhanVien FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien)
);
GO

-- 9. Tạo bảng ChiTietPhieuMuon (Chặn mượn 2 sách cùng 1 đầu sách trong 1 phiếu)
CREATE TABLE ChiTietPhieuMuon (
    MaChiTiet NVARCHAR(20) PRIMARY KEY,
    MaPhieuMuon NVARCHAR(20) NOT NULL,
    MaDauSach NVARCHAR(20) NOT NULL,
    NgayTraThucTe DATE NULL,
    TinhTrangTra NVARCHAR(50) NULL,
    CONSTRAINT UQ_ChiTiet_Phieu_DauSach UNIQUE (MaPhieuMuon, MaDauSach),
    CONSTRAINT FK_ChiTiet_PhieuMuon FOREIGN KEY (MaPhieuMuon) REFERENCES PhieuMuon(MaPhieuMuon),
    CONSTRAINT FK_ChiTiet_DauSach FOREIGN KEY (MaDauSach) REFERENCES DauSach(MaDauSach)
);
GO

-- 10. Tạo bảng PhieuPhat
CREATE TABLE PhieuPhat (
    MaPhieuPhat NVARCHAR(20) PRIMARY KEY,
    MaChiTiet NVARCHAR(20) NOT NULL,
    MaNhanVien NVARCHAR(20) NOT NULL,
    NgayPhat DATE NOT NULL,
    LyDo NVARCHAR(200) NOT NULL,
    PhiPhat DECIMAL(18, 2) NOT NULL CONSTRAINT DF_PhieuPhat_Phi DEFAULT 0,
    CONSTRAINT CK_PhieuPhat_Phi CHECK (PhiPhat >= 0),
    CONSTRAINT FK_PhieuPhat_ChiTiet FOREIGN KEY (MaChiTiet) REFERENCES ChiTietPhieuMuon(MaChiTiet),
    CONSTRAINT FK_PhieuPhat_NhanVien FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien)
);
GO

-- 11. Thêm dữ liệu mẫu ban đầu để test giao diện
INSERT INTO NhanVien (MaNhanVien, Ho, Ten, Phai, NgaySinh, ChucVu, SoDienThoai) VALUES
('NV01', N'Nguyễn Văn', N'An', N'Nam', '1990-01-15', N'Thủ thư', '0901234567'),
('NV02', N'Trần Thị', N'Bình', N'Nữ', '1995-05-20', N'Quản lý sách', '0912345678');

INSERT INTO TheLoai (MaTheLoai, TenTheLoai) VALUES
('TL01', N'Công nghệ thông tin'),
('TL02', N'Kinh tế'),
('TL03', N'Văn học');

INSERT INTO NhaXuatBan (MaNhaXuatBan, DiaChi, SoDienThoai) VALUES
('NXB01', N'Hà Nội', '0241111222'),
('NXB02', N'TP. Hồ Chí Minh', '0283333444');

INSERT INTO DauSach (MaDauSach, TenSach, NamXuatBan, SoLuongHienCo, MaTheLoai, MaNhaXuatBan) VALUES
('DS01', N'Lập trình C# WinForms cơ bản', 2023, 5, 'TL01', 'NXB01'),
('DS02', N'Phân tích thiết kế hệ thống với UML', 2022, 3, 'TL01', 'NXB02'),
('DS03', N'Kinh tế học vi mô', 2021, 2, 'TL02', 'NXB01');

INSERT INTO DocGia (MaDocGia, Ho, Ten, NgaySinh, Phai, SoDienThoai, DiaChi, Email, Anh3x4) VALUES
('DG01', N'Lê Hoàng', N'Nam', '2003-03-10', N'Nam', '0988776655', N'123 Lê Lợi', 'nam@gmail.com', 'nam.jpg');

INSERT INTO TheDocGia (MaThe, MaDocGia, NgayCap, HanSuDung, DaDongLePhi, TrangThai) VALUES
('THE01', 'DG01', '2026-01-01', '2026-12-31', 1, 1);
GO