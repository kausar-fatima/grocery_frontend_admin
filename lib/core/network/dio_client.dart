import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../storage/token_storage.dart';

/// Wraps a configured [Dio] instance with auth-token injection and light
/// request/response logging in debug mode.
class DioClient {
  DioClient(this._tokenStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        contentType: 'application/json',
        // Let us handle non-2xx ourselves via DioException mapping.
        validateStatus: (code) => code != null && code < 500,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _tokenStorage.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            debugPrint('→ ${options.method} ${options.uri}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('← ${response.statusCode} ${response.requestOptions.uri}');
          }
          handler.next(response);
        },
        onError: (e, handler) {
          if (kDebugMode) {
            debugPrint('✗ ${e.requestOptions.uri} → ${e.message}');
          }
          handler.next(e);
        },
      ),
    );
  }

  late final Dio dio;
  final TokenStorage _tokenStorage;
}
