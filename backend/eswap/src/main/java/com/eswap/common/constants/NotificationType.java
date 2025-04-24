package com.eswap.common.constants;

public enum NotificationType {
    INFORM,     // Thông báo thông thường (ví dụ: có người like)
    ALERT,      // Thông báo cần chú ý hơn (ví dụ: ai đó báo cáo bạn)
    SUCCESS,    // Khi thao tác thành công (ví dụ: đổi mật khẩu thành công)
    ERROR,      // Khi có lỗi (ví dụ: thao tác thất bại)
    WARNING,    // Cảnh báo (ví dụ: đăng bài vi phạm)
    SYSTEM      // Thông báo từ hệ thống (ví dụ: maintenance)
}
