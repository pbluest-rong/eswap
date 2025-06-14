package com.eswap.request;

import jakarta.validation.constraints.*;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
@Builder
public class ChangeInfoRequest {
    @Size(min = 3, max = 30, message = "Tên đăng nhập phải từ 3 đến 30 ký tự")
    @Pattern(
            regexp = "^(?!.*\\.\\.)(?!.*\\.$)[a-zA-Z0-9._]+$",
            message = "Tên đăng nhập chỉ được chứa chữ cái, số, dấu chấm và gạch dưới, không được bắt đầu/kết thúc bằng dấu chấm hoặc có nhiều dấu chấm liên tiếp"
    )
    private String username;
    @NotEmpty(message = "Họ không được để trống")
    @NotBlank(message = "Họ không được chỉ chứa khoảng trắng")
    @Size(max = 100, message = "Họ không được vượt quá 100 ký tự")
    @Pattern(regexp = "^[\\p{L} .'-]+$", message = "Họ chứa ký tự không hợp lệ")
    private String firstname;

    @NotEmpty(message = "Tên không được để trống")
    @NotBlank(message = "Tên không được chỉ chứa khoảng trắng")
    @Size(max = 100, message = "Tên không được vượt quá 100 ký tự")
    @Pattern(regexp = "^[\\p{L} .'-]+$", message = "Tên chứa ký tự không hợp lệ")
    private String lastname;

    private Long educationInstitutionId;

    private boolean requireFollowApproval;
}