import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Local Storage wrapper for SharedPreferences
/// Compatible with React Native AsyncStorage keys
class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  /// Save token data (same format as React Native)
  Future<void> saveToken(String token) async {
    await _prefs.setString('dataToken', token);
  }

  /// Get token
  Future<String?> getToken() async {
    return _prefs.getString('dataToken');
  }

  /// Get token data as JSON
  Future<Map<String, dynamic>?> getTokenData() async {
    final token = await getToken();
    if (token != null) {
      try {
        return jsonDecode(token) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Save string
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  /// Get string
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  /// Save JSON (list or map)
  Future<void> saveJson(String key, dynamic jsonData) async {
    final jsonString = jsonEncode(jsonData);
    await _prefs.setString(key, jsonString);
  }

  /// Get JSON
  Future<dynamic> getJson(String key) async {
    final jsonString = _prefs.getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Remove key
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  /// Clear all
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

