package com.eswap.service;

import com.eswap.model.Brand;
import com.eswap.model.Category;
import com.eswap.repository.BrandRepository;
import com.eswap.repository.CategoryRepository;
import com.eswap.request.AddBrandRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class BrandService {
    private final BrandRepository brandRepository;
    private final CategoryRepository categoryRepository;

    public List<Brand> getAllBrands() {
        return brandRepository.findAll();
    }

    public Optional<Brand> getBrandById(Long id) {
        return brandRepository.findById(id);
    }

    public Brand addBrand(AddBrandRequest request) {
        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new IllegalArgumentException("Category not found"));


        Brand brand = brandRepository.findByName(request.getName().trim());
        if (brand == null) {
            brand = new Brand();
            brand.setName(request.getName());
            brand = brandRepository.save(brand);
            category.getBrands().add(brand);
            categoryRepository.save(category);
        }
        return brand;
    }
}
