package com.wabizone.ecommerce.repository;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.wabizone.ecommerce.models.Product;

public interface ProductRepository extends JpaRepository<Product, Long> {
    Optional<Product> findByCustomId(String customId);
}
