package com.wabizone.ecommerce.services;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.wabizone.ecommerce.api.request.PedidoCreationRequest;
import com.wabizone.ecommerce.models.Pedido;
import com.wabizone.ecommerce.models.User;
import com.wabizone.ecommerce.repository.PedidoRepository;
import com.wabizone.ecommerce.repository.UserRepository;

@Service
public class PedidoService {

    private final PedidoRepository pedidoRepository;
    private final UserRepository userRepository;

    public PedidoService(PedidoRepository pedidoRepository, UserRepository userRepository) {
        this.pedidoRepository = pedidoRepository;
        this.userRepository = userRepository;
    }

    public Pedido createPedido(PedidoCreationRequest pedidoCreationRequest) {
        Pedido pedido = mapToPedido(pedidoCreationRequest);
        
        if (pedido.getUsuarioId() != null && (pedido.getNombreUsuario() == null || pedido.getNombreUsuario().isEmpty())) {
            Optional<User> user = userRepository.findById(pedido.getUsuarioId());
            user.ifPresent(u -> pedido.setNombreUsuario(u.getNombre()));
        }
        
        return pedidoRepository.save(pedido);
    }

    private Pedido mapToPedido(PedidoCreationRequest createRequest) {
        Pedido pedido = new Pedido();
        pedido.setNPedido(createRequest.nPedido());
        pedido.setDetallesPedido(createRequest.detallesPedido());
        pedido.setEstadoPedido(createRequest.estadoPedido());
        pedido.setPrecioTotal(createRequest.precioTotal());
        pedido.setUsuarioId(createRequest.usuarioId());
        pedido.setNombreUsuario(createRequest.nombreUsuario());
        pedido.setNombreCompleto(createRequest.nombreCompleto());
        pedido.setDireccion(createRequest.direccion());
        pedido.setCiudad(createRequest.ciudad());
        pedido.setCodigoPostal(createRequest.codigoPostal());
        pedido.setTelefono(createRequest.telefono());
        pedido.setEmail(createRequest.email());
        pedido.setComentarios(createRequest.comentarios());
        return pedido;
    }

    public void removePedido(Long id) {
        pedidoRepository.deleteById(id);
    }

    public Optional<Pedido> getPedido(final long id) {
        return pedidoRepository.findById(id);
    }

    public List<Pedido> getAllPedidos() {
        List<Pedido> pedidos = pedidoRepository.findAll();
        pedidos.forEach(this::completarInformacionUsuario);
        return pedidos;
    }
    
    public Pedido updatePedido(Long id, PedidoCreationRequest pedidoUpdateRequest) {
        Optional<Pedido> existingPedido = pedidoRepository.findById(id);
        if (existingPedido.isPresent()) {
            Pedido pedido = existingPedido.get();
            pedido.setNPedido(pedidoUpdateRequest.nPedido());
            pedido.setDetallesPedido(pedidoUpdateRequest.detallesPedido());
            pedido.setEstadoPedido(pedidoUpdateRequest.estadoPedido());
            pedido.setPrecioTotal(pedidoUpdateRequest.precioTotal());
            pedido.setUsuarioId(pedidoUpdateRequest.usuarioId());
            pedido.setNombreUsuario(pedidoUpdateRequest.nombreUsuario());
            pedido.setNombreCompleto(pedidoUpdateRequest.nombreCompleto());
            pedido.setDireccion(pedidoUpdateRequest.direccion());
            pedido.setCiudad(pedidoUpdateRequest.ciudad());
            pedido.setCodigoPostal(pedidoUpdateRequest.codigoPostal());
            pedido.setTelefono(pedidoUpdateRequest.telefono());
            pedido.setEmail(pedidoUpdateRequest.email());
            pedido.setComentarios(pedidoUpdateRequest.comentarios());
            
            completarInformacionUsuario(pedido);
            
            return pedidoRepository.save(pedido);
        } else {
            throw new RuntimeException("Pedido con id " + id + " no encontrado");
        }
    }
    
    public List<Pedido> getPedidosByEstado(String estado) {
        List<Pedido> pedidos = pedidoRepository.findAll();
        pedidos = pedidos.stream()
                .filter(pedido -> pedido.getEstadoPedido().equals(estado))
                .toList();
        pedidos.forEach(this::completarInformacionUsuario);
        return pedidos;
    }

    private void completarInformacionUsuario(Pedido pedido) {
        if (pedido.getUsuarioId() != null && (pedido.getNombreUsuario() == null || pedido.getNombreUsuario().isEmpty())) {
            Optional<User> user = userRepository.findById(pedido.getUsuarioId());
            user.ifPresent(u -> pedido.setNombreUsuario(u.getNombre()));
        }
    }
}
