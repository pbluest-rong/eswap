package com.eswap.request;

import jakarta.validation.constraints.*;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class ForgotPasswordRequest {
    @NotEmpty(message = "Token is mandatory")
    @NotBlank(message = "Token is mandatory")
    private String token;
    @NotEmpty(message = "Password is mandatory")
    @NotBlank(message = "Password is mandatory")
    @Size(min = 8, message = "Password should be at least 8 characters long")
    @Pattern(
            regexp = "^(?=.*[A-Z])(?=.*\\d)(?=.*[\\W_])(?!.*\\s)[A-Za-z\\d\\W_]{8,}$",
            message = "Password must contain at least one uppercase letter, one number, and one special character"
    )
    private String newPassword;
}
