INSERT INTO `categories` (`id`, `title`, `parent_id`) VALUES
-- Danh mục chính
(1, 'Sách vở & Tài liệu học tập', NULL),
(2, 'Thiết bị điện tử & Phụ kiện', NULL),
(3, 'Dụng cụ học tập & Văn phòng phẩm', NULL),
(4, 'Đồ dùng cá nhân & Thời trang', NULL),
(5, 'Đồ ăn uống', NULL),
(6, 'Thiết bị thể thao & Giải trí', NULL),
(7, 'Vật dụng', NULL),
(8, 'Dụng cụ nghệ thuật & Âm nhạc', NULL),

-- Danh mục con cho Sách vở & Tài liệu học tập
(9, 'Sách giáo khoa', 1),
(10, 'Sách tham khảo', 1),
(11, 'Sách ngoại văn', 1),
(12, 'Tài liệu học tập', 1),

-- Danh mục con cho Thiết bị điện tử & Phụ kiện
(13, 'Laptop', 2),
(14, 'Máy tính bảng', 2),
(15, 'Điện thoại', 2),
(16, 'Phụ kiện điện tử', 2),

-- Danh mục con cho Dụng cụ học tập & Văn phòng phẩm
(17, 'Bút & Viết', 3),
(18, 'Sổ tay & Giấy', 3),
(19, 'Dụng cụ văn phòng', 3),

-- Danh mục con cho Đồ dùng cá nhân & Thời trang
(20, 'Ba lô & Túi xách', 4),
(21, 'Quần áo & Giày dép', 4),
(22, 'Phụ kiện thời trang', 4),

-- Danh mục con cho Đồ ăn uống
(23, 'Đồ ăn vặt', 5),
(24, 'Nước uống', 5),

-- Danh mục con cho Thiết bị thể thao & Giải trí
(25, 'Dụng cụ tập gym', 6),
(26, 'Dụng cụ thể thao', 6),

-- Danh mục con cho Vật dụng
(27, 'Đồ gia dụng', 7),
(28, 'Đồ nội thất', 7),

-- Danh mục con cho Dụng cụ nghệ thuật & Âm nhạc
(29, 'Nhạc cụ', 8),
(30, 'Dụng cụ vẽ & thủ công', 8);

INSERT INTO `brands` (`id`, `name`) VALUES
-- Thương hiệu cho Thiết bị điện tử & Phụ kiện
(1, 'Apple'),
(2, 'Samsung'),
(3, 'Dell'),
(4, 'HP'),
(5, 'Lenovo'),

-- Thương hiệu cho Sách vở & Tài liệu học tập
(6, 'NXB Giáo Dục'),
(7, 'NXB Kim Đồng'),
(8, 'NXB Trẻ'),

-- Thương hiệu cho Dụng cụ học tập & Văn phòng phẩm
(9, 'Thiên Long'),
(10, 'Stabilo'),
(11, 'Casio'),

-- Thương hiệu cho Đồ dùng cá nhân & Thời trang
(12, 'Nike'),
(13, 'Adidas'),
(14, 'Puma'),

-- Thương hiệu cho Thiết bị thể thao & Giải trí
(15, 'Decathlon'),
(16, 'Wilson'),

-- Thương hiệu cho Dụng cụ nghệ thuật & Âm nhạc
(17, 'Yamaha'),
(18, 'Faber-Castell'),
(19, 'Winsor & Newton');


INSERT INTO `category_brand` (`category_id`, `brand_id`) VALUES
-- Liên kết Sách vở & Tài liệu học tập
(9, 6), (10, 7), (11, 8), (12, 6),

-- Liên kết Thiết bị điện tử & Phụ kiện
(13, 3), (13, 4), (13, 5), (14, 2), (15, 1), (15, 2), (16, 1), (16, 2), (16, 5),

-- Liên kết Dụng cụ học tập & Văn phòng phẩm
(17, 9), (17, 10), (18, 9), (18, 11), (19, 9),

-- Liên kết Đồ dùng cá nhân & Thời trang
(20, 12), (20, 13), (21, 12), (21, 13), (21, 14), (22, 12), (22, 14),

-- Liên kết Đồ ăn uống (không có thương hiệu cụ thể)

-- Liên kết Thiết bị thể thao & Giải trí
(25, 15), (26, 15), (26, 16),

-- Liên kết Dụng cụ nghệ thuật & Âm nhạc
(29, 17), (30, 18), (30, 19);
