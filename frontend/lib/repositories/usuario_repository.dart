import '../models/usuario.dart';

abstract class IUsuarioRepository {
  Future<String?> validarCredenciales(String usuario, String contrasena);
  Future<Usuario?> buscarPorCredenciales(String usuario, String contrasena);
  Future<Usuario?> buscarPorNombre(String nombre);
  Future<List<Usuario>> obtenerTodos();
  Future<Map<String, dynamic>> crear(Usuario usuario);
  Future<bool> actualizar(Usuario usuario, int id);
  Future<bool> eliminar(int id);
}

class ApiUsuarioRepository implements IUsuarioRepository {
  final String endpoint;
  final _dioClient;

  List<Usuario> _usuariosCache = [];

  ApiUsuarioRepository(this._dioClient, {this.endpoint = '/users'});

  Usuario _mapearUsuario(Map<String, dynamic> json) {
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

  Map<String, dynamic> _usuarioToJson(Usuario usuario) {
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

  @override
  Future<String?> validarCredenciales(String usuario, String contrasena) async {
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
      } else if (response.statusCode == 401) {
        return "Contraseña incorrecta. Por favor, verifica tus credenciales.";
      } else {
        return "Error de autenticación. Credenciales incorrectas.";
      }
    } catch (e) {
      String errorMsg = e.toString().toLowerCase();

      if (errorMsg.contains('403') ||
          errorMsg.contains('forbidden') ||
          errorMsg.contains('bloqueado') ||
          errorMsg.contains('baneado') ||
          errorMsg.contains('usuario_bloqueado')) {
        return "Has sido baneado, por favor contacta con un administrador";
      } else if (errorMsg.contains('404') || errorMsg.contains('not_found')) {
        return "El usuario no existe. Por favor, verifica tu nombre de usuario.";
      } else if (errorMsg.contains('401') ||
          errorMsg.contains('unauthorized')) {
        return "Contraseña incorrecta. Por favor, verifica tus credenciales.";
      }

      return "Error de conexión con el servidor: ${e.toString().replaceAll('Exception: ', '')}";
    }
  }

  @override
  Future<Usuario?> buscarPorCredenciales(
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
        return _mapearUsuario(userData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Usuario?> buscarPorNombre(String nombre) async {
    try {
      final processedNombre = nombre.trim().toLowerCase();

      final response = await _dioClient.get(
        '$endpoint/buscar',
        queryParameters: {'nombre': processedNombre},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = response.data;
        return _mapearUsuario(userData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Usuario>> obtenerTodos() async {
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

  @override
  Future<Map<String, dynamic>> crear(Usuario usuario) async {
    try {
      final response = await _dioClient.post(
        endpoint,
        data: _usuarioToJson(usuario),
      );

      if (response.statusCode == 201) {
        await obtenerTodos();
        return {'success': true, 'message': 'Usuario creado correctamente'};
      } else if (response.statusCode == 409) {
        final usuarioBuscado = await buscarPorNombre(usuario.usuario);
        if (usuarioBuscado == null) {
          await obtenerTodos();
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
      if (e.toString().contains('409') ||
          e.toString().contains('user_exists')) {
        return {'success': false, 'message': 'El nombre de usuario ya existe'};
      }

      return {'success': false, 'message': 'Error al crear usuario: $e'};
    }
  }

  @override
  Future<bool> actualizar(Usuario usuario, int id) async {
    try {
      final response = await _dioClient.put(
        '$endpoint/$id',
        data: _usuarioToJson(usuario),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> eliminar(int id) async {
    try {
      final response = await _dioClient.delete('$endpoint/$id');
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
