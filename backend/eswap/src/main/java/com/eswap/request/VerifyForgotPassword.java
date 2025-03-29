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
    @NotEmpty(message = "Username or email or phone number is mandatory")
    private String usernameEmailPhoneNumber;
    @NotEmpty(message = "Code is mandatory")
    @NotBlank(message = "Code is mandatory")
    @Size(min = 6, message = "Code must be at least 6 characters long")
    private String otp;
}
