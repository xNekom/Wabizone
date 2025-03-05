import 'package:flutter/foundation.dart';
import '../models/pedido.dart';
import '../repositories/pedido_repository.dart';
import '../services/service_locator.dart';

/// Provider para gestionar el estado relacionado con los pedidos
class PedidoProvider with ChangeNotifier {
  // Repositorio de pedidos
  final IPedidoRepository _pedidoRepository;

  // Estado del provider
  bool _isLoading = false;
  String _error = '';
  List<Pedido> _pedidos = [];
  Pedido? _pedidoSeleccionado;

  // Getters para acceder al estado
  bool get isLoading => _isLoading;
  String get error => _error;
  List<Pedido> get pedidos => _pedidos;
  Pedido? get pedidoSeleccionado => _pedidoSeleccionado;

  // Constructor que recibe el repositorio
  PedidoProvider({IPedidoRepository? pedidoRepository})
      : _pedidoRepository =
            pedidoRepository ?? ServiceLocator().pedidoRepository;

  /// Obtener todos los pedidos
  Future<void> obtenerTodosPedidos() async {
    _setLoading(true);
    _setError('');

    try {
      _pedidos = await _pedidoRepository.obtenerTodos();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Error al obtener pedidos: $e');
      _setLoading(false);
    }
  }

  /// Obtener pedidos por estado
  Future<List<Pedido>> obtenerPedidosPorEstado(String estado) async {
    _setLoading(true);
    _setError('');

    try {
      final pedidosFiltrados = await _pedidoRepository.obtenerPorEstado(estado);
      _setLoading(false);
      return pedidosFiltrados;
    } catch (e) {
      _setError('Error al obtener pedidos por estado: $e');
      _setLoading(false);
      return [];
    }
  }

  /// Seleccionar un pedido específico
  void seleccionarPedido(Pedido pedido) {
    _pedidoSeleccionado = pedido;
    notifyListeners();
  }

  /// Limpiar la selección de pedido
  void limpiarSeleccion() {
    _pedidoSeleccionado = null;
    notifyListeners();
  }

  /// Obtener un pedido por su ID
  Future<Pedido?> obtenerPedidoPorId(String id) async {
    _setLoading(true);
    _setError('');

    try {
      final pedido = await _pedidoRepository.obtenerPorId(id);

      if (pedido != null) {
        _pedidoSeleccionado = pedido;
      } else {
        _setError('No se encontró el pedido');
      }

      _setLoading(false);
      notifyListeners();
      return pedido;
    } catch (e) {
      _setError('Error al obtener pedido: $e');
      _setLoading(false);
      return null;
    }
  }

  /// Crear un nuevo pedido
  Future<Pedido?> crearPedido(Pedido pedido) async {
    _setLoading(true);
    _setError('');

    try {
      final nuevoPedido = await _pedidoRepository.crear(pedido);

      if (nuevoPedido != null) {
        await obtenerTodosPedidos(); // Refrescar la lista
        _pedidoSeleccionado = nuevoPedido;
      } else {
        _setError('No se pudo crear el pedido');
      }

      _setLoading(false);
      notifyListeners();
      return nuevoPedido;
    } catch (e) {
      _setError('Error al crear pedido: $e');
      _setLoading(false);
      return null;
    }
  }

  /// Actualizar un pedido existente
  Future<bool> actualizarPedido(Pedido pedido, String id) async {
    _setLoading(true);
    _setError('');

    try {
      final result = await _pedidoRepository.actualizar(pedido, id);

      if (result) {
        // Si es el pedido seleccionado, actualizar la instancia
        if (_pedidoSeleccionado != null && _pedidoSeleccionado!.nPedido == id) {
          _pedidoSeleccionado = pedido;
        }

        await obtenerTodosPedidos(); // Refrescar la lista
      } else {
        _setError('No se pudo actualizar el pedido');
      }

      _setLoading(false);
      return result;
    } catch (e) {
      _setError('Error al actualizar pedido: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Cambiar el estado de un pedido
  Future<bool> cambiarEstadoPedido(String id, String nuevoEstado) async {
    _setLoading(true);
    _setError('');

    try {
      // Primero obtener el pedido actual
      final pedido = await _pedidoRepository.obtenerPorId(id);

      if (pedido == null) {
        _setError('No se encontró el pedido');
        _setLoading(false);
        return false;
      }

      // Actualizar el estado
      pedido.estadoPedido = nuevoEstado;

      // Guardar los cambios
      return await actualizarPedido(pedido, id);
    } catch (e) {
      _setError('Error al cambiar estado del pedido: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Eliminar un pedido
  Future<bool> eliminarPedido(String id) async {
    _setLoading(true);
    _setError('');

    try {
      final result = await _pedidoRepository.eliminar(id);

      if (result) {
        // Si es el pedido seleccionado, limpiar la selección
        if (_pedidoSeleccionado != null && _pedidoSeleccionado!.nPedido == id) {
          _pedidoSeleccionado = null;
        }

        // Eliminar de la lista local
        _pedidos.removeWhere((pedido) => pedido.nPedido == id);

        await obtenerTodosPedidos(); // Refrescar la lista completa
      } else {
        _setError('No se pudo eliminar el pedido');
      }

      _setLoading(false);
      notifyListeners();
      return result;
    } catch (e) {
      _setError('Error al eliminar pedido: $e');
      _setLoading(false);
      return false;
    }
  }

  // Método interno para establecer el estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Método interno para establecer el mensaje de error
  void _setError(String errorMessage) {
    _error = errorMessage;
    if (errorMessage.isNotEmpty) {
      notifyListeners();
    }
  }
}
