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
    private Boolean gender;
    private String address;
}
