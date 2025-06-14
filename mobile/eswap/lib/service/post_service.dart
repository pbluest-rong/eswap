import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/model/enum_model.dart';
import 'package:eswap/model/like_model.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:eswap/model/page_response.dart';
import 'package:eswap/model/post_model.dart';
import 'package:eswap/presentation/views/home/search_filter_sort_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
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

  Future<PageResponse<Post>> fetchPostsForHome(
      int page, int size, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final userSession = await UserSession.load();
      final response = await dio.get('${ApiEndpoints.getExplorePosts}/home',
          queryParameters: {
            'page': page,
            'size': size,
          },
          data: Provider.of<SearchFilterSortProvider>(context, listen: false)
              .toJsonForSearchFilterSortPosts(),
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
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
        pageResponse.content.shuffle(Random());
        return pageResponse;
      } else {
        throw Exception(response.data["message"]);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data["message"] ?? "general_error".tr());
      } else {
        throw Exception("network_error".tr());
      }
    } catch (e, stackTrace) {
      throw Exception("general_error".tr());
    }
  }

  Future<PageResponse<Post>> fetchPostByEducationInstitution(int institutionId,
      int page, int size, bool isOnlyShop, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final userSession = await UserSession.load();
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
            "Authorization": "Bearer ${userSession!.accessToken}",
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
        pageResponse.content.shuffle(Random());
        return pageResponse;
      } else {
        throw Exception(response.data["message"]);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data["message"] ?? "general_error".tr());
      } else {
        throw Exception("network_error".tr());
      }
    } catch (e, stackTrace) {
      throw Exception("general_error".tr());
    }
  }

  Future<PageResponse<Post>> fetchPostsOfFollowing(
      int page, int size, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final userSession = await UserSession.load();
      final response = await dio.get(ApiEndpoints.getPostsOfFollowing,
          queryParameters: {'page': page, 'size': size},
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final pageResponse = PageResponse<Post>.fromJson(
          responseData,
          (json) => Post.fromJson(json),
        );
        pageResponse.content.shuffle(Random());
        return pageResponse;
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

  Future<PageResponse<Post>> fetchStorePosts(
      int page, int size, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final userSession = await UserSession.load();
      final response = await dio.get("${ApiEndpoints.getExplorePosts}/store",
          queryParameters: {'page': page, 'size': size},
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final pageResponse = PageResponse<Post>.fromJson(
          responseData,
          (json) => Post.fromJson(json),
        );
        pageResponse.content.shuffle(Random());
        return pageResponse;
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

  Future<PageResponse<Post>> fetchPostsOnlyStore(
      PostStatus status, int page, int size, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final userSession = await UserSession.load();
      String url = "";
      if (status == PostStatus.PENDING) {
        url = "${ApiEndpoints.getExplorePosts}/store/pending";
      } else if (status == PostStatus.REJECTED) {
        url = "${ApiEndpoints.getExplorePosts}/store/rejected";
      } else if (status == PostStatus.PUBLISHED) {
        url = "${ApiEndpoints.getExplorePosts}/store/accepted";
      }
      final response = await dio.get(url,
          queryParameters: {'page': page, 'size': size},
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final pageResponse = PageResponse<Post>.fromJson(
          responseData,
          (json) => Post.fromJson(json),
        );
        pageResponse.content.shuffle(Random());
        return pageResponse;
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

  Future<PageResponse<Post>> fetchExplorePosts(
      int page, int size, bool isOnlyShop, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;

      final userSession = await UserSession.load();
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
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final pageResponse = PageResponse<Post>.fromJson(
          responseData,
          (json) => Post.fromJson(json),
        );
        pageResponse.content.shuffle(Random());
        return pageResponse;
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

  Future<PageResponse<Post>> fetchRecommendPosts(
      int page, int size, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;

      final userSession = await UserSession.load();
      final response = await dio.get(
          "${ApiEndpoints.getExplorePosts}/user/recommend",
          queryParameters: {
            'page': page,
            'size': size,
          },
          data: Provider.of<SearchFilterSortProvider>(context, listen: false)
              .toJsonForSearchFilterSortPosts(),
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final pageResponse = PageResponse<Post>.fromJson(
          responseData,
          (json) => Post.fromJson(json),
        );
        pageResponse.content.shuffle(Random());
        return pageResponse;
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

  Future<PageResponse<Post>> fetchPostsByProvince(String provinceId, int page,
      int size, bool isOnlyShop, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;

      final userSession = await UserSession.load();
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
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final pageResponse = PageResponse<Post>.fromJson(
          responseData,
          (json) => Post.fromJson(json),
        );
        pageResponse.content.shuffle(Random());
        return pageResponse;
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

  Future<PageResponse<Post>> fetchShowingUserPosts(
      int userId, int page, int size, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;

      final userSession = await UserSession.load();
      final response = await dio.get(
          "${ApiEndpoints.getExplorePosts}/user/$userId",
          queryParameters: {
            'page': page,
            'size': size,
          },
          data: Provider.of<SearchFilterSortProvider>(context, listen: false)
              .toJsonForSearchFilterSortPosts(),
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final pageResponse = PageResponse<Post>.fromJson(
          responseData,
          (json) => Post.fromJson(json),
        );
        pageResponse.content.shuffle(Random());
        return pageResponse;
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

  Future<PageResponse<Post>> fetchSoldUserPosts(
      int userId, int page, int size, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;

      final userSession = await UserSession.load();
      final response = await dio.get(
          "${ApiEndpoints.getExplorePosts}/user/$userId/sold",
          queryParameters: {
            'page': page,
            'size': size,
          },
          data: Provider.of<SearchFilterSortProvider>(context, listen: false)
              .toJsonForSearchFilterSortPosts(),
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final pageResponse = PageResponse<Post>.fromJson(
          responseData,
          (json) => Post.fromJson(json),
        );
        pageResponse.content.shuffle(Random());
        return pageResponse;
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

  Future<Like> like(int postId, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;

      final userSession = await UserSession.load();

      final response = await dio.post("${ApiEndpoints.like_post_url}/$postId",
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
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

  Future<Like> unlike(int postId, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;

      final userSession = await UserSession.load();

      final response = await dio.post("${ApiEndpoints.unlike_post_url}/$postId",
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
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
      final userSession = await UserSession.load();
      final response = await dio.get("${ApiEndpoints.getPostById_url}/$id",
          options: Options(headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${userSession!.accessToken}",
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

  Future<int> getUnreadNotificationNumber(BuildContext context) async {
    try {
      final userSession = await UserSession.load();
      final response = await dio.get(ApiEndpoints.getUnreadNotificationNumber,
          options: Options(headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        return responseData;
      } else {
        throw Exception(response.data["message"] ??
            "Failed to getUnreadNotificationNumber");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Network error occurred");
    } catch (e) {
      throw Exception("Failed to getUnreadNotificationNumber: ${e.toString()}");
    }
  }
  bool _isVideoMedia(String url) {
    return url.contains('video') ||
        url.endsWith('.mp4') ||
        url.endsWith('.mov') ||
        url.endsWith('.avi');
  }
  Future<void> addPost(
      Map<String, dynamic> postData, List<String> mediaFiles) async {
    try {
      final userSession = await UserSession.load();

      List<MultipartFile> mediaFileList = [];
      List<String> compressedFilePaths = []; // Để lưu lại đường dẫn file nén

      for (String filePath in mediaFiles) {
        // Video
        if (_isVideoMedia(filePath)) {
          mediaFileList.add(await MultipartFile.fromFile(
            filePath,
            filename: filePath.split('/').last,
          ));
        }
        // Image
        else{
          final tempDir = await getTemporaryDirectory();
          final targetPath =
              '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';

          final compressedFile = await FlutterImageCompress.compressAndGetFile(
            filePath,
            targetPath,
            quality: 70,
          );
          if (compressedFile != null) {
            mediaFileList.add(
              await MultipartFile.fromFile(
                compressedFile.path,
                filename: compressedFile.path.split('/').last,
              ),
            );
            compressedFilePaths.add(compressedFile.path);
          }
        }
      }

      FormData formData = FormData.fromMap({
        "post": MultipartFile.fromString(
          jsonEncode(postData),
          filename: 'post.json',
          contentType: DioMediaType('application', 'json'),
        ),
        "mediaFiles": mediaFileList,
      });

      final response = await dio.post(
        ApiEndpoints.addPost_url,
        data: formData,
        options: Options(headers: {
          "Authorization": "Bearer ${userSession!.accessToken}",
        }),
      );

      if (response.statusCode == 200) {
        print("Add Post Successful");
      } else {
        throw Exception(response.data["message"] ?? "Failed to load post");
      }

      // Xoá hết các file nén
      for (var path in compressedFilePaths) {
        final compressedFile = File(path);
        if (await compressedFile.exists()) {
          await compressedFile.delete();
        }
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Network error occurred");
    } catch (e) {
      throw Exception("Failed to load post: ${e.toString()}");
    }
  }

  Future<void> acceptPostByStore(int postId, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;

      final userSession = await UserSession.load();

      await dio.put("${ApiEndpoints.getExplorePosts}/store/accept/$postId",
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
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

  Future<void> rejectPostByStore(int postId, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;

      final userSession = await UserSession.load();

      await dio.put("${ApiEndpoints.getExplorePosts}/store/reject/$postId",
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
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

  Future<void> removePost(int postId, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;

      final userSession = await UserSession.load();

      await dio.delete("${ApiEndpoints.getExplorePosts}/remove/$postId",
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
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
}
