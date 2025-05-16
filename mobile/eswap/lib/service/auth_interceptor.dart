import 'package:dio/dio.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/main.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:eswap/presentation/views/login/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final userSession = await UserSession.load();
      try {
        final refreshResponse = await dio.post(ApiEndpoints.refresh_url, data: {
          'refreshToken': userSession!.refreshToken,
        });
        final newAccessToken = refreshResponse.data['data']['accessToken'];
        // Save new accessToken
        userSession.accessToken = newAccessToken;
        await userSession.save();
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
    final userSession = await UserSession.load();
    options.headers['Authorization'] = 'Bearer ${userSession!.accessToken}';
    return handler.next(options);
  }
}
