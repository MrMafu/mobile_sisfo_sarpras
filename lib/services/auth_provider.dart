import 'package:flutter/material.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  User? _user;

  AuthProvider({required AuthService authService}) : _authService = authService;

  bool get isLoggedIn => _user != null;
  User? get user => _user;

  Future<void> init() async {
    if (_authService.isLoggedIn()) {
      _user = _authService.getUser();
    }
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final ok = await _authService.login(username, password);
    if (ok) {
      _user = _authService.getUser();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}