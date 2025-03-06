import '../models/cart_item.dart';
import '../models/shopping_cart.dart';
import 'dio_client.dart';
import 'package:dio/dio.dart';

class CarritoService {
  final DioClient _dioClient = DioClient();

  Future<ShoppingCart> getCartBySessionId(String sessionId) async {
    try {
      final response = await _dioClient.get('/cart/session/$sessionId');
      return ShoppingCart.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw Exception('Carrito no encontrado');
        }
      }
      throw Exception('Error obteniendo carrito: $e');
    }
  }

  Future<ShoppingCart> getCartByUserId(int userId) async {
    try {
      final response = await _dioClient.get('/cart/user/$userId');
      return ShoppingCart.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          try {
            final newCart = await createNewCart(userId, null);
            return newCart;
          } catch (createError) {
            return ShoppingCart.empty();
          }
        }
      }
      throw Exception('Error obteniendo carrito: $e');
    }
  }

  Future<ShoppingCart> addItemToCart(String cartId, CartItem item) async {
    try {
      final response = await _dioClient.post(
        '/cart/$cartId/items',
        data: item.toJson(),
      );
      return ShoppingCart.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
            'Error code: ${e.response?.statusCode}. Error añadiendo ítem al carrito');
      }
      throw Exception('Error añadiendo ítem al carrito: $e');
    }
  }

  Future<ShoppingCart> updateItemQuantity(
      String cartId, int productoId, int cantidad) async {
    try {
      final response = await _dioClient.put(
        '/cart/$cartId/items/$productoId',
        queryParameters: {'cantidad': cantidad},
      );
      return ShoppingCart.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
            'Error code: ${e.response?.statusCode}. Error actualizando cantidad');
      }
      throw Exception('Error actualizando cantidad: $e');
    }
  }

  Future<ShoppingCart> removeItemFromCart(String cartId, int productoId) async {
    try {
      final response = await _dioClient.delete(
        '/cart/$cartId/items/$productoId',
      );
      return ShoppingCart.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
            'Error code: ${e.response?.statusCode}. Error eliminando ítem');
      }
      throw Exception('Error eliminando ítem: $e');
    }
  }

  Future<ShoppingCart> clearCart(String cartId) async {
    try {
      final response = await _dioClient.delete('/cart/$cartId');

      return ShoppingCart.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
            'Error code: ${e.response?.statusCode}. Error vaciando carrito');
      }
      throw Exception('Error vaciando carrito: $e');
    }
  }

  Future<ShoppingCart> transferCartToUser(String sessionId, int userId) async {
    try {
      _debugLog(
          "Implementando transferencia de carrito en el cliente: sessionId=$sessionId, userId=$userId");

      // 1. Obtener el carrito de la sesión
      ShoppingCart sessionCart;
      try {
        sessionCart = await getCartBySessionId(sessionId);
        _debugLog("Carrito de sesión obtenido: ${sessionCart.id}");
      } catch (e) {
        _debugLog("No se encontró carrito para la sesión");
        // Si no hay carrito de sesión, simplemente obtenemos o creamos uno para el usuario
        return await _getOrCreateUserCart(userId);
      }

      // 2. Obtener o crear el carrito del usuario
      ShoppingCart userCart;
      try {
        userCart = await getCartByUserId(userId);
        _debugLog("Carrito de usuario obtenido: ${userCart.id}");
      } catch (e) {
        _debugLog("No se encontró carrito para el usuario, creando uno nuevo");
        userCart = await createNewCart(userId, null);
        _debugLog("Carrito de usuario creado: ${userCart.id}");
      }

      // 3. Transferir los items del carrito de sesión al carrito del usuario
      if (sessionCart.items.isNotEmpty) {
        _debugLog(
            "Transfiriendo ${sessionCart.items.length} items al carrito del usuario");
        for (var item in sessionCart.items) {
          try {
            userCart = await addItemToCart(userCart.id!, item);
          } catch (e) {
            _debugLog("Error al añadir item al carrito");
            // Si falla, lo añadimos manualmente
            userCart = userCart.addItem(item);
          }
        }
      }

      // 4. Intentar limpiar el carrito de sesión (no es crítico si falla)
      if (sessionCart.id != null) {
        try {
          await clearCart(sessionCart.id!);
          _debugLog("Carrito de sesión limpiado");
        } catch (e) {
          _debugLog("Error al limpiar carrito de sesión");
        }
      }

      _debugLog("Transferencia completada con éxito");
      return userCart;
    } catch (e) {
      _debugLog("Error general en transferencia de carrito");
      // Si ocurre cualquier error, intentamos obtener o crear un carrito para el usuario
      return await _getOrCreateUserCart(userId);
    }
  }

  // Método auxiliar para obtener o crear un carrito de usuario
  Future<ShoppingCart> _getOrCreateUserCart(int userId) async {
    try {
      return await getCartByUserId(userId);
    } catch (e) {
      try {
        return await createNewCart(userId, null);
      } catch (createError) {
        _debugLog("Error al crear carrito para usuario");
        return ShoppingCart.empty();
      }
    }
  }

  Future<ShoppingCart> createNewCart(int? userId, String? sessionId) async {
    try {
      if (userId == null && sessionId == null) {
        throw Exception('Se requiere userId o sessionId para crear un carrito');
      }

      Map<String, dynamic> queryParams = {};
      if (userId != null) {
        queryParams['userId'] = userId;
      }
      if (sessionId != null) {
        queryParams['sessionId'] = sessionId;
      }

      _debugLog("Intentando crear carrito");
      final response = await _dioClient.post(
        '/cart/create',
        queryParameters: queryParams,
      );
      _debugLog(
          "Respuesta del servidor al crear carrito: ${response.statusCode}");
      return ShoppingCart.fromJson(response.data);
    } catch (e) {
      _debugLog("Error al crear carrito");
      if (e is DioException && e.response != null) {
        _debugLog("Status code: ${e.response?.statusCode}");
        throw Exception(
            'Error code: ${e.response?.statusCode}. Error creando carrito');
      }
      throw Exception('Error creando carrito: $e');
    }
  }

  // Método para imprimir logs solo en modo desarrollo
  void _debugLog(String message) {
    assert(() {
      print(message);
      return true;
    }());
  }
}
