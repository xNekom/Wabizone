package main.java.com.example.demo.repository;
import org.springframework.data.mongodb.repository.MongoRepository;
import com.itacadam.myapp.models.Transport;

import java.util.List;



public interface TransportRepository extends MongoRepository<Transport, String> {
    List<Transport> findByCategory(String category);        // Buscar por tipo de transporte
    Transport findByLicense(String license);    // Buscar por matrícula
}