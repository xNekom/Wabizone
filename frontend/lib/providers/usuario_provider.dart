import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../repositories/usuario_repository.dart';
import '../services/service_locator.dart';

class UsuarioProvider with ChangeNotifier {
  final IUsuarioRepository _usuarioRepository;

  bool _isLoading = false;
  String _error = '';
  List<Usuario> _usuarios = [];
  Usuario? _usuarioActual;

  bool get isLoading => _isLoading;
  String get error => _error;
  List<Usuario> get usuarios => _usuarios;
  Usuario? get usuarioActual => _usuarioActual;
  bool get isLoggedIn => _usuarioActual != null;
  bool get isAdmin => _usuarioActual?.esAdmin ?? false;

  UsuarioProvider({IUsuarioRepository? usuarioRepository})
      : _usuarioRepository =
            usuarioRepository ?? ServiceLocator().usuarioRepository;

  Future<bool> login(String usuario, String contrasena) async {
    _setLoading(true);
    _setError('');

    try {
      final errorMsg =
          await _usuarioRepository.validarCredenciales(usuario, contrasena);

      if (errorMsg != null) {
        if (errorMsg.toLowerCase().contains('baneado') ||
            errorMsg.toLowerCase().contains('bloqueado') ||
            errorMsg.toLowerCase().contains('403')) {
          _setError(
              'Has sido baneado, por favor contacta con un administrador');
        } else {
          _setError(errorMsg);
        }
        _setLoading(false);
        return false;
      }

      final user =
          await _usuarioRepository.buscarPorCredenciales(usuario, contrasena);

      if (user == null) {
        _setError('No se pudo obtener la información del usuario');
        _setLoading(false);
        return false;
      }

      if (user.bloqueado) {
        _setError('Has sido baneado, por favor contacta con un administrador');
        _setLoading(false);
        return false;
      }

      _usuarioActual = user;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      String errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('usuario_bloqueado') ||
          errorMsg.contains('bloqueado') ||
          errorMsg.contains('baneado') ||
          errorMsg.contains('403') ||
          errorMsg.contains('forbidden')) {
        _setError('Has sido baneado, por favor contacta con un administrador');
      } else if (errorMsg.contains('401') ||
          errorMsg.contains('unauthorized') ||
          errorMsg.contains('credenciales')) {
        _setError(
            'Usuario o contraseña incorrectos. Por favor, inténtalo de nuevo.');
      } else {
        _setError('Error de conexión: $e');
      }
      _setLoading(false);
      return false;
    }
  }

  void logout() {
    _usuarioActual = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> registrar(Usuario usuario) async {
    _setLoading(true);
    _setError('');

    try {
      usuario.usuario = usuario.usuario.trim();

      final result = await _usuarioRepository.crear(usuario);

      _setLoading(false);

      if (result['success']) {
        await obtenerTodosUsuarios();
      } else {
        _setError(result['message']);
      }

      return result;
    } catch (e) {
      _setLoading(false);
      _setError('Error al registrar usuario: $e');
      return {'success': false, 'message': 'Error al registrar: $e'};
    }
  }

  Future<void> obtenerTodosUsuarios() async {
    _setLoading(true);
    _setError('');

    try {
      _usuarios = await _usuarioRepository.obtenerTodos();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Error al obtener usuarios: $e');
      _setLoading(false);
    }
  }

  Future<bool> actualizarUsuario(Usuario usuario, int id) async {
    _setLoading(true);
    _setError('');

    try {
      final result = await _usuarioRepository.actualizar(usuario, id);

      if (result) {
        if (_usuarioActual != null && _usuarioActual!.id == usuario.id) {
          _usuarioActual = usuario;
        }

        await obtenerTodosUsuarios();
      } else {
        _setError('No se pudo actualizar el usuario');
      }

      _setLoading(false);
      return result;
    } catch (e) {
      _setError('Error al actualizar usuario: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> eliminarUsuario(int id) async {
    _setLoading(true);
    _setError('');

    try {
      final result = await _usuarioRepository.eliminar(id);

      if (result) {
        await obtenerTodosUsuarios();
      } else {
        _setError('No se pudo eliminar el usuario');
      }

      _setLoading(false);
      return result;
    } catch (e) {
      _setError('Error al eliminar usuario: $e');
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
