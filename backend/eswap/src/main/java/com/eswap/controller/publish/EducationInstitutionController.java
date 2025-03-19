
package com.eswap.controller.publish;

import com.eswap.common.ApiResponse;
import com.eswap.common.constants.InstitutionType;
import com.eswap.service.EducationInstitutionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("institutions")
public class EducationInstitutionController {
    private final EducationInstitutionService educationInstitutionService;

    @GetMapping
    public ResponseEntity<ApiResponse> getAll() {
        return ResponseEntity.ok(new ApiResponse(true, "All education institutions",
                educationInstitutionService.getProvinces()));
    }

    @GetMapping("/{provinceId}")
    public ResponseEntity<ApiResponse> getEducationInstitutionsByProvinceId(@PathVariable String provinceId) {
        return ResponseEntity.ok(new ApiResponse(true, "Education institutions in province " + provinceId,
                educationInstitutionService.getEducationInstitutionsByProvinceId(provinceId)));
    }

    @GetMapping("/{provinceId}/type")
    public ResponseEntity<ApiResponse> getEducationInstitutionsByProvinceIdAndInstitutionType(
            @PathVariable String provinceId, @RequestParam String institutionType) {
        try {
            InstitutionType type = InstitutionType.valueOf(institutionType.toUpperCase());
            return ResponseEntity.ok(new ApiResponse(true,
                    "Education institutions in province " + provinceId + " with type " + institutionType,
                    educationInstitutionService.getEducationInstitutionsByProvinceIdAndInstitutionType(provinceId, type)));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new ApiResponse(false, "Invalid institution type: " + institutionType, null));
        }
    }
}
