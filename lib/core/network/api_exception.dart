import 'package:dio/dio.dart';

/// A user-friendly, typed error surfaced from the API layer.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;

  /// Translates a Dio failure into a readable message, preferring the
  /// backend's own error text (NestJS returns `{ "message": ... }`).
  factory ApiException.fromDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map && data['message'] != null) {
      final msg = data['message'];
      final text = msg is List ? msg.join('\n') : msg.toString();
      return ApiException(text, statusCode: status);
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiException(
          'The server took too long to respond. Please try again.',
          statusCode: status,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          'Could not reach the server. Make sure the backend is running.',
          statusCode: status,
        );
      default:
        return ApiException(
          e.message ?? 'Something went wrong. Please try again.',
          statusCode: status,
        );
    }
  }
}
