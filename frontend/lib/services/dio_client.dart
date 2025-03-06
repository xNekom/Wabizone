import 'package:dio/dio.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  final Dio _dio = Dio();

  static const String baseUrl = 'http://localhost:8081/api/v1';

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

    _setupInterceptors();
  }

  _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        Map<String, dynamic> safeParams = {};
        if (options.queryParameters.isNotEmpty) {
          safeParams = Map.from(options.queryParameters);
          if (safeParams.containsKey('contrasena')) {
            safeParams['contrasena'] = '********';
          }
          if (safeParams.containsKey('password')) {
            safeParams['password'] = '********';
          }
        }

        assert(() {
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          if (safeParams.isNotEmpty) {
            print('QUERY PARAMS: $safeParams');
          }

          if (options.data != null && options.data is Map) {
            Map<String, dynamic> safeData = Map.from(options.data);
            if (safeData.containsKey('contrasena')) {
              safeData['contrasena'] = '********';
            }
            if (safeData.containsKey('password')) {
              safeData['password'] = '********';
            }
            print('REQUEST DATA: $safeData');
          }
          return true;
        }());

        handler.next(options);
      },
      onResponse: (response, handler) {
        assert(() {
          print(
              'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          return true;
        }());

        handler.next(response);
      },
      onError: (DioException e, handler) {
        assert(() {
          print(
              'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
          print('ERROR MESSAGE: ${e.message}');
          return true;
        }());

        final statusCode = e.response?.statusCode;
        final path = e.requestOptions.path;

        if (statusCode == 403) {
          if (path.contains('/login') || path.contains('/users/login')) {
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

        return handler.next(e);
      },
    ));
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 &&
          path.contains('/buscar') &&
          queryParameters != null &&
          queryParameters.containsKey('nombre')) {
        return Response(
          statusCode: 404,
          requestOptions: e.requestOptions,
          statusMessage: 'Not Found',
        );
      }

      throw _handleError(e);
    }
  }

  Future<Response> post(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response =
          await _dio.post(path, data: data, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response =
          await _dio.put(path, data: data, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path,
          data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    String errorMessage = '';

    if (e.response?.statusCode == 404) {
      if ((e.requestOptions.path.contains('/buscar') ||
          e.requestOptions.method == 'GET' &&
              e.requestOptions.path.contains('/users/'))) {
        return Exception('not_found');
      }

      if (e.requestOptions.method == 'PUT' &&
          e.requestOptions.path.contains('/users/')) {
        return Exception('user_not_found');
      }

      if (e.requestOptions.path.contains('/products/')) {
        if (e.requestOptions.method == 'PUT') {
          return Exception('producto_no_encontrado');
        } else if (e.requestOptions.method == 'GET') {
          return Exception('producto_no_encontrado');
        } else if (e.requestOptions.method == 'DELETE') {
          return Exception('producto_no_encontrado');
        }
      }

      return Exception('resource_not_found');
    }

    if (e.response?.statusCode == 409 &&
        (e.requestOptions.method == 'POST' ||
            e.requestOptions.method == 'PUT') &&
        e.requestOptions.path.contains('/users')) {
      return Exception('user_exists');
    }

    if (e.response?.statusCode == 403 &&
        e.requestOptions.path.contains('/users')) {
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
