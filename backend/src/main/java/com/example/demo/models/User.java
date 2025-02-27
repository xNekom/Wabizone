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
@Table(name = "User")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "nombre")
    private String nombre;

    @Column(name = "contrasena")
    private String contrasena;

    @Column(name = "edad")
    private Integer edad;
    
    @Column(name = "administrador")
    private Boolean administrador = false;
    
    @Column(name = "trato")
    private String trato;
    
    @Column(name = "imagen")
    private String imagen;
    
    @Column(name = "lugar_nacimiento")
    private String lugarNacimiento;
    
    @Column(name = "bloqueado")
    private Boolean bloqueado = false;

    public User() {
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
        final User other = (User) obj;
        return Objects.equals(this.id, other.id);
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getContrasena() {
        return contrasena;
    }

    public void setContrasena(String contrasena) {
        this.contrasena = contrasena;
    }

    public Integer getEdad() {
        return edad;
    }

    public void setEdad(Integer edad) {
        this.edad = edad;
    }

    public Boolean isAdministrador() {
        return administrador == null ? false : administrador;
    }

    public void setAdministrador(Boolean administrador) {
        this.administrador = administrador == null ? false : administrador;
    }
    
    public String getTrato() {
        return trato;
    }

    public void setTrato(String trato) {
        this.trato = trato;
    }

    public String getImagen() {
        return imagen;
    }

    public void setImagen(String imagen) {
        this.imagen = imagen;
    }

    public String getLugarNacimiento() {
        return lugarNacimiento;
    }

    public void setLugarNacimiento(String lugarNacimiento) {
        this.lugarNacimiento = lugarNacimiento;
    }

    public Boolean isBloqueado() {
        return bloqueado == null ? false : bloqueado;
    }

    public void setBloqueado(Boolean bloqueado) {
        this.bloqueado = bloqueado == null ? false : bloqueado;
    }
}
