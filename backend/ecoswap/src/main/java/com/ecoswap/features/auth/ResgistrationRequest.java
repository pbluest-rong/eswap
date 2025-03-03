package com.ecoswap.features.auth;

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
    @NotNull(message = "Gender is mandatory")
    private Boolean gender;
    @Email(message = "Email is not formatted")
    @NotEmpty(message = "Email is mandatory")
    private String email;
    @NotEmpty(message = "Password is mandatory")
    @NotBlank(message = "Password is mandatory")
    @Size(min = 8, message = "Password should be 8 characters long minimum")
    private String password;
    @NotEmpty(message = "Code is mandatory")
    @NotBlank(message = "Code is mandatory")
    @Size(min = 6, message = "Code must be at least 6 characters long")
    private String codeToken;
}