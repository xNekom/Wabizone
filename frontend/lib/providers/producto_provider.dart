import 'package:flutter/foundation.dart';
import '../models/producto.dart';
import '../repositories/producto_repository.dart';
import '../services/service_locator.dart';

/// Provider para gestionar el estado relacionado con los productos
class ProductoProvider with ChangeNotifier {
  // Repositorio de productos
  final IProductoRepository _productoRepository;

  // Estado del provider
  bool _isLoading = false;
  String _error = '';
  List<Producto> _productos = [];
  Producto? _productoSeleccionado;

  // Getters para acceder al estado
  bool get isLoading => _isLoading;
  String get error => _error;
  List<Producto> get productos => _productos;
  Producto? get productoSeleccionado => _productoSeleccionado;

  // Constructor que recibe el repositorio
  ProductoProvider({IProductoRepository? productoRepository})
      : _productoRepository =
            productoRepository ?? ServiceLocator().productoRepository;

  /// Obtener todos los productos
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

  /// Seleccionar un producto específico
  void seleccionarProducto(Producto producto) {
    _productoSeleccionado = producto;
    notifyListeners();
  }

  /// Limpiar la selección de producto
  void limpiarSeleccion() {
    _productoSeleccionado = null;
    notifyListeners();
  }

  /// Obtener un producto por su ID
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

  /// Crear un nuevo producto
  Future<bool> crearProducto(Producto producto) async {
    _setLoading(true);
    _setError('');

    try {
      final result = await _productoRepository.crear(producto);

      if (result) {
        await obtenerTodosProductos(); // Refrescar la lista
      } else {
        _setError('No se pudo crear el producto');
      }

      _setLoading(false);
      return result;
    } catch (e) {
      _setError('Error al crear producto: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Actualizar un producto existente
  Future<bool> actualizarProducto(Producto producto, int id) async {
    _setLoading(true);
    _setError('');

    try {
      final result = await _productoRepository.actualizar(producto, id);

      if (result) {
        // Si es el producto seleccionado, actualizar la instancia
        if (_productoSeleccionado != null &&
            _productoSeleccionado!.id == producto.id) {
          _productoSeleccionado = producto;
        }

        await obtenerTodosProductos(); // Refrescar la lista
      } else {
        _setError('No se pudo actualizar el producto');
      }

      _setLoading(false);
      return result;
    } catch (e) {
      _setError('Error al actualizar producto: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Eliminar un producto
  Future<bool> eliminarProducto(String id) async {
    _setLoading(true);
    _setError('');

    try {
      final result = await _productoRepository.eliminar(id);

      if (result) {
        // Si es el producto seleccionado, limpiar la selección
        if (_productoSeleccionado != null && _productoSeleccionado!.id == id) {
          _productoSeleccionado = null;
        }

        // Eliminar de la lista local
        _productos.removeWhere((producto) => producto.id == id);

        await obtenerTodosProductos(); // Refrescar la lista completa
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
