package com.eswap.request;

import jakarta.validation.constraints.*;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
@Builder
public class ResgistrationRequest {
    @NotEmpty(message = "Fistname is mandatory")
    @NotBlank(message = "Fistname is mandatory")
    private String firstname;
    @NotEmpty(message = "Lastname is mandatory")
    @NotBlank(message = "Lastname is mandatory")
    private String lastname;
    @NotNull(message = "Date of birth is mandatory")
    private LocalDate dob;
    @NotNull(message = "Education Institution is mandatory")
    private long educationInstitutionId;
    @NotNull(message = "Gender is mandatory")
    private Boolean gender;
    @NotEmpty(message = "email or phone number is mandatory")
    private String emailPhoneNumber;
    @NotEmpty(message = "Password is mandatory")
    @NotBlank(message = "Password is mandatory")
    @Size(min = 8, message = "Password should be at least 8 characters long")
    @Pattern(
            regexp = "^(?=.*[A-Z])(?=.*\\d)(?=.*[\\W_])(?!.*\\s)[A-Za-z\\d\\W_]{8,}$",
            message = "Password must contain at least one uppercase letter, one number, and one special character"
    )
    private String password;
    private String otp;
}