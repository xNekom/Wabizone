import 'package:dio/dio.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  final Dio _dio = Dio();

  // URL base de la API
  static const String baseUrl = 'http://localhost:8081/api/v1';

  // Tiempo de espera para las solicitudes (en milisegundos)
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(milliseconds: connectTimeout);
    _dio.options.receiveTimeout = Duration(milliseconds: receiveTimeout);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Interceptores para manejo de errores y logging
    _setupInterceptors();
  }

  // Interceptor para manejar errores de respuesta
  _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('SOLICITUD [${options.method}] => PATH: ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print(
            'RESPUESTA [${response.statusCode}] => PATH: ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (DioException e, handler) {
        print(
            'ERROR [${e.response?.statusCode}] => This exception was thrown because ${e.message}');

        // Imprimir información detallada para depuración
        print('StatusCode: ${e.response?.statusCode}');
        print('Request path: ${e.requestOptions.path}');
        print('Request method: ${e.requestOptions.method}');

        // Añadir manejo específico para errores comunes
        final statusCode = e.response?.statusCode;
        final path = e.requestOptions.path;

        if (statusCode == 403) {
          print('Manejando 403 - Usuario bloqueado o sin permisos: $path');
          // Podemos modificar el error para hacerlo más específico
          final responseData = e.response?.data;
          if (path.contains('/login') || path.contains('/users/login')) {
            // Es un intento de login, así que probablemente es un usuario bloqueado
            final customError = DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: DioExceptionType.badResponse,
              message:
                  'Has sido baneado, por favor contacta con un administrador',
            );
            return handler.reject(customError);
          }
        }

        // Pasar el error original si no lo manejamos específicamente
        return handler.next(e);
      },
    ));
  }

  // Método para GET
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      print('DIO_GET: Enviando GET a $path con params: $queryParameters');
      final response = await _dio.get(path, queryParameters: queryParameters);
      print('DIO_GET: Respuesta recibida con código: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('DIO_GET: Error capturado: ${e.type} - ${e.message}');

      // Para llamadas específicas a buscar usuario, manejamos 404 sin lanzar excepción
      if (e.response?.statusCode == 404 &&
          path.contains('/buscar') &&
          queryParameters != null &&
          queryParameters.containsKey('nombre')) {
        print('DIO_GET: Retornando 404 normal para buscarPorNombre');
        return Response(
          statusCode: 404,
          requestOptions: e.requestOptions,
          statusMessage: 'Not Found',
        );
      }

      throw _handleError(e);
    }
  }

  // Método para POST
  Future<Response> post(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      print('DIO_POST: Enviando POST a $path');
      if (data != null) {
        print('DIO_POST: Datos: $data');
      }

      final response =
          await _dio.post(path, data: data, queryParameters: queryParameters);
      print('DIO_POST: Respuesta recibida con código: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('DIO_POST: Error capturado: ${e.type} - ${e.message}');
      throw _handleError(e);
    }
  }

  // Método para PUT
  Future<Response> put(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      print('DIO_PUT: Enviando PUT a $path');
      if (data != null) {
        print('DIO_PUT: Datos: $data');
      }

      final response =
          await _dio.put(path, data: data, queryParameters: queryParameters);
      print('DIO_PUT: Respuesta recibida con código: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('DIO_PUT: Error capturado: ${e.type} - ${e.message}');
      print('DIO_PUT: StatusCode: ${e.response?.statusCode}');
      print('DIO_PUT: Response data: ${e.response?.data}');

      // Información detallada para errores 404 en PUT
      if (e.response?.statusCode == 404) {
        print(
            'DIO_PUT: Error 404 - Recurso no encontrado en: ${e.requestOptions.path}');
        print(
            'DIO_PUT: Esto puede indicar que el ID no existe en la base de datos');
        print('DIO_PUT: Datos enviados: ${e.requestOptions.data}');
      }

      throw _handleError(e);
    }
  }

  // Método para DELETE
  Future<Response> delete(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path,
          data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Manejo de errores
  Exception _handleError(DioException e) {
    String errorMessage = '';
    print('DioException: ${e.type} - ${e.message}');
    print('StatusCode: ${e.response?.statusCode}');

    // Proporcionar más información sobre la solicitud
    print('Request path: ${e.requestOptions.path}');
    print('Request method: ${e.requestOptions.method}');
    if (e.requestOptions.data != null) {
      print('Request data: ${e.requestOptions.data}');
    }

    // Manejar respuestas 404 para búsqueda de usuarios
    if (e.response?.statusCode == 404) {
      print('LOG_404: Detectado error 404 en ${e.requestOptions.path}');
      print('LOG_404: Request method: ${e.requestOptions.method}');
      print('LOG_404: Query params: ${e.requestOptions.queryParameters}');

      // Para búsquedas de usuarios
      if ((e.requestOptions.path.contains('/buscar') ||
          e.requestOptions.method == 'GET' &&
              e.requestOptions.path.contains('/users/'))) {
        print('LOG_404: Retornando not_found para búsqueda de usuario');
        return Exception('not_found');
      }

      // Para actualizaciones de usuarios
      if (e.requestOptions.method == 'PUT' &&
          e.requestOptions.path.contains('/users/')) {
        print('LOG_404: Error en actualización de usuario - ID no encontrado');
        return Exception('user_not_found');
      }

      // Para operaciones con productos
      if (e.requestOptions.path.contains('/products/')) {
        if (e.requestOptions.method == 'PUT') {
          print(
              'LOG_404: Error en actualización de producto - ID no encontrado: ${e.requestOptions.path}');
          return Exception('producto_no_encontrado');
        } else if (e.requestOptions.method == 'GET') {
          print(
              'LOG_404: Error en búsqueda de producto - ID no encontrado: ${e.requestOptions.path}');
          return Exception('producto_no_encontrado');
        } else if (e.requestOptions.method == 'DELETE') {
          print(
              'LOG_404: Error en eliminación de producto - ID no encontrado: ${e.requestOptions.path}');
          return Exception('producto_no_encontrado');
        }
      }

      // Para otros casos de 404
      return Exception('resource_not_found');
    }

    // Manejar respuestas 409 para creación/actualización de usuarios
    if (e.response?.statusCode == 409 &&
        (e.requestOptions.method == 'POST' ||
            e.requestOptions.method == 'PUT') &&
        e.requestOptions.path.contains('/users')) {
      print(
          'Manejando 409 como "usuario ya existe" para: ${e.requestOptions.path}');
      return Exception('user_exists');
    }

    // Manejar respuestas 403 para usuarios bloqueados
    if (e.response?.statusCode == 403 &&
        e.requestOptions.path.contains('/users')) {
      print(
          'Manejando 403 - Usuario bloqueado o sin permisos: ${e.requestOptions.path}');

      // Verificar si el mensaje indica que es un usuario bloqueado
      final responseData = e.response?.data;
      if (responseData != null &&
          responseData is Map &&
          responseData['message'] != null &&
          responseData['message']
              .toString()
              .toLowerCase()
              .contains('bloqueado')) {
        return Exception(
            'Has sido baneado, por favor contacta con un administrador');
      }

      // Si llegamos aquí, es un error 403 genérico relacionado con usuarios
      return Exception(
          'Has sido baneado, por favor contacta con un administrador');
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Tiempo de conexión agotado';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Tiempo de envío agotado';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Tiempo de recepción agotado';
        break;
      case DioExceptionType.badResponse:
        // Extraer mensaje del cuerpo de la respuesta si existe
        if (e.response?.data != null && e.response?.data is Map) {
          final data = e.response?.data as Map;
          if (data.containsKey('message')) {
            errorMessage = 'Error: ${data['message']}';
          } else {
            errorMessage = 'Respuesta incorrecta: ${e.response?.statusCode}';
          }
        } else {
          errorMessage = 'Respuesta incorrecta: ${e.response?.statusCode}';
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Solicitud cancelada';
        break;
      default:
        errorMessage = 'Error de conexión';
        break;
    }
    return Exception(errorMessage);
  }
}
