import 'package:flutter/foundation.dart';
import '../models/producto.dart';
import '../repositories/producto_repository.dart';
import '../services/service_locator.dart';

class ProductoProvider with ChangeNotifier {
  final IProductoRepository _productoRepository;

  bool _isLoading = false;
  String _error = '';
  List<Producto> _productos = [];
  Producto? _productoSeleccionado;

  bool get isLoading => _isLoading;
  String get error => _error;
  List<Producto> get productos => _productos;
  Producto? get productoSeleccionado => _productoSeleccionado;

  ProductoProvider({IProductoRepository? productoRepository})
      : _productoRepository =
            productoRepository ?? ServiceLocator().productoRepository;

  Future<void> obtenerTodosProductos() async {
    _setLoading(true);
    _setError('');

    try {
      _productos = await _productoRepository.obtenerTodos();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Error al obtener productos: $e');
      _setLoading(false);
    }
  }

  void seleccionarProducto(Producto producto) {
    _productoSeleccionado = producto;
    notifyListeners();
  }

  void limpiarSeleccion() {
    _productoSeleccionado = null;
    notifyListeners();
  }

  Future<Producto?> obtenerProductoPorId(String id) async {
    _setLoading(true);
    _setError('');

    try {
      final producto = await _productoRepository.obtenerPorId(id);

      if (producto != null) {
        _productoSeleccionado = producto;
      } else {
        _setError('No se encontró el producto');
      }

      _setLoading(false);
      notifyListeners();
      return producto;
    } catch (e) {
      _setError('Error al obtener producto: $e');
      _setLoading(false);
      return null;
    }
  }

  Future<bool> crearProducto(Producto producto) async {
    _setLoading(true);
    _setError('');

    try {
      final result = await _productoRepository.crear(producto);

      if (result) {
        await obtenerTodosProductos();
      } else {
        _setError('No se pudo crear el producto');
      }

      _setLoading(false);
      return result;
    } catch (e) {
      String errorMsg = e.toString();

      if (errorMsg.contains('Data truncation') ||
          errorMsg.contains('too long for column')) {
        _setError(
            'La imagen seleccionada es demasiado grande para la base de datos. Por favor, selecciona una imagen más pequeña o utiliza la imagen predeterminada.');
      } else if (errorMsg.contains('constraint') ||
          errorMsg.contains('duplicate')) {
        _setError(
            'Ya existe un producto con el mismo ID. Intente crear el producto nuevamente.');
      } else {
        _setError('Error al crear producto: $e');
      }

      _setLoading(false);
      return false;
    }
  }

  Future<bool> actualizarProducto(Producto producto, int id) async {
    _setLoading(true);
    _setError('');

    try {
      final result = await _productoRepository.actualizar(producto, id);

      if (result) {
        if (_productoSeleccionado != null &&
            _productoSeleccionado!.id == producto.id) {
          _productoSeleccionado = producto;
        }

        await obtenerTodosProductos();
      } else {
        _setError('No se pudo actualizar el producto');
      }

      _setLoading(false);
      return result;
    } catch (e) {
      String errorMsg = e.toString();

      if (errorMsg.contains('producto_no_encontrado')) {
        _setError(
            'No se encontró el producto con ID $id. Verifique que el producto existe.');
      } else if (errorMsg.contains('resource_not_found')) {
        _setError('Recurso no encontrado. Verifique que el producto existe.');
      } else {
        _setError('Error al actualizar producto: $e');
      }

      _setLoading(false);
      return false;
    }
  }

  Future<bool> eliminarProducto(String id) async {
    _setLoading(true);
    _setError('');

    try {
      final result = await _productoRepository.eliminar(id);

      if (result) {
        if (_productoSeleccionado != null && _productoSeleccionado!.id == id) {
          _productoSeleccionado = null;
        }

        _productos.removeWhere((producto) => producto.id == id);

        await obtenerTodosProductos();
      } else {
        _setError('No se pudo eliminar el producto');
      }

      _setLoading(false);
      notifyListeners();
      return result;
    } catch (e) {
      _setError('Error al eliminar producto: $e');
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
