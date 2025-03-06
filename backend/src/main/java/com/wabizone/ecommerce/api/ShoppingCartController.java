package com.wabizone.ecommerce.api;

import java.util.Optional;

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

    public ShoppingCartController(ShoppingCartRepository shoppingCartRepository) {
        this.shoppingCartRepository = shoppingCartRepository;
    }

    @GetMapping("/session/{sessionId}")
    public ResponseEntity<ShoppingCart> getCartBySessionId(@PathVariable String sessionId) {
        Optional<ShoppingCart> cart = shoppingCartRepository.findBySessionId(sessionId);
        return cart.map(ResponseEntity::ok)
                .orElseGet(() -> {
                    ShoppingCart newCart = new ShoppingCart(sessionId, null);
                    return ResponseEntity.ok(shoppingCartRepository.save(newCart));
                });
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<ShoppingCart> getCartByUserId(@PathVariable Long userId) {
        Optional<ShoppingCart> cart = shoppingCartRepository.findByUsuarioId(userId);
        return cart.map(ResponseEntity::ok)
                .orElseGet(() -> {
                    ShoppingCart newCart = new ShoppingCart(null, userId);
                    return ResponseEntity.ok(shoppingCartRepository.save(newCart));
                });
    }

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
    
    @PostMapping("/transfer")
    public ResponseEntity<ShoppingCart> transferSessionCartToUser(
            @RequestParam String sessionId,
            @RequestParam Long userId) {
        
        Optional<ShoppingCart> sessionCart = shoppingCartRepository.findBySessionId(sessionId);
        if (!sessionCart.isPresent()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
        
        Optional<ShoppingCart> userCart = shoppingCartRepository.findByUsuarioId(userId);
        
        if (userCart.isPresent()) {
            ShoppingCart existingUserCart = userCart.get();
            for (CartItem item : sessionCart.get().getItems()) {
                existingUserCart.addItem(item);
            }
            
            shoppingCartRepository.delete(sessionCart.get());
            
            return ResponseEntity.ok(shoppingCartRepository.save(existingUserCart));
        } else {
            ShoppingCart cartToTransfer = sessionCart.get();
            cartToTransfer.setUsuarioId(userId);
            cartToTransfer.setSessionId(null);
            return ResponseEntity.ok(shoppingCartRepository.save(cartToTransfer));
        }
    }

    @PostMapping("/create")
    public ResponseEntity<ShoppingCart> createNewCart(
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) String sessionId) {
        
        if (userId == null && sessionId == null) {
            return ResponseEntity.badRequest().build();
        }
        
        ShoppingCart newCart;
        if (userId != null) {
            Optional<ShoppingCart> existingCart = shoppingCartRepository.findByUsuarioId(userId);
            if (existingCart.isPresent()) {
                return ResponseEntity.ok(existingCart.get());
            }
            newCart = new ShoppingCart(null, userId);
        } else {
            Optional<ShoppingCart> existingCart = shoppingCartRepository.findBySessionId(sessionId);
            if (existingCart.isPresent()) {
                return ResponseEntity.ok(existingCart.get());
            }
            newCart = new ShoppingCart(sessionId, null);
        }
        
        return ResponseEntity.ok(shoppingCartRepository.save(newCart));
    }
}