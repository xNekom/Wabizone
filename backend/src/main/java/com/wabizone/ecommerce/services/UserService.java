package com.wabizone.ecommerce.services;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.wabizone.ecommerce.api.request.UserCreationRequest;
import com.wabizone.ecommerce.models.User;
import com.wabizone.ecommerce.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class UserService {
    private static final Logger logger = LoggerFactory.getLogger(UserService.class);
    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User createUser(UserCreationRequest userCreationRequest) {
        logger.info("Creating new user with name: {}", userCreationRequest.nombre());
        User user = userRepository.save(mapToUser(userCreationRequest));
        logger.info("User created successfully with ID: {}", user.getId());
        return user;
    }

    private User mapToUser(UserCreationRequest createRequest) {
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

    public void removeUser(Long id) {
        logger.info("Removing user with ID: {}", id);
        userRepository.deleteById(id);
        logger.info("User removed successfully");
    }

    public Optional<User> getUser(final long id) {
        return userRepository.findById(id);
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }
    
    public Optional<User> authenticateUser(String nombre, String contrasena) {
        logger.info("Attempting to authenticate user: {}", nombre);
        Optional<User> user = userRepository.findByNombreAndContrasena(nombre, contrasena);
        if (user.isPresent()) {
            logger.info("User {} authenticated successfully", nombre);
        } else {
            logger.warn("Authentication failed for user: {}", nombre);
        }
        return user;
    }
    
    public Optional<User> findUserByNombre(String nombre) {
        return userRepository.findByNombre(nombre);
    }
    
    public User updateUser(Long id, UserCreationRequest userUpdateRequest) {
        logger.info("Updating user with ID: {}", id);
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
            User updatedUser = userRepository.save(user);
            logger.info("User updated successfully");
            return updatedUser;
        } else {
            logger.error("User with ID {} not found", id);
            throw new RuntimeException("Usuario con id " + id + " no encontrado");
        }
    }
}
