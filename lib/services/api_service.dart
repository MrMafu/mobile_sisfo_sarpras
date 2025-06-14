import 'package:dio/dio.dart';
import 'package:mobile_sisfo_sarpras/constants/app_constants.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    _dio.options
      ..baseUrl = 'http://127.0.0.1:8000/api'
      ..connectTimeout = AppConstants.apiTimeout
      ..receiveTimeout = AppConstants.apiTimeout
      ..headers = {'Accept': 'application/json'};

    _dio.interceptors.addAll([
      InterceptorsWrapper(onError: (error, handler) => handler.next(error)),
      LogInterceptor(responseBody: true, error: true),
    ]);
  }

  void setAuthToken(String token) {
    token.isNotEmpty
      ? _dio.options.headers['Authorization'] = 'Bearer $token'
      : _dio.options.headers.remove('Authorization');
  }

  void refreshToken(String newToken) {
    setAuthToken(newToken);
  }

  Future<Response> get(
    String endpoint, {
      Map<String, dynamic>? query,
      CancelToken? cancelToken
    }
  ) async {
    return await _dio.get(
      endpoint,
      queryParameters: query,
      cancelToken: cancelToken
    );
  }

  Future<Response> post(String endpoint, dynamic data) => _dio.post(
    endpoint,
    data: data,
    options: Options(contentType: Headers.jsonContentType),
  );
}