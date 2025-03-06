package com.wabizone.ecommerce.repository;

import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;

import com.wabizone.ecommerce.models.ShoppingCart;

public interface ShoppingCartRepository extends MongoRepository<ShoppingCart, String> {
    
    Optional<ShoppingCart> findBySessionId(String sessionId);
    
    Optional<ShoppingCart> findByUsuarioId(Long usuarioId);
    
    void deleteByUltimaActualizacionBefore(java.util.Date date);
}