package com.example.demo.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.example.demo.models.Product;
import com.example.demo.models.User;
import com.example.demo.repository.ProductRepository;
import com.example.demo.repository.UserRepository;

@Configuration
public class DataLoader {
    
    @Bean
    public CommandLineRunner initData(ProductRepository productRepository, UserRepository userRepository) {
        return args -> {
            // Verificar si ya hay datos en la base de datos
            if (productRepository.count() == 0) {
                // Crear productos de ejemplo
                Product product1 = new Product();
                product1.setCustomId("p1");
                product1.setNombre("Producto 1");
                product1.setDescripcion("Descripción del producto 1");
                product1.setStock(10);
                product1.setPrecio(100.0);
                product1.setImagen("prod1.png");
                productRepository.save(product1);
                
                Product product2 = new Product();
                product2.setCustomId("p2");
                product2.setNombre("Producto 2");
                product2.setDescripcion("Descripción del producto 2");
                product2.setStock(5);
                product2.setPrecio(150.0);
                product2.setImagen("prod2.png");
                productRepository.save(product2);
                
                Product product3 = new Product();
                product3.setCustomId("p3");
                product3.setNombre("Producto 3");
                product3.setDescripcion("Descripción del producto 3");
                product3.setStock(8);
                product3.setPrecio(200.0);
                product3.setImagen("prod3.png");
                productRepository.save(product3);
            }
            
            if (userRepository.count() == 0) {
                // Crear usuarios de ejemplo
                User user1 = new User();
                user1.setNombre("Pedro");
                user1.setContrasena("Pedro");
                user1.setEdad(31);
                user1.setAdministrador(false);
                user1.setTrato("Sr.");
                user1.setImagen("");
                user1.setLugarNacimiento("Albacete");
                user1.setBloqueado(false);
                userRepository.save(user1);
                
                User user2 = new User();
                user2.setNombre("admin");
                user2.setContrasena("admin");
                user2.setEdad(30);
                user2.setAdministrador(true);
                user2.setTrato("Sr.");
                user2.setImagen("");
                user2.setLugarNacimiento("AdminCity");
                user2.setBloqueado(false);
                userRepository.save(user2);
            }
        };
    }
} 