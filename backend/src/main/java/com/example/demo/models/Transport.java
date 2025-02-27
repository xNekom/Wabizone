package main.java.com.example.demo.models;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "transports")
public class Transport {

    @Id
    private String id;
    private String category;         // Ejemplo: "Camión", "Avión", "Barco"
    private String license;    // Número de matrícula o identificador
    private double capacity;    // capacity en toneladas, litros, etc.

    public Transport() {}

    public Transport(String category, String license, double capacity) {
        this.category = category;
        this.license = license;
        this.capacity = capacity;
    }

    // Getters y Setters
    public String getId() { return id; }
    public String getcategory() { return category; }
    public void setcategory(String category) { this.category = category; }
    public String getlicense() { return license; }
    public void setlicense(String license) { this.license = license; }
    public double getcapacity() { return capacity; }
    public void setcapacity(double capacity) { this.capacity = capacity; }
}