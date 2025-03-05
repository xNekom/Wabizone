import '../models/pedido.dart';

abstract class IPedidoRepository {
  Future<List<Pedido>> obtenerTodos();
  Future<List<Pedido>> obtenerPorEstado(String estado);
  Future<Pedido?> obtenerPorId(String id);
  Future<Pedido?> crear(Pedido pedido);
  Future<bool> actualizar(Pedido pedido, String id);
  Future<bool> eliminar(String id);
}

class ApiPedidoRepository implements IPedidoRepository {
  final String endpoint;
  final _dioClient;

  List<Pedido> _pedidosCache = [];

  ApiPedidoRepository(this._dioClient, {this.endpoint = '/pedidos'});

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
        return _pedidosCache;
      }
    } catch (e) {
      return _pedidosCache;
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
      return false;
    }
  }

  @override
  Future<bool> eliminar(String id) async {
    try {
      final response = await _dioClient.delete('$endpoint/$id');
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
