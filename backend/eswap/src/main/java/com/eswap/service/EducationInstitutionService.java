
package com.eswap.service;

import com.eswap.common.constants.AppErrorCode;
import com.eswap.common.constants.InstitutionType;
import com.eswap.common.exception.ResourceNotFoundException;
import com.eswap.model.EducationInstitution;
import com.eswap.model.Province;
import com.eswap.repository.EducationInstitutionRepository;
import com.eswap.repository.ProvinceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class EducationInstitutionService {
    private final EducationInstitutionRepository educationInstitutionRepository;
    private final ProvinceRepository provinceRepository;

    public List<Province> getProvinces() {
        return provinceRepository.findAll();
    }

    public List<EducationInstitution> getEducationInstitutionsByProvinceId(String provinceId) {
        Province province = provinceRepository.findById(provinceId).orElseThrow(
                () -> new ResourceNotFoundException(AppErrorCode.PROVINCE_NOT_FOUND)
        );
        return educationInstitutionRepository.findByProvince(province);
    }

    public List<EducationInstitution> getEducationInstitutionsByProvinceIdAndInstitutionType(String provinceId, InstitutionType institutionType) {
        Province province = provinceRepository.findById(provinceId).orElseThrow(
                () -> new ResourceNotFoundException(AppErrorCode.PROVINCE_NOT_FOUND)
        );
        return educationInstitutionRepository.findByProvinceAndInstitutionType(province, institutionType);
    }
}