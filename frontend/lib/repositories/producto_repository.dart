import '../models/producto.dart';
import '../services/producto_service.dart';

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
    print(
        'Repository: Convirtiendo producto a JSON. ID: ${producto.id}, Nombre: ${producto.nombre}');

    final Map<String, dynamic> data = {
      'customId': producto.id,
      'nombre': producto.nombre,
      'descripcion': producto.descripcion,
      'stock': producto.stock,
      'precio': producto.precio,
    };

    // Manejamos la imagen de manera especial
    if (producto.imagen.isNotEmpty) {
      String imagenValue = producto.imagen;

      // Verificamos si es una ruta base64 (empieza con data:)
      if (imagenValue.startsWith('data:')) {
        print('Repository: Imagen en formato base64 detectada');
        // Verificamos si la imagen base64 es demasiado grande
        if (imagenValue.length > 20 * 1024 * 1024) {
          // 20MB como límite de seguridad
          print('Repository: ¡Advertencia! Imagen base64 demasiado grande');
          // Usamos una imagen por defecto en este caso
          data['imagen'] = 'assets/imagenes/producto_default.png';
        } else {
          // Enviamos la imagen en base64 directamente para almacenarla en la base de datos
          data['imagen'] = imagenValue;
          print(
              'Repository: Enviando imagen en formato base64 a la base de datos. Longitud: ${imagenValue.length} caracteres');
        }
      } else {
        // Si no es base64, asumimos que es una referencia válida y la enviamos tal cual
        data['imagen'] = imagenValue;
        print('Repository: Usando valor de imagen existente: $imagenValue');
      }
    } else {
      // Si no hay imagen, enviamos un valor por defecto
      data['imagen'] = 'assets/imagenes/producto_default.png';
      print('Repository: No hay imagen, usando imagen por defecto');
    }

    return data;
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
      print('ProductoRepository: creando producto ${producto.id}');
      final response = await _dioClient.post(
        endpoint,
        data: _productoToJson(producto),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('ProductoRepository: Error al crear producto: $e');
      // Propagar la excepción para que pueda ser manejada en el provider
      rethrow;
    }
  }

  @override
  Future<bool> actualizar(Producto producto, int id) async {
    try {
      print(
          'ProductoRepository: actualizando producto con ID=$id, customId=${producto.id}');
      if (id <= 0) {
        print(
            'ProductoRepository: ID inválido ($id), se intentará usar el endpoint de customId');
        // Si el ID es inválido (0 o negativo), usamos directamente el endpoint de customId
        final result =
            await ProductoService.actualizarProductoPorCustomId(producto);
        return result;
      } else {
        final result = await ProductoService.actualizarProducto(producto, id);
        return result;
      }
    } catch (e) {
      print('ProductoRepository: Error al actualizar producto: $e');
      rethrow;
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
