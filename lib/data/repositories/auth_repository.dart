import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/storage/local_storage.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../../config/app_config.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final LocalStorage _storage;

  AuthRepository(this._apiClient, this._storage);

  Future<LoginResponse> login(String email, String password) async {
    try {
      final request = LoginRequest(
        emailAddress: email,
        password: password,
      );

      final response = await _apiClient.dio.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      if (loginResponse.flag) {
        await _storage.saveToken(loginResponse);
        await _storage.saveString(AppConfig.keyUserName, email);
        await _storage.saveString(AppConfig.keyPassword, password);
      }

      return loginResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == null) {
        throw Exception('WMSに問題が発生してるため、WMSサーバに接続できません');
      }
      final data = e.response?.data;
      if (data != null) {
        return LoginResponse.fromJson(data);
      }
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<LoginResponse> loginByQR(String email, String password) async {
    try {
      final request = LoginRequest(
        emailAddress: email,
        password: password,
        remember: true,
      );

      final response = await _apiClient.dio.post(
        ApiEndpoints.loginByQR,
        data: request.toJson(),
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      if (loginResponse.flag) {
        await _storage.saveToken(loginResponse);
        await _storage.saveString(AppConfig.keyUserName, email);
        await _storage.saveString(AppConfig.keyPassword, password);
        await _storage.saveString(AppConfig.keyLoginType, 'QR');
      }

      return loginResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == null) {
        throw Exception('WMSに問題が発生してるため、WMSサーバに接続できません');
      }
      final data = e.response?.data;
      if (data != null) {
        return LoginResponse.fromJson(data);
      }
      throw Exception('QR Login failed: ${e.message}');
    } catch (e) {
      throw Exception('QR Login failed: $e');
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }

  Future<String?> getStoredToken() async {
    return await _storage.getToken();
  }

  Future<bool> hasStoredToken() async {
    final token = await getStoredToken();
    return token != null && token.isNotEmpty;
  }

  Future<LoginResponse?> refreshStoredToken() async {
    try {
      final userName = await _storage.getString(AppConfig.keyUserName);
      final password = await _storage.getString(AppConfig.keyPassword);
      final loginType = await _storage.getString(AppConfig.keyLoginType);

      if (userName == null || password == null) {
        return null;
      }

      if (loginType == 'QR') {
        return await loginByQR(userName, password);
      } else {
        return await login(userName, password);
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserName() async {
    return await _storage.getString(AppConfig.keyUserName);
  }
}

