----------------------------------------------------------------------------------------------------
-- HỆ THỐNG QUẢN LÝ BÁN HÀNG TRỰC TUYẾN E-SHOPPING
-- CƠ SỞ DỮ LIỆU: eShoppingDB
----------------------------------------------------------------------------------------------------

-- 1. TẠO CƠ SỞ DỮ LIỆU (Nếu đã tồn tại sẽ xóa tạo mới để đồng bộ)
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'eShoppingDB')
BEGIN
    ALTER DATABASE eShoppingDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE eShoppingDB;
END
GO

CREATE DATABASE eShoppingDB;
GO

USE eShoppingDB;
GO

----------------------------------------------------------------------------------------------------
-- 2. TẠO CÁC BẢNG DỮ LIỆU (TABLES & CONSTRAINTS)
----------------------------------------------------------------------------------------------------

-- Bảng 1: Nhóm sản phẩm (Máy chụp hình, Đồ chơi, Gia dụng, Máy tính...)
CREATE TABLE NhomSanPham (
    MaNhom INT PRIMARY KEY,
    TenNhom NVARCHAR(150) NOT NULL,
    MoTa NVARCHAR(255)
);
GO

-- Bảng 2: Sản phẩm (Tên, mã, hãng SX, hình ảnh, mô tả, thông số kỹ thuật, giá, tình trạng hàng)
CREATE TABLE SanPham (
    MaSanPham VARCHAR(20) PRIMARY KEY,
    MaNhom INT NOT NULL,
    TenSanPham NVARCHAR(255) NOT NULL,
    NhaSanXuat NVARCHAR(100) NOT NULL,
    HinhAnh VARCHAR(255),
    MoTa NVARCHAR(MAX),
    ThongSoKyThuat NVARCHAR(MAX),
    GiaHienHanh DECIMAL(18,2) NOT NULL CHECK (GiaHienHanh >= 0),
    TinhTrangHang NVARCHAR(30) NOT NULL DEFAULT N'Còn hàng' CHECK (TinhTrangHang IN (N'Còn hàng', N'Hết hàng')),
    CONSTRAINT FK_SanPham_NhomSanPham FOREIGN KEY (MaNhom) REFERENCES NhomSanPham(MaNhom)
);
GO

-- Bảng 3: Khách hàng (Họ tên, ngày sinh, CMND/Passport, địa chỉ, ĐT, tài khoản, mật khẩu, email)
CREATE TABLE KhachHang (
    MaKhachHang INT IDENTITY(1,1) PRIMARY KEY,
    TenDangNhap VARCHAR(50) NOT NULL UNIQUE,
    MatKhauHash VARCHAR(256) NOT NULL,
    HoTen NVARCHAR(100) NOT NULL,
    NgaySinh DATE NOT NULL,
    CMND_Passport VARCHAR(25) NOT NULL UNIQUE,
    DiaChi NVARCHAR(255) NOT NULL,
    SoDienThoai VARCHAR(15) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    NgayTao DATETIME DEFAULT GETDATE()
);
GO

-- Bảng 4: Loại hình giao hàng (BR01 - Thường, Nhanh, Trong ngày)
CREATE TABLE LoaiGiaoHang (
    MaLoaiGiaoHang INT PRIMARY KEY,
    TenLoai NVARCHAR(100) NOT NULL,
    PhiCoBan DECIMAL(18,2) NOT NULL CHECK (PhiCoBan >= 0),
    ThoiGianXuLy NVARCHAR(50) NOT NULL
);
GO

