# Eswap – Ứng dụng trao đổi đồ dùng học sinh, sinh viên

**Eswap** là nền tảng giúp học sinh, sinh viên tại Việt Nam kết nối để trao đổi, tặng hoặc bán đồ dùng học tập đã qua sử dụng. Ứng dụng hướng đến cộng đồng trẻ có ngân sách hạn chế, góp phần tiết kiệm chi phí, khuyến khích tái sử dụng và thúc đẩy kinh tế chia sẻ.

---

## 📌 Tính năng nổi bật

- **🔐 Tài khoản:** Đăng ký, đăng nhập, khôi phục mật khẩu, cập nhật thông tin.
- **📝 Bài đăng:** Tạo, xem, xóa, thích/bỏ thích bài viết; tìm kiếm và lọc theo danh mục, thương hiệu, khu vực, trường học.
- **💼 Giao dịch:** Đặt cọc, hủy, hoàn tất giao dịch để đảm bảo an toàn và minh bạch.
- **💬 Trò chuyện:** Nhắn tin thời gian thực qua STOMP/WebSocket.
- **🏪 Cửa hàng:** Gửi yêu cầu bán đồ cho cửa hàng; quản lý xác nhận hoặc từ chối.
- **🔔 Thông báo:** Gửi thông báo đẩy qua Firebase Cloud Messaging (FCM).
- **🔍 Tìm kiếm:** Hỗ trợ tìm kiếm nâng cao và lưu lịch sử để gợi ý thông minh.
- **👥 Cộng đồng:** Theo dõi người dùng, tạo nhóm chia sẻ theo sở thích.
- **🛠️ Quản trị:** Dashboard admin quản lý người dùng, danh mục, thương hiệu, giải ngân.

---

## 🧱 Kiến trúc hệ thống

Hệ thống được xây dựng theo mô hình **Client - Server**, gồm các thành phần:

![Kiến trúc hệ thống](https://res.cloudinary.com/dskq8cjqn/image/upload/v1752613544/system_architecture_yo0jbb.png)

- **Frontend:** Flutter – giao tiếp với backend qua HTTP (REST API) và STOMP (WebSocket).
- **Backend:** Spring Boot – xử lý nghiệp vụ, cung cấp API và WebSocket.
- **Kafka & Zookeeper:** Hàng đợi tin nhắn và điều phối xử lý bất đồng bộ.
- **MySQL:** Lưu trữ dữ liệu quan hệ.
- **Firebase:** Gửi thông báo và xác thực qua SMS.
- **Momo:** Tích hợp thanh toán.
- **Cloudinary:** Lưu trữ và quản lý hình ảnh, video.
- **Docker:** Đóng gói và triển khai container.

---

## 🛠️ Công nghệ sử dụng

| Thành phần         | Công nghệ / Công cụ                                     |
|--------------------|---------------------------------------------------------|
| Backend            | Java, Spring Boot                                       |
| Frontend           | Flutter                                                 |
| Cơ sở dữ liệu      | MySQL                                                   |
| Khác               | Docker, Firebase, Cloudinary, Momo, Ngrok, Scrcpy       |

---

## 📱 Giao diện ứng dụng

| Giới thiệu | Đăng nhập | Trang chủ |
|---------------------|-----------|-----------|
| ![](https://res.cloudinary.com/dskq8cjqn/image/upload/v1752613544/0_zbrvtx.png) | ![](https://res.cloudinary.com/dskq8cjqn/image/upload/v1752613543/1_agy36f.png) | ![](https://res.cloudinary.com/dskq8cjqn/image/upload/v1752613545/2_t5n3b3.png) |

| Khám phá | Đăng bài | Chọn media |
|----------|------------|----------|
| ![](https://res.cloudinary.com/dskq8cjqn/image/upload/v1752613544/3_ksi6j5.png) | ![](https://res.cloudinary.com/dskq8cjqn/image/upload/v1752613544/4_odeiao.png) | ![](https://res.cloudinary.com/dskq8cjqn/image/upload/v1752613545/5_t1yg48.png) |

| Nhắn tin | Mua hàng (đặt cọc) | Mua hàng (không đặt cọc) |
|----------|--------------------|---------------------------|
| ![](https://res.cloudinary.com/dskq8cjqn/image/upload/v1752613545/6_tz1f3n.png) | ![](https://res.cloudinary.com/dskq8cjqn/image/upload/v1752613545/7_bdmr2j.png) | ![](https://res.cloudinary.com/dskq8cjqn/image/upload/v1752613546/9_f4j5bp.png) |

| Thanh toán | Hồ sơ người dùng | Chỉnh sửa thông tin |
|------------|------------------|----------------------|
| ![](https://res.cloudinary.com/dskq8cjqn/image/upload/v1752613545/8_udtxtu.png) | ![](https://res.cloudinary.com/dskq8cjqn/image/upload/v1752613546/10_nazn8v.png) | ![](https://res.cloudinary.com/dskq8cjqn/image/upload/v1752613546/12_ktesur.png) |

---

## 🎥 Demo chi tiết

🔗 [Xem demo trên YouTube](https://www.youtube.com/watch?v=i6rknCfkpR4)

---
