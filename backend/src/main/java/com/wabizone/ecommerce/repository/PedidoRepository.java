package com.wabizone.ecommerce.repository;
import org.springframework.data.jpa.repository.JpaRepository;

import com.wabizone.ecommerce.models.Pedido;

//El long del JpaRepository viene del tipo de dato que tiene asociado el id de la tabla, en este caso User
public interface PedidoRepository extends JpaRepository<Pedido, Long> {}
