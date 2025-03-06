package com.wabizone.ecommerce.repository;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.wabizone.ecommerce.models.User;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByNombre(String nombre);
    Optional<User> findByNombreAndContrasena(String nombre, String contrasena);
}
