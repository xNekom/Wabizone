import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class UsuarioService {
  // URL base para la API
  static const String baseUrl = 'http://localhost:8081/api/v1/users';

  // Caché local para usuarios (mejora rendimiento y permite trabajar offline)
  static List<Usuario> _usuariosCache = [];

  // Getter para acceder a la caché de usuarios
  static List<Usuario> get usuarios => _usuariosCache;

  // Convertir User del backend a Usuario del frontend
  static Usuario _mapearUsuario(Map<String, dynamic> json) {
    return Usuario(
      id: json['id']?.toString(),
      trato: json['trato'] ?? '',
      imagen: json['imagen'] ?? '',
      edad: json['edad'] ?? 0,
      usuario: json['nombre'] ?? '',
      contrasena: json['contrasena'] ?? '',
      lugarNacimiento: json['lugarNacimiento'] ?? '',
      bloqueado: json['bloqueado'] ?? false,
      esAdmin: json['administrador'] ?? false,
    );
  }

  // Convertir Usuario del frontend a formato JSON para el backend
  static Map<String, dynamic> _usuarioToJson(Usuario usuario) {
    return {
      'nombre': usuario.usuario,
      'contrasena': usuario.contrasena,
      'edad': usuario.edad,
      'administrador': usuario.esAdmin || false,
      'trato': usuario.trato,
      'imagen': usuario.imagen,
      'lugarNacimiento': usuario.lugarNacimiento,
      'bloqueado': usuario.bloqueado || false,
    };
  }

  // Validar credenciales de usuario
  static Future<String?> validarUsuario(
      String usuario, String contrasena) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'nombre': usuario,
          'contrasena': contrasena,
        },
      );

      if (response.statusCode == 200) {
        return null; // Autenticación exitosa
      } else if (response.statusCode == 403) {
        return "Has sido baneado, por favor contacta con el administrador";
      } else {
        return "Credenciales incorrectas";
      }
    } catch (e) {
      return "Error de conexión: $e";
    }
  }

  // Buscar usuario por credenciales
  static Future<Usuario?> buscarUsuario(
      String usuario, String contrasena) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'nombre': usuario,
          'contrasena': contrasena,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = json.decode(response.body);
        Usuario user = _mapearUsuario(userData);
        return user;
      } else {
        return null;
      }
    } catch (e) {
      print('Error al buscar usuario: $e');
      return null;
    }
  }

  // Buscar usuario por nombre
  static Future<Usuario?> buscarUsuarioPorNombre(String usuario) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/buscar?nombre=$usuario'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = json.decode(response.body);
        Usuario user = _mapearUsuario(userData);
        return user;
      } else {
        return null;
      }
    } catch (e) {
      print('Error al buscar usuario por nombre: $e');
      return null;
    }
  }

  // Obtener todos los usuarios
  static Future<List<Usuario>> obtenerTodosUsuarios() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> usersData = json.decode(response.body);
        _usuariosCache =
            usersData.map((userData) => _mapearUsuario(userData)).toList();
        return _usuariosCache;
      } else {
        return [];
      }
    } catch (e) {
      print('Error al obtener usuarios: $e');
      return [];
    }
  }

  // Agregar nuevo usuario
  static Future<Map<String, dynamic>> agregarUsuario(Usuario usuario) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_usuarioToJson(usuario)),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Usuario creado correctamente'};
      } else if (response.statusCode == 409) {
        print('Error: El usuario ya existe');
        return {'success': false, 'message': 'El nombre de usuario ya existe'};
      } else {
        print(
            'Error al agregar usuario: ${response.statusCode} - ${response.body}');
        return {'success': false, 'message': 'Error al registrar el usuario'};
      }
    } catch (e) {
      print('Error al agregar usuario: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Actualizar usuario existente
  static Future<bool> actualizarUsuario(Usuario usuario, int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_usuarioToJson(usuario)),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar usuario: $e');
      return false;
    }
  }

  // Eliminar usuario
  static Future<bool> eliminarUsuario(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return response.statusCode == 204;
    } catch (e) {
      print('Error al eliminar usuario: $e');
      return false;
    }
  }
}
