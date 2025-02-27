package com.wabizone.ecommerce.models;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "shopping_carts")
public class ShoppingCart {
    
    @Id
    private String id;
    private String sessionId;      // Para carritos de usuarios no registrados
    private Long usuarioId;        // Para usuarios registrados (puede ser null)
    private List<CartItem> items = new ArrayList<>();  // Lista de items en el carrito
    private Date ultimaActualizacion = new Date();
    private Double total = 0.0;
    
    public ShoppingCart() {}
    
    public ShoppingCart(String sessionId, Long usuarioId) {
        this.sessionId = sessionId;
        this.usuarioId = usuarioId;
    }
    
    // Métodos para manipular el carrito
    public void addItem(CartItem item) {
        // Verificar si el producto ya está en el carrito
        for (int i = 0; i < items.size(); i++) {
            CartItem existingItem = items.get(i);
            if (existingItem.getProductoId().equals(item.getProductoId())) {
                // Si el producto ya está en el carrito, incrementar cantidad
                existingItem.setCantidad(existingItem.getCantidad() + item.getCantidad());
                this.recalculateTotal();
                this.ultimaActualizacion = new Date();
                return;
            }
        }
        
        // Si el producto no está en el carrito, añadirlo
        this.items.add(item);
        this.recalculateTotal();
        this.ultimaActualizacion = new Date();
    }
    
    public void removeItem(Long productoId) {
        this.items.removeIf(item -> item.getProductoId().equals(productoId));
        this.recalculateTotal();
        this.ultimaActualizacion = new Date();
    }
    
    public void updateItemQuantity(Long productoId, Integer cantidad) {
        for (CartItem item : items) {
            if (item.getProductoId().equals(productoId)) {
                item.setCantidad(cantidad);
                break;
            }
        }
        this.recalculateTotal();
        this.ultimaActualizacion = new Date();
    }
    
    public void clearCart() {
        this.items.clear();
        this.total = 0.0;
        this.ultimaActualizacion = new Date();
    }
    
    private void recalculateTotal() {
        this.total = 0.0;
        for (CartItem item : items) {
            this.total += item.getPrecio() * item.getCantidad();
        }
    }
    
    // Getters y Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getSessionId() {
        return sessionId;
    }

    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }

    public Long getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(Long usuarioId) {
        this.usuarioId = usuarioId;
    }

    public List<CartItem> getItems() {
        return items;
    }

    public void setItems(List<CartItem> items) {
        this.items = items;
        this.recalculateTotal();
    }

    public Date getUltimaActualizacion() {
        return ultimaActualizacion;
    }

    public void setUltimaActualizacion(Date ultimaActualizacion) {
        this.ultimaActualizacion = ultimaActualizacion;
    }

    public Double getTotal() {
        return total;
    }
} 