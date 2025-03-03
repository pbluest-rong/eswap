package com.ecoswap.features.role;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.ecoswap.features.user.User;
import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Table(name = "roles")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Role {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;
    private String name;// USER, SHOP, ADMIN
    @OneToMany(mappedBy = "role",fetch = FetchType.LAZY,
            cascade = {CascadeType.PERSIST, CascadeType.MERGE, CascadeType.DETACH, CascadeType.REFRESH})
    @JsonIgnore
    @ToString.Exclude
    private List<User> users;
}
