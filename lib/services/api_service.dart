import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    final baseUrl = 'http://127.0.0.1:8000/api';
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 120);
    _dio.options.headers['Accept'] = 'application/json';

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {}
          return handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(request: true, responseBody: true, error: true),
    );
  }

  // Set authentication token
  void setAuthToken(String token) {
    if (token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  // GET request
  Future<Response> get(String endpoint, {Map<String, dynamic>? query}) async {
    return await _dio.get(
      endpoint,
      queryParameters: query,
    );
  }

  // POST request
  Future<Response> post(String endpoint, dynamic data) async {
    return await _dio.post(
      endpoint,
      data: data,
      options: Options(contentType: Headers.jsonContentType),
    );
  }
}