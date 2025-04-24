-- Insert main categories
INSERT INTO `categories` (`name`, `parent_id`) VALUES
                                                    ('Đồ dùng học tập', NULL),
                                                    ('Thiết bị điện tử & phụ kiện', NULL),
                                                    ('Đồ dùng cá nhân & sinh hoạt', NULL),
                                                    ('Thời trang & phụ kiện', NULL),
                                                    ('Thực phẩm & đồ uống', NULL),
                                                    ('Thể thao & giải trí', NULL);

-- Insert sub-categories for 'Đồ dùng học tập'
INSERT INTO `categories` (`name`, `parent_id`) VALUES
                                                    ('Sách giáo khoa', 1),
                                                    ('Vở viết', 1),
                                                    ('Bút các loại', 1),
                                                    ('Dụng cụ học sinh', 1),
                                                    ('Balô, cặp sách', 1),
                                                    ('Khác', 1);  -- Other option

-- Insert sub-categories for 'Thiết bị điện tử & phụ kiện'
INSERT INTO `categories` (`name`, `parent_id`) VALUES
                                                    ('Laptop', 2),
                                                    ('Điện thoại', 2),
                                                    ('Máy tính bảng', 2),
                                                    ('Tai nghe', 2),
                                                    ('Chuột, bàn phím', 2),
                                                    ('Ổ cứng, USB', 2),
                                                    ('Khác', 2);  -- Other option

-- Insert sub-categories for 'Đồ dùng cá nhân & sinh hoạt'
INSERT INTO `categories` (`name`, `parent_id`) VALUES
                                                    ('Dụng cụ nhà bếp', 3),
                                                    ('Chăn, ga, gối', 3),
                                                    ('Đồ dùng vệ sinh', 3),
                                                    ('Dụng cụ phòng tắm', 3),
                                                    ('Đồ dùng phòng ngủ', 3),
                                                    ('Khác', 3);  -- Other option

-- Insert sub-categories for 'Thời trang & phụ kiện'
INSERT INTO `categories` (`name`, `parent_id`) VALUES
                                                    ('Quần áo nam', 4),
                                                    ('Quần áo nữ', 4),
                                                    ('Giày dép', 4),
                                                    ('Túi xách', 4),
                                                    ('Phụ kiện', 4),
                                                    ('Khác', 4);  -- Other option

-- Insert sub-categories for 'Thực phẩm & đồ uống'
INSERT INTO `categories` (`name`, `parent_id`) VALUES
                                                    ('Đồ ăn nhanh', 5),
                                                    ('Nước uống', 5),
                                                    ('Đồ hộp', 5),
                                                    ('Bánh kẹo', 5),
                                                    ('Đồ khô', 5),
                                                    ('Khác', 5);  -- Other option

-- Insert sub-categories for 'Thể thao & giải trí'
INSERT INTO `categories` (`name`, `parent_id`) VALUES
                                                    ('Dụng cụ thể thao', 6),
                                                    ('Trò chơi điện tử', 6),
                                                    ('Nhạc cụ', 6),
                                                    ('Sách, truyện', 6),
                                                    ('Đồ tập gym', 6),
                                                    ('Khác', 6);  -- Other option

-- Insert brands
INSERT INTO `brands` (`name`) VALUES
-- Stationery brands
('Thiên Long'), ('Bến Nghé'), ('Hồng Hà'),
-- Electronics brands
('Apple'), ('Samsung'), ('Xiaomi'), ('Dell'), ('Logitech'), ('Asus'),
-- Fashion brands
('Nike'), ('Adidas'), ('Uniqlo'), ('Zara'), ('Gucci'), ('LV'),
-- Food brands
('Coca Cola'), ('Pepsi'), ('Kinh Đô'), ('Vina Acecook'), ('TH true MILK'),
-- Sports brands
('Decathlon'), ('Yonex'), ('Wilson'), ('Nike'), ('Adidas'),
-- Other brand
('Khác');  -- ID: 26

-- Insert category_brand relationships
INSERT INTO `category_brand` (`category_id`, `brand_id`) VALUES
-- Đồ dùng học tập brands
(1, 1), (1, 2), (1, 3), -- Thiên Long, Bến Nghé, Hồng Hà
(7, 1), (7, 2), (7, 3), -- Sách giáo khoa
(8, 1), (8, 3),         -- Vở viết (Thiên Long, Hồng Hà)
(9, 1), (9, 2),         -- Bút các loại
(12, 26),               -- Other option

-- Thiết bị điện tử brands
(2, 4), (2, 5), (2, 6), (2, 7), (2, 8), (2, 9), -- Apple, Samsung, Xiaomi, Dell, Logitech, Asus
(13, 4), (13, 5), (13, 7), -- Laptop (Apple, Samsung, Dell)
(14, 4), (14, 5), (14, 6), -- Điện thoại
(17, 8), -- Chuột, bàn phím (Logitech)
(19, 26), -- Other option

-- Thời trang brands
(4, 10), (4, 11), (4, 12), (4, 13), (4, 14), (4, 15), -- Nike, Adidas, Uniqlo, Zara, Gucci, LV
(20, 10), (20, 11), -- Quần áo nam (Nike, Adidas)
(21, 12), (21, 13), -- Quần áo nữ (Uniqlo, Zara)
(22, 10), (22, 11), -- Giày dép (Nike, Adidas)
(25, 26),           -- Other option

-- Thực phẩm brands
(5, 16), (5, 17), (5, 18), (5, 19), (5, 20), -- Coca Cola, Pepsi, Kinh Đô, Vina Acecook, TH true MILK
(26, 16), (26, 17), -- Nước uống
(29, 18), -- Bánh kẹo (Kinh Đô)
(31, 26), -- Other option

-- Thể thao brands
(6, 21), (6, 22), (6, 23), (6, 24), (6, 25), -- Decathlon, Yonex, Wilson, Nike, Adidas
(32, 21), -- Dụng cụ thể thao (Decathlon)
(35, 22), -- Đồ tập gym (Yonex)
(37, 26); -- Other option