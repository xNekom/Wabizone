package com.example.demo.repository;
import org.springframework.data.jpa.repository.JpaRepository;

import com.example.demo.models.Pedido;

//El long del JpaRepository viene del tipo de dato que tiene asociado el id de la tabla, en este caso User
public interface PedidoRepository extends JpaRepository<Pedido, Long> {}
