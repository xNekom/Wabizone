package com.wabizone.ecommerce.services;


import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.wabizone.ecommerce.api.request.ProductCreationRequest;
import com.wabizone.ecommerce.models.Product;
import com.wabizone.ecommerce.repository.ProductRepository;


//Plantear aqui toda la logica de negocio ademas del crud llamar a todos los metodos que haran cosas adicionales cuando se haga algo del CRUD, o no
@Service
public class ProductService {

    private final ProductRepository productRepository;

    public ProductService (ProductRepository productRepository){
        this.productRepository = productRepository;
    }

    public Product createProduct (ProductCreationRequest productCreationRequest){
        return productRepository.save(mapToProduct(productCreationRequest));
    }

    private Product mapToProduct (ProductCreationRequest createRequest){
        Product product = new Product();
        String customId = createRequest.customId();
        if (customId == null || customId.isEmpty()) {
            customId = "p" + UUID.randomUUID().toString().substring(0, 8);
        }
        product.setCustomId(customId);
        product.setNombre(createRequest.nombre());
        product.setDescripcion(createRequest.descripcion());
        product.setStock(createRequest.stock());
        product.setPrecio(createRequest.precio());
        product.setImagen(createRequest.imagen());
        return product;
    }

    public void removeProduct (Long id){
        productRepository.deleteById(id);
    }

    public Optional<Product> getProduct (final long id){
        return productRepository.findById(id);
    }

    public List<Product> getAllProducts(){
        return productRepository.findAll();
    }
    
    public Optional<Product> findProductByCustomId(String customId) {
        List<Product> products = productRepository.findAll();
        return products.stream()
                .filter(product -> product.getCustomId().equals(customId))
                .findFirst();
    }
    
    public Product updateProduct(Long id, ProductCreationRequest productUpdateRequest) {
        Optional<Product> existingProduct = productRepository.findById(id);
        if (existingProduct.isPresent()) {
            Product product = existingProduct.get();
            product.setNombre(productUpdateRequest.nombre());
            product.setDescripcion(productUpdateRequest.descripcion());
            product.setStock(productUpdateRequest.stock());
            product.setPrecio(productUpdateRequest.precio());
            product.setImagen(productUpdateRequest.imagen());
            return productRepository.save(product);
        } else {
            throw new RuntimeException("Producto con id " + id + " no encontrado");
        }
    }
    
    public void removeProductByCustomId(String customId) {
        Optional<Product> product = findProductByCustomId(customId);
        if (product.isPresent()) {
            productRepository.delete(product.get());
        } else {
            throw new RuntimeException("Producto con customId " + customId + " no encontrado");
        }
    }
}
