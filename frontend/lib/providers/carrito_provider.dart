import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/cart_item.dart';
import '../models/shopping_cart.dart';
import '../services/carrito_service.dart';

class CarritoProvider extends ChangeNotifier {
  final CarritoService _carritoService = CarritoService();

  ShoppingCart _cart = ShoppingCart.empty();
  bool _isLoading = false;
  String? _error;
  String? _sessionId;
  int? _userId;

  ShoppingCart get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _cart.items.length;
  double get total => _cart.total;
  bool get isEmpty => _cart.items.isEmpty;

  CarritoProvider() {
    _initCart();
  }

  Future<void> _initCart() async {
    _setLoading(true);
    _error = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      _sessionId = prefs.getString('cart_session_id');
      _userId = prefs.getInt('user_id');

      if (_sessionId == null && _userId == null) {
        _sessionId = const Uuid().v4();
        await prefs.setString('cart_session_id', _sessionId!);

        _cart = ShoppingCart.empty();
        notifyListeners();
        _setLoading(false);
        return;
      }

      try {
        if (_userId != null) {
          await _loadUserCart(_userId!);
        } else if (_sessionId != null) {
          await _loadSessionCart(_sessionId!);
        }
      } catch (innerError) {
        _cart = ShoppingCart.empty();
        notifyListeners();
      }
    } catch (e) {
      _cart = ShoppingCart.empty();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadSessionCart(String sessionId) async {
    try {
      _cart = await _carritoService.getCartBySessionId(sessionId);
      notifyListeners();
    } catch (e) {
      _cart = ShoppingCart(
        sessionId: sessionId,
        items: [],
        ultimaActualizacion: DateTime.now(),
        total: 0.0,
      );

      _tryCreateNewCart();

      notifyListeners();
    }
  }

  Future<void> _loadUserCart(int userId) async {
    try {
      _cart = await _carritoService.getCartByUserId(userId);
      notifyListeners();
    } catch (e) {
      _cart = ShoppingCart(
        usuarioId: userId,
        items: [],
        ultimaActualizacion: DateTime.now(),
        total: 0.0,
      );

      _tryCreateNewCart();

      notifyListeners();
    }
  }

  Future<void> addToCart({
    required int productoId,
    required String nombre,
    required double precio,
    int cantidad = 1,
    String? opciones,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final item = CartItem(
        productoId: productoId,
        nombre: nombre,
        cantidad: cantidad,
        precio: precio,
        opciones: opciones,
      );

      if (_cart.id == null) {
        try {
          if (_userId != null) {
            _cart = await _carritoService.getCartByUserId(_userId!);
          } else if (_sessionId != null) {
            _cart = await _carritoService.getCartBySessionId(_sessionId!);
          }
        } catch (e) {}
      }

      if (_cart.id != null) {
        try {
          _cart = await _carritoService.addItemToCart(_cart.id!, item);
        } catch (e) {
          _cart = _cart.addItem(item);
        }
      } else {
        _cart = _cart.addItem(item);
        _tryCreateNewCart();
      }

      notifyListeners();
    } catch (e) {
      _setError('Error al agregar al carrito: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _tryCreateNewCart() async {
    try {
      if (_userId != null) {
        _cart = await _carritoService.createNewCart(_userId!, null);
      } else if (_sessionId != null) {
        _cart = await _carritoService.createNewCart(null, _sessionId!);
      }
    } catch (e) {}
  }

  Future<void> updateItemQuantity(int productoId, int cantidad) async {
    if (cantidad <= 0) {
      await removeFromCart(productoId);
      return;
    }

    _setLoading(true);

    try {
      if (_cart.id != null) {
        _cart = await _carritoService.updateItemQuantity(
            _cart.id!, productoId, cantidad);
      } else {
        _cart = _cart.updateItemQuantity(productoId, cantidad);
      }

      notifyListeners();
    } catch (e) {
      _setError('Error al actualizar la cantidad: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeFromCart(int productoId) async {
    _setLoading(true);

    try {
      if (_cart.id != null) {
        _cart = await _carritoService.removeItemFromCart(_cart.id!, productoId);
      } else {
        _cart = _cart.removeItem(productoId);
      }

      notifyListeners();
    } catch (e) {
      _setError('Error al eliminar del carrito: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearCart() async {
    _setLoading(true);

    try {
      if (_cart.id != null) {
        _cart = await _carritoService.clearCart(_cart.id!);
      } else {
        _cart = _cart.clearCart();
      }

      notifyListeners();
    } catch (e) {
      _setError('Error al vaciar el carrito: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> transferCartToUser(int userId) async {
    if (_sessionId == null || _cart.id == null) return;

    _setLoading(true);

    try {
      _cart = await _carritoService.transferCartToUser(_sessionId!, userId);

      _userId = userId;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', userId);

      notifyListeners();
    } catch (e) {
      _setError('Error al transferir el carrito: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _error = null;
    }
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
}
