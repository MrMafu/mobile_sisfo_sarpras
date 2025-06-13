import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio() {
    _dio.options
      ..baseUrl = 'http://127.0.0.1:8000/api'
      ..connectTimeout = const Duration(seconds: 30)
      ..receiveTimeout = const Duration(seconds: 30)
      ..headers = {'Accept': 'application/json'};

    _dio.interceptors.addAll([
      InterceptorsWrapper(onError: (e, handler) => handler.next(e)),
      LogInterceptor(responseBody: true, error: true),
    ]);
  }

  void setAuthToken(String token) {
    token.isNotEmpty
      ? _dio.options.headers['Authorization'] = 'Bearer $token'
      : _dio.options.headers.remove('Authorization');
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? query}) =>
    _dio.get(endpoint, queryParameters: query);

  Future<Response> post(String endpoint, dynamic data) =>
    _dio.post(endpoint, data: data);
}