import 'package:dio/dio.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/model/category_brand_model.dart';
import 'package:eswap/service/auth_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryBrandService {
  final dio = Dio();

  Future<List<Brand>> fetchBrandsByCategoryId(int categoryId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString("accessToken");
      dio.interceptors.add(AuthInterceptor(dio, prefs));

      final response = await dio.get(
        "${ApiEndpoints.getCategories}/$categoryId/brands",
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data'])
              .map((json) => Brand.fromJson(json))
              .toList();
        } else {
          throw Exception('API returned unsuccessful response');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
