package com.wabizone.ecommerce.services;


import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.wabizone.ecommerce.api.request.UserCreationRequest;
import com.wabizone.ecommerce.models.User;
import com.wabizone.ecommerce.repository.UserRepository;


//Plantear aqui toda la logica de negocio ademas del crud llamar a todos los metodos que haran cosas adicionales cuando se haga algo del CRUD, o no
@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService (UserRepository userRepository){
        this.userRepository = userRepository;
    }

    public User createUser (UserCreationRequest userCreationRequest){
        return userRepository.save(mapToUser(userCreationRequest));
    }

    private User mapToUser (UserCreationRequest createRequest){
        User user = new User();
        user.setNombre(createRequest.nombre());
        user.setContrasena(createRequest.contrasena());
        user.setEdad(createRequest.edad());
        user.setAdministrador(createRequest.administrador());
        user.setTrato(createRequest.trato());
        user.setImagen(createRequest.imagen());
        user.setLugarNacimiento(createRequest.lugarNacimiento());
        user.setBloqueado(createRequest.bloqueado());
        return user;
    }

    public void removeUser (Long id){
        userRepository.deleteById(id);
    }

    public Optional<User> getUser (final long id){
        return userRepository.findById(id);
    }

    public List<User> getAllUsers(){
        return userRepository.findAll();
    }
    
    public Optional<User> authenticateUser(String nombre, String contrasena) {
        return userRepository.findByNombreAndContrasena(nombre, contrasena);
    }
    
    public Optional<User> findUserByNombre(String nombre) {
        return userRepository.findByNombre(nombre);
    }
    
    public User updateUser(Long id, UserCreationRequest userUpdateRequest) {
        Optional<User> existingUser = userRepository.findById(id);
        if (existingUser.isPresent()) {
            User user = existingUser.get();
            user.setNombre(userUpdateRequest.nombre());
            user.setContrasena(userUpdateRequest.contrasena());
            user.setEdad(userUpdateRequest.edad());
            user.setAdministrador(userUpdateRequest.administrador());
            user.setTrato(userUpdateRequest.trato());
            user.setImagen(userUpdateRequest.imagen());
            user.setLugarNacimiento(userUpdateRequest.lugarNacimiento());
            user.setBloqueado(userUpdateRequest.bloqueado());
            return userRepository.save(user);
        } else {
            throw new RuntimeException("Usuario con id " + id + " no encontrado");
        }
    }
}
