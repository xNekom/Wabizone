package com.wabizone.ecommerce.api.request;

public record ProductCreationRequest(String customId, String nombre, String descripcion, int stock, double precio, String imagen) {}
