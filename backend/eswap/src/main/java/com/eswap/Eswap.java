package com.eswap;

import com.eswap.common.constants.RoleType;
import com.eswap.model.Role;
import com.eswap.repository.RoleRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.context.annotation.Bean;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableJpaAuditing
@EnableAsync
@EnableFeignClients
public class Eswap {
    @Bean
    public CommandLineRunner runner(RoleRepository roleRepository) {
        return args -> {
            if (roleRepository.findByName(RoleType.USER).isEmpty()) {
                roleRepository.save(Role.builder().name(RoleType.USER).build());
            }
            if (roleRepository.findByName(RoleType.STORE).isEmpty()) {
                roleRepository.save(Role.builder().name(RoleType.STORE).build());
            }
            if (roleRepository.findByName(RoleType.ADMIN).isEmpty()) {
                roleRepository.save(Role.builder().name(RoleType.ADMIN).build());
            }
        };
    }

    public static void main(String[] args) {
        SpringApplication.run(Eswap.class, args);
    }

}
