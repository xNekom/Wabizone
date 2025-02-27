import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pedido.dart';

class PedidoService {
  // URL base para la API
  static const String baseUrl = 'http://localhost:8081/api/v1/pedidos';

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
    };
  }

  // Obtener todos los pedidos
  static Future<List<Pedido>> obtenerTodosPedidos() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // Decodificar con UTF-8 para manejar caracteres especiales
        final String decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> pedidosData = json.decode(decodedBody);

        // Imprimir para depuración
        print('Pedidos obtenidos: ${pedidosData.length}');
        if (pedidosData.isNotEmpty) {
          print('Muestra de estado: ${pedidosData[0]['estadoPedido']}');
        }

        _pedidosCache = pedidosData
            .map((pedidoData) => Pedido.fromJson(pedidoData))
            .toList();
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
      final response = await http.get(
        Uri.parse('$baseUrl/estado?estado=$estado'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // Decodificar con UTF-8 para manejar caracteres especiales
        final String decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> pedidosData = json.decode(decodedBody);
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

  // Obtener pedido por ID
  static Future<Pedido?> obtenerPedidoPorId(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // Decodificar con UTF-8 para manejar caracteres especiales
        final String decodedBody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> pedidoData = json.decode(decodedBody);
        return Pedido.fromJson(pedidoData);
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
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
        body: json.encode(_pedidoToJson(pedido)),
      );

      if (response.statusCode == 201) {
        // Decodificar con UTF-8 para manejar caracteres especiales
        final String decodedBody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> pedidoData = json.decode(decodedBody);
        return Pedido.fromJson(pedidoData);
      } else {
        return null;
      }
    } catch (e) {
      print('Error al crear pedido: $e');
      return null;
    }
  }

  // Actualizar pedido existente
  static Future<bool> actualizarPedido(Pedido pedido, String id) async {
    try {
      print('Actualizando pedido a estado: ${pedido.estadoPedido}');

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
        body: json.encode(_pedidoToJson(pedido)),
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
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return response.statusCode == 204;
    } catch (e) {
      print('Error al eliminar pedido: $e');
      return false;
    }
  }
}
