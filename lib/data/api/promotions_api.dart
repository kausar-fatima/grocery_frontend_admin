import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/promotion.dart';
import 'api_helpers.dart';

/// Admin promotions management (`/promotions`).
class PromotionsApi {
  PromotionsApi(this._client);
  final DioClient _client;

  Future<List<Promotion>> getAll() async {
    try {
      final res = await _client.dio.get('/promotions');
      ensureOk(res);
      return (res.data as List)
          .whereType<Map<String, dynamic>>()
          .map(Promotion.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Promotion> create(Map<String, dynamic> body) async {
    try {
      final res = await _client.dio.post('/promotions', data: body);
      ensureOk(res);
      return Promotion.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Promotion> update(int id, Map<String, dynamic> body) async {
    try {
      final res = await _client.dio.patch('/promotions/$id', data: body);
      ensureOk(res);
      return Promotion.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> remove(int id) async {
    try {
      final res = await _client.dio.delete('/promotions/$id');
      ensureOk(res);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
