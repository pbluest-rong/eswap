import 'package:dio/dio.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/model/category_brand_model.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:eswap/service/auth_interceptor.dart';
import 'package:flutter/material.dart';

class CategoryBrandService {
  final Dio _dio = Dio();

  Future<List<Brand>> fetchBrandsByCategoryId(int categoryId) async {
    try {
      final userSession = await UserSession.load();
      _dio.interceptors.add(AuthInterceptor(_dio));

      final response = await _dio.get(
        "${ApiEndpoints.getCategories}/$categoryId/brands",
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${userSession!.accessToken}",
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

  Future<Category> createCategory({
    required BuildContext context,
    required int? parentCategoryId,
    required String name,
  }) async {
    try {
      final userSession = await UserSession.load();
      final response = await _dio.post(
        '${ApiEndpoints.admin_url}/categories',
        data: {
          'parentCategoryId': parentCategoryId,
          'name': name,
        },
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${userSession!.accessToken}",
        }),
      );

      if (response.data['success'] == true) {
        return Category.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create category');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  Future<Brand> createBrand({
    required BuildContext context,
    required int categoryId,
    required String name,
  }) async {
    try {
      final userSession = await UserSession.load();
      final response = await _dio.post(
        '${ApiEndpoints.admin_url}/brands',
        data: {
          'categoryId': categoryId,
          'name': name,
        },
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${userSession!.accessToken}",
        }),
      );

      if (response.data['success'] == true) {
        return Brand.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create brand');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }
  Future<void> removeBrandFromCategory({
    required BuildContext context,
    required int categoryId,
    required int brandId,
  }) async {
    try {
      final userSession = await UserSession.load();
      await _dio.delete(
        '${ApiEndpoints.admin_url}/categories/$categoryId/brands/$brandId',
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${userSession!.accessToken}",
        }),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }
}
