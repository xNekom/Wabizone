package com.example.demo.repository;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.demo.models.Product;

//El long del JpaRepository viene del tipo de dato que tiene asociado el id de la tabla, en este caso Product
public interface ProductRepository extends JpaRepository<Product, Long> {
    Optional<Product> findByCustomId(String customId);
}
