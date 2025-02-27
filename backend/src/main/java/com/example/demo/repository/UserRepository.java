package com.example.demo.repository;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.demo.models.User;

//El long del JpaRepository viene del tipo de dato que tiene asociado el id de la tabla, en este caso User
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByNombre(String nombre);
    Optional<User> findByNombreAndContrasena(String nombre, String contrasena);
}
