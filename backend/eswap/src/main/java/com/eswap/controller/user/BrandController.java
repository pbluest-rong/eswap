package com.eswap.controller.user;

import com.eswap.common.ApiResponse;
import com.eswap.model.Brand;
import com.eswap.service.BrandService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("brands")
@RequiredArgsConstructor
public class BrandController {
    private final BrandService brandService;

    @GetMapping
    public ResponseEntity<ApiResponse> getAllBrands() {
        List<Brand> brands = brandService.getAllBrands();
        return ResponseEntity.ok(new ApiResponse(true, "Fetched brands successfully", brands));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse> getBrandById(@PathVariable Long id) {
        return brandService.getBrandById(id)
                .map(brand -> ResponseEntity.ok(new ApiResponse(true, "Fetched brand successfully", brand)))
                .orElseGet(() -> ResponseEntity.badRequest().body(new ApiResponse(false, "Brand not found", null)));
    }
}
