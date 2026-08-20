import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/admin_stats.dart';
import '../models/app_user.dart';
import '../models/order.dart';
import '../models/store.dart';
import 'api_helpers.dart';

class AdminApi {
  AdminApi(this._client);
  final DioClient _client;

  Future<AdminStats> stats() async {
    try {
      final res = await _client.dio.get('/admin/stats');
      ensureOk(res);
      return AdminStats.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<AppUser>> users({String? role}) async {
    try {
      final res = await _client.dio.get('/admin/users',
          queryParameters: role == null ? null : {'role': role});
      ensureOk(res);
      return (res.data as List)
          .whereType<Map<String, dynamic>>()
          .map(AppUser.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> setApproval(int id, bool approved) async {
    try {
      final res = await _client.dio
          .patch('/admin/users/$id/approve', data: {'approved': approved});
      ensureOk(res);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> setRole(int id, String role) async {
    try {
      final res =
          await _client.dio.patch('/admin/users/$id/role', data: {'role': role});
      ensureOk(res);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      final res = await _client.dio.delete('/admin/users/$id');
      ensureOk(res);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<Store>> stores() async {
    try {
      final res = await _client.dio.get('/admin/stores');
      ensureOk(res);
      return (res.data as List)
          .whereType<Map<String, dynamic>>()
          .map(Store.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<Order>> orders() async {
    try {
      final res = await _client.dio.get('/admin/orders');
      ensureOk(res);
      return (res.data as List)
          .whereType<Map<String, dynamic>>()
          .map(Order.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
