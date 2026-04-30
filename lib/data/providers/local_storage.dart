import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_model.dart';

class LocalStorage {
  LocalStorage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _keyToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUser = 'user';
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyOnboarded = 'onboarded';

  static Future<String?> get token => _storage.read(key: _keyToken);

  static Future<void> setToken(String? value) {
    if (value == null) return _storage.delete(key: _keyToken);
    return _storage.write(key: _keyToken, value: value);
  }

  static Future<String?> get refreshToken => _storage.read(key: _keyRefreshToken);

  static Future<void> setRefreshToken(String? value) {
    if (value == null) return _storage.delete(key: _keyRefreshToken);
    return _storage.write(key: _keyRefreshToken, value: value);
  }

  static Future<bool> get hasToken async {
    final value = await token;
    return value != null && value.isNotEmpty;
  }

  static Future<UserModel?> get user async {
    final value = await _storage.read(key: _keyUser);
    if (value == null || value.isEmpty) return null;
    return UserModel.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  static Future<void> setUser(UserModel? value) {
    if (value == null) return _storage.delete(key: _keyUser);
    return _storage.write(key: _keyUser, value: jsonEncode(value.toJson()));
  }

  static Future<bool> get isDarkMode async =>
      (await _storage.read(key: _keyDarkMode)) == 'true';

  static Future<void> setDarkMode(bool value) =>
      _storage.write(key: _keyDarkMode, value: value.toString());

  static Future<bool> get isOnboarded async =>
      (await _storage.read(key: _keyOnboarded)) == 'true';

  static Future<void> setOnboarded(bool value) =>
      _storage.write(key: _keyOnboarded, value: value.toString());

  static Future<void> clearAuth() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUser);
  }

  static Future<void> clear() => _storage.deleteAll();
}