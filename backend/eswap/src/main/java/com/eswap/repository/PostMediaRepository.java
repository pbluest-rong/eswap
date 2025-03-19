package com.eswap.repository;

import com.eswap.model.PostMedia;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PostMediaRepository extends JpaRepository<PostMedia, Long> {
}
