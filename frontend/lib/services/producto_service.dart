import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';

class ProductoService {
  // URL base para la API
  static const String baseUrl = 'http://localhost:8081/api/v1/products';

  // Caché local para productos
  static List<Producto> _productosCache = [];

  // Getter para acceder a la caché de productos
  static List<Producto> get productos => _productosCache;

  // Convertir Product del backend a Producto del frontend
  static Producto _mapearProducto(Map<String, dynamic> json) {
    // Decodificar la descripción correctamente para manejar tildes
    String descripcion = json['descripcion'] ?? '';

    // Imprimir para depuración
    print('Descripción original: $descripcion');

    return Producto(
      id: json['customId'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: descripcion,
      imagen: json['imagen'] ?? '',
      stock: json['stock'] ?? 0,
      precio: json['precio'] ?? 0.0,
    );
  }

  // Convertir Producto del frontend a formato JSON para el backend
  static Map<String, dynamic> _productoToJson(Producto producto) {
    return {
      'customId': producto.id,
      'nombre': producto.nombre,
      'descripcion': producto.descripcion,
      'stock': producto.stock,
      'precio': producto.precio,
      'imagen': producto.imagen,
    };
  }

  // Obtener todos los productos
  static Future<List<Producto>> obtenerTodosProductos() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // Decodificar con UTF-8 para manejar caracteres especiales
        final String decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> productsData = json.decode(decodedBody);
        _productosCache = productsData
            .map((productData) => _mapearProducto(productData))
            .toList();
        return _productosCache;
      } else {
        return _productosCache;
      }
    } catch (e) {
      print('Error al obtener productos: $e');
      return _productosCache;
    }
  }

  // Obtener producto por ID
  static Future<Producto?> obtenerProductoPorId(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/custom/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // Decodificar con UTF-8 para manejar caracteres especiales
        final String decodedBody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> productData = json.decode(decodedBody);
        return _mapearProducto(productData);
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener producto por ID: $e');
      return null;
    }
  }

  // Agregar nuevo producto
  static Future<bool> agregarProducto(Producto producto) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_productoToJson(producto)),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error al agregar producto: $e');
      return false;
    }
  }

  // Actualizar producto existente
  static Future<bool> actualizarProducto(Producto producto, int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_productoToJson(producto)),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar producto: $e');
      return false;
    }
  }

  // Eliminar producto
  static Future<bool> eliminarProducto(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/custom/$id'));
      return response.statusCode == 204;
    } catch (e) {
      print('Error al eliminar producto: $e');
      return false;
    }
  }
}
