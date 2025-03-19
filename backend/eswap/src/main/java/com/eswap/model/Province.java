package com.eswap.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;
import lombok.ToString;

import java.util.List;
@Entity
@Table(name = "provinces")
@Data
public class Province {

    @Id
    private String id;

    private String name;

    private String nameEn;

    private String codeName;

    @OneToMany(mappedBy = "province", fetch = FetchType.LAZY,
            cascade = {CascadeType.PERSIST, CascadeType.MERGE, CascadeType.DETACH, CascadeType.REFRESH})
    @JsonIgnore
    @ToString.Exclude
    private List<EducationInstitution> educationInstitutions;
}
