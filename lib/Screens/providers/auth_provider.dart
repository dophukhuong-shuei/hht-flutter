import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/auth/login_response.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider(this._authRepository);

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _userName;
  LoginResponse? _currentUser;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get userName => _userName;
  LoginResponse? get currentUser => _currentUser;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasToken = await _authRepository.hasStoredToken();
      if (hasToken) {
        // Try to refresh token
        final refreshed = await _authRepository.refreshStoredToken();
        if (refreshed != null && refreshed.flag) {
          _isAuthenticated = true;
          _currentUser = refreshed;
          _userName = await _authRepository.getUserName();
        } else {
          _isAuthenticated = false;
        }
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authRepository.login(email, password);

      if (response.flag) {
        _isAuthenticated = true;
        _currentUser = response;
        _userName = email;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> loginByQR(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authRepository.loginByQR(email, password);

      if (response.flag) {
        _isAuthenticated = true;
        _currentUser = response;
        _userName = email;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear stored token and all related data
      await _authRepository.logout();
    } catch (_) {
      // Ignore storage errors on logout – we still want to force local state to logged-out
    } finally {
      _isAuthenticated = false;
      _currentUser = null;
      _userName = null;
      _isLoading = false;
      notifyListeners();
    }
  }
}

