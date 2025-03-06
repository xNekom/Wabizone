package com.wabizone.ecommerce.api;

import java.util.List;
import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.wabizone.ecommerce.api.request.ProductCreationRequest;
import com.wabizone.ecommerce.models.Product;
import com.wabizone.ecommerce.services.ProductService;

@RestController
@RequestMapping("/api/v1/products")
@CrossOrigin(origins = "*")
public class ProductController {

    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @PostMapping
    public ResponseEntity<Product> createProduct(@RequestBody ProductCreationRequest productCreationRequest){
        return ResponseEntity.status(HttpStatus.CREATED).body(productService.createProduct(productCreationRequest));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id){
        productService.removeProduct(id);
        return ResponseEntity.noContent().build();
    }
    
    @DeleteMapping("/custom/{customId}")
    public ResponseEntity<Void> deleteProductByCustomId(@PathVariable String customId){
        try {
            productService.removeProductByCustomId(customId);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getProduct(@PathVariable Long id){
        Optional<Product> product = productService.getProduct(id);
        return product.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }
    
    @GetMapping("/custom/{customId}")
    public ResponseEntity<Product> getProductByCustomId(@PathVariable String customId){
        Optional<Product> product = productService.findProductByCustomId(customId);
        return product.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping
    public ResponseEntity<List<Product>> getAllProducts(){
        return ResponseEntity.ok(productService.getAllProducts());
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(@PathVariable Long id, @RequestBody ProductCreationRequest productUpdateRequest) {
        try {
            Product updatedProduct = productService.updateProduct(id, productUpdateRequest);
            return ResponseEntity.ok(updatedProduct);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @PutMapping("/custom/{customId}")
    public ResponseEntity<Product> updateProductByCustomId(@PathVariable String customId, @RequestBody ProductCreationRequest productUpdateRequest) {
        try {
            Optional<Product> existingProduct = productService.findProductByCustomId(customId);
            
            if (existingProduct.isPresent()) {
                Product updatedProduct = productService.updateProduct(existingProduct.get().getId(), productUpdateRequest);
                return ResponseEntity.ok(updatedProduct);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
