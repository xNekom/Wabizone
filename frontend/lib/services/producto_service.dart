import '../models/producto.dart';
import 'dio_client.dart';
import 'dart:math' as math;
import 'dart:convert';

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
    // Obtener el ID del producto
    String id = json['customId'] ?? '';

    // Obtener la imagen del backend
    String imagen = json['imagen'] ?? '';

    print('ProductoService: Mapeando producto con ID: $id');
    print('ProductoService: Imagen original del backend: $imagen');

    // IMPORTANTE: Para el Producto 4, verificamos si la imagen del backend está vacía
    // Solo en ese caso usamos la imagen por defecto
    if ((id == 'p4' ||
            id == '4' ||
            (id.startsWith('p') && id.substring(1) == '4')) &&
        (imagen.isEmpty || imagen == 'assets/imagenes/producto_default.png')) {
      print(
          'ProductoService: Producto 4 sin imagen en backend, usando imagen por defecto');
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

  // Convertir Producto del frontend a formato JSON para el backend
  static Map<String, dynamic> _productoToJson(Producto producto) {
    print(
        'Convirtiendo producto a JSON. ID: ${producto.id}, Nombre: ${producto.nombre}');

    final Map<String, dynamic> data = {
      'nombre': producto.nombre,
      'descripcion': producto.descripcion,
      'precio': producto.precio,
      'stock': producto.stock,
      'customId': producto.id,
    };

    // Manejamos la imagen de manera especial
    if (producto.imagen != null && producto.imagen.isNotEmpty) {
      String imagenValue = producto.imagen;
      print(
          'Tipo de imagen: ${imagenValue.startsWith('data:') ? 'base64' : 'ruta'}');

      // Imprimir los primeros caracteres para depuración
      if (imagenValue.length > 50) {
        print(
            'Primeros 50 caracteres de la imagen: ${imagenValue.substring(0, 50)}...');
        print(
            'Últimos 50 caracteres de la imagen: ${imagenValue.substring(imagenValue.length - 50)}');
      } else {
        print('Imagen completa: $imagenValue');
      }

      // Verificamos si es una ruta base64 (empieza con data:)
      if (imagenValue.startsWith('data:')) {
        print('Imagen en formato base64 detectada');

        // Verificar que la cadena base64 sea válida
        try {
          final comma = imagenValue.indexOf(',');
          if (comma != -1) {
            final data64 = imagenValue.substring(comma + 1);
            if (data64.isEmpty) {
              print('¡Error! Datos base64 vacíos');
              data['imagen'] = 'assets/imagenes/producto_default.png';
              return data;
            }

            // Intentar decodificar para verificar que es válido
            try {
              final bytes = base64Decode(data64);
              print('Base64 válido. Tamaño: ${bytes.length} bytes');
            } catch (e) {
              print('¡Error! Base64 inválido: $e');
              data['imagen'] = 'assets/imagenes/producto_default.png';
              return data;
            }
          } else {
            print('¡Error! No se encontró la coma en la URL de datos');
            data['imagen'] = 'assets/imagenes/producto_default.png';
            return data;
          }
        } catch (e) {
          print('¡Error al procesar base64! $e');
          data['imagen'] = 'assets/imagenes/producto_default.png';
          return data;
        }

        // Verificamos si la imagen base64 es demasiado grande
        if (imagenValue.length > 20 * 1024 * 1024) {
          // 20MB como límite de seguridad
          print(
              '¡Advertencia! Imagen base64 demasiado grande (${(imagenValue.length / (1024 * 1024)).toStringAsFixed(2)} MB)');
          // Usamos una imagen por defecto en este caso
          data['imagen'] = 'assets/imagenes/producto_default.png';
        } else {
          // Enviamos la imagen en base64 directamente para almacenarla en la base de datos
          data['imagen'] = imagenValue;
          print(
              'Enviando imagen en formato base64 a la base de datos. Longitud: ${imagenValue.length} caracteres');
        }
      } else {
        // Si no es base64, asumimos que es una referencia válida y la enviamos tal cual
        data['imagen'] = imagenValue;
        print('Usando valor de imagen existente: $imagenValue');
      }
    } else {
      // Si no hay imagen, enviamos un valor por defecto
      data['imagen'] = 'assets/imagenes/producto_default.png';
      print('No hay imagen, usando imagen por defecto');
    }

    return data;
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
      print(
          'Actualizando producto con ID numérico: $id, customId: ${producto.id}');
      print(
          'Imagen del producto a actualizar: ${producto.imagen.substring(0, math.min(50, producto.imagen.length))}...');

      // Si el ID comienza con 'p', es un customId y debemos usar directamente ese método
      if (producto.id.startsWith('p')) {
        print(
            'Detectado customId con formato "p". Usando actualización directa por customId.');
        return await actualizarProductoPorCustomId(producto);
      }

      // Primero intentamos actualizar usando el ID numérico
      try {
        final response = await _dioClient.put(
          '$endpoint/$id',
          data: _productoToJson(producto),
        );

        // Si la actualización fue exitosa, actualizar la caché local
        if (response.statusCode == 200) {
          // Actualizar producto en caché si existe
          final index = _productosCache.indexWhere((p) => p.id == producto.id);
          if (index != -1) {
            _productosCache[index] = producto;
            print('Producto actualizado en caché local. Índice: $index');
          } else {
            print(
                'Producto no encontrado en caché local. Actualizando lista completa...');
            // Si no está en caché, refrescar toda la lista
            await obtenerTodosProductos();
          }
          print('Producto actualizado exitosamente usando ID numérico: $id');
          return true;
        }
        return false;
      } catch (e) {
        // Si el error es que no se encontró el producto con ID numérico, intentamos con customId
        if (e.toString().contains('producto_no_encontrado') ||
            e.toString().contains('resource_not_found') ||
            e.toString().contains('404')) {
          print(
              'ID numérico $id no encontrado. Intentando actualizar usando customId: ${producto.id}');

          // Intentar actualizar usando el customId directamente
          return await actualizarProductoPorCustomId(producto);
        } else {
          // Para otros errores, intentamos también con customId como último recurso
          print(
              'Error desconocido al actualizar por ID numérico: $e. Intentando por customId como último recurso.');
          return await actualizarProductoPorCustomId(producto);
        }
      }
    } catch (e) {
      print('Error al actualizar producto: $e');
      return false; // Cambiamos para devolver false en lugar de propagar el error
    }
  }

  // Actualizar producto directamente por customId
  static Future<bool> actualizarProductoPorCustomId(Producto producto) async {
    try {
      print('Actualizando producto directamente por customId: ${producto.id}');

      // Verificar si la imagen es base64
      if (producto.imagen.startsWith('data:')) {
        print(
            'Imagen en formato base64 detectada para actualización por customId');
        print('Longitud de la imagen: ${producto.imagen.length} caracteres');
      } else {
        print('Usando imagen existente: ${producto.imagen}');
      }

      final response = await _dioClient.put(
        '$endpoint/custom/${producto.id}',
        data: _productoToJson(producto),
      );

      // Si la actualización fue exitosa, actualizar la caché local
      if (response.statusCode == 200) {
        // Actualizar producto en caché si existe
        final index = _productosCache.indexWhere((p) => p.id == producto.id);
        if (index != -1) {
          _productosCache[index] = producto;
          print('Producto actualizado en caché local. Índice: $index');
        } else {
          print(
              'Producto no encontrado en caché local. Actualizando lista completa...');
          // Si no está en caché, refrescar toda la lista
          await obtenerTodosProductos();
        }
        print(
            'Producto actualizado exitosamente usando customId: ${producto.id}');
        return true;
      }
      return false;
    } catch (e) {
      print('Error al actualizar producto por customId: $e');
      // No propagamos el error, simplemente devolvemos false
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
