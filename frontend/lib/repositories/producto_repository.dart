import '../models/producto.dart';

/// Interfaz que define las operaciones para el repositorio de productos
abstract class IProductoRepository {
  /// Obtiene todos los productos
  Future<List<Producto>> obtenerTodos();

  /// Obtiene un producto por su ID
  Future<Producto?> obtenerPorId(String id);

  /// Crea un nuevo producto
  Future<bool> crear(Producto producto);

  /// Actualiza un producto existente
  Future<bool> actualizar(Producto producto, int id);

  /// Elimina un producto
  Future<bool> eliminar(String id);
}

/// Implementación del repositorio de productos que utiliza DIO para acceder a la API
class ApiProductoRepository implements IProductoRepository {
  final String endpoint;
  final _dioClient;

  // Caché local para productos
  List<Producto> _productosCache = [];

  ApiProductoRepository(this._dioClient, {this.endpoint = '/products'});

  // Convertir Product del backend a Producto del frontend
  Producto _mapearProducto(Map<String, dynamic> json) {
    String descripcion = json['descripcion'] ?? '';

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
  Map<String, dynamic> _productoToJson(Producto producto) {
    return {
      'customId': producto.id,
      'nombre': producto.nombre,
      'descripcion': producto.descripcion,
      'stock': producto.stock,
      'precio': producto.precio,
      'imagen': producto.imagen,
    };
  }

  @override
  Future<List<Producto>> obtenerTodos() async {
    try {
      final response = await _dioClient.get(endpoint);

      if (response.statusCode == 200) {
        List<dynamic> productsData = response.data;
        _productosCache = productsData
            .map((productData) => _mapearProducto(productData))
            .toList();
        return _productosCache;
      } else {
        return _productosCache; // Retorna la caché si hay error
      }
    } catch (e) {
      print('Error al obtener productos: $e');
      return _productosCache; // Retorna la caché si hay excepción
    }
  }

  @override
  Future<Producto?> obtenerPorId(String id) async {
    try {
      final response = await _dioClient.get('$endpoint/custom/$id');

      if (response.statusCode == 200) {
        Map<String, dynamic> productData = response.data;
        return _mapearProducto(productData);
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener producto por ID: $e');
      return null;
    }
  }

  @override
  Future<bool> crear(Producto producto) async {
    try {
      final response = await _dioClient.post(
        endpoint,
        data: _productoToJson(producto),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error al agregar producto: $e');
      return false;
    }
  }

  @override
  Future<bool> actualizar(Producto producto, int id) async {
    try {
      final response = await _dioClient.put(
        '$endpoint/$id',
        data: _productoToJson(producto),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar producto: $e');
      return false;
    }
  }

  @override
  Future<bool> eliminar(String id) async {
    try {
      final response = await _dioClient.delete('$endpoint/custom/$id');
      return response.statusCode == 204;
    } catch (e) {
      print('Error al eliminar producto: $e');
      return false;
    }
  }
}