-- Bảng 5: Phiếu đặt hàng (Mã phiếu, khách đặt, loại giao hàng, tiền hàng, phí giao, tổng thanh toán)
CREATE TABLE PhieuDatHang (
    MaPhieuDat INT IDENTITY(1001,1) PRIMARY KEY,
    MaKhachHang INT NOT NULL,
    NgayDat DATETIME DEFAULT GETDATE(),
    MaLoaiGiaoHang INT NOT NULL,
    TongTienHang DECIMAL(18,2) NOT NULL CHECK (TongTienHang >= 0),
    PhiGiaoHang DECIMAL(18,2) NOT NULL CHECK (PhiGiaoHang >= 0),
    TongThanhToan DECIMAL(18,2) NOT NULL CHECK (TongThanhToan >= 0),
    TrangThai NVARCHAR(50) DEFAULT N'Đã thanh toán',
    CONSTRAINT FK_PhieuDatHang_KhachHang FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang),
    CONSTRAINT FK_PhieuDatHang_LoaiGiaoHang FOREIGN KEY (MaLoaiGiaoHang) REFERENCES LoaiGiaoHang(MaLoaiGiaoHang)
);
GO

-- Bảng 6: Người nhận hàng (BR04 - Cho phép thông tin người nhận khác người đặt mua)
CREATE TABLE NguoiNhanHang (
    MaNhanHang INT IDENTITY(1,1) PRIMARY KEY,
    MaPhieuDat INT NOT NULL UNIQUE,
    HoTenNguoiNhan NVARCHAR(100) NOT NULL,
    DiaChiGiao NVARCHAR(255) NOT NULL,
    KhuVucGiao NVARCHAR(100) NOT NULL,
    SoDienThoai VARCHAR(15) NOT NULL,
    CONSTRAINT FK_NguoiNhanHang_PhieuDatHang FOREIGN KEY (MaPhieuDat) REFERENCES PhieuDatHang(MaPhieuDat) ON DELETE CASCADE
);
GO

-- Bảng 7: Chi tiết đặt hàng (Các sản phẩm cần mua kèm số lượng và đơn giá)
CREATE TABLE ChiTietDatHang (
    MaPhieuDat INT NOT NULL,
    MaSanPham VARCHAR(20) NOT NULL,
    SoLuong INT NOT NULL CHECK (SoLuong > 0),
    DonGia DECIMAL(18,2) NOT NULL CHECK (DonGia >= 0),
    CONSTRAINT PK_ChiTietDatHang PRIMARY KEY (MaPhieuDat, MaSanPham),
    CONSTRAINT FK_ChiTietDatHang_PhieuDatHang FOREIGN KEY (MaPhieuDat) REFERENCES PhieuDatHang(MaPhieuDat) ON DELETE CASCADE,
    CONSTRAINT FK_ChiTietDatHang_SanPham FOREIGN KEY (MaSanPham) REFERENCES SanPham(MaSanPham)
);
GO

-- Bảng 8: Giao dịch thanh toán thẻ tín dụng (BR03 - Visa, Master, Discover, AMEX)
CREATE TABLE GiaoDichThanhToan (
    MaGiaoDich INT IDENTITY(1,1) PRIMARY KEY,
    MaPhieuDat INT NOT NULL UNIQUE,
    LoaiThe VARCHAR(30) NOT NULL CHECK (LoaiThe IN ('VISA', 'Master', 'Discover', 'American Express')),
    SoTheMasked VARCHAR(25) NOT NULL,
    TenChuThe NVARCHAR(100) NOT NULL,
    LePhi DECIMAL(18,2) NOT NULL CHECK (LePhi >= 0),
    SoTienThanhToan DECIMAL(18,2) NOT NULL CHECK (SoTienThanhToan >= 0),
    MaGiaoDichNgoai VARCHAR(100) NOT NULL,
    TrangThai VARCHAR(30) NOT NULL,
    ThoiGianThanhToan DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_GiaoDichThanhToan_PhieuDatHang FOREIGN KEY (MaPhieuDat) REFERENCES PhieuDatHang(MaPhieuDat) ON DELETE CASCADE
);
GO

----------------------------------------------------------------------------------------------------
-- 3. NẠP DỮ LIỆU MẪU ĐẦY ĐỦ (SAMPLE DATA)
----------------------------------------------------------------------------------------------------

