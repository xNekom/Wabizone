import '../models/pedido.dart';
import '../models/usuario.dart';
import 'dio_client.dart';
import 'usuario_service.dart';

class PedidoService {
  // URL base para la API (ahora relativa ya que la base está en DioClient)
  static const String endpoint = '/pedidos';

  // Cliente DIO
  static final DioClient _dioClient = DioClient();

  // Caché local para pedidos
  static List<Pedido> _pedidosCache = [];

  // Getter para acceder a la caché de pedidos
  static List<Pedido> get pedidos => _pedidosCache;

  // Convertir Pedido del frontend a formato JSON para el backend
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

  // Obtener el nombre del usuario para un pedido
  static Future<String?> _obtenerNombreUsuario(String? usuarioId) async {
    if (usuarioId == null) return null;
    try {
      // Intentar obtener el usuario por ID
      final usuario = await UsuarioService.buscarUsuarioPorId(usuarioId);
      return usuario?.usuario;
    } catch (e) {
      print('Error al obtener nombre de usuario: $e');
      return null;
    }
  }

  // Obtener todos los pedidos
  static Future<List<Pedido>> obtenerTodosPedidos() async {
    try {
      final response = await _dioClient.get(endpoint);

      if (response.statusCode == 200) {
        List<dynamic> pedidosData = response.data;

        // Imprimir para depuración
        print('Pedidos obtenidos: ${pedidosData.length}');

        // Lista para almacenar los pedidos mientras se procesan
        List<Pedido> pedidosProcesados = [];

        // Procesar cada pedido y obtener el nombre del usuario
        for (var pedidoData in pedidosData) {
          Pedido pedido = Pedido.fromJson(pedidoData);

          // Si el pedido tiene un ID de usuario pero no tiene nombre, intentar obtenerlo
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
      print('Error al obtener pedidos: $e');
      return _pedidosCache;
    }
  }

  // Obtener pedidos por estado
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
      print('Error al obtener pedidos por estado: $e');
      return [];
    }
  }

  // Obtener pedido por ID
  static Future<Pedido?> obtenerPedidoPorId(String id) async {
    try {
      final response = await _dioClient.get('$endpoint/$id');

      if (response.statusCode == 200) {
        Map<String, dynamic> pedidoData = response.data;
        Pedido pedido = Pedido.fromJson(pedidoData);

        // Obtener el nombre del usuario si es necesario
        if (pedido.usuarioId != null && pedido.nombreUsuario == null) {
          pedido.nombreUsuario = await _obtenerNombreUsuario(pedido.usuarioId);
        }

        return pedido;
      } else {
        return null;
      }
    } catch (e) {
      print('Error al obtener pedido por ID: $e');
      return null;
    }
  }

  // Crear nuevo pedido
  static Future<Pedido?> crearPedido(Pedido pedido) async {
    try {
      print('Intentando crear pedido con datos:');
      print('Usuario ID: ${pedido.usuarioId}');
      print('Nombre Usuario: ${pedido.nombreUsuario}');
      print('Nombre Completo: ${pedido.nombreCompleto}');
      print('Dirección: ${pedido.direccion}');

      final jsonData = _pedidoToJson(pedido);
      print('Datos JSON a enviar: $jsonData');

      final response = await _dioClient.post(
        endpoint,
        data: jsonData,
      );

      print('Respuesta del servidor: ${response.statusCode}');
      print('Datos de respuesta: ${response.data}');

      if (response.statusCode == 201) {
        Map<String, dynamic> pedidoData = response.data;
        return Pedido.fromJson(pedidoData);
      } else {
        print('Error: Código de estado inesperado ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error detallado al crear pedido: $e');
      if (e is Exception) {
        print('Stack trace: ${e.toString()}');
      }
      return null;
    }
  }

  // Actualizar pedido existente
  static Future<bool> actualizarPedido(Pedido pedido, String id) async {
    try {
      print('Actualizando pedido a estado: ${pedido.estadoPedido}');

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

  // Eliminar pedido
  static Future<bool> eliminarPedido(String id) async {
    try {
      final response = await _dioClient.delete('$endpoint/$id');
      return response.statusCode == 204;
    } catch (e) {
      print('Error al eliminar pedido: $e');
      return false;
    }
  }
}
