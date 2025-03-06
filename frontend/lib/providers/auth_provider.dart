import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';

class AuthProvider extends ChangeNotifier {
  Usuario? _usuario;
  bool _isLoading = false;
  String? _error;

  Usuario? get usuario => _usuario;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _usuario != null;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? usuarioId = prefs.getString('usuario_id');
      final String? usuarioNombre = prefs.getString('usuario_nombre');
      final String? usuarioContrasena = prefs.getString('usuario_contrasena');

      if (usuarioId != null &&
          usuarioNombre != null &&
          usuarioContrasena != null) {
        final usuario = await UsuarioService.buscarUsuarioPorId(usuarioId);
        if (usuario != null) {
          _usuario = usuario;
        } else {
          final usuario = await UsuarioService.buscarUsuario(
              usuarioNombre, usuarioContrasena);
          _usuario = usuario;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String usuario, String contrasena) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final errorMsg = await UsuarioService.validarUsuario(usuario, contrasena);
      if (errorMsg != null) {
        _error = errorMsg;
        _isLoading = false;
        notifyListeners();

        if (_error!.contains("baneado")) {}

        return false;
      }

      final usuarioObj =
          await UsuarioService.buscarUsuario(usuario, contrasena);
      if (usuarioObj == null) {
        _error = "No se pudo obtener la información del usuario";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _usuario = usuarioObj;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('usuario_id', usuarioObj.id ?? '');
      await prefs.setString('usuario_nombre', usuario);
      await prefs.setString('usuario_contrasena', contrasena);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('usuario_id');
      await prefs.remove('usuario_nombre');
      await prefs.remove('usuario_contrasena');
      _usuario = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(Usuario usuario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await UsuarioService.agregarUsuario(usuario);
      if (result['success'] == true) {
        return await login(usuario.usuario, usuario.contrasena);
      } else {
        _error = result['message'] ?? "Error al registrar usuario";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void actualizarUsuario(Usuario usuario) {
    _usuario = usuario;
    notifyListeners();
  }
}