-- 3.1. Dữ liệu bảng LoaiGiaoHang (BR01)
INSERT INTO LoaiGiaoHang (MaLoaiGiaoHang, TenLoai, PhiCoBan, ThoiGianXuLy) VALUES
(1, N'Phiếu đặt hàng thường', 30000, N'3 - 5 ngày làm việc'),
(2, N'Phiếu đặt hàng chuyển phát nhanh', 60000, N'1 - 2 ngày làm việc'),
(3, N'Phiếu đặt hàng chuyển phát nhanh trong ngày', 120000, N'Trong vòng 24 giờ');
GO

-- 3.2. Dữ liệu bảng NhomSanPham (Bám sát ví dụ trong đề bài)
INSERT INTO NhomSanPham (MaNhom, TenNhom, MoTa) VALUES
(1, N'Thiết bị máy tính', N'Linh kiện, chuột, bàn phím và phụ kiện tin học'),
(2, N'Máy chụp hình kỹ thuật số', N'Máy ảnh cơ, Mirrorless, DSLR và ống kính chuyên dụng'),
(3, N'Đồ chơi thông minh', N'Đồ chơi giáo dục, mô hình lắp ráp, robotic cho trẻ em'),
(4, N'Thiết bị điện gia dụng', N'Đồ dùng nhà bếp, máy hút bụi, thiết bị gia đình thông minh');
GO

-- 3.3. Dữ liệu bảng SanPham (Có đầy đủ thông số kỹ thuật, mô tả, tình trạng hàng, nhiều mức giá)
INSERT INTO SanPham (MaSanPham, MaNhom, TenSanPham, NhaSanXuat, HinhAnh, MoTa, ThongSoKyThuat, GiaHienHanh, TinhTrangHang) VALUES
-- Nhóm 1: Thiết bị máy tính
('PC01', 1, N'Bàn phím cơ không dây MX Keys S', 'Logitech', 'mx_keys.png', 
 N'Bàn phím không dây cao cấp với đèn nền thông minh và phím gõ êm ái.', 
 N'Kết nối: Bluetooth & Logi Bolt; Pin: 10 ngày (hoặc 5 tháng tắt đèn); Đèn nền thông minh; Trọng lượng: 810g', 
 2490000, N'Còn hàng'),

('PC02', 1, N'Chuột công thái học không dây Lift Vertical', 'Logitech', 'lift_mouse.png', 
 N'Chuột đứng công thái học giúp giảm áp lực cổ tay cho người làm việc văn phòng.', 
 N'Góc nghiêng: 57 độ; Độ phân giải: 4000 DPI; Kết nối: Bluetooth/Bolt; Pin: 1 pin AA dùng 2 năm', 
 850000, N'Còn hàng'),

('PC03', 1, N'Màn hình chuyên đồ họa UltraSharp U2723QE 27 inch 4K', 'Dell', 'dell_u2723qe.png', 
 N'Màn hình 4K sắc nét công nghệ IPS Black cho độ tương phản vượt trội.', 
 N'Kích thước: 27 inch; Độ phân giải: 4K UHD (3840 x 2160); Tấm nền: IPS Black; Cổng: Type-C 90W, RJ45, DP 1.4, HDMI', 
 13200000, N'Còn hàng'),

('PC04', 1, N'Tai nghe chống ồn không dây WH-1000XM5', 'Sony', 'sony_xm5.png', 
 N'Tai nghe chụp tai chống ồn chủ động đỉnh cao với chất âm chi tiết.', 
 N'Driver: 30mm; Thời lượng pin: 30 giờ; Chống ồn: V1 & QN1; Bluetooth: 5.2; Trọng lượng: 250g', 
 6990000, N'Còn hàng'),

('PC05', 1, N'Ổ cứng SSD di động Extreme Portable 1TB', 'SanDisk', 'sandisk_1tb.png', 
 N'Ổ cứng chống nước, chống bụi chuẩn IP55, tốc độ truyền tải cực nhanh.', 
 N'Dung lượng: 1TB; Tốc độ đọc: 1050 MB/s; Tốc độ ghi: 1000 MB/s; Chuẩn kết nối: USB 3.2 Gen 2 Type-C', 
 2750000, N'Hết hàng'),

