package com.wabizone.ecommerce.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;

import com.wabizone.ecommerce.models.ShoppingCart;

/**
 * Repositorio para acceder a los carritos de compra almacenados en MongoDB
 */
public interface ShoppingCartRepository extends MongoRepository<ShoppingCart, String> {
    
    // Encontrar carrito por ID de sesión (para usuarios no autenticados)
    Optional<ShoppingCart> findBySessionId(String sessionId);
    
    // Encontrar carrito por ID de usuario (para usuarios autenticados)
    Optional<ShoppingCart> findByUsuarioId(Long usuarioId);
    
    // Eliminar carritos antiguos (podría usarse para tareas programadas de limpieza)
    void deleteByUltimaActualizacionBefore(java.util.Date date);
}