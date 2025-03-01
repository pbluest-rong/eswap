# EcoSwap

#### Bắt nguồn từ nhu cầu thực tế của sinh viên về việc trao đổi đồ dùng cũ trở nên dễ dàng, tiện lợi, cá nhân hóa thông tin hơn. Hiện nay trên các mạng xã hội như Facebook, Zalo, … ít ai mà chưa từng nhìn thấy các bài đăng về việc trao đổi đồ cũ, điều này chứng tỏ nhu cầu “pass đồ” hầu như đều có ở mọi cá nhân, đặc biệt là học sinh, sinh viên.

#### EcoSwap hướng đến mục tiêu mang lại giá trị cho mọi người nói chung và học sinh, sinh viên nói riêng có một không gian mà nơi đó có thể dễ dàng tìm kiếm, trao đổi đồ dùng với nhau một cách dễ dàng và góp phần bảo vệ môi trường xung quanh chúng ta trở nên xanh, sạch, đẹp.

---
## Chức năng người dùng

### 1. Tài khoản người dùng

> ### - Đăng ký, đăng nhập qua gmail, password.
> ### - Đăng ký, đăng nhập qua Google, Facebook.
> ### - Đăng nhập với xác thực qua Spring Security và JWT.
> ### - Đăng xuất.
> ### - Quên mật khẩu.
> ### - Chỉnh sửa thông tin cá nhân.
> ### - Vô hiệu hóa tài khoản.
> ### - Theo dõi/hủy theo dõi người dùng khác.
> ### - Báo cáo người dùng khác.
> ### - Chặn người dùng khác.
> ### - Gửi ý kiến đến quản trị viên.

### 2. Quản lý bài viết

> ### - Đăng bài viết
> ### - Xóa bài viết
> ### - Chỉnh sửa thông tin bài viết
> ### - Đánh dấu bài viết
> ### - Like bài viết
> ### - Share bài viết
> ### - Báo cáo bài viết
> ### - Nhắn tin qua bài viết

### 3. Tìm kiếm

> ### - Tìm kiếm theo bài đăng
> ### - Tìm kiếm theo người dùng
> ### - Tìm kiếm theo hashtag

### 4. Chức năng nhắn tin

> ### - Mỗi cuộc trò chuyện gắn liền với nhiều bài đăng.
> ### - Hỗ trợ gửi text, image, video, link, position
> ### - Giới hạn số lượng tin nhắn cho mỗi cuộc trò chuyện, giới hạn dung lượng gửi file.
> ### - Liên lạc, đồng ý trao đổi, người đánh dấu tương ứng quá trình.
> ### - Sau khi nhận hàng, bên nhận chọn "Đã nhận", Profile người đăng được cộng 1 điểm uy tín.

### 5. Chức năng mở rộng khác

> ### - Cập nhật tin tức.
> ### - Hỗ trợ tiếp cận việc làm.
> ### - Gán quảng cáo.

## Chức năng người trung chuyển

## Chức năng quản trị viên

> ### 1. Khóa/khôi phục tài khoản.
> ### 2. Ẩn/hiện bài đăng.
> ### 3. Thêm, sửa, xóa, tùy chỉnh vị trí trong cấu trúc cha-con của danh mục.
> ### 4. Thêm, sửa xóa hashtag
> ### 5. Xem, xử lý báo cáo về các báo cáo tài khoản.
> ### 6. Xem, xử lý báo cáo về các báo cao bài đăng.
> ### 7. Trả lời ý kiến của người dùng.
> ### 8. Xem log hệ thống.
> ### 9. Thêm tài khoản quản lý khác (đồi với tài khoản có quyền cao nhất).
> ### 10. Thông báo cho toàn bộ người dùng.
> ### 11. Thông báo đến người dùng cụ thể.
> ### 12. Thêm, sửa, xóa tin tức.
> ### 13. Thêm, sửa, xóa quảng cáo.
> ### 14. Thêm, sửa, xóa thông tin tuyển dụng việc làm.
> ### 15. Đưa ra các chỉ số về trạng thái hoạt động của website.

## Git conventions

### Quy ước đặt tên nhánh git

- Viết thường (lowercase)
- Dùng gạch nối để phân tách (hyphen-separated)
- Chỉ sử dụng các ký tự a-z và 0-9
- Tiền tố quy ước: `fe`, `be`, `docs`, `feature`, `bugfix`, `hotfix`, `release`

> ##### Ví dụ:
>    - `fe/feature/login-page`
>    - `be/feature/user`
>    - `docs/readme.md`
>    - `be/bugfix/mail`

### Quy ước về commit message

Cấu trúc của một commit message:
> < type >[optional scope]: < subject >
> [optional description(body)]
> [optional footer(s)]

- **Viết hoa chữ cái đầu tiên của `subject`.**
- **Không kết thúc dòng `subject` bằng dấu chấm.**

#### Các loại `type`:

- `feat`: Thêm tính năng mới
- `fix`: Sửa lỗi
- `refactor`: Thay đổi code mà không ảnh hưởng đến chức năng tổng thể
- `chore`: Cập nhật không ảnh hưởng đến production code, liên quan đến công cụ, cấu hình hoặc thư viện
- `docs`: Cập nhật hoặc sửa đổi tài liệu
- `perf`: Thay đổi code để cải thiện hiệu suất
- `style`: Cải thiện cách trình bày code
- `test`: Thêm hoặc sửa các test
- `build`: Sửa đổi ảnh hưởng đến hệ thống build hoặc các phụ thuộc bên ngoài
- `ci`: Thay đổi các tệp hoặc cấu hình CI
- `env`: Mô tả các thay đổi hoặc bổ sung trong cấu hình CI

#### `scope`:

Phạm vi có thể thêm vào sau `type` để cung cấp thêm thông tin về ngữ cảnh.

- Ví dụ: `fix(ui)`, `feat(auth)`

#### `description/body`:

- Ví dụ: `feat: Add new functionality to handle user authentication.`

#### `footer`:

- Ví dụ: `Signed-off-by: John <john.doe@example.com>`
- Ví dụ: `Reviewed-by: Anthony <anthony@example.com>`

> ##### Ví dụ 1 commit hoàn chỉnh:<br>
> feat(profile): Allow users to update personal information<br>
> Add functionality to update user details such as name, email, and phone number.<br>
> Validate user input to ensure data integrity before saving changes to the database.<br>
> Signed-off-by: Pblues <pbluest.rong@gmail.com>

## Liên hệ

> **Lê Bá Phụng**  
> Email: **pbluest.rong@gmail.com**

Xem thêm tại: [Pass Làng Đại Học](https://github.com/pbluest-rong/pass-lang-dai-hoc)
