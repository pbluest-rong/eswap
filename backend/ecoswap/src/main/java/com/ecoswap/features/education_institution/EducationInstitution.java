package com.ecoswap.features.education_institution;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.ecoswap.features.user.User;
import jakarta.persistence.*;
import lombok.Data;
import lombok.ToString;

import java.util.List;

@Entity
@Table(name = "education_institutions")
@Data
public class EducationInstitution {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;
    private String code;
    private String name;
    @ManyToOne
    @JoinColumn(name = "province_id")
    @ToString.Exclude
    private Province province;
    private String address;
    @OneToMany(mappedBy = "educationInstitution",fetch = FetchType.LAZY,
            cascade = {CascadeType.PERSIST, CascadeType.MERGE, CascadeType.DETACH, CascadeType.REFRESH})
    @JsonIgnore
    @ToString.Exclude
    private List<User> users;
}
