package com.eswap.repository;

import com.eswap.model.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface UserRepositoryCustom {
    Page<User> searchUsersWithPriority(User currentUser, String keyword, Pageable pageable);
}
