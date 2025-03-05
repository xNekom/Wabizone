import '../models/pedido.dart';

/// Interfaz que define las operaciones para el repositorio de pedidos
abstract class IPedidoRepository {
  /// Obtiene todos los pedidos
  Future<List<Pedido>> obtenerTodos();

  /// Obtiene pedidos por estado
  Future<List<Pedido>> obtenerPorEstado(String estado);

  /// Obtiene un pedido por su ID
  Future<Pedido?> obtenerPorId(String id);

  /// Crea un nuevo pedido
  Future<Pedido?> crear(Pedido pedido);

  /// Actualiza un pedido existente
  Future<bool> actualizar(Pedido pedido, String id);

  /// Elimina un pedido
  Future<bool> eliminar(String id);
}

/// Implementación del repositorio de pedidos que utiliza DIO para acceder a la API
class ApiPedidoRepository implements IPedidoRepository {
  final String endpoint;
  final _dioClient;

  // Caché local para pedidos
  List<Pedido> _pedidosCache = [];

  ApiPedidoRepository(this._dioClient, {this.endpoint = '/pedidos'});

  // Convertir Pedido del frontend a formato JSON para el backend
  Map<String, dynamic> _pedidoToJson(Pedido pedido) {
    return {
      'nPedido': pedido.nPedido,
      'detallesPedido': pedido.detallesPedido,
      'estadoPedido': pedido.estadoPedido,
      'precioTotal': pedido.precioTotal,
      'usuarioId': pedido.usuarioId,
      'nombreUsuario': pedido.nombreUsuario,
      'nombreCompleto': pedido.nombreCompleto,
      'direccion': pedido.direccion,
      'ciudad': pedido.ciudad,
      'codigoPostal': pedido.codigoPostal,
      'telefono': pedido.telefono,
      'email': pedido.email,
      'comentarios': pedido.comentarios,
    };
  }

  @override
  Future<List<Pedido>> obtenerTodos() async {
    try {
      final response = await _dioClient.get(endpoint);

      if (response.statusCode == 200) {
        List<dynamic> pedidosData = response.data;
        _pedidosCache = pedidosData
            .map((pedidoData) => Pedido.fromJson(pedidoData))
            .toList();
        return _pedidosCache;
      } else {
        return _pedidosCache; // Retorna la caché si hay error
      }
    } catch (e) {
      print('Error al obtener pedidos: $e');
      return _pedidosCache; // Retorna la caché si hay excepción
    }
  }

  @override
  Future<List<Pedido>> obtenerPorEstado(String estado) async {
    try {
      final response = await _dioClient.get(
        '$endpoint/estado',
        queryParameters: {'estado': estado},
      );

      if (response.statusCode == 200) {
        List<dynamic> pedidosData = response.data;
        return pedidosData
            .map((pedidoData) => Pedido.fromJson(pedidoData))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error al obtener pedidos por estado: $e');
      return [];
    }
  }

  @override
  Future<Pedido?> obtenerPorId(String id) async {
    try {
      final response = await _dioClient.get('$endpoint/$id');

      if (response.statusCode == 200) {
        Map<String, dynamic> pedidoData = response.data;
        return Pedido.fromJson(pedidoData);
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener pedido por ID: $e');
      return null;
    }
  }

  @override
  Future<Pedido?> crear(Pedido pedido) async {
    try {
      final response = await _dioClient.post(
        endpoint,
        data: _pedidoToJson(pedido),
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> pedidoData = response.data;
        return Pedido.fromJson(pedidoData);
      } else {
        return null;
      }
    } catch (e) {
      print('Error al crear pedido: $e');
      return null;
    }
  }

  @override
  Future<bool> actualizar(Pedido pedido, String id) async {
    try {
      final response = await _dioClient.put(
        '$endpoint/$id',
        data: _pedidoToJson(pedido),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar pedido: $e');
      return false;
    }
  }

  @override
  Future<bool> eliminar(String id) async {
    try {
      final response = await _dioClient.delete('$endpoint/$id');
      return response.statusCode == 204;
    } catch (e) {
      print('Error al eliminar pedido: $e');
      return false;
    }
  }
}
