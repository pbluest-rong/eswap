# Eswap – Ứng dụng trao đổi đồ dùng học sinh, sinh viên

**Eswap** là nền tảng giúp học sinh, sinh viên tại Việt Nam kết nối để trao đổi, tặng hoặc bán đồ dùng học tập đã qua sử dụng. Ứng dụng hướng đến cộng đồng trẻ có ngân sách hạn chế, góp phần tiết kiệm chi phí, khuyến khích tái sử dụng và thúc đẩy kinh tế chia sẻ.

---

## 📌 Tính năng nổi bật

- **🔐 Quản lý tài khoản:** Người dùng có thể đăng ký, đăng nhập, khôi phục mật khẩu, và quản lý thông tin cá nhân một cách an toàn.

- **📝 Quản lý bài đăng:** Hỗ trợ tạo, xem, xóa, thích/bỏ thích bài đăng. Tính năng tìm kiếm và lọc bài đăng theo danh mục, thương hiệu, khu vực, hoặc trường học được tích hợp, giúp người dùng dễ dàng tìm kiếm món đồ phù hợp.

- **💼 Quản lý giao dịch:** Hỗ trợ tạo, hủy, và hoàn thành đơn hàng, với cơ chế đặt cọc bảo vệ quyền lợi cho cả người mua và người bán. Giao dịch đặt cọc đảm bảo tính minh bạch và giảm thiểu rủi ro lừa đảo.

- **💬 Trò chuyện thời gian thực:** Tính năng chat tích hợp giao thức STOMP/WebSocket cho phép người dùng trao đổi thông tin nhanh chóng, hỗ trợ giao tiếp giữa người mua, người bán, và cửa hàng.

- **🏪 Hỗ trợ thu mua cho cửa hàng:** Người dùng có thể gửi yêu cầu bán đồ đến các cửa hàng, cửa hàng sẽ liên hệ sau đó xác nhận hoặc từ chối yêu cầu.

- **🔔 Thông báo:** Tích hợp Firebase Cloud Messaging (FCM) để gửi thông báo đẩy giúp người dùng luôn cập nhật được thông báo tức thì.

- **🔍 Tìm kiếm:** Người dùng có thể tìm kiếm các bài đăng hay người dùng một cách dễ dàng, hệ thống lưu trữ lịch sử tìm kiếm gần đây nhằm gợi ý bài đăng, nâng cao trải nghiệm người dùng.

- **👥 Theo dõi và cộng đồng:** Người dùng có thể theo dõi hoặc bỏ theo dõi người dùng khác, tạo ra các cộng đồng nhỏ kết nối dựa trên sở thích và nhu cầu trao đổi.

- **🛠️ Quản lý admin:** Cung cấp dashboard quản trị để quản lý tài khoản người dùng, danh mục, thương hiệu, và giải ngân tiền, đảm bảo vận hành hệ thống hiệu quả.


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
| Backend            | Java Spring Boot                                       |
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
