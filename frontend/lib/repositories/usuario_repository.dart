import '../models/usuario.dart';

/// Interfaz que define las operaciones para el repositorio de usuarios
abstract class IUsuarioRepository {
  /// Valida las credenciales de un usuario
  Future<String?> validarCredenciales(String usuario, String contrasena);

  /// Busca un usuario por sus credenciales
  Future<Usuario?> buscarPorCredenciales(String usuario, String contrasena);

  /// Busca un usuario por su nombre
  Future<Usuario?> buscarPorNombre(String nombre);

  /// Obtiene todos los usuarios
  Future<List<Usuario>> obtenerTodos();

  /// Crea un nuevo usuario
  Future<Map<String, dynamic>> crear(Usuario usuario);

  /// Actualiza un usuario existente
  Future<bool> actualizar(Usuario usuario, int id);

  /// Elimina un usuario
  Future<bool> eliminar(int id);
}

/// Implementación del repositorio de usuarios que utiliza DIO para acceder a la API
class ApiUsuarioRepository implements IUsuarioRepository {
  final String endpoint;
  final _dioClient;

  // Caché local para usuarios
  List<Usuario> _usuariosCache = [];

  ApiUsuarioRepository(this._dioClient, {this.endpoint = '/users'});

  // Convertir User del backend a Usuario del frontend
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

  // Convertir Usuario del frontend a formato JSON para el backend
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
      print('Error al buscar usuario: $e');
      return null;
    }
  }

  @override
  Future<Usuario?> buscarPorNombre(String nombre) async {
    try {
      final processedNombre = nombre.trim().toLowerCase();
      print('LOG_BUSCAR: Iniciando búsqueda de usuario: $processedNombre');

      final response = await _dioClient.get(
        '$endpoint/buscar',
        queryParameters: {'nombre': processedNombre},
      );

      print('LOG_BUSCAR: Código de respuesta: ${response.statusCode}');

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = response.data;
        print('LOG_BUSCAR: Usuario encontrado: $processedNombre');
        return _mapearUsuario(userData);
      } else if (response.statusCode == 404) {
        print('LOG_BUSCAR: Usuario no encontrado por código 404');
        return null;
      } else {
        print(
            'LOG_BUSCAR: Código de respuesta no esperado: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('LOG_BUSCAR: Error capturado: ${e.toString()}');
      // Si el error es 404, significa que el usuario no existe
      if (e.toString().contains('404') ||
          e.toString().contains('not_found') ||
          e.toString().contains('DioException') &&
              e.toString().contains('404')) {
        print('LOG_BUSCAR: Exception 404 - Usuario no existe');
        return null;
      }
      // Para otros errores, los registramos pero retornamos null para mantener el flujo
      print('LOG_BUSCAR: Error general: ${e.toString()}');
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
      print('Error al obtener usuarios: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> crear(Usuario usuario) async {
    try {
      print('LOG_CREAR: Intentando crear usuario: ${usuario.usuario}');

      // Intentamos crear el usuario
      print('LOG_CREAR: Enviando solicitud de creación');

      final response = await _dioClient.post(
        endpoint,
        data: _usuarioToJson(usuario),
      );

      print('LOG_CREAR: Respuesta del servidor: ${response.statusCode}');

      if (response.statusCode == 201) {
        print('LOG_CREAR: Usuario creado correctamente: ${usuario.usuario}');
        await obtenerTodos(); // Actualizar caché
        return {'success': true, 'message': 'Usuario creado correctamente'};
      } else if (response.statusCode == 409) {
        print('LOG_CREAR: Error 409 - El usuario ya existe');
        // Verificar si el usuario realmente existe
        final usuarioBuscado = await buscarPorNombre(usuario.usuario);
        if (usuarioBuscado == null) {
          print('LOG_CREAR: Conflict ignorado, usuario no existe realmente');
          await obtenerTodos();
          return {'success': true, 'message': 'Usuario creado correctamente'};
        }
        return {'success': false, 'message': 'El nombre de usuario ya existe'};
      } else {
        print('LOG_CREAR: Error inesperado: ${response.statusCode}');
        return {
          'success': false,
          'message':
              'Error al registrar el usuario: Código ${response.statusCode}'
        };
      }
    } catch (e) {
      print('LOG_CREAR: Excepción: $e');

      // Manejar específicamente el error de conflicto (usuario ya existe)
      if (e.toString().contains('409') ||
          e.toString().contains('user_exists')) {
        print('LOG_CREAR: Error de conflicto - Usuario ya existe');
        return {'success': false, 'message': 'El nombre de usuario ya existe'};
      }

      return {'success': false, 'message': 'Error al crear usuario: $e'};
    }
  }

  @override
  Future<bool> actualizar(Usuario usuario, int id) async {
    try {
      print('LOG_ACTUALIZAR: Iniciando actualización de usuario ID: $id');

      // Preparar los datos para el envío
      Map<String, dynamic> datos = _usuarioToJson(usuario);

      // Verificar y procesar la imagen correctamente
      if (datos['imagen'] != null) {
        // Si la imagen es una cadena muy larga (probablemente base64), verificar que sea una URL de datos válida
        if (datos['imagen'].toString().length > 500 &&
            !datos['imagen'].toString().startsWith('data:image')) {
          print(
              'LOG_ACTUALIZAR: Formato de imagen inválido. Se procesa como base64.');
          // Convertir a formato de URL de datos si no tiene el prefijo
          datos['imagen'] = 'data:image/png;base64,' +
              datos['imagen']
                  .toString()
                  .replaceAll(RegExp(r'^data:image\/[^;]+;base64,'), '');
        }
      }

      print('LOG_ACTUALIZAR: Enviando solicitud PUT a $endpoint/$id');
      final response = await _dioClient.put(
        '$endpoint/$id',
        data: datos,
      );

      print('LOG_ACTUALIZAR: Respuesta recibida ${response.statusCode}');
      if (response.statusCode == 200) {
        print('LOG_ACTUALIZAR: Usuario actualizado correctamente');
        return true;
      } else {
        print(
            'LOG_ACTUALIZAR: Error al actualizar. Código: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('LOG_ACTUALIZAR: Excepción al actualizar usuario: $e');
      return false;
    }
  }

  @override
  Future<bool> eliminar(int id) async {
    try {
      final response = await _dioClient.delete('$endpoint/$id');
      return response.statusCode == 204;
    } catch (e) {
      print('Error al eliminar usuario: $e');
      return false;
    }
  }
}
