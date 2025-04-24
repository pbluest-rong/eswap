import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/model/like_model.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/core/onboarding/onboarding_page_position.dart';
import 'package:eswap/model/category_brand_model.dart';
import 'package:eswap/model/page_response.dart';
import 'package:eswap/model/post_model.dart';
import 'package:eswap/presentation/views/home/search_filter_sort_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class PostService {
  final dio = Dio();
  final Map<String, VideoPlayerController> _videoControllers = {};
  final Map<String, ChewieController> _chewieControllers = {};

  void dispose() {
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();

    for (final controller in _chewieControllers.values) {
      controller.dispose();
    }
    _chewieControllers.clear();
  }

  Future<PageResponse<Post>> fetchPostByEducationInstitution(int institutionId,
      int page, int size, bool isOnlyShop, BuildContext context) async
  {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final response = await dio.get(
          '${ApiEndpoints.getPostsByEducationInstitution_url}/$institutionId',
          queryParameters: {
            'page': page,
            'size': size,
            'isOnlyShop': isOnlyShop
          },
          data: Provider.of<SearchFilterSortProvider>(context, listen: false)
              .toJsonForSearchFilterSortPosts(),
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer $accessToken",
          }));
      if (response.statusCode == 200) {
        final responseData =
            response.data['data']; // Get the 'data' object from response
        final pageResponse = PageResponse<Post>.fromJson(
          responseData,
          // Pass the inner data object which contains the pagination fields
          (json) =>
              Post.fromJson(json), // Pass a function that converts JSON to Post
        );
        return pageResponse;
      } else {
        print("error 1");
        showErrorDialog(context, response.data["message"]);
        throw Exception(response.data["message"]);
      }
    } on DioException catch (e) {
      print("error 2");
      print(e);
      if (e.response != null) {
        showErrorDialog(
            context, e.response?.data["message"] ?? "general_error".tr());
        throw Exception(e.response?.data["message"] ?? "general_error".tr());
      } else {
        showErrorDialog(context, "network_error".tr());
        throw Exception("network_error".tr());
      }
    } catch (e, stackTrace) {
      print('Lỗi: $e');
      print('Stack trace: $stackTrace');
      print("error 3");
      print(e);
      showErrorDialog(context, "general_error".tr());
      throw Exception("general_error".tr());
    }
  }

  Future<PageResponse<Post>> fetchPostsOfFollowing(
      int page, int size, BuildContext context) async
  {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final response = await dio.get(ApiEndpoints.getPostsOfFollowing,
          queryParameters: {'page': page, 'size': size},
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer $accessToken",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final pageResponse = PageResponse<Post>.fromJson(
          responseData,
          (json) => Post.fromJson(json),
        );
        return pageResponse;
      } else {
        print("error 1");
        showErrorDialog(context, response.data["message"]);
        throw Exception(response.data["message"]);
      }
    } on DioException catch (e) {
      print("error 2");
      print(e);
      if (e.response != null) {
        showErrorDialog(
            context, e.response?.data["message"] ?? "general_error".tr());
        throw Exception(e.response?.data["message"] ?? "general_error".tr());
      } else {
        showErrorDialog(context, "network_error".tr());
        throw Exception("network_error".tr());
      }
    } catch (e) {
      print("error 3");
      print(e);
      showErrorDialog(context, "general_error".tr());
      throw Exception("general_error".tr());
    }
  }

  Future<PageResponse<Post>> fetchExplorePosts(
      int page, int size, bool isOnlyShop, BuildContext context) async
  {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final response = await dio.get(ApiEndpoints.getExplorePosts,
          queryParameters: {
            'page': page,
            'size': size,
            'isOnlyShop': isOnlyShop
          },
          data: Provider.of<SearchFilterSortProvider>(context, listen: false)
              .toJsonForSearchFilterSortPosts(),
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer $accessToken",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final pageResponse = PageResponse<Post>.fromJson(
          responseData,
          (json) => Post.fromJson(json),
        );
        return pageResponse;
      } else {
        print("error 1");
        showErrorDialog(context, response.data["message"]);
        throw Exception(response.data["message"]);
      }
    } on DioException catch (e) {
      print("error 2");
      print(e);
      if (e.response != null) {
        showErrorDialog(
            context, e.response?.data["message"] ?? "general_error".tr());
        throw Exception(e.response?.data["message"] ?? "general_error".tr());
      } else {
        showErrorDialog(context, "network_error".tr());
        throw Exception("network_error".tr());
      }
    } catch (e) {
      print("error 3");
      print(e);
      showErrorDialog(context, "general_error".tr());
      throw Exception("general_error".tr());
    }
  }

  Future<PageResponse<Post>> fetchPostsByProvince(String provinceId, int page,
      int size, bool isOnlyShop, BuildContext context) async
  {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final response = await dio.get(
          "${ApiEndpoints.getPostsByProvince}/$provinceId",
          queryParameters: {
            'page': page,
            'size': size,
            'isOnlyShop': isOnlyShop
          },
          data: Provider.of<SearchFilterSortProvider>(context, listen: false)
              .toJsonForSearchFilterSortPosts(),
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer $accessToken",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final pageResponse = PageResponse<Post>.fromJson(
          responseData,
          (json) => Post.fromJson(json),
        );
        return pageResponse;
      } else {
        print("error 1");
        showErrorDialog(context, response.data["message"]);
        throw Exception(response.data["message"]);
      }
    } on DioException catch (e) {
      print("error 2");
      print(e);
      if (e.response != null) {
        showErrorDialog(
            context, e.response?.data["message"] ?? "general_error".tr());
        throw Exception(e.response?.data["message"] ?? "general_error".tr());
      } else {
        showErrorDialog(context, "network_error".tr());
        throw Exception("network_error".tr());
      }
    } catch (e) {
      print("error 3");
      print(e);
      showErrorDialog(context, "general_error".tr());
      throw Exception("general_error".tr());
    }
  }

  Future<Like> like(int postId, BuildContext context) async
  {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      final response = await dio.post("${ApiEndpoints.like_post_url}/$postId",
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer $accessToken",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        Like like = Like.fromJson(responseData);
        return like;
      } else {
        throw Exception(response.data["message"]);
      }
    } on DioException catch (e) {
      print("error 2");
      print(e);
      if (e.response != null) {
        throw Exception(e.response?.data["message"] ?? "general_error".tr());
      } else {
        throw Exception("network_error".tr());
      }
    } catch (e) {
      throw Exception("general_error".tr());
    }
  }
  Future<Like> unlike(int postId, BuildContext context) async
  {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      final response = await dio.post("${ApiEndpoints.unlike_post_url}/$postId",
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer $accessToken",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        Like like = Like.fromJson(responseData);
        return like;
      } else {
        throw Exception(response.data["message"]);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data["message"] ?? "general_error".tr());
      } else {
        throw Exception("network_error".tr());
      }
    } catch (e) {
      throw Exception("general_error".tr());
    }
  }

  Future<Post> fetchById(int id, BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      print("CHECK ${ApiEndpoints.getPostById_url}/$id");
      final response = await dio.get(
          "${ApiEndpoints.getPostById_url}/$id",
          options: Options(headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken",
          }));

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        if (responseData == null) {
          throw Exception("Post data not found in response");
        }
        return Post.fromJson(responseData);
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
