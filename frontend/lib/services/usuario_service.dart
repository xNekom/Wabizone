import '../models/usuario.dart';
import 'dio_client.dart';
import '../utils/image_utils.dart';

// Constantes para la gestión de imágenes
const int MAX_IMAGE_SIZE_BYTES =
    16 * 1024 * 1024; // 16MB (tamaño máximo de MEDIUMBLOB)

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
    print('Convirtiendo usuario a JSON: ${usuario.usuario}');

    // Verificar si la imagen es una URL de datos (base64)
    String imagen = usuario.imagen;

    if (imagen.isEmpty) {
      print('Imagen vacía, usando imagen por defecto');
      imagen = ImageUtils.getDefaultImage(usuario.esAdmin);
      print('Imagen por defecto asignada: $imagen');
    } else if (imagen.startsWith('data:image')) {
      // Calcular el tamaño aproximado de la imagen en base64
      int tamanoEstimado = imagen.length;
      print('Imagen en formato base64 detectada');
      print(
          'Tamaño de la imagen: ${(tamanoEstimado / 1024).toStringAsFixed(2)} KB');

      // Si la imagen es demasiado grande para la base de datos
      if (tamanoEstimado > MAX_IMAGE_SIZE_BYTES) {
        print(
            'Advertencia: La imagen es demasiado grande para la base de datos (${(tamanoEstimado / 1024).toStringAsFixed(2)} KB)');
        print('Usando imagen por defecto en su lugar');
        imagen = ImageUtils.getDefaultImage(usuario.esAdmin);
      }
    } else if (imagen.startsWith('assets/')) {
      print('Usando imagen de assets: $imagen');
    } else {
      print('Formato de imagen: $imagen');
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

    print('JSON generado para usuario: ${jsonData['nombre']}');
    return jsonData;
  }

  // Validar credenciales de usuario
  static Future<String?> validarUsuario(
      String usuario, String contrasena) async {
    try {
      print('LOG_VALIDAR: Validando usuario: $usuario');
      final response = await _dioClient.post(
        '$endpoint/login',
        queryParameters: {
          'nombre': usuario,
          'contrasena': contrasena,
        },
      );

      print('LOG_VALIDAR: Código de respuesta: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('LOG_VALIDAR: Autenticación exitosa');
        return null; // Autenticación exitosa
      } else if (response.statusCode == 403) {
        print('LOG_VALIDAR: Usuario bloqueado (403)');
        return "Has sido baneado, por favor contacta con un administrador";
      } else {
        print('LOG_VALIDAR: Credenciales incorrectas');
        return "Credenciales incorrectas";
      }
    } on Exception catch (e) {
      print('LOG_VALIDAR: Error capturado: $e');
      String errorMsg = e.toString().toLowerCase();

      if (errorMsg.contains('403') ||
          errorMsg.contains('forbidden') ||
          errorMsg.contains('bloqueado') ||
          errorMsg.contains('baneado') ||
          errorMsg.contains('usuario_bloqueado')) {
        print('LOG_VALIDAR: Error de usuario bloqueado detectado');
        return "Has sido baneado, por favor contacta con un administrador";
      } else if (errorMsg.contains('401') ||
          errorMsg.contains('unauthorized')) {
        print('LOG_VALIDAR: Error de credenciales incorrectas');
        return "Credenciales incorrectas";
      } else if (errorMsg.contains('timeout') ||
          errorMsg.contains('connection') ||
          errorMsg.contains('network')) {
        print('LOG_VALIDAR: Error de conexión');
        return "Error de conexión con el servidor. Inténtalo más tarde.";
      }

      print('LOG_VALIDAR: Error general: $e');
      return "Error de conexión con el servidor. Inténtalo más tarde.";
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

  // Buscar un usuario por su ID
  static Future<Usuario?> buscarUsuarioPorId(String id) async {
    try {
      print('LOG_SEARCH_ID: Buscando usuario con ID: $id');

      final response = await _dioClient.get('$endpoint/$id');

      print('LOG_SEARCH_ID: Código respuesta: ${response.statusCode}');

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = response.data;
        return _mapearUsuario(userData);
      } else {
        return null;
      }
    } catch (e) {
      print('LOG_SEARCH_ID: Error al buscar usuario por ID: $e');
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

  // Agregar usuario
  static Future<Map<String, dynamic>> agregarUsuario(Usuario usuario) async {
    try {
      print('Agregando nuevo usuario: ${usuario.usuario}');

      final jsonData = _usuarioToJson(usuario);
      print('Datos a enviar: $jsonData');

      // Verificar el tamaño de la imagen antes de enviarla
      if (jsonData['imagen'].toString().startsWith('data:image')) {
        int imageSize = jsonData['imagen'].toString().length;
        if (imageSize > MAX_IMAGE_SIZE_BYTES) {
          print(
              'ERROR: La imagen sigue siendo demasiado grande para la base de datos: ${(imageSize / 1024).toStringAsFixed(2)} KB');
          print(
              'Cambiando a imagen por defecto para evitar error de truncamiento');
          jsonData['imagen'] = ImageUtils.getDefaultImage(usuario.esAdmin);
        }
      }

      // Verificar si el usuario ya existe
      final existe = await buscarUsuarioPorNombre(usuario.usuario);
      if (existe != null) {
        print('Usuario ya existe: ${usuario.usuario}');
        return {'success': false, 'message': 'El nombre de usuario ya existe'};
      }

      final response = await _dioClient.post(
        endpoint,
        data: jsonData,
      );

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

      // Si el error es por truncamiento de datos, mostrar un mensaje más específico
      if (e.toString().contains('Data truncation') ||
          e.toString().contains('too long for column')) {
        print(
            'ERROR DE TRUNCAMIENTO: La imagen es demasiado grande para la base de datos');
        return {
          'success': false,
          'message':
              'La imagen seleccionada es demasiado grande. Por favor, seleccione una imagen más pequeña o use la imagen por defecto.'
        };
      }

      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Actualizar usuario existente
  static Future<bool> actualizarUsuario(Usuario usuario, int id) async {
    try {
      print('Actualizando usuario con ID: $id');

      // Verificar que el ID sea válido
      if (id <= 0) {
        print('Error: ID de usuario inválido ($id)');
        return false;
      }

      final jsonData = _usuarioToJson(usuario);
      print('Datos a enviar: $jsonData');

      // Verificar el tamaño de la imagen antes de enviarla
      if (jsonData['imagen'].toString().startsWith('data:image')) {
        int imageSize = jsonData['imagen'].toString().length;
        if (imageSize > MAX_IMAGE_SIZE_BYTES) {
          print(
              'ERROR: La imagen sigue siendo demasiado grande para la base de datos: ${(imageSize / 1024).toStringAsFixed(2)} KB');
          print(
              'Cambiando a imagen por defecto para evitar error de truncamiento');
          jsonData['imagen'] = ImageUtils.getDefaultImage(usuario.esAdmin);
        }
      }

      print('URL completa: ${DioClient.baseUrl}$endpoint/$id');

      // Verificar primero si el usuario existe
      try {
        final usuarioExistente = await buscarUsuarioPorId(id.toString());
        if (usuarioExistente == null) {
          print('Error: El usuario con ID $id no existe');
          return false;
        }
        print(
            'El usuario con ID $id existe, continuando con la actualización...');
      } catch (e) {
        print('Error al verificar si el usuario existe: $e');
        // Si el error es específicamente que el usuario no existe
        if (e.toString().contains('not_found') ||
            e.toString().contains('user_not_found') ||
            e.toString().contains('404')) {
          print('Error 404: Usuario con ID $id no encontrado');
          return false;
        }
        // Para otros tipos de errores
        return false;
      }

      final response = await _dioClient.put(
        '$endpoint/$id',
        data: jsonData,
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

      // Manejar errores de truncamiento de datos
      if (e.toString().contains('Data truncation') ||
          e.toString().contains('too long for column')) {
        print(
            'ERROR DE TRUNCAMIENTO: La imagen es demasiado grande para la base de datos');
        return false;
      }

      // Manejar específicamente errores 404 (usuario no encontrado)
      if (e.toString().contains('user_not_found') ||
          e.toString().contains('resource_not_found') ||
          e.toString().contains('404')) {
        print(
            'Error 404: No se pudo actualizar el usuario con ID $id porque no existe');
        return false;
      }

      // Manejar errores de conflicto (nombre de usuario duplicado)
      if (e.toString().contains('user_exists') ||
          e.toString().contains('409')) {
        print('Error 409: El nombre de usuario ya existe');
        return false;
      }

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
