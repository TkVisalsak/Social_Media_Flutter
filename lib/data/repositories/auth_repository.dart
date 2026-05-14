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

  Future<ApiResponse<void>> updatePersonalInfo({
    String? firstName,
    String? lastName,
    String? dob,
    String? gender,
    String? bio,
    String? phoneNumber,
  });

  Future<ApiResponse<UserModel>> uploadProfilePic(String filePath);

  Future<ApiResponse<void>> updatePrivacy({
    bool? followersListPublic,
    bool? followingListPublic,
    bool? savedPostsPublic,
  });
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
      final body = _normalizeBody(res.data);
      final token = _extractToken(body);
      final refreshToken = _extractRefreshToken(body);
      final user = _extractUser(body) ?? UserModel(id: '', email: email.trim());

      if (token == null || token.isEmpty) {
        return ApiResponse.failure('Invalid login response from server');
      }

      // Persist tokens & user locally
      await LocalStorage.setToken(token);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await LocalStorage.setRefreshToken(refreshToken);
      }
      await LocalStorage.setUser(user);

      return ApiResponse.success(user);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(_dioErrorMessage(e, fallback: 'Login failed'));
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
      final body = _normalizeBody(res.data);
      final token = _extractToken(body);
      final refreshToken = _extractRefreshToken(body);
      final user = _extractUser(body);

      if (user == null || token == null || token.isEmpty) {
        return ApiResponse.failure('Invalid registration response from server');
      }

      await LocalStorage.setToken(token);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await LocalStorage.setRefreshToken(refreshToken);
      }
      await LocalStorage.setUser(user);

      return ApiResponse.success(user);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(_dioErrorMessage(e, fallback: 'Registration failed'));
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
      return ApiResponse.failure(_dioErrorMessage(e, fallback: 'Request failed'));
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
      return ApiResponse.failure(_dioErrorMessage(e, fallback: 'Reset failed'));
    } catch (e) {
      return ApiResponse.failure('Unexpected error');
    }
  }

  // ── Current user ───────────────────────────

  @override
  Future<ApiResponse<UserModel>> me() async {
    try {
      final res = await _provider.me();
      final body = _normalizeBody(res.data);
      final userJson = body['user'];
      if (userJson is! Map<String, dynamic>) {
        return ApiResponse.failure('Invalid user response from server');
      }
      final user = UserModel.fromJson(userJson);

      // Keep local cache in sync
      await LocalStorage.setUser(user);

      return ApiResponse.success(user);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(_dioErrorMessage(e, fallback: 'Failed to fetch user'));
    } catch (e) {
      return ApiResponse.failure('Unexpected error');
    }
  }

  // ── Personal info (onboarding) ────────────

  @override
  Future<ApiResponse<void>> updatePersonalInfo({
    String? firstName,
    String? lastName,
    String? dob,
    String? gender,
    String? bio,
    String? phoneNumber,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (firstName != null) payload['firstName'] = firstName;
      if (lastName != null) payload['lastName'] = lastName;
      if (dob != null) payload['dob'] = dob;
      if (gender != null) payload['gender'] = gender;
      if (bio != null) payload['bio'] = bio;
      if (phoneNumber != null) payload['phoneNumber'] = phoneNumber;

      await _provider.personalInfo(payload);

      // Keep local cache fresh so callers can read the merged user.
      final cached = await LocalStorage.user;
      if (cached != null) {
        await LocalStorage.setUser(cached.copyWith(
          firstName: firstName ?? cached.firstName,
          lastName: lastName ?? cached.lastName,
          dob: dob ?? cached.dob,
          gender: gender ?? cached.gender,
          bio: bio ?? cached.bio,
        ));
      }
      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(_dioErrorMessage(e, fallback: 'Failed to save'));
    } catch (e) {
      return ApiResponse.failure('Unexpected error');
    }
  }

  // ── Profile pic upload ────────────────────

  @override
  Future<ApiResponse<UserModel>> uploadProfilePic(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'profilePic': await MultipartFile.fromFile(filePath),
      });
      final res = await _provider.updateProfilePic(formData);
      final body = _normalizeBody(res.data);
      final user = _extractUser(body);
      if (user == null) {
        return ApiResponse.failure('Invalid update-profile response');
      }
      await LocalStorage.setUser(user);
      return ApiResponse.success(user);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(_dioErrorMessage(e, fallback: 'Upload failed'));
    } catch (e) {
      return ApiResponse.failure('Unexpected error');
    }
  }

  // ── Privacy settings ──────────────────────

  @override
  Future<ApiResponse<void>> updatePrivacy({
    bool? followersListPublic,
    bool? followingListPublic,
    bool? savedPostsPublic,
  }) async {
    try {
      final payload = <String, bool>{};
      if (followersListPublic != null) payload['followersListPublic'] = followersListPublic;
      if (followingListPublic != null) payload['followingListPublic'] = followingListPublic;
      if (savedPostsPublic != null) payload['savedPostsPublic'] = savedPostsPublic;

      final res = await _provider.updatePrivacy(payload);

      // Update cached user with new privacy settings
      final cached = await LocalStorage.user;
      if (cached != null) {
        final body = _normalizeBody(res.data);
        final updatedUser = _extractUser(body);
        await LocalStorage.setUser(updatedUser ?? cached.copyWith(
          followersListPublic: followersListPublic ?? cached.followersListPublic,
          followingListPublic: followingListPublic ?? cached.followingListPublic,
          savedPostsPublic: savedPostsPublic ?? cached.savedPostsPublic,
        ));
      }

      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(_dioErrorMessage(e, fallback: 'Failed to update privacy'));
    } catch (e) {
      return ApiResponse.failure('Unexpected error');
    }
  }

  Map<String, dynamic> _normalizeBody(dynamic data) {
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) {
        return nested;
      }
      return data;
    }
    return const {};
  }

  String? _extractToken(Map<String, dynamic> body) {
    final direct = body['access_token'] ?? body['accessToken'] ?? body['token'];
    if (direct is String && direct.trim().isNotEmpty) return direct;

    final nestedAuth = body['auth'];
    if (nestedAuth is Map<String, dynamic>) {
      final nested = nestedAuth['access_token'] ??
          nestedAuth['accessToken'] ??
          nestedAuth['token'];
      if (nested is String && nested.trim().isNotEmpty) return nested;
    }
    return null;
  }

  String? _extractRefreshToken(Map<String, dynamic> body) {
    final direct = body['refresh_token'] ?? body['refreshToken'];
    if (direct is String && direct.trim().isNotEmpty) return direct;

    final nestedAuth = body['auth'];
    if (nestedAuth is Map<String, dynamic>) {
      final nested = nestedAuth['refresh_token'] ?? nestedAuth['refreshToken'];
      if (nested is String && nested.trim().isNotEmpty) return nested;
    }
    return null;
  }

  UserModel? _extractUser(Map<String, dynamic> body) {
    final direct = body['user'] ?? body['account'] ?? body['profile'];
    if (direct is Map<String, dynamic>) {
      return UserModel.fromJson(direct);
    }

    // Some APIs return the user object at top-level (with id/email fields).
    if (body.containsKey('id') || body.containsKey('_id') || body.containsKey('email')) {
      return UserModel.fromJson(body);
    }
    return null;
  }

  String _dioErrorMessage(DioException e, {required String fallback}) {
    final wrappedError = e.error;
    if (wrappedError is AppException) {
      return wrappedError.message;
    }

    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'] ?? responseData['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    final msg = e.message;
    if (msg != null && msg.trim().isNotEmpty) {
      return msg;
    }
    return fallback;
  }
}