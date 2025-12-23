import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// API Client configuration
/// Base URL: http://133.167.47.242:9500 (same as React Native)
class ApiClient {
  late Dio dio;
  
  // Base URL - same as React Native
  static const String baseUrl = 'http://133.167.47.242:9500';
  
  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptors
    dio.interceptors.add(_AuthInterceptor());
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }
}

/// Interceptor for authentication
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Get token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final tokenData = prefs.getString('dataToken');
    
    if (tokenData != null) {
      try {
        final tokenJson = tokenData; // Already a JSON string
        // Parse to get token
        final token = _extractToken(tokenJson);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        print('Error parsing token: $e');
      }
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('userName');
      final password = prefs.getString('passWord');
      
      if (userName != null && password != null) {
        try {
          // Refresh token logic here
          // For now, just retry with new token
          final newToken = await _refreshToken(userName, password);
          if (newToken != null) {
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final response = await ApiClient().dio.fetch(err.requestOptions);
            handler.resolve(response);
            return;
          }
        } catch (e) {
          print('Error refreshing token: $e');
        }
      }
    }
    
    handler.next(err);
  }

  String? _extractToken(String tokenData) {
    try {
      // Token is stored as JSON string: {"token": "...", "refreshToken": "...", ...}
      if (tokenData.startsWith('{')) {
        final tokenJson = jsonDecode(tokenData) as Map<String, dynamic>;
        return tokenJson['token'] as String?;
      }
      // If it's just a token string, return as is
      return tokenData;
    } catch (e) {
      print('Error extracting token: $e');
      return null;
    }
  }

  Future<String?> _refreshToken(String userName, String password) async {
    // Implement token refresh logic
    // This should call the refresh token API
    return null;
  }
}

