package com.wabizone.ecommerce.api;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.wabizone.ecommerce.models.CartItem;
import com.wabizone.ecommerce.models.ShoppingCart;
import com.wabizone.ecommerce.repository.ShoppingCartRepository;

@RestController
@RequestMapping("/api/v1/cart")
public class ShoppingCartController {

    private final ShoppingCartRepository shoppingCartRepository;

    @Autowired
    public ShoppingCartController(ShoppingCartRepository shoppingCartRepository) {
        this.shoppingCartRepository = shoppingCartRepository;
    }

    // Obtener carrito por ID de sesión (usuarios no autenticados)
    @GetMapping("/session/{sessionId}")
    public ResponseEntity<ShoppingCart> getCartBySessionId(@PathVariable String sessionId) {
        Optional<ShoppingCart> cart = shoppingCartRepository.findBySessionId(sessionId);
        return cart.map(ResponseEntity::ok)
                .orElseGet(() -> {
                    ShoppingCart newCart = new ShoppingCart(sessionId, null);
                    return ResponseEntity.ok(shoppingCartRepository.save(newCart));
                });
    }

    // Obtener carrito por ID de usuario (usuarios autenticados)
    @GetMapping("/user/{userId}")
    public ResponseEntity<ShoppingCart> getCartByUserId(@PathVariable Long userId) {
        Optional<ShoppingCart> cart = shoppingCartRepository.findByUsuarioId(userId);
        return cart.map(ResponseEntity::ok)
                .orElseGet(() -> {
                    ShoppingCart newCart = new ShoppingCart(null, userId);
                    return ResponseEntity.ok(shoppingCartRepository.save(newCart));
                });
    }

    // Añadir producto al carrito
    @PostMapping("/{cartId}/items")
    public ResponseEntity<ShoppingCart> addItemToCart(@PathVariable String cartId, @RequestBody CartItem item) {
        Optional<ShoppingCart> optionalCart = shoppingCartRepository.findById(cartId);
        if (optionalCart.isPresent()) {
            ShoppingCart cart = optionalCart.get();
            cart.addItem(item);
            return ResponseEntity.ok(shoppingCartRepository.save(cart));
        }
        return ResponseEntity.notFound().build();
    }

    // Actualizar cantidad de un producto en el carrito
    @PutMapping("/{cartId}/items/{productId}")
    public ResponseEntity<ShoppingCart> updateItemQuantity(
            @PathVariable String cartId,
            @PathVariable Long productId,
            @RequestParam Integer cantidad) {
        
        Optional<ShoppingCart> optionalCart = shoppingCartRepository.findById(cartId);
        if (optionalCart.isPresent()) {
            ShoppingCart cart = optionalCart.get();
            cart.updateItemQuantity(productId, cantidad);
            return ResponseEntity.ok(shoppingCartRepository.save(cart));
        }
        return ResponseEntity.notFound().build();
    }

    // Eliminar producto del carrito
    @DeleteMapping("/{cartId}/items/{productId}")
    public ResponseEntity<ShoppingCart> removeItemFromCart(
            @PathVariable String cartId,
            @PathVariable Long productId) {
        
        Optional<ShoppingCart> optionalCart = shoppingCartRepository.findById(cartId);
        if (optionalCart.isPresent()) {
            ShoppingCart cart = optionalCart.get();
            cart.removeItem(productId);
            return ResponseEntity.ok(shoppingCartRepository.save(cart));
        }
        return ResponseEntity.notFound().build();
    }

    // Vaciar carrito
    @DeleteMapping("/{cartId}")
    public ResponseEntity<ShoppingCart> clearCart(@PathVariable String cartId) {
        Optional<ShoppingCart> optionalCart = shoppingCartRepository.findById(cartId);
        if (optionalCart.isPresent()) {
            ShoppingCart cart = optionalCart.get();
            cart.clearCart();
            return ResponseEntity.ok(shoppingCartRepository.save(cart));
        }
        return ResponseEntity.notFound().build();
    }
    
    // Transferir carrito de sesión a usuario (cuando un usuario inicia sesión)
    @PostMapping("/transfer")
    public ResponseEntity<ShoppingCart> transferSessionCartToUser(
            @RequestParam String sessionId,
            @RequestParam Long userId) {
        
        Optional<ShoppingCart> sessionCart = shoppingCartRepository.findBySessionId(sessionId);
        if (!sessionCart.isPresent()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
        
        // Buscar si el usuario ya tiene un carrito
        Optional<ShoppingCart> userCart = shoppingCartRepository.findByUsuarioId(userId);
        
        if (userCart.isPresent()) {
            // Si el usuario ya tiene carrito, transferir los elementos del carrito de sesión
            ShoppingCart existingUserCart = userCart.get();
            for (CartItem item : sessionCart.get().getItems()) {
                existingUserCart.addItem(item);
            }
            
            // Eliminar el carrito de sesión
            shoppingCartRepository.delete(sessionCart.get());
            
            // Guardar el carrito actualizado del usuario
            return ResponseEntity.ok(shoppingCartRepository.save(existingUserCart));
        } else {
            // Si el usuario no tiene carrito, simplemente actualizar el de la sesión
            ShoppingCart cartToTransfer = sessionCart.get();
            cartToTransfer.setUsuarioId(userId);
            cartToTransfer.setSessionId(null);  // Ya no necesitamos el sessionId
            return ResponseEntity.ok(shoppingCartRepository.save(cartToTransfer));
        }
    }
}