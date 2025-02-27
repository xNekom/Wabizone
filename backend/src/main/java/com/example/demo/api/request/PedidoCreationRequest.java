package com.example.demo.api.request;

public record PedidoCreationRequest(Long nPedido, String detallesPedido, String estadoPedido, double precioTotal) {}