-- Nhóm 2: Máy chụp hình kỹ thuật số
('CAM01', 2, N'Máy ảnh Mirrorless Sony Alpha A7 IV (Body)', 'Sony', 'sony_a7m4.png', 
 N'Máy ảnh full-frame lai hoàn hảo giữa chụp ảnh độ nét cao và quay phim chuyên nghiệp.', 
 N'Cảm biến: Full-Frame 33MP Exmor R; Quay video: 4K 60p 10-bit 4:2:2; Hệ thống lấy nét: 759 điểm pha; Chống rung: 5.5 stop', 
 53990000, N'Còn hàng'),

('CAM02', 2, N'Máy ảnh Fujifilm X-T5 kèm Lens 16-50mm', 'Fujifilm', 'fuji_xt5.png', 
 N'Thiết kế hoài cổ, cảm biến 40MP thế hệ mới với bộ lọc màu phim độc quyền.', 
 N'Cảm biến: APS-C X-Trans CMOS 5 HR 40.2MP; Chống rung trong thân máy: 7 stop; Chụp liên tiếp: 15 fps; Quay phim: 6.2K 30p', 
 48500000, N'Còn hàng'),

('CAM03', 2, N'Ống kính Canon RF 50mm f/1.8 STM', 'Canon', 'canon_50f18.png', 
 N'Ống kính chân dung khẩu độ lớn gọn nhẹ dành cho dòng máy không gương lật Canon R.', 
 N'Tiêu cự: 50mm; Khẩu độ lớn nhất: f/1.8; Động cơ lấy nét: STM; Số lá khẩu: 7; Đường kính filter: 43mm', 
 3900000, N'Còn hàng'),

-- Nhóm 3: Đồ chơi thông minh
('TOY01', 3, N'Bộ lắp ráp Lego Robot Mindstorms Robot Inventor', 'Lego', 'lego_robot.png', 
 N'Bộ lắp ghép thông minh hỗ trợ học lập trình Scratch và Python cho thiếu nhi.', 
 N'Số chi tiết: 949 mảnh; Bộ điều khiển thông minh Hub: 6 cổng vào/ra, màn hình LED 5x5; Động cơ & cảm biến khoảng cách/màu', 
 8990000, N'Còn hàng'),

('TOY02', 3, N'Mô hình lắp ráp tàu không gian NASA Apollo Saturn V', 'Lego', 'lego_saturn_v.png', 
 N'Mô hình chi tiết tỷ lệ 1:110 của tên lửa lịch sử đưa con người lên mặt trăng.', 
 N'Số chi tiết: 1969 mảnh; Chiều cao mô hình: 100 cm; Đường kính: 17 cm; Chất liệu: Nhựa ABS an toàn cao cấp', 
 3490000, N'Còn hàng'),

('TOY03', 3, N'Quả cầu tương tác thông minh Sphero BOLT', 'Sphero', 'sphero_bolt.png', 
 N'Quả cầu robot điều khiển qua ứng dụng hỗ trợ vừa học vừa chơi công nghệ cao.', 
 N'Màn hình LED ma trận 8x8; Cảm biến hồng ngoại, la bàn số, con quay hồi chuyển; Pin sạc cảm ứng dùng 2 giờ liên tục', 
 4200000, N'Còn hàng'),

-- Nhóm 4: Thiết bị điện gia dụng
('APP01', 4, N'Nồi chiên không dầu điện tử Philips XXL HD9650', 'Philips', 'philips_xxl.png', 
 N'Công nghệ giải phóng dầu mỡ Fat Removal, dung tích lớn nướng nguyên con gà.', 
 N'Dung tích chứa: 3.5 lít (1.4 kg thực phẩm); Công suất: 2200W; Công nghệ nhiệt: Twin TurboStar; Bảng điều khiển: Điện tử', 
 4690000, N'Còn hàng'),

