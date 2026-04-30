import 'package:dio/dio.dart';

import '../models/user_model.dart';
import '../network/api_response.dart';
import '../network/exceptions/app_exception.dart';
import '../providers/auth_provider.dart';
import '../providers/local_storage.dart';

// ─────────────────────────────────────────────
// Abstract contract
// ─────────────────────────────────────────────

abstract class AuthRepository {
  Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  });

  Future<ApiResponse<UserModel>> register({
    required String email,
    required String password,
    required String username,
  });

  Future<ApiResponse<void>> logout();

  Future<ApiResponse<void>> forgotPassword({required String email});

  Future<ApiResponse<void>> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<ApiResponse<UserModel>> me();
}

// ─────────────────────────────────────────────
// Implementation
// ─────────────────────────────────────────────

class AuthRepositoryImpl implements AuthRepository {
  final AuthProvider _provider;

  const AuthRepositoryImpl(this._provider);

  // ── Login ──────────────────────────────────

  @override
  Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _provider.login(email: email, password: password);
      final user = UserModel.fromJson(res.data['user']);
      final token = res.data['access_token'] as String;
      final refreshToken = res.data['refresh_token'] as String?;

      // Persist tokens & user locally
      await LocalStorage.setToken(token);
      if (refreshToken != null) {
        await LocalStorage.setRefreshToken(refreshToken);
      }
      await LocalStorage.setUser(user);

      return ApiResponse.success(user);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(e.message ?? 'Login failed');
    } catch (e) {
      return ApiResponse.failure('Unexpected error during login');
    }
  }

  // ── Register ───────────────────────────────

  @override
  Future<ApiResponse<UserModel>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final res = await _provider.register(
        email: email,
        password: password,
        username: username,
      );
      final user = UserModel.fromJson(res.data['user']);
      final token = res.data['access_token'] as String;
      final refreshToken = res.data['refresh_token'] as String?;

      await LocalStorage.setToken(token);
      if (refreshToken != null) {
        await LocalStorage.setRefreshToken(refreshToken);
      }
      await LocalStorage.setUser(user);

      return ApiResponse.success(user);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(e.message ?? 'Registration failed');
    } catch (e) {
      return ApiResponse.failure('Unexpected error during registration');
    }
  }

  // ── Logout ─────────────────────────────────

  @override
  Future<ApiResponse<void>> logout() async {
    try {
      // Best-effort server call — clear local state regardless of outcome
      try {
        await _provider.logout();
      } catch (_) {}
      await LocalStorage.clear();
      return const ApiResponse.success(null);
    } catch (e) {
      // Still clear local state even if the server call fails
      await LocalStorage.clear();
      return const ApiResponse.success(null);
    }
  }

  // ── Forgot password ────────────────────────

  @override
  Future<ApiResponse<void>> forgotPassword({required String email}) async {
    try {
      await _provider.forgotPassword(email: email);
      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(e.message ?? 'Request failed');
    } catch (e) {
      return ApiResponse.failure('Unexpected error');
    }
  }

  // ── Reset password ─────────────────────────

  @override
  Future<ApiResponse<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _provider.resetPassword(token: token, newPassword: newPassword);
      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(e.message ?? 'Reset failed');
    } catch (e) {
      return ApiResponse.failure('Unexpected error');
    }
  }

  // ── Current user ───────────────────────────

  @override
  Future<ApiResponse<UserModel>> me() async {
    try {
      final res = await _provider.me();
      final user = UserModel.fromJson(res.data['user']);

      // Keep local cache in sync
      await LocalStorage.setUser(user);

      return ApiResponse.success(user);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(e.message ?? 'Failed to fetch user');
    } catch (e) {
      return ApiResponse.failure('Unexpected error');
    }
  }
}