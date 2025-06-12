import 'package:flutter/material.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
final AuthService _authService;
  final ApiService _apiService;
  User? _user;

  AuthProvider({
    required AuthService authService,
    required ApiService apiService,
  }) : _authService = authService, _apiService = apiService;

  bool get isLoggedIn => _authService.isLoggedIn();
  User? get user => _user;

  Future<void> init() async {
    if (_authService.isLoggedIn()) {
      final token = _authService.getToken()!;
      _apiService.setAuthToken(token);
      _user = _authService.getUser();
    }
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final ok = await _authService.login(username, password);
    if (ok) {
      final token = _authService.getToken()!;
      _apiService.setAuthToken(token);
      _user = _authService.getUser();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _apiService.setAuthToken('');
    _user = null;
    notifyListeners();
  }
}