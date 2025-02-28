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
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('SOLICITUD [${options.method}] => PATH: ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print(
            'RESPUESTA [${response.statusCode}] => PATH: ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('ERROR [${e.response?.statusCode}] => ${e.message}');
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
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
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
    if (e.response?.statusCode == 404 &&
        (e.requestOptions.path.contains('/buscar') ||
            e.requestOptions.method == 'GET' &&
                e.requestOptions.path.contains('/users/'))) {
      print('LOG_404: Detectado error 404 en ${e.requestOptions.path}');
      print('LOG_404: Request method: ${e.requestOptions.method}');
      print('LOG_404: Query params: ${e.requestOptions.queryParameters}');
      print('LOG_404: Retornando not_found');

      // Devolvemos una excepción específica para 404
      return Exception('not_found');
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
