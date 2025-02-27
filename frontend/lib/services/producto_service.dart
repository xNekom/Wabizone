import '../models/producto.dart';
import 'dio_client.dart';

class ProductoService {
  // URL base para la API (ahora relativa ya que la base está en DioClient)
  static const String endpoint = '/products';

  // Cliente DIO
  static final DioClient _dioClient = DioClient();

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
      // Si ya tenemos productos en caché y no son vacíos, devolverlos
      if (_productosCache.isNotEmpty) {
        return _productosCache;
      }

      // DIO maneja automáticamente la codificación/decodificación UTF-8
      final response = await _dioClient.get(endpoint);

      if (response.statusCode == 200) {
        List<dynamic> productsData = response.data;
        _productosCache = productsData
            .map((productData) => _mapearProducto(productData))
            .toList();

        print('Productos cargados exitosamente: ${_productosCache.length}');
        return _productosCache;
      } else {
        print('Error al obtener productos: Código ${response.statusCode}');
        return _productosCache.isNotEmpty ? _productosCache : [];
      }
    } catch (e) {
      print('Error al obtener productos: $e');
      return _productosCache.isNotEmpty ? _productosCache : [];
    }
  }

  // Obtener producto por ID
  static Future<Producto?> obtenerProductoPorId(String id) async {
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

  // Agregar nuevo producto
  static Future<bool> agregarProducto(Producto producto) async {
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

  // Actualizar producto existente
  static Future<bool> actualizarProducto(Producto producto, int id) async {
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

  // Eliminar producto
  static Future<bool> eliminarProducto(String id) async {
    try {
      final response = await _dioClient.delete('$endpoint/custom/$id');
      return response.statusCode == 204;
    } catch (e) {
      print('Error al eliminar producto: $e');
      return false;
    }
  }
}
