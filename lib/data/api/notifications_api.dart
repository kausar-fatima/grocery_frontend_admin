import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/notification.dart';
import 'api_helpers.dart';

class NotificationsApi {
  NotificationsApi(this._client);
  final DioClient _client;

  Future<List<AppNotification>> getAll() async {
    try {
      final res = await _client.dio.get('/notifications');
      ensureOk(res);
      return (res.data as List)
          .whereType<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<int> unread() async {
    try {
      final res = await _client.dio.get('/notifications/unread');
      ensureOk(res);
      final data = res.data as Map<String, dynamic>;
      return data['unread'] is int
          ? data['unread']
          : int.tryParse('${data['unread']}') ?? 0;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> markRead(int id) async {
    try {
      final res = await _client.dio.patch('/notifications/$id/read');
      ensureOk(res);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> markAllRead() async {
    try {
      final res = await _client.dio.patch('/notifications/read-all');
      ensureOk(res);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
