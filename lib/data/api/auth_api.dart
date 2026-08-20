import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/app_user.dart';
import 'api_helpers.dart';

class AuthResult {
  final String token;
  final AppUser user;
  const AuthResult({required this.token, required this.user});
}

class AuthApi {
  AuthApi(this._client);
  final DioClient _client;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      ensureOk(res);
      final data = res.data as Map<String, dynamic>;
      return AuthResult(
        token: data['access_token'] as String,
        user: AppUser.fromJson(data['user'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<AppUser> profile() async {
    try {
      final res = await _client.dio.get('/auth/profile');
      ensureOk(res);
      return AppUser.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
