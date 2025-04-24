import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/model/enum_model.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/core/onboarding/onboarding_page_position.dart';
import 'package:eswap/model/page_response.dart';
import 'package:eswap/model/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final dio = Dio();

  Future<PageResponse<UserInfomation>> fetchSearchUser(
      String keyword, int page, int size, BuildContext context) async
  {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      final response = await dio.get(ApiEndpoints.search_url,
          queryParameters: {'page': page, 'size': size, 'keyword': keyword},
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer $accessToken",
          }));

      if (response.statusCode == 200) {
        if (response.data['data'] != null) {
          final responseData = response.data['data'];
          final pageResponse = PageResponse<UserInfomation>.fromJson(
              responseData, (json) => UserInfomation.fromJson(json));
          return pageResponse;
        } else {
          throw Exception("no_result_found".tr());
        }
      } else {
        showErrorDialog(context, response.data['message']);
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        showErrorDialog(
            context, e.response?.data["message"] ?? "general_error".tr());
        throw Exception(e.response?.data["message"] ?? "general_error".tr());
      } else {
        showErrorDialog(context, "network_error".tr());
        throw Exception("network_error".tr());
      }
    } catch (e) {
      showErrorDialog(context, "general_error".tr());
      throw Exception("general_error".tr());
    }
  }

  Future<FollowStatus?> follow(int followeeUserId, BuildContext context) async
  {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.get("accessToken");
      final response = await dio
          .post(
            "${ApiEndpoints.follow_url}/$followeeUserId",
            options: Options(
              headers: {
                "Content-Type": "application/json",
                "Accept-Language": context.locale.languageCode,
                "Authorization": "Bearer $accessToken"
              },
            ),
          )
          .catchError((error) => print("follow error"));

      return FollowStatus.fromString(response.data['data']['status']);
    } on DioException catch (e) {
      if (e.response != null) {
        showErrorDialog(
            context, e.response?.data["message"] ?? "general_error".tr());
      } else {
        showErrorDialog(context, "network_error".tr());
      }
    }
    return null;
  }
  Future<void> unfollow(int followeeUserId, BuildContext context) async
  {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.get("accessToken");
      final response = await dio
          .post(
        "${ApiEndpoints.unfollow_url}/$followeeUserId",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept-Language": context.locale.languageCode,
            "Authorization": "Bearer $accessToken"
          },
        ),
      )
          .catchError((error) => print("follow error"));
    } on DioException catch (e) {
      if (e.response != null) {
        showErrorDialog(
            context, e.response?.data["message"] ?? "general_error".tr());
      } else {
        showErrorDialog(context, "network_error".tr());
      }
    }
  }

  Future<UserInfomation> fetchUserById(int userId, BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final response = await dio.get(
          "${ApiEndpoints.detail_accounts_url}/$userId",
          options: Options(headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        if (responseData == null) {
          throw Exception("Post data not found in response");
        }
        return UserInfomation.fromJson(responseData);
      } else {
        throw Exception(response.data["message"] ?? "Failed to load post");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Network error occurred");
    } catch (e) {
      throw Exception("Failed to load post: ${e.toString()}");
    }
  }
}