('APP02', 4, N'Máy lọc không khí thông minh Xiaomi Air Purifier 4 Pro', 'Xiaomi', 'xiaomi_4pro.png', 
 N'Lọc bụi mịn PM2.5, khử mùi hiệu quả cho phòng diện tích tới 60 mét vuông.', 
 N'Công suất lọc CADR: 500 m3/h; Màng lọc: HEPA 5 lớp; Độ ồn thấp: 33.7 dB; Màn hình OLED hiển thị chất lượng không khí', 
 4150000, N'Còn hàng'),

('APP03', 4, N'Máy hút bụi cầm tay không dây Dyson V12 Detect Slim', 'Dyson', 'dyson_v12.png', 
 N'Tích hợp tia laser soi bụi mịn tàng hình cùng cảm biến âm học đo lượng hạt bụi.', 
 N'Lực hút cực đại: 150 AW; Trọng lượng: 2.2 kg; Thời lượng pin: 60 phút; Đầu hút Fluffy có laser soi góc hẹp', 
 17990000, N'Còn hàng');
GO

-- 3.4. Dữ liệu bảng KháchHang (Tài khoản mẫu để thử nghiệm đăng nhập)
INSERT INTO KhachHang (TenDangNhap, MatKhauHash, HoTen, NgaySinh, CMND_Passport, DiaChi, SoDienThoai, Email) VALUES
('lan_cao', '123456', N'Cao Vũ Ngọc Lan', '2004-09-02', '079204000123', N'280 An Dương Vương, Phường 4, Quận 5', '0912345678', 'ngoclan@gmail.com'),
('hoang_nam', '123456', N'Nguyễn Hoàng Nam', '2000-11-20', '079200000456', N'123 Cách Mạng Tháng 8, Phường 7, Quận 3', '0988776655', 'hoangnam@gmail.com');
GO

-- 3.5. Dữ liệu một đơn hàng mẫu để kiểm tra báo cáo & giao dịch
INSERT INTO PhieuDatHang (MaKhachHang, NgayDat, MaLoaiGiaoHang, TongTienHang, PhiGiaoHang, TongThanhToan, TrangThai) VALUES
(1, GETDATE(), 2, 2490000, 0, 2490000, N'Đã thanh toán');

INSERT INTO NguoiNhanHang (MaPhieuDat, HoTenNguoiNhan, DiaChiGiao, KhuVucGiao, SoDienThoai) VALUES
(1001, N'Trần Thị Mai', N'456 Lê Văn Sỹ, Phường 12', N'Quận 3, TP. Hồ Chí Minh', '0903123456');

INSERT INTO ChiTietDatHang (MaPhieuDat, MaSanPham, SoLuong, DonGia) VALUES
(1001, 'PC01', 1, 2490000);

INSERT INTO GiaoDichThanhToan (MaPhieuDat, LoaiThe, SoTheMasked, TenChuThe, LePhi, SoTienThanhToan, MaGiaoDichNgoai, TrangThai) VALUES
(1001, 'VISA', '************1111', N'CAO VU NGOC LAN', 37350, 2490000, 'TXN20261003001', 'SUCCESS');
GO

----------------------------------------------------------------------------------------------------
-- 4. TRUY VẤN KIỂM TRA TỔNG QUAN HỆ THỐNG
----------------------------------------------------------------------------------------------------
SELECT 'KhachHang' AS TenBang, COUNT(*) AS SoLuongDong FROM KhachHang
UNION ALL
SELECT 'NhomSanPham', COUNT(*) FROM NhomSanPham
UNION ALL
SELECT 'SanPham', COUNT(*) FROM SanPham
UNION ALL
SELECT 'LoaiGiaoHang', COUNT(*) FROM LoaiGiaoHang
UNION ALL
SELECT 'PhieuDatHang', COUNT(*) FROM PhieuDatHang
UNION ALL
SELECT 'NguoiNhanHang', COUNT(*) FROM NguoiNhanHang
UNION ALL
SELECT 'ChiTietDatHang', COUNT(*) FROM ChiTietDatHang
UNION ALL
SELECT 'GiaoDichThanhToan', COUNT(*) FROM GiaoDichThanhToan;
GO