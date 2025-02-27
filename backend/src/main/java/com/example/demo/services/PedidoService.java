package com.example.demo.services;


import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.example.demo.api.request.PedidoCreationRequest;
import com.example.demo.models.Pedido;
import com.example.demo.repository.PedidoRepository;


//Plantear aqui toda la logica de negocio ademas del crud llamar a todos los metodos que haran cosas adicionales cuando se haga algo del CRUD, o no
@Service
public class PedidoService {

    private final PedidoRepository pedidoRepository;

    public PedidoService (PedidoRepository pedidoRepository){
        this.pedidoRepository = pedidoRepository;
    }

    public Pedido createPedido (PedidoCreationRequest pedidoCreationRequest){
        return pedidoRepository.save(mapToPedido(pedidoCreationRequest));
    }

    private Pedido mapToPedido (PedidoCreationRequest createRequest){
        Pedido pedido = new Pedido();
        pedido.setNPedido(createRequest.nPedido());
        pedido.setDetallesPedido(createRequest.detallesPedido());
        pedido.setEstadoPedido(createRequest.estadoPedido());
        pedido.setPrecioTotal(createRequest.precioTotal());
        return pedido;
    }

    public void removePedido (Long id){
        pedidoRepository.deleteById(id);
    }

    public Optional<Pedido> getPedido (final long id){
        return pedidoRepository.findById(id);
    }

    public List<Pedido> getAllPedidos(){
        return pedidoRepository.findAll();
    }
    
    public Pedido updatePedido(Long id, PedidoCreationRequest pedidoUpdateRequest) {
        Optional<Pedido> existingPedido = pedidoRepository.findById(id);
        if (existingPedido.isPresent()) {
            Pedido pedido = existingPedido.get();
            pedido.setNPedido(pedidoUpdateRequest.nPedido());
            pedido.setDetallesPedido(pedidoUpdateRequest.detallesPedido());
            pedido.setEstadoPedido(pedidoUpdateRequest.estadoPedido());
            pedido.setPrecioTotal(pedidoUpdateRequest.precioTotal());
            return pedidoRepository.save(pedido);
        } else {
            throw new RuntimeException("Pedido con id " + id + " no encontrado");
        }
    }
    
    public List<Pedido> getPedidosByEstado(String estado) {
        List<Pedido> pedidos = pedidoRepository.findAll();
        return pedidos.stream()
                .filter(pedido -> pedido.getEstadoPedido().equals(estado))
                .toList();
    }
}

