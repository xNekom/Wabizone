import '../models/producto.dart';
import 'dio_client.dart';
import 'dart:convert';

class ProductoService {
  static const String endpoint = '/products';
  static final DioClient _dioClient = DioClient();
  static List<Producto> _productosCache = [];
  static List<Producto> get productos => _productosCache;

  static Producto _mapearProducto(Map<String, dynamic> json) {
    String id = json['customId'] ?? '';
    String imagen = json['imagen'] ?? '';

    if ((id == 'p4' ||
            id == '4' ||
            (id.startsWith('p') && id.substring(1) == '4')) &&
        (imagen.isEmpty || imagen == 'assets/imagenes/producto_default.png')) {
      imagen = 'assets/imagenes/prod4.png';
    }

    return Producto(
      id: id,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      imagen: imagen,
      stock: json['stock'] ?? 0,
      precio: json['precio'] ?? 0.0,
    );
  }

  static Map<String, dynamic> _productoToJson(Producto producto) {
    final Map<String, dynamic> data = {
      'nombre': producto.nombre,
      'descripcion': producto.descripcion,
      'precio': producto.precio,
      'stock': producto.stock,
      'customId': producto.id,
    };

    if (producto.imagen.isNotEmpty) {
      String imagenValue = producto.imagen;

      if (imagenValue.startsWith('data:')) {
        try {
          final comma = imagenValue.indexOf(',');
          if (comma != -1) {
            final data64 = imagenValue.substring(comma + 1);
            if (data64.isEmpty) {
              data['imagen'] = 'assets/imagenes/producto_default.png';
              return data;
            }

            try {
              base64Decode(data64);
            } catch (e) {
              data['imagen'] = 'assets/imagenes/producto_default.png';
              return data;
            }
          } else {
            data['imagen'] = 'assets/imagenes/producto_default.png';
            return data;
          }
        } catch (e) {
          data['imagen'] = 'assets/imagenes/producto_default.png';
          return data;
        }

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

  static Future<List<Producto>> obtenerTodosProductos() async {
    try {
      if (_productosCache.isNotEmpty) {
        return _productosCache;
      }

      final response = await _dioClient.get(endpoint);

      if (response.statusCode == 200) {
        List<dynamic> productsData = response.data;
        _productosCache = productsData
            .map((productData) => _mapearProducto(productData))
            .toList();
        return _productosCache;
      } else {
        return _productosCache.isNotEmpty ? _productosCache : [];
      }
    } catch (e) {
      return _productosCache.isNotEmpty ? _productosCache : [];
    }
  }

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
      return null;
    }
  }

  static Future<bool> agregarProducto(Producto producto) async {
    try {
      final response = await _dioClient.post(
        endpoint,
        data: _productoToJson(producto),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> actualizarProducto(Producto producto, int id) async {
    try {
      if (producto.id.startsWith('p')) {
        return await actualizarProductoPorCustomId(producto);
      }

      try {
        final response = await _dioClient.put(
          '$endpoint/$id',
          data: _productoToJson(producto),
        );

        if (response.statusCode == 200) {
          final index = _productosCache.indexWhere((p) => p.id == producto.id);
          if (index != -1) {
            _productosCache[index] = producto;
          } else {
            await obtenerTodosProductos();
          }
          return true;
        }
        return false;
      } catch (e) {
        if (e.toString().contains('producto_no_encontrado') ||
            e.toString().contains('resource_not_found') ||
            e.toString().contains('404')) {
          return await actualizarProductoPorCustomId(producto);
        } else {
          return await actualizarProductoPorCustomId(producto);
        }
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> actualizarProductoPorCustomId(Producto producto) async {
    try {
      final response = await _dioClient.put(
        '$endpoint/custom/${producto.id}',
        data: _productoToJson(producto),
      );

      if (response.statusCode == 200) {
        final index = _productosCache.indexWhere((p) => p.id == producto.id);
        if (index != -1) {
          _productosCache[index] = producto;
        } else {
          await obtenerTodosProductos();
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> eliminarProducto(String id) async {
    try {
      final response = await _dioClient.delete('$endpoint/custom/$id');
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
