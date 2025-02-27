package com.example.demo.models;
import java.util.Objects;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;


//Modelo objeto relacionandolo con la tabla 
@Entity
@Table(name = "Pedido")
public class Pedido {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "n_pedido")
    private Long nPedido;

    @Column(name = "detalles_pedido")
    private String detallesPedido;

    @Column(name = "estado_pedido")
    private String estadoPedido;
    
    @Column(name = "precio_total")
    private double precioTotal;

    public Pedido() {
    }

    //Generado en source actions solo el id de la tabla para comprobar
    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final Pedido other = (Pedido) obj;
        return Objects.equals(this.id, other.id);
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getNPedido() {
        return nPedido;
    }

    public void setNPedido(Long nPedido) {
        this.nPedido = nPedido;
    }

    public String getDetallesPedido() {
        return detallesPedido;
    }

    public void setDetallesPedido(String detallesPedido) {
        this.detallesPedido = detallesPedido;
    }

    public String getEstadoPedido() {
        return estadoPedido;
    }

    public void setEstadoPedido(String estadoPedido) {
        this.estadoPedido = estadoPedido;
    }

    public double getPrecioTotal() {
        return precioTotal;
    }

    public void setPrecioTotal(double precioTotal) {
        this.precioTotal = precioTotal;
    }
}
