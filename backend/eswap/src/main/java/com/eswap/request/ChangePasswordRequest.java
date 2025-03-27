package com.eswap.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class ChangePasswordRequest {
    @NotEmpty(message = "Password is mandatory")
    @NotBlank(message = "Password is mandatory")
    @Size(min = 8, message = "Password should be at least 8 characters long")
    @Pattern(
            regexp = "^(?=.*[A-Z])(?=.*\\d)(?=.*[\\W_])(?!.*\\s)[A-Za-z\\d\\W_]{8,}$",
            message = "Password must contain at least one uppercase letter, one number, and one special character"
    )
    private String newPassword;
    @NotEmpty(message = "Code is mandatory")
    @NotBlank(message = "Code is mandatory")
    @Size(min = 6, message = "Code must be at least 6 characters long")
    private String codeToken;
}
