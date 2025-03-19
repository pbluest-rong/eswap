package com.eswap.repository;

import com.eswap.common.constants.InstitutionType;
import com.eswap.model.EducationInstitution;
import com.eswap.model.Province;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EducationInstitutionRepository extends JpaRepository<EducationInstitution, Long> {

    List<EducationInstitution> findByProvince(Province province);

    List<EducationInstitution> findByProvinceAndInstitutionType(Province province, InstitutionType institutionType);
}
