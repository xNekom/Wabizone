import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/cart_item.dart';
import '../models/shopping_cart.dart';
import '../services/carrito_service.dart';

class CarritoProvider extends ChangeNotifier {
  final CarritoService _carritoService = CarritoService();

  // Estado del carrito
  ShoppingCart _cart = ShoppingCart.empty();
  bool _isLoading = false;
  String? _error;
  String? _sessionId;
  int? _userId;

  // Getters
  ShoppingCart get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _cart.items.length;
  double get total => _cart.total;
  bool get isEmpty => _cart.items.isEmpty;

  // Constructor
  CarritoProvider() {
    _initCart();
  }

  // Inicializar carrito
  Future<void> _initCart() async {
    _setLoading(true);
    _error = null; // Limpiar errores al inicio

    try {
      // Intentar cargar el sessionId guardado
      final prefs = await SharedPreferences.getInstance();
      _sessionId = prefs.getString('cart_session_id');
      _userId = prefs.getInt('user_id');

      print('Inicializando carrito: sessionId=$_sessionId, userId=$_userId');

      // Si no hay sessionId o userId, creamos un carrito vacío en memoria
      if (_sessionId == null && _userId == null) {
        // Si no hay sessionId, crear uno nuevo
        _sessionId = const Uuid().v4();
        await prefs.setString('cart_session_id', _sessionId!);
        print('Nuevo sessionId generado: $_sessionId');

        // Crear un nuevo carrito vacío en memoria sin intentar acceder al servidor
        _cart = ShoppingCart.empty();
        notifyListeners();
        _setLoading(false);
        return;
      }

      // Intentamos cargar el carrito, pero manejamos los errores silenciosamente
      try {
        if (_userId != null) {
          // Si hay un usuario logueado, cargar su carrito
          await _loadUserCart(_userId!);
        } else if (_sessionId != null) {
          // Si hay un sessionId guardado, cargar el carrito por sessionId
          await _loadSessionCart(_sessionId!);
        }
      } catch (innerError) {
        print('Error al cargar el carrito: $innerError');
        // Si hay un error al cargar, simplemente usamos un carrito vacío
        _cart = ShoppingCart.empty();
        notifyListeners();
      }
    } catch (e) {
      print('Error controlado al inicializar el carrito: $e');
      // No mostrar error al usuario, en su lugar usar un carrito vacío
      _cart = ShoppingCart.empty();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Cargar carrito por ID de sesión
  Future<void> _loadSessionCart(String sessionId) async {
    try {
      print('Intentando cargar carrito por sessionId: $sessionId');
      _cart = await _carritoService.getCartBySessionId(sessionId);
      print('Carrito cargado exitosamente por sessionId');
      notifyListeners();
    } catch (e) {
      print('Error controlado al cargar carrito por sessionId: $e');
      // Para cualquier error, simplemente usamos un carrito vacío local
      print('Creando carrito vacío para la sesión');
      _cart = ShoppingCart(
        sessionId: sessionId,
        items: [],
        ultimaActualizacion: DateTime.now(),
        total: 0.0,
      );

      // No mostramos error al usuario
      // _setError('Error al cargar el carrito: $e');

      // Intentamos crear un carrito en el servidor silenciosamente
      _tryCreateNewCart();

      notifyListeners();
    }
  }

  // Cargar carrito por ID de usuario
  Future<void> _loadUserCart(int userId) async {
    try {
      print('Intentando cargar carrito para usuario $userId');
      _cart = await _carritoService.getCartByUserId(userId);
      print('Carrito cargado exitosamente para usuario $userId');
      notifyListeners();
    } catch (e) {
      print('Error controlado al cargar carrito: $e');
      // Para cualquier error al cargar el carrito del usuario, simplemente creamos uno vacío
      // No distinguimos entre tipos de error, ya que el resultado es el mismo
      print('Creando carrito vacío para el usuario $userId');

      // Crear un nuevo carrito vacío con el ID de usuario
      _cart = ShoppingCart(
        usuarioId: userId,
        items: [],
        ultimaActualizacion: DateTime.now(),
        total: 0.0,
      );

      // No mostramos el error al usuario
      // _setError(null);

      // Intentamos crear un carrito en el servidor silenciosamente
      _tryCreateNewCart();

      notifyListeners();
    }
  }

  // Agregar un producto al carrito
  Future<void> addToCart({
    required int productoId,
    required String nombre,
    required double precio,
    int cantidad = 1,
    String? opciones,
  }) async {
    _setLoading(true);
    _error = null; // Limpiar errores previos

    try {
      // Crear el ítem para agregar
      final item = CartItem(
        productoId: productoId,
        nombre: nombre,
        cantidad: cantidad,
        precio: precio,
        opciones: opciones,
      );

      // Si el carrito aún no tiene ID, primero hay que crearlo
      if (_cart.id == null) {
        try {
          if (_userId != null) {
            // Crear el carrito para el usuario
            _cart = await _carritoService.getCartByUserId(_userId!);
          } else if (_sessionId != null) {
            // Crear el carrito para la sesión
            _cart = await _carritoService.getCartBySessionId(_sessionId!);
          }
        } catch (e) {
          // Si ocurre un error al obtener el carrito, procedemos con el carrito local
          print('Error al obtener el carrito del servidor: $e');
        }
      }

      if (_cart.id != null) {
        // Agregar el ítem al carrito existente
        try {
          _cart = await _carritoService.addItemToCart(_cart.id!, item);
        } catch (e) {
          // Si falla al agregar al carrito en el servidor, manejarlo localmente
          print('Error al agregar al carrito en el servidor: $e');
          _cart = _cart.addItem(item);
          // No mostrar el error al usuario directamente, sino manejar silenciosamente
        }
      } else {
        // Si no tenemos un ID de carrito, manejar localmente
        _cart = _cart.addItem(item);
        // Intentar crear un nuevo carrito para futuros elementos
        _tryCreateNewCart();
      }

      notifyListeners();
    } catch (e) {
      _setError('Error al agregar al carrito: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Método para intentar crear un nuevo carrito
  Future<void> _tryCreateNewCart() async {
    try {
      if (_userId != null) {
        // Intentar crear un carrito para el usuario
        _cart = await _carritoService.createNewCart(_userId!, null);
      } else if (_sessionId != null) {
        // Intentar crear un carrito para la sesión
        _cart = await _carritoService.createNewCart(null, _sessionId!);
      }
    } catch (e) {
      print('No se pudo crear un nuevo carrito: $e');
      // No mostrar error al usuario, solo registrar en consola
    }
  }

  // Actualizar cantidad de un ítem
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

  // Eliminar un ítem del carrito
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

  // Vaciar el carrito
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

  // Transferir carrito de sesión a usuario cuando inicia sesión
  Future<void> transferCartToUser(int userId) async {
    if (_sessionId == null || _cart.id == null) return;

    _setLoading(true);

    try {
      _cart = await _carritoService.transferCartToUser(_sessionId!, userId);

      // Actualizar el userId
      _userId = userId;

      // Guardar el userId en las preferencias
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', userId);

      notifyListeners();
    } catch (e) {
      _setError('Error al transferir el carrito: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Método para actualizar la bandera de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _error = null;
    }
    notifyListeners();
  }

  // Método para actualizar el error
  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
}
