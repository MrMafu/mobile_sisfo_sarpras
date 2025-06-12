import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/user.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';
  
  final ApiService _apiService = ApiService();
  final SharedPreferences _prefs;

  AuthService(this._prefs, ApiService apiService);

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

        // Save token and user data
        await _prefs.setString(_tokenKey, token);
        await _prefs.setString(_userKey, json.encode(user.toJson()));
        
        // Set authorization header
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
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_userKey);
      _apiService.setAuthToken('');
    }
  }

  bool isLoggedIn() {
    return _prefs.containsKey(_tokenKey);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  User? getUser() {
    final userString = _prefs.getString(_userKey);
    return userString != null ? User.fromJson(json.decode(userString)) : null;
  }
}