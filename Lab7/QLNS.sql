-- 1. KHỞI TẠO CƠ SỞ DỮ LIỆU
CREATE DATABASE QLNS;
GO

USE QLNS;
GO

-- 2. TẠO CÁC BẢNG ĐỘC LẬP TRƯỚC (BẢNG CHA)

-- Bảng Phòng Ban
CREATE TABLE PhongBan (
    MaPB VARCHAR(10) NOT NULL,
    TenPB NVARCHAR(100) NOT NULL,
    DienThoai VARCHAR(15),
    TruongPhong NVARCHAR(100),
    CONSTRAINT PK_PhongBan PRIMARY KEY (MaPB)
);
GO

-- Bảng Quyết Định Khen Thưởng Kỷ Luật
CREATE TABLE QuyetDinhKhenThuongKyLuat (
    MaQDKTKL VARCHAR(10) NOT NULL,
    LoaiQuyetDinh NVARCHAR(50) NOT NULL,     -- 'Khen thưởng' hoặc 'Kỷ luật'
    HinhThuc NVARCHAR(100),                 -- 'Tăng ca', 'Ngày lễ', 'Thưởng tết', 'Nộp phạt'...
    NgayKy DATE NOT NULL,
    SoTien DECIMAL(18, 2) DEFAULT 0,
    NoiDung NVARCHAR(MAX),
    NguoiKy NVARCHAR(100),
    CONSTRAINT PK_QuyetDinhKhenThuongKyLuat PRIMARY KEY (MaQDKTKL)
);
GO

-- 3. BẢNG NHÂN VIÊN VÀ CÁC THỰC THỂ PHỤ THUỘC TRỰC TIẾP

-- Bảng Nhân Viên
CREATE TABLE NhanVien (
    MaNV VARCHAR(10) NOT NULL,
    HoTen NVARCHAR(100) NOT NULL,
    NgaySinh DATE,
    GioiTinh NVARCHAR(10),
    DiaChi NVARCHAR(255),
    DienThoai VARCHAR(15),
    MaPB VARCHAR(10),
    TrangThai NVARCHAR(50),                 -- 'Thử việc', 'Chính thức', 'Đã nghỉ việc'
    CONSTRAINT PK_NhanVien PRIMARY KEY (MaNV),
    CONSTRAINT FK_NhanVien_PhongBan FOREIGN KEY (MaPB) REFERENCES PhongBan(MaPB)
);
GO

-- Bảng Quyết Định Tuyển Dụng (Thử việc)
CREATE TABLE QuyetDinhTuyenDung (
    MaQDTD VARCHAR(10) NOT NULL,
    MaNV VARCHAR(10) NOT NULL,
    MaPB VARCHAR(10) NOT NULL,
    NgayKy DATE NOT NULL,
    NgayBatDauThuViec DATE NOT NULL,
    NgayKetThucThuViec DATE NOT NULL,
    LuongThuViec DECIMAL(18, 2) NOT NULL,
    DieuKhoan NVARCHAR(MAX),
    TrangThai NVARCHAR(50),                 -- 'Đang thử việc', 'Đạt', 'Không đạt'
    CONSTRAINT PK_QuyetDinhTuyenDung PRIMARY KEY (MaQDTD),
    CONSTRAINT FK_QDTD_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV),
    CONSTRAINT FK_QDTD_PhongBan FOREIGN KEY (MaPB) REFERENCES PhongBan(MaPB)
);
GO

