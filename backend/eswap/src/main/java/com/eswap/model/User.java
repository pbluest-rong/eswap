package com.eswap.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
@Entity
@Table(name = "users", uniqueConstraints = {
        @UniqueConstraint(columnNames = "email"),
        @UniqueConstraint(columnNames = "username")
})
@EntityListeners(AuditingEntityListener.class)
public class User implements UserDetails {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;
    @Size(min = 3, max = 30, message = "Username must be between 3 and 30 characters")
    @Pattern(
            regexp = "^(?!.*\\.\\.)(?!.*\\.$)[a-zA-Z0-9._]+$",
            message = "Username can only contain letters, numbers, periods, and underscores, but cannot start or end with a period or have consecutive periods"
    )
    private String username;
    @Column(name = "first_name")
    private String firstName;
    @Column(name = "last_name")
    private String lastName;
    private LocalDate dob;
    private Boolean gender;
    private String email;
    private String password;

    // Sau khi register -> update : address, phone number, avatar url
    private String address;
    @Column(name = "phone_number")
    private String phoneNumber;
    @Column(name = "avatar_url")
    private String avatarUrl;

    private boolean requireFollowApproval = false;
    private boolean accountLocked = false;
    private boolean enabled = true;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "education_institution_id")
    private EducationInstitution educationInstitution;

    @ManyToOne()
    @JoinColumn(name = "role_id")
    @ToString.Exclude
    private Role role;

    @OneToMany(mappedBy = "follower", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnore
    private List<Follow> following = new ArrayList<>();

    @OneToMany(mappedBy = "followee", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnore
    private List<Follow> followers = new ArrayList<>();

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdDate;
    @LastModifiedDate
    @Column(insertable = false)
    private LocalDateTime lastModifiedDate;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return Collections.singletonList(new SimpleGrantedAuthority(role.getName()));
    }

    @Override
    public String getUsername() {
        return username;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return !accountLocked;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return enabled;
    }

    @PrePersist
    public void generateUsernameIfEmpty() {
        if (this.username == null || this.username.isEmpty()) {
            this.username = "user" + System.currentTimeMillis() + UUID.randomUUID().toString().substring(0, 4);
        }
    }
    public static boolean isValidEmail(String email) {
        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$";
        return email != null && email.matches(emailRegex);
    }

    public static boolean isValidPhoneNumber(String phoneNumber) {
        String phoneRegex = "^\\+?[0-9]{7,15}$";
        return phoneNumber != null && phoneNumber.matches(phoneRegex);
    }

    public static boolean isValidUsername(String username) {
        String usernameRegex = "^(?!.*\\.\\.)(?!.*\\.$)[a-zA-Z0-9._]{3,30}$";
        return username != null && username.matches(usernameRegex);
    }
}
