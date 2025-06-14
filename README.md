# Eswap - Ứng dụng trao đổi đồ dùng học sinh sinh viên.
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
