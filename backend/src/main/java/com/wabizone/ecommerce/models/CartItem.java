package com.wabizone.ecommerce.models;

public class CartItem {
    
    private Long productoId;
    private String nombre;
    private Integer cantidad;
    private Double precio;
    private String opciones;
    
    public CartItem() {}
    
    public CartItem(Long productoId, String nombre, Integer cantidad, Double precio) {
        this.productoId = productoId;
        this.nombre = nombre;
        this.cantidad = cantidad;
        this.precio = precio;
    }
    
    public CartItem(Long productoId, String nombre, Integer cantidad, Double precio, String opciones) {
        this.productoId = productoId;
        this.nombre = nombre;
        this.cantidad = cantidad;
        this.precio = precio;
        this.opciones = opciones;
    }
    
    public Long getProductoId() {
        return productoId;
    }
    
    public void setProductoId(Long productoId) {
        this.productoId = productoId;
    }
    
    public String getNombre() {
        return nombre;
    }
    
    public void setNombre(String nombre) {
        this.nombre = nombre;
    }
    
    public Integer getCantidad() {
        return cantidad;
    }
    
    public void setCantidad(Integer cantidad) {
        this.cantidad = cantidad;
    }
    
    public Double getPrecio() {
        return precio;
    }
    
    public void setPrecio(Double precio) {
        this.precio = precio;
    }
    
    public String getOpciones() {
        return opciones;
    }
    
    public void setOpciones(String opciones) {
        this.opciones = opciones;
    }
}