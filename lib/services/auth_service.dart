import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/user.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';
  
  final SharedPreferences _prefs;
  final ApiService _apiService;

  AuthService(this._prefs, this._apiService);

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiService.post('/login', {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final token = data['token'];
        final user = User.fromJson(data['user']);

        await Future.wait([
          _prefs.setString(_tokenKey, token),
          _prefs.setString(_userKey, json.encode(user.toJson())),
        ]);
        
        _apiService.setAuthToken(token);
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server took too long to respond. Please try again.');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('Only user accounts can access the app');
      }
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/logout', {});
    } finally {
      await Future.wait([
        _prefs.remove(_tokenKey),
        _prefs.remove(_userKey),
      ]);
      _apiService.setAuthToken('');
    }
  }

  Future<void> refreshToken() async {
    final token = getToken();
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }

  bool isLoggedIn() => _prefs.containsKey(_tokenKey);
  String? getToken() => _prefs.getString(_tokenKey);
  User? getUser() => _prefs.getString(_userKey)?.let(
    (userString) => User.fromJson(json.decode(userString))
  );
}

extension _NullableStringExtension on String? {
  T? let<T>(T Function(String) block) => this != null ? block(this!) : null;
}