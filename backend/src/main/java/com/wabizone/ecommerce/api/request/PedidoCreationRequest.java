package com.wabizone.ecommerce.api.request;

public record PedidoCreationRequest(
    Long nPedido, 
    String detallesPedido, 
    String estadoPedido, 
    double precioTotal,
    Long usuarioId,
    String nombreUsuario,
    String nombreCompleto,
    String direccion,
    String ciudad,
    String codigoPostal,
    String telefono,
    String email,
    String comentarios
) {}
