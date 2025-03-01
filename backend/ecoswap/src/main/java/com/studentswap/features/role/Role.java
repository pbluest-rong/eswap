package com.studentswap.features.role;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.studentswap.common.enums.RoleType;
import com.studentswap.features.user.User;
import jakarta.persistence.*;
import lombok.Data;
import lombok.ToString;

import java.util.List;

@Entity
@Table(name = "roles")
@Data
public class Role {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;
    private RoleType role;
    @OneToMany(mappedBy = "role",fetch = FetchType.LAZY,
            cascade = {CascadeType.PERSIST, CascadeType.MERGE, CascadeType.DETACH, CascadeType.REFRESH})
    @JsonIgnore
    @ToString.Exclude
    private List<User> users;
}