-- Bảng Hợp Đồng Lao Động
CREATE TABLE HopDongLaoDong (
    MaHD VARCHAR(10) NOT NULL,
    MaNV VARCHAR(10) NOT NULL,
    LoaiHopDong NVARCHAR(50) NOT NULL,      -- 'Ngắn hạn', 'Dài hạn'
    NgayKy DATE NOT NULL,
    NgayHieuLuc DATE NOT NULL,
    NgayHetHan DATE,
    NoiDung NVARCHAR(MAX),
    CONSTRAINT PK_HopDongLaoDong PRIMARY KEY (MaHD),
    CONSTRAINT FK_HDLD_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
GO

-- Bảng Quyết Định Chức Vụ
CREATE TABLE QuyetDinhChucVu (
    MaQDCV VARCHAR(10) NOT NULL,
    MaNV VARCHAR(10) NOT NULL,
    ChucVu NVARCHAR(50) NOT NULL,
    PhuCapChucVu DECIMAL(18, 2) DEFAULT 0,
    NgayHieuLuc DATE NOT NULL,
    LyDo NVARCHAR(255),
    CONSTRAINT PK_QuyetDinhChucVu PRIMARY KEY (MaQDCV),
    CONSTRAINT FK_QDCV_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
GO

-- Bảng Quyết Định Lương
CREATE TABLE QuyetDinhLuong (
    MaQDL VARCHAR(10) NOT NULL,
    MaNV VARCHAR(10) NOT NULL,
    LuongCoBan DECIMAL(18, 2) NOT NULL,
    PhuCapLuong DECIMAL(18, 2) DEFAULT 0,
    PhuCapDocHai DECIMAL(18, 2) DEFAULT 0,
    NgayHieuLuc DATE NOT NULL,
    CONSTRAINT PK_QuyetDinhLuong PRIMARY KEY (MaQDL),
    CONSTRAINT FK_QDL_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
GO

-- Bảng Hồ Sơ Bảo Hiểm
CREATE TABLE BaoHiem (
    MaBH VARCHAR(10) NOT NULL,
    MaNV VARCHAR(10) NOT NULL,
    SoTheBHYT VARCHAR(20),
    SoSoBHXH VARCHAR(20),
    TyLeDongNV DECIMAL(5, 2) DEFAULT 10.5,  -- 8% BHXH + 1.5% BHYT + 1% BHTN
    TyLeDongCT DECIMAL(5, 2) DEFAULT 21.5,
    NgayThamGia DATE,
    CONSTRAINT PK_BaoHiem PRIMARY KEY (MaBH),
    CONSTRAINT FK_BaoHiem_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
GO

-- 4. BẢNG PHÂN CÔNG, CHẤM CÔNG VÀ PHỤ TRỘI

-- Bảng Kế Hoạch Phân Công
CREATE TABLE KeHoachPhanCong (
    MaKH VARCHAR(10) NOT NULL,
    MaPB VARCHAR(10) NOT NULL,
    TuNgay DATE NOT NULL,
    DenNgay DATE NOT NULL,
    NguoiLap NVARCHAR(100),
    NgayLap DATE NOT NULL,
    CONSTRAINT PK_KeHoachPhanCong PRIMARY KEY (MaKH),
    CONSTRAINT FK_KHPC_PhongBan FOREIGN KEY (MaPB) REFERENCES PhongBan(MaPB)
);
GO

-- Bảng Chấm Công
CREATE TABLE BangChamCong (
    MaCC VARCHAR(10) NOT NULL,
    MaNV VARCHAR(10) NOT NULL,
    Thang INT NOT NULL CHECK (Thang BETWEEN 1 AND 12),
    Nam INT NOT NULL CHECK (Nam >= 2000),
    SoNgayCongChuan DECIMAL(4, 1) DEFAULT 26,
    SoNgayDiLam DECIMAL(4, 1) DEFAULT 0,
    SoNgayNghiCoPhep DECIMAL(4, 1) DEFAULT 0,
    SoNgayNghiKhongPhep DECIMAL(4, 1) DEFAULT 0,
    CONSTRAINT PK_BangChamCong PRIMARY KEY (MaCC),
    CONSTRAINT FK_BCC_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
GO

-- Bảng Phiếu Ghi Nhận Phụ Trội
CREATE TABLE PhieuGhiNhanPhuTroi (
    MaPPT VARCHAR(10) NOT NULL,
    MaPB VARCHAR(10) NOT NULL,
    NgayPhuTroi DATE NOT NULL,
    HinhThucPhuTroi NVARCHAR(50),           -- 'Tăng ca ngày thường', 'Ngày lễ', 'Ngày nghỉ'
    HeSoPhuTroi DECIMAL(3, 2) DEFAULT 1.5,
    NguoiXacNhan NVARCHAR(100),
    CONSTRAINT PK_PhieuGhiNhanPhuTroi PRIMARY KEY (MaPPT),
    CONSTRAINT FK_PGNPT_PhongBan FOREIGN KEY (MaPB) REFERENCES PhongBan(MaPB)
);
GO

-- Bảng Chi Tiết Phụ Trội
CREATE TABLE ChiTietPhuTroi (
    MaCTPT VARCHAR(10) NOT NULL,
    MaPPT VARCHAR(10) NOT NULL,
    MaNV VARCHAR(10) NOT NULL,
    SoGioPhuTroi DECIMAL(4, 1) NOT NULL,
    CongViecCuThe NVARCHAR(255),
    CONSTRAINT PK_ChiTietPhuTroi PRIMARY KEY (MaCTPT),
    CONSTRAINT FK_CTPT_PhieuPhuTroi FOREIGN KEY (MaPPT) REFERENCES PhieuGhiNhanPhuTroi(MaPPT),
    CONSTRAINT FK_CTPT_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
GO

-- 5. BẢNG CHI TIẾT KHEN THƯỞNG KỶ LUẬT VÀ BẢNG LƯƠNG

-- Bảng Chi Tiết Khen Thưởng Kỷ Luật (Áp dụng cho cá nhân NV hoặc tập thể PB)
CREATE TABLE ChiTietKhenThuongKyLuat (
    MaCTKTKL VARCHAR(10) NOT NULL,
    MaQDKTKL VARCHAR(10) NOT NULL,
    MaNV VARCHAR(10) NULL,                  -- Có thể NULL nếu khen thưởng tập thể
    MaPB VARCHAR(10) NULL,                  -- Có thể NULL nếu khen thưởng cá nhân
    SoTienCuThe DECIMAL(18, 2) NOT NULL,
    GhiChu NVARCHAR(255),
    CONSTRAINT PK_ChiTietKhenThuongKyLuat PRIMARY KEY (MaCTKTKL),
    CONSTRAINT FK_CTKTKL_QuyetDinh FOREIGN KEY (MaQDKTKL) REFERENCES QuyetDinhKhenThuongKyLuat(MaQDKTKL),
    CONSTRAINT FK_CTKTKL_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV),
    CONSTRAINT FK_CTKTKL_PhongBan FOREIGN KEY (MaPB) REFERENCES PhongBan(MaPB)
);
GO

-- Bảng Lương Hằng Tháng
CREATE TABLE BangLuong (
    MaBL VARCHAR(10) NOT NULL,
    MaNV VARCHAR(10) NOT NULL,
    Thang INT NOT NULL CHECK (Thang BETWEEN 1 AND 12),
    Nam INT NOT NULL CHECK (Nam >= 2000),
    LuongChinh DECIMAL(18, 2) DEFAULT 0,
    TienPhuTroi DECIMAL(18, 2) DEFAULT 0,
    TienPhuCap DECIMAL(18, 2) DEFAULT 0,
    TienThuong DECIMAL(18, 2) DEFAULT 0,
    TienPhat DECIMAL(18, 2) DEFAULT 0,
    TrichBaoHiem DECIMAL(18, 2) DEFAULT 0,
    ThucLinh DECIMAL(18, 2) DEFAULT 0,
    CONSTRAINT PK_BangLuong PRIMARY KEY (MaBL),
    CONSTRAINT FK_BangLuong_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
GO