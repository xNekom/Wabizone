package com.example.demo.api;

import java.util.List;
import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.api.request.PedidoCreationRequest;
import com.example.demo.models.Pedido;
import com.example.demo.services.PedidoService;

@RestController
@RequestMapping("/api/v1/pedidos")
@CrossOrigin(origins = "*")
public class PedidoController {

    private final PedidoService pedidoService;

    public PedidoController(PedidoService pedidoService) {
        this.pedidoService = pedidoService;
    }

    @PostMapping
    public ResponseEntity<Pedido> createPedido(@RequestBody PedidoCreationRequest pedidoCreationRequest){
        return ResponseEntity.status(HttpStatus.CREATED).body(pedidoService.createPedido(pedidoCreationRequest));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePedido(@PathVariable Long id){
        pedidoService.removePedido(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Pedido> getPedido(@PathVariable Long id){
        Optional<Pedido> pedido = pedidoService.getPedido(id);
        return pedido.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping
    public ResponseEntity<List<Pedido>> getAllPedidos(){
        return ResponseEntity.ok(pedidoService.getAllPedidos());
    }
    
    @GetMapping("/estado")
    public ResponseEntity<List<Pedido>> getPedidosByEstado(@RequestParam String estado) {
        List<Pedido> pedidos = pedidoService.getPedidosByEstado(estado);
        return ResponseEntity.ok(pedidos);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Pedido> updatePedido(@PathVariable Long id, @RequestBody PedidoCreationRequest pedidoUpdateRequest) {
        try {
            Pedido updatedPedido = pedidoService.updatePedido(id, pedidoUpdateRequest);
            return ResponseEntity.ok(updatedPedido);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
