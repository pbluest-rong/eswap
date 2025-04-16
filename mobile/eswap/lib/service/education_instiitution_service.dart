
import 'package:dio/dio.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/model/education_institution_model.dart';
import 'package:eswap/model/province_model.dart';

class EducationInstitutionService{
  final dio = Dio();

  Future<List<Province>> fetchProvinces() async {
    try {
      final dio = Dio();
      final response = await dio.get(ApiEndpoints.getProvinces_url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data'])
              .map((json) => Province.fromJson(json))
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

  Future<List<EducationInstitution>> fetchInstitutions(
      String provinceId, String? institutionType) async {
    try {
      final dio = Dio();
      final String url = institutionType != null
          ? '${ApiEndpoints.getProvinces_url}/$provinceId/type?institutionType=${institutionType.toString().split('.').last}'
          : '${ApiEndpoints.getProvinces_url}/$provinceId';

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data'])
              .map((json) => EducationInstitution.fromJson(json))
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