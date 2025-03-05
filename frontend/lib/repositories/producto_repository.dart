import '../models/producto.dart';
import '../services/producto_service.dart';

abstract class IProductoRepository {
  Future<List<Producto>> obtenerTodos();
  Future<Producto?> obtenerPorId(String id);
  Future<bool> crear(Producto producto);
  Future<bool> actualizar(Producto producto, int id);
  Future<bool> eliminar(String id);
}

class ApiProductoRepository implements IProductoRepository {
  final String endpoint;
  final _dioClient;

  List<Producto> _productosCache = [];

  ApiProductoRepository(this._dioClient, {this.endpoint = '/products'});

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

  Map<String, dynamic> _productoToJson(Producto producto) {
    final Map<String, dynamic> data = {
      'customId': producto.id,
      'nombre': producto.nombre,
      'descripcion': producto.descripcion,
      'stock': producto.stock,
      'precio': producto.precio,
    };

    if (producto.imagen.isNotEmpty) {
      String imagenValue = producto.imagen;

      if (imagenValue.startsWith('data:')) {
        if (imagenValue.length > 20 * 1024 * 1024) {
          data['imagen'] = 'assets/imagenes/producto_default.png';
        } else {
          data['imagen'] = imagenValue;
        }
      } else {
        data['imagen'] = imagenValue;
      }
    } else {
      data['imagen'] = 'assets/imagenes/producto_default.png';
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
        return _productosCache;
      }
    } catch (e) {
      return _productosCache;
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
      rethrow;
    }
  }

  @override
  Future<bool> actualizar(Producto producto, int id) async {
    try {
      if (id <= 0) {
        final result =
            await ProductoService.actualizarProductoPorCustomId(producto);
        return result;
      } else {
        final result = await ProductoService.actualizarProducto(producto, id);
        return result;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> eliminar(String id) async {
    try {
      final response = await _dioClient.delete('$endpoint/custom/$id');
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
