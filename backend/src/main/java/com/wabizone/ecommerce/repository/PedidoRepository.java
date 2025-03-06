package com.wabizone.ecommerce.repository;
import org.springframework.data.jpa.repository.JpaRepository;

import com.wabizone.ecommerce.models.Pedido;

public interface PedidoRepository extends JpaRepository<Pedido, Long> {}
