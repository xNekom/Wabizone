import '../models/usuario.dart';
import 'dio_client.dart';
import 'package:dio/dio.dart';

class UsuarioService {
  // URL base para la API (ahora relativa ya que la base está en DioClient)
  static const String endpoint = '/users';

  // Cliente DIO
  static final DioClient _dioClient = DioClient();

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
      'nombre': usuario.usuario.trim().toLowerCase(),
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
      final response = await _dioClient.post(
        '$endpoint/login',
        queryParameters: {
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
    } on Exception catch (e) {
      return "Error de conexión: $e";
    }
  }

  // Buscar usuario por credenciales
  static Future<Usuario?> buscarUsuario(
      String usuario, String contrasena) async {
    try {
      final response = await _dioClient.post(
        '$endpoint/login',
        queryParameters: {
          'nombre': usuario,
          'contrasena': contrasena,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = response.data;
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

  // Buscar un usuario por su nombre
  static Future<Usuario?> buscarUsuarioPorNombre(String nombre) async {
    try {
      final processedNombre = nombre.trim().toLowerCase();
      print('LOG_SEARCH_SVC: Buscando usuario: $processedNombre');

      final response = await _dioClient.get(
        '$endpoint/buscar',
        queryParameters: {'nombre': processedNombre},
      );

      print('LOG_SEARCH_SVC: Código respuesta: ${response.statusCode}');

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = response.data;
        return _mapearUsuario(userData);
      } else {
        return null;
      }
    } catch (e) {
      print('LOG_SEARCH_SVC: Error al buscar usuario por nombre: $e');
      // Si recibimos un 404, el usuario no existe
      if (e.toString().contains('404') || e.toString().contains('not_found')) {
        return null;
      }
      throw Exception('Error al buscar usuario: $e');
    }
  }

  // Obtener todos los usuarios
  static Future<List<Usuario>> obtenerTodosUsuarios() async {
    try {
      final response = await _dioClient.get(endpoint);

      if (response.statusCode == 200) {
        List<dynamic> usersData = response.data;
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
      print('Intentando crear usuario: ${usuario.usuario}');

      // Verificar primero si el usuario ya existe
      try {
        print('Verificando si el usuario ya existe...');
        final usuarioExistente = await buscarUsuarioPorNombre(usuario.usuario);
        if (usuarioExistente != null) {
          print('Error: El usuario ${usuario.usuario} ya existe');
          return {
            'success': false,
            'message': 'El nombre de usuario ya existe'
          };
        }
        print('El usuario no existe, continuando con la creación...');
      } catch (e) {
        // Si falla la verificación, continuamos con el intento de registro
        print('Error al verificar si el usuario existe: $e');
      }

      print('Enviando solicitud para crear usuario...');
      print('Datos a enviar: ${_usuarioToJson(usuario)}');

      final response = await _dioClient.post(
        endpoint,
        data: _usuarioToJson(usuario),
      );

      print('Respuesta del servidor: ${response.statusCode}');

      if (response.statusCode == 201) {
        print('Usuario creado correctamente: ${usuario.usuario}');
        // Actualizar caché después de agregar un nuevo usuario
        await obtenerTodosUsuarios();
        return {'success': true, 'message': 'Usuario creado correctamente'};
      } else if (response.statusCode == 409) {
        print('Error: El usuario ya existe');
        // Verificar si el usuario realmente existe
        final usuarioBuscado = await buscarUsuarioPorNombre(usuario.usuario);
        if (usuarioBuscado == null) {
          print(
              'LOG_ADD_USER: Conflicto ignorado, usuario no existe realmente');
          await obtenerTodosUsuarios();
          return {'success': true, 'message': 'Usuario creado correctamente'};
        }
        return {'success': false, 'message': 'El nombre de usuario ya existe'};
      } else {
        print(
            'Error al agregar usuario: ${response.statusCode} - ${response.data}');
        return {
          'success': false,
          'message':
              'Error al registrar el usuario: Código ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Excepción al agregar usuario: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Actualizar usuario existente
  static Future<bool> actualizarUsuario(Usuario usuario, int id) async {
    try {
      print('Actualizando usuario con ID: $id');
      print('Datos a enviar: ${_usuarioToJson(usuario)}');

      final response = await _dioClient.put(
        '$endpoint/$id',
        data: _usuarioToJson(usuario),
      );

      if (response.statusCode == 200) {
        print('Usuario actualizado con éxito');
        // Actualizar el usuario en la caché
        int index = _usuariosCache.indexWhere((u) => u.id == usuario.id);
        if (index >= 0) {
          _usuariosCache[index] = usuario;
        } else {
          // Si no se encuentra en la caché, recargar todos
          await obtenerTodosUsuarios();
        }
        return true;
      } else if (response.statusCode == 409) {
        print('Error al actualizar usuario: Nombre de usuario ya existe');
        return false;
      } else {
        print('Error al actualizar usuario: Código ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error al actualizar usuario: $e');
      return false;
    }
  }

  // Eliminar usuario
  static Future<bool> eliminarUsuario(int id) async {
    try {
      final response = await _dioClient.delete('$endpoint/$id');
      return response.statusCode == 204;
    } catch (e) {
      print('Error al eliminar usuario: $e');
      return false;
    }
  }
}
