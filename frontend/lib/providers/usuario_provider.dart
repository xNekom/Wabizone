import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../repositories/usuario_repository.dart';
import '../services/service_locator.dart';

/// Provider para gestionar el estado relacionado con los usuarios
class UsuarioProvider with ChangeNotifier {
  // Repositorio de usuarios
  final IUsuarioRepository _usuarioRepository;

  // Estado del provider
  bool _isLoading = false;
  String _error = '';
  List<Usuario> _usuarios = [];
  Usuario? _usuarioActual;

  // Getters para acceder al estado
  bool get isLoading => _isLoading;
  String get error => _error;
  List<Usuario> get usuarios => _usuarios;
  Usuario? get usuarioActual => _usuarioActual;
  bool get isLoggedIn => _usuarioActual != null;
  bool get isAdmin => _usuarioActual?.esAdmin ?? false;

  // Constructor que recibe el repositorio
  UsuarioProvider({IUsuarioRepository? usuarioRepository})
      : _usuarioRepository =
            usuarioRepository ?? ServiceLocator().usuarioRepository;

  /// Iniciar sesión con nombre de usuario y contraseña
  Future<bool> login(String usuario, String contrasena) async {
    _setLoading(true);
    _setError('');

    try {
      final errorMsg =
          await _usuarioRepository.validarCredenciales(usuario, contrasena);

      if (errorMsg != null) {
        _setError(errorMsg);
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

      _usuarioActual = user;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Cerrar sesión
  void logout() {
    _usuarioActual = null;
    notifyListeners();
  }

  /// Registrar un nuevo usuario
  Future<Map<String, dynamic>> registrar(Usuario usuario) async {
    _setLoading(true);
    _setError('');

    try {
      print('LOG_REGISTRO: Iniciando registro para ${usuario.usuario}');

      // Asegurarse de eliminar espacios en blanco del nombre de usuario
      usuario.usuario = usuario.usuario.trim();

      // Vamos directo a crear el usuario y manejar los errores apropiadamente
      final result = await _usuarioRepository.crear(usuario);

      print(
          'LOG_REGISTRO: Resultado de creación: ${result['success']} - ${result['message']}');

      _setLoading(false);

      if (result['success']) {
        print('LOG_REGISTRO: Usuario creado exitosamente');
        await obtenerTodosUsuarios(); // Refrescar la lista
      } else {
        print('LOG_REGISTRO: Error al crear usuario: ${result['message']}');
        _setError(result['message']);
      }

      return result;
    } catch (e) {
      print('LOG_REGISTRO: Excepción al registrar: $e');
      _setLoading(false);
      _setError('Error al registrar usuario: $e');
      return {'success': false, 'message': 'Error al registrar: $e'};
    }
  }

  /// Obtener todos los usuarios
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

  /// Actualizar un usuario existente
  Future<bool> actualizarUsuario(Usuario usuario, int id) async {
    _setLoading(true);
    _setError('');

    try {
      final result = await _usuarioRepository.actualizar(usuario, id);

      if (result) {
        // Si el usuario actualizado es el actual, actualizar la instancia
        if (_usuarioActual != null && _usuarioActual!.id == usuario.id) {
          _usuarioActual = usuario;
        }

        await obtenerTodosUsuarios(); // Refrescar la lista
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

  /// Eliminar un usuario
  Future<bool> eliminarUsuario(int id) async {
    _setLoading(true);
    _setError('');

    try {
      final result = await _usuarioRepository.eliminar(id);

      if (result) {
        await obtenerTodosUsuarios(); // Refrescar la lista
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
