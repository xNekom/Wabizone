import '../models/cart_item.dart';
import '../models/shopping_cart.dart';
import 'dio_client.dart';
import 'package:dio/dio.dart';

class CarritoService {
  final DioClient _dioClient = DioClient();
  final String _baseUrl = '/api/v1/cart';

  Future<ShoppingCart> getCartBySessionId(String sessionId) async {
    try {
      final response = await _dioClient.get('$_baseUrl/session/$sessionId');
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
      final response = await _dioClient.get('$_baseUrl/user/$userId');
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
        '$_baseUrl/$cartId/items',
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
        '$_baseUrl/$cartId/items/$productoId',
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
        '$_baseUrl/$cartId/items/$productoId',
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
      final response = await _dioClient.delete('$_baseUrl/$cartId');
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
      final response = await _dioClient.post(
        '$_baseUrl/transfer',
        queryParameters: {
          'sessionId': sessionId,
          'userId': userId,
        },
      );
      return ShoppingCart.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
            'Error code: ${e.response?.statusCode}. Error transfiriendo carrito');
      }
      throw Exception('Error transfiriendo carrito: $e');
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

      final response = await _dioClient.post(
        '$_baseUrl/create',
        queryParameters: queryParams,
      );
      return ShoppingCart.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
            'Error code: ${e.response?.statusCode}. Error creando carrito');
      }
      throw Exception('Error creando carrito: $e');
    }
  }
}
