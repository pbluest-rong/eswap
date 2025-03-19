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
    private String address;
    // +81 90 1234 5678
    // +1 202 555 0125
    // +84901234567
    @Pattern(regexp = "^[0-9]{10}$", message = "Phone number must be exactly 10 digits")
    private String phoneNumber;
}
