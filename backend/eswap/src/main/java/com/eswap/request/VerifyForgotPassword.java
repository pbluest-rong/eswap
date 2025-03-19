package com.eswap.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class VerifyForgotPassword {
    @Email(message = "Email is not formatted")
    @NotEmpty(message = "Email is mandatory")
    private String email;
    @NotEmpty(message = "Code is mandatory")
    @NotBlank(message = "Code is mandatory")
    @Size(min = 6, message = "Code must be at least 6 characters long")
    private String otp;
}
