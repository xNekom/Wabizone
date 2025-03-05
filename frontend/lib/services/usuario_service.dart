import '../models/usuario.dart';
import 'dio_client.dart';
import '../utils/image_utils.dart';

const int MAX_IMAGE_SIZE_BYTES = 16 * 1024 * 1024;

class UsuarioService {
  static const String endpoint = '/users';
  static final DioClient _dioClient = DioClient();
  static List<Usuario> _usuariosCache = [];
  static List<Usuario> get usuarios => _usuariosCache;

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

  static Map<String, dynamic> _usuarioToJson(Usuario usuario) {
    String imagen = usuario.imagen;

    if (imagen.isEmpty) {
      imagen = ImageUtils.getDefaultImage(usuario.esAdmin);
    } else if (imagen.startsWith('data:image')) {
      int tamanoEstimado = imagen.length;

      if (tamanoEstimado > MAX_IMAGE_SIZE_BYTES) {
        imagen = ImageUtils.getDefaultImage(usuario.esAdmin);
      }
    }

    final jsonData = {
      'nombre': usuario.usuario.trim().toLowerCase(),
      'contrasena': usuario.contrasena,
      'edad': usuario.edad,
      'administrador': usuario.esAdmin || false,
      'trato': usuario.trato,
      'imagen': imagen,
      'lugarNacimiento': usuario.lugarNacimiento,
      'bloqueado': usuario.bloqueado || false,
    };

    return jsonData;
  }

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
        return null;
      } else if (response.statusCode == 403) {
        return "Has sido baneado, por favor contacta con un administrador";
      } else {
        return "Credenciales incorrectas";
      }
    } on Exception catch (e) {
      String errorMsg = e.toString().toLowerCase();

      if (errorMsg.contains('403') ||
          errorMsg.contains('forbidden') ||
          errorMsg.contains('bloqueado') ||
          errorMsg.contains('baneado') ||
          errorMsg.contains('usuario_bloqueado')) {
        return "Has sido baneado, por favor contacta con un administrador";
      } else if (errorMsg.contains('401') ||
          errorMsg.contains('unauthorized')) {
        return "Credenciales incorrectas";
      } else if (errorMsg.contains('timeout') ||
          errorMsg.contains('connection') ||
          errorMsg.contains('network')) {
        return "Error de conexión con el servidor. Inténtalo más tarde.";
      }

      return "Error de conexión con el servidor. Inténtalo más tarde.";
    }
  }

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
      return null;
    }
  }

  static Future<Usuario?> buscarUsuarioPorNombre(String nombre) async {
    try {
      final processedNombre = nombre.trim().toLowerCase();

      final response = await _dioClient.get(
        '$endpoint/buscar',
        queryParameters: {'nombre': processedNombre},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = response.data;
        return _mapearUsuario(userData);
      } else {
        return null;
      }
    } catch (e) {
      if (e.toString().contains('404') || e.toString().contains('not_found')) {
        return null;
      }
      throw Exception('Error al buscar usuario: $e');
    }
  }

  static Future<Usuario?> buscarUsuarioPorId(String id) async {
    try {
      final response = await _dioClient.get('$endpoint/$id');

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = response.data;
        return _mapearUsuario(userData);
      } else {
        return null;
      }
    } catch (e) {
      if (e.toString().contains('404') || e.toString().contains('not_found')) {
        return null;
      }
      throw Exception('Error al buscar usuario: $e');
    }
  }

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
      return [];
    }
  }

  static Future<Map<String, dynamic>> agregarUsuario(Usuario usuario) async {
    try {
      final jsonData = _usuarioToJson(usuario);

      if (jsonData['imagen'].toString().startsWith('data:image')) {
        int imageSize = jsonData['imagen'].toString().length;
        if (imageSize > MAX_IMAGE_SIZE_BYTES) {
          jsonData['imagen'] = ImageUtils.getDefaultImage(usuario.esAdmin);
        }
      }

      final existe = await buscarUsuarioPorNombre(usuario.usuario);
      if (existe != null) {
        return {'success': false, 'message': 'El nombre de usuario ya existe'};
      }

      final response = await _dioClient.post(
        endpoint,
        data: jsonData,
      );

      if (response.statusCode == 201) {
        await obtenerTodosUsuarios();
        return {'success': true, 'message': 'Usuario creado correctamente'};
      } else if (response.statusCode == 409) {
        final usuarioBuscado = await buscarUsuarioPorNombre(usuario.usuario);
        if (usuarioBuscado == null) {
          await obtenerTodosUsuarios();
          return {'success': true, 'message': 'Usuario creado correctamente'};
        }
        return {'success': false, 'message': 'El nombre de usuario ya existe'};
      } else {
        return {
          'success': false,
          'message':
              'Error al registrar el usuario: Código ${response.statusCode}'
        };
      }
    } catch (e) {
      if (e.toString().contains('Data truncation') ||
          e.toString().contains('too long for column')) {
        return {
          'success': false,
          'message':
              'La imagen seleccionada es demasiado grande. Por favor, seleccione una imagen más pequeña o use la imagen por defecto.'
        };
      }

      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<bool> actualizarUsuario(Usuario usuario, int id) async {
    try {
      if (id <= 0) {
        return false;
      }

      final jsonData = _usuarioToJson(usuario);

      if (jsonData['imagen'].toString().startsWith('data:image')) {
        int imageSize = jsonData['imagen'].toString().length;
        if (imageSize > MAX_IMAGE_SIZE_BYTES) {
          jsonData['imagen'] = ImageUtils.getDefaultImage(usuario.esAdmin);
        }
      }

      try {
        final usuarioExistente = await buscarUsuarioPorId(id.toString());
        if (usuarioExistente == null) {
          return false;
        }
      } catch (e) {
        if (e.toString().contains('not_found') ||
            e.toString().contains('user_not_found') ||
            e.toString().contains('404')) {
          return false;
        }
        return false;
      }

      final response = await _dioClient.put(
        '$endpoint/$id',
        data: jsonData,
      );

      if (response.statusCode == 200) {
        int index = _usuariosCache.indexWhere((u) => u.id == usuario.id);
        if (index >= 0) {
          _usuariosCache[index] = usuario;
        } else {
          await obtenerTodosUsuarios();
        }
        return true;
      } else if (response.statusCode == 409) {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      if (e.toString().contains('Data truncation') ||
          e.toString().contains('too long for column')) {
        return false;
      }

      if (e.toString().contains('user_not_found') ||
          e.toString().contains('resource_not_found') ||
          e.toString().contains('404')) {
        return false;
      }

      if (e.toString().contains('user_exists') ||
          e.toString().contains('409')) {
        return false;
      }

      return false;
    }
  }

  static Future<bool> eliminarUsuario(int id) async {
    try {
      final response = await _dioClient.delete('$endpoint/$id');
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
