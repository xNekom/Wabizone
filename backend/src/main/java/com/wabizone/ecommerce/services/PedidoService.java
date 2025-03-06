package com.wabizone.ecommerce.services;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.wabizone.ecommerce.api.request.PedidoCreationRequest;
import com.wabizone.ecommerce.models.Pedido;
import com.wabizone.ecommerce.models.User;
import com.wabizone.ecommerce.repository.PedidoRepository;
import com.wabizone.ecommerce.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class PedidoService {

    private static final Logger logger = LoggerFactory.getLogger(PedidoService.class);
    private final PedidoRepository pedidoRepository;
    private final UserRepository userRepository;

    public PedidoService(PedidoRepository pedidoRepository, UserRepository userRepository) {
        this.pedidoRepository = pedidoRepository;
        this.userRepository = userRepository;
    }

    public Pedido createPedido(PedidoCreationRequest pedidoCreationRequest) {
        logger.info("Creating new pedido with number: {}", pedidoCreationRequest.nPedido());
        Pedido pedido = mapToPedido(pedidoCreationRequest);
        
        if (pedido.getUsuarioId() != null && (pedido.getNombreUsuario() == null || pedido.getNombreUsuario().isEmpty())) {
            logger.debug("Completing user information for pedido");
            Optional<User> user = userRepository.findById(pedido.getUsuarioId());
            user.ifPresent(u -> pedido.setNombreUsuario(u.getNombre()));
        }
        
        Pedido savedPedido = pedidoRepository.save(pedido);
        logger.info("Pedido created successfully with ID: {}", savedPedido.getId());
        return savedPedido;
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
        logger.info("Removing pedido with ID: {}", id);
        pedidoRepository.deleteById(id);
        logger.info("Pedido removed successfully");
    }

    public Optional<Pedido> getPedido(final long id) {
        logger.debug("Fetching pedido with ID: {}", id);
        return pedidoRepository.findById(id);
    }

    public List<Pedido> getAllPedidos() {
        logger.debug("Fetching all pedidos");
        List<Pedido> pedidos = pedidoRepository.findAll();
        pedidos.forEach(this::completarInformacionUsuario);
        logger.debug("Retrieved {} pedidos", pedidos.size());
        return pedidos;
    }
    
    public Pedido updatePedido(Long id, PedidoCreationRequest pedidoUpdateRequest) {
        logger.info("Updating pedido with ID: {}", id);
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
            
            Pedido updatedPedido = pedidoRepository.save(pedido);
            logger.info("Pedido updated successfully");
            return updatedPedido;
        } else {
            logger.error("Pedido with ID {} not found", id);
            throw new RuntimeException("Pedido con id " + id + " no encontrado");
        }
    }
    
    public List<Pedido> getPedidosByEstado(String estado) {
        logger.debug("Fetching pedidos with estado: {}", estado);
        List<Pedido> pedidos = pedidoRepository.findAll();
        pedidos = pedidos.stream()
                .filter(pedido -> pedido.getEstadoPedido().equals(estado))
                .toList();
        pedidos.forEach(this::completarInformacionUsuario);
        logger.debug("Retrieved {} pedidos with estado: {}", pedidos.size(), estado);
        return pedidos;
    }

    private void completarInformacionUsuario(Pedido pedido) {
        if (pedido.getUsuarioId() != null && (pedido.getNombreUsuario() == null || pedido.getNombreUsuario().isEmpty())) {
            logger.debug("Completing user information for pedido ID: {}", pedido.getId());
            Optional<User> user = userRepository.findById(pedido.getUsuarioId());
            user.ifPresent(u -> pedido.setNombreUsuario(u.getNombre()));
        }
    }
}
