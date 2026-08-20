import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';

/// DioClient lets any status < 500 through so we can read NestJS error bodies.
/// Funnel responses here to surface 4xx `{ message }` as an [ApiException].
void ensureOk(Response res) {
  final code = res.statusCode ?? 0;
  if (code < 400) return;
  final data = res.data;
  final msg = (data is Map && data['message'] != null)
      ? (data['message'] is List
          ? (data['message'] as List).join('\n')
          : data['message'].toString())
      : 'Request failed ($code).';
  throw ApiException(msg, statusCode: code);
}
