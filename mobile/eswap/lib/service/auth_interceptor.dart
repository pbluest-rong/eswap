import 'package:dio/dio.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/main.dart';
import 'package:eswap/presentation/views/login/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
  final dio = Dio();
  final prefs = await SharedPreferences.getInstance();
  dio.interceptors.add(AuthInterceptor(dio, prefs));
  */
class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SharedPreferences prefs;

  AuthInterceptor(this.dio, this.prefs);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await prefs.getString("refreshToken");
      try {
        final refreshResponse = await dio.post(ApiEndpoints.refresh_url, data: {
          'refreshToken': refreshToken,
        });
        final newAccessToken = refreshResponse.data['data']['accessToken'];
        // Save new accessToken
        await prefs.setString("accessToken", newAccessToken);
        // Resend api
        final cloneReq = err.requestOptions;
        cloneReq.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await dio.fetch(cloneReq);
        return handler.resolve(retryResponse);
      } catch (e) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginPage()),
              (Route<dynamic> route) => false,
        );
        return handler.reject(err);
      }
    }
    return handler.next(err);
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = prefs.getString("accessToken");
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }
}
