import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/dialogs/dialog.dart';
import 'package:eswap/core/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:eswap/provider/info_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> getPostsByEducationInstitution(
      BuildContext context, int page, int size) async {
    final institutionId = Provider.of<InfoProvider>(context, listen: false)
        .educationInstitutionId;
    try {
      final locale = Localizations.localeOf(context).languageCode;
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      final response = await _dio.get(
        '${ServerInfo.getPostsByEducationInstitution_url}/$institutionId',
        queryParameters: {'page': page, 'size': size},
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept-Language": context.locale.languageCode,
            "Authorization": "Bearer $accessToken",
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        showErrorDialog(context, response.data["message"]);
        throw Exception(response.data["message"]); // Add throw statement
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
}
