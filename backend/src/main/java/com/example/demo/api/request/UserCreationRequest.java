package com.example.demo.api.request;

public record UserCreationRequest(
    String nombre, 
    String contrasena, 
    int edad, 
    boolean administrador,
    String trato,
    String imagen,
    String lugarNacimiento,
    boolean bloqueado
) {}
