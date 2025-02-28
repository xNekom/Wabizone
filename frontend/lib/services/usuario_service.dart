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
        // Si falla la verificación, asumimos que el usuario no existe
        print('Error al verificar si el usuario existe: $e');
        // No interrumpimos el flujo, continuamos con el registro
      }

      print('Enviando solicitud para crear usuario...');

      // Preparar los datos para el envío
      Map<String, dynamic> datosUsuario = _usuarioToJson(usuario);

      // Verificar y procesar la imagen correctamente
      if (datosUsuario['imagen'] != null) {
        String imagen = datosUsuario['imagen'].toString();

        // Verificar si la imagen está vacía
        if (imagen.trim().isEmpty) {
          print('Imagen vacía, estableciendo a null');
          datosUsuario['imagen'] = null;
        }
        // Si la imagen es una cadena muy larga (probablemente base64)
        else if (imagen.length > 500) {
          print('Procesando imagen larga: ${imagen.length} caracteres');

          // Asegurar que la imagen tiene el prefijo correcto
          if (!imagen.startsWith('data:image')) {
            print('Añadiendo prefijo data:URL a la imagen');
            imagen = 'data:image/png;base64,' +
                imagen.replaceAll(RegExp(r'^data:image\/[^;]+;base64,'), '');
          }

          // Limitar longitud si es extremadamente grande (ejemplo: limitar a ~100KB)
          // Esto es una solución temporal - lo ideal sería comprimir la imagen real
          if (imagen.length > 100000) {
            print(
                '¡Alerta! Imagen demasiado grande (${imagen.length} caracteres), truncando');
            imagen = imagen.substring(0, 100000);
            print('Imagen truncada a ${imagen.length} caracteres');
          }

          datosUsuario['imagen'] = imagen;
        }
      }

      print(
          'Datos a enviar: ${datosUsuario['nombre']} (imagen: ${datosUsuario['imagen']?.length ?? 0} caracteres)');

      final response = await _dioClient.post(
        endpoint,
        data: datosUsuario,
      );

      print('Respuesta del servidor: ${response.statusCode}');

      if (response.statusCode == 201) {
        print('Usuario creado correctamente: ${usuario.usuario}');
        // Actualizar caché después de agregar un nuevo usuario
        await obtenerTodosUsuarios();
        return {'success': true, 'message': 'Usuario creado correctamente'};
      } else if (response.statusCode == 409) {
        print('Error: El usuario ya existe según el servidor');
        // Intentar verificar de nuevo
        try {
          final usuarioBuscado = await buscarUsuarioPorNombre(usuario.usuario);
          if (usuarioBuscado == null) {
            print(
                'Conflicto ignorado, usuario no existe realmente. Reintentando...');
            // Podríamos intentar de nuevo, pero por ahora reportamos un error
          }
        } catch (searchError) {
          print(
              'Error al verificar usuario después de conflicto: $searchError');
        }
        return {
          'success': false,
          'message': 'El nombre de usuario ya existe según el servidor'
        };
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
      if (id <= 0) {
        print('ERROR: ID de usuario inválido ($id). No se puede actualizar.');
        return false;
      }

      // Preparar los datos, asegurando que la imagen esté en formato correcto
      Map<String, dynamic> datosActualizados = _usuarioToJson(usuario);

      // Asegurarnos que la imagen es procesada correctamente
      if (datosActualizados['imagen'] != null) {
        String imagen = datosActualizados['imagen'].toString();

        // Verificar si está vacía
        if (imagen.trim().isEmpty) {
          print('La imagen estaba vacía, estableciendo a null');
          datosActualizados['imagen'] = null;
        }
        // Verificar si es una cadena muy larga (probablemente base64)
        else if (imagen.length > 500) {
          print(
              'Procesando imagen larga para actualización: ${imagen.length} caracteres');

          // Asegurar que tiene el prefijo correcto
          if (!imagen.startsWith('data:image')) {
            print('Añadiendo prefijo data:URL a la imagen');
            imagen = 'data:image/png;base64,' +
                imagen.replaceAll(RegExp(r'^data:image\/[^;]+;base64,'), '');
          }

          // Limitar longitud si es extremadamente grande
          if (imagen.length > 100000) {
            print(
                '¡Alerta! Imagen demasiado grande (${imagen.length} caracteres), truncando');
            imagen = imagen.substring(0, 100000);
            print('Imagen truncada a ${imagen.length} caracteres');
          }

          datosActualizados['imagen'] = imagen;
        }
      }

      print(
          'Datos a enviar: ${datosActualizados['nombre']} (imagen: ${datosActualizados['imagen']?.length ?? 0} caracteres)');

      // Construir URL completa para debugging
      final endpointCompleto = '$endpoint/$id';
      print('URL completa para actualización: $endpointCompleto');

      final response = await _dioClient.put(
        endpointCompleto,
        data: datosActualizados,
      );

      print('Respuesta del servidor: ${response.statusCode}');

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
