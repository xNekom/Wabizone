import 'package:flutter/foundation.dart';
import '../models/pedido.dart';
import '../repositories/pedido_repository.dart';
import '../services/service_locator.dart';

class PedidoProvider with ChangeNotifier {
  final IPedidoRepository _pedidoRepository;

  bool _isLoading = false;
  String _error = '';
  List<Pedido> _pedidos = [];
  Pedido? _pedidoSeleccionado;

  bool get isLoading => _isLoading;
  String get error => _error;
  List<Pedido> get pedidos => _pedidos;
  Pedido? get pedidoSeleccionado => _pedidoSeleccionado;

  PedidoProvider({IPedidoRepository? pedidoRepository})
      : _pedidoRepository =
            pedidoRepository ?? ServiceLocator().pedidoRepository;

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

  void seleccionarPedido(Pedido pedido) {
    _pedidoSeleccionado = pedido;
    notifyListeners();
  }

  void limpiarSeleccion() {
    _pedidoSeleccionado = null;
    notifyListeners();
  }

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

  Future<Pedido?> crearPedido(Pedido pedido) async {
    _setLoading(true);
    _setError('');

    try {
      final nuevoPedido = await _pedidoRepository.crear(pedido);

      if (nuevoPedido != null) {
        await obtenerTodosPedidos();
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

  Future<bool> actualizarPedido(Pedido pedido, String id) async {
    _setLoading(true);
    _setError('');

    try {
      final result = await _pedidoRepository.actualizar(pedido, id);

      if (result) {
        if (_pedidoSeleccionado != null && _pedidoSeleccionado!.nPedido == id) {
          _pedidoSeleccionado = pedido;
        }

        await obtenerTodosPedidos();
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

  Future<bool> cambiarEstadoPedido(String id, String nuevoEstado) async {
    _setLoading(true);
    _setError('');

    try {
      final pedido = await _pedidoRepository.obtenerPorId(id);

      if (pedido == null) {
        _setError('No se encontró el pedido');
        _setLoading(false);
        return false;
      }

      pedido.estadoPedido = nuevoEstado;

      return await actualizarPedido(pedido, id);
    } catch (e) {
      _setError('Error al cambiar estado del pedido: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> eliminarPedido(String id) async {
    _setLoading(true);
    _setError('');

    try {
      final result = await _pedidoRepository.eliminar(id);

      if (result) {
        if (_pedidoSeleccionado != null && _pedidoSeleccionado!.nPedido == id) {
          _pedidoSeleccionado = null;
        }

        _pedidos.removeWhere((pedido) => pedido.nPedido == id);

        await obtenerTodosPedidos();
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

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    if (errorMessage.isNotEmpty) {
      notifyListeners();
    }
  }
}
