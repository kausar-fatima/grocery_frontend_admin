import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/review.dart';
import 'api_helpers.dart';

class ReviewsApi {
  ReviewsApi(this._client);
  final DioClient _client;

  Future<List<Review>> getAll() async {
    try {
      final res = await _client.dio.get('/reviews');
      ensureOk(res);
      return (res.data as List)
          .whereType<Map<String, dynamic>>()
          .map(Review.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      final res = await _client.dio.delete('/reviews/$id');
      ensureOk(res);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
