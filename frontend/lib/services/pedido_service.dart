import '../models/pedido.dart';
import 'dio_client.dart';
import 'usuario_service.dart';

class PedidoService {
  static const String endpoint = '/pedidos';
  static final DioClient _dioClient = DioClient();
  static List<Pedido> _pedidosCache = [];

  static List<Pedido> get pedidos => _pedidosCache;

  static Map<String, dynamic> _pedidoToJson(Pedido pedido) {
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

  static Future<String?> _obtenerNombreUsuario(String? usuarioId) async {
    if (usuarioId == null) return null;
    try {
      final usuario = await UsuarioService.buscarUsuarioPorId(usuarioId);
      return usuario?.usuario;
    } catch (e) {
      return null;
    }
  }

  static Future<List<Pedido>> obtenerTodosPedidos() async {
    try {
      final response = await _dioClient.get(endpoint);

      if (response.statusCode == 200) {
        List<dynamic> pedidosData = response.data;
        List<Pedido> pedidosProcesados = [];

        for (var pedidoData in pedidosData) {
          Pedido pedido = Pedido.fromJson(pedidoData);

          if (pedido.usuarioId != null && pedido.nombreUsuario == null) {
            pedido.nombreUsuario =
                await _obtenerNombreUsuario(pedido.usuarioId);
          }

          pedidosProcesados.add(pedido);
        }

        _pedidosCache = pedidosProcesados;
        return _pedidosCache;
      } else {
        return _pedidosCache;
      }
    } catch (e) {
      return _pedidosCache;
    }
  }

  static Future<List<Pedido>> obtenerPedidosPorEstado(String estado) async {
    try {
      final response = await _dioClient.get(
        '$endpoint/estado',
        queryParameters: {'estado': estado},
      );

      if (response.statusCode == 200) {
        List<dynamic> pedidosData = response.data;
        List<Pedido> pedidosProcesados = [];

        for (var pedidoData in pedidosData) {
          Pedido pedido = Pedido.fromJson(pedidoData);
          if (pedido.usuarioId != null && pedido.nombreUsuario == null) {
            pedido.nombreUsuario =
                await _obtenerNombreUsuario(pedido.usuarioId);
          }
          pedidosProcesados.add(pedido);
        }

        return pedidosProcesados;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<Pedido?> obtenerPedidoPorId(String id) async {
    try {
      final response = await _dioClient.get('$endpoint/$id');

      if (response.statusCode == 200) {
        Map<String, dynamic> pedidoData = response.data;
        Pedido pedido = Pedido.fromJson(pedidoData);

        if (pedido.usuarioId != null && pedido.nombreUsuario == null) {
          pedido.nombreUsuario = await _obtenerNombreUsuario(pedido.usuarioId);
        }

        return pedido;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Pedido?> crearPedido(Pedido pedido) async {
    try {
      final jsonData = _pedidoToJson(pedido);
      final response = await _dioClient.post(
        endpoint,
        data: jsonData,
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

  static Future<bool> actualizarPedido(Pedido pedido, String id) async {
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

  static Future<bool> eliminarPedido(String id) async {
    try {
      final response = await _dioClient.delete('$endpoint/$id');
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
