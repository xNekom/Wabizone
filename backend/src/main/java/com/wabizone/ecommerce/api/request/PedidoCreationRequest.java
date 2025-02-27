package com.wabizone.ecommerce.api.request;

public record PedidoCreationRequest(Long nPedido, String detallesPedido, String estadoPedido, double precioTotal) {}
