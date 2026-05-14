import 'package:dio/dio.dart';

import '../network/api_endpoint.dart';

class FollowProvider {
  const FollowProvider(this._dio);
  final Dio _dio;

  Future<Response<dynamic>> follow(String userId) =>
      _dio.post('${ApiEndpoints.follow}/$userId');

  Future<Response<dynamic>> unfollow(String userId) =>
      _dio.delete('${ApiEndpoints.unfollow}/$userId');

  Future<Response<dynamic>> isFollowing(String userId) =>
      _dio.get('${ApiEndpoints.followCheck}/$userId');

  Future<Response<dynamic>> followers(String userId) =>
      _dio.get('${ApiEndpoints.followers}/$userId');

  Future<Response<dynamic>> following(String userId) =>
      _dio.get('${ApiEndpoints.following}/$userId');

  Future<Response<dynamic>> notFollowingBack() =>
      _dio.get(ApiEndpoints.followNotFollowingBack);
}
