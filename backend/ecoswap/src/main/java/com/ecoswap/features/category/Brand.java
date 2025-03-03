package com.ecoswap.features.category;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.util.Set;

@Entity
@Table(name = "brands")
@Getter
@Setter
public class Brand {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;
    private String name;
    @ManyToMany(mappedBy = "brands")
    @JsonIgnore
    @ToString.Exclude
    private Set<Category> categories;
}
