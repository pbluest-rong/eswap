import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/dialogs/dialog.dart';
import 'package:eswap/core/utils/enums.dart';
import 'package:eswap/model/category_brand.dart';
import 'package:eswap/model/page_response.dart';
import 'package:eswap/model/post_model.dart';
import 'package:eswap/provider/search_filter_sort_provider.dart';
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

  Future<PageResponse<Post>> fetchPostByEducationInstitution(
      int institutionId,
      int page,
      int size,
      bool isOnlyShop,
      BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final response = await dio.get(
          '${ServerInfo.getPostsByEducationInstitution_url}/$institutionId',
          queryParameters: {
            'page': page,
            'size': size,
            'isOnlyShop': isOnlyShop
          },
          data: Provider.of<SearchFilterSortProvider>(context, listen: false).toJsonForSearchFilterSortPosts(),
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
    } catch (e) {
      print("error 3");
      print(e);
      showErrorDialog(context, "general_error".tr());
      throw Exception("general_error".tr());
    }
  }

  Future<PageResponse<Post>> fetchPostsOfFollowing(
      int page, int size, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final response = await dio.get(ServerInfo.getPostsOfFollowing,
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
      int page,
      int size,
      bool isOnlyShop,
      BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final response = await dio.get(ServerInfo.getExplorePosts,
          queryParameters: {
            'page': page,
            'size': size,
            'isOnlyShop': isOnlyShop
          },
          data: Provider.of<SearchFilterSortProvider>(context, listen: false).toJsonForSearchFilterSortPosts(),
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

  Future<PageResponse<Post>> fetchPostsByProvince(
      String provinceId,
      int page,
      int size,
      bool isOnlyShop,
      BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final response = await dio.get(
          "${ServerInfo.getPostsByProvince}/$provinceId",
          queryParameters: {
            'page': page,
            'size': size,
            'isOnlyShop': isOnlyShop
          },
          data: Provider.of<SearchFilterSortProvider>(context, listen: false).toJsonForSearchFilterSortPosts(),
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

  Widget buildPostItem(Post post, BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: post.avtUrl != null
                      ? NetworkImage("${post.avtUrl}")
                      : null,
                  child: post.avtUrl == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${post.firstname} ${post.lastname}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        post.educationInstitutionName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            post.privacy == Privacy.FOLLOWERS
                                ? Icons.person_sharp
                                : Icons.public,
                            size: 15,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 5),
                          Text(
                            post.createdAt,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: post.isFollowing == null
                          ? SizedBox.shrink()
                          : (post.isFollowing == true)
                              ? Text(
                                  "Đang theo dõi",
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontSize: 12,
                                  ),
                                )
                              : Text(
                                  "Theo dõi",
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontSize: 12,
                                  ),
                                ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: GestureDetector(
                        onTap: () {},
                        child: Icon(Icons.more_vert,
                            color: Colors.grey[600], size: 20),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.name ?? 'Không có tiêu đề',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.description ?? 'Không có mô tả',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          if (post.media.isNotEmpty)
            Column(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: post.media.length > 1
                        ? Swiper(
                            itemBuilder: (BuildContext context, int index) {
                              return _buildMediaItem(post.media[index],
                                  post.id.toString(), context);
                            },
                            itemCount: post.media.length,
                            viewportFraction: 1.0,
                            scale: 0.9,
                            autoplay: false,
                            pagination: SwiperPagination(
                              builder: DotSwiperPaginationBuilder(
                                activeColor: Colors.blue,
                                color: Colors.grey[300],
                                size: 6,
                                activeSize: 8,
                              ),
                            ),
                            // control: SwiperControl(
                            //   color: Colors.black54,
                            //   padding: const EdgeInsets.all(8),
                            // ),
                          )
                        : _buildMediaItem(
                            post.media[0], post.id.toString(), context),
                  ),
                ),
              ],
            ),

          // Price and quantity info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.originalPrice != null && post.originalPrice! > 0)
                      Row(
                        children: [
                          Text(
                            "Giá gốc: ",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "${post.originalPrice} VND",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    Row(
                      children: [
                        Text(
                          "Giá bán: ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "${post.salePrice} VND",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Số lượng: ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "${post.quantity}",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Đã bán: ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "${post.sold}",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(
                  icon: Icons.favorite_border,
                  activeIcon: Icons.favorite,
                  label: "${post.likesNumber}",
                  onPressed: () {},
                ),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  label: "Nhắn tin",
                  onPressed: () {},
                ),
                _buildActionButton(
                  icon: Icons.share,
                  label: "Chia sẻ",
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPostItemHorizontal(Post post, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Kiểm tra media có tồn tại không
    if (post.media == null || post.media.isEmpty) {
      return _buildEmptyMediaItem(textTheme, post);
    }

    final firstMedia = post.media[0];
    final isVideo = _isVideoMedia(firstMedia);

    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần hiển thị media (ảnh hoặc video)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: isVideo
                ? _buildVideoThumbnail(firstMedia, post.id.toString())
                : _buildCachedImage(firstMedia),
          ),

          // Phần text
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.name ?? 'Không có tiêu đề',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  post.description ?? 'Không có mô tả',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge,
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (post.salePrice != null)
                      Text(
                        "${post.salePrice} VND",
                        style: textTheme.bodyMedium!.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Icon(Icons.chat_bubble_outline)
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

// Helper methods
  Widget _buildEmptyMediaItem(TextTheme textTheme, Post post) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            height: 150,
            color: Colors.grey[200],
            child: const Icon(Icons.photo, size: 50, color: Colors.grey),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.name ?? 'Không có tiêu đề',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  post.description ?? 'Không có mô tả',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCachedImage(dynamic mediaItem) {
    return CachedNetworkImage(
      imageUrl: mediaItem.originalUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, size: 50),
      ),
    );
  }

  Widget _buildVideoThumbnail(dynamic mediaItem, String postId) {
    final url = mediaItem.originalUrl;
    final videoKey = '${postId}_$url';

    // Tạo controller nếu chưa tồn tại
    if (!_videoControllers.containsKey(videoKey)) {
      final controller = VideoPlayerController.network(url);
      _videoControllers[videoKey] = controller;

      // Khởi tạo video nhưng không tự động play
      controller.initialize();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        VideoPlayer(_videoControllers[videoKey]!),
        const Center(
          child:
              Icon(Icons.play_circle_filled, size: 50, color: Colors.white70),
        ),
      ],
    );
  }

  bool _isVideoMedia(dynamic mediaItem) {
    final url = mediaItem.originalUrl?.toString().toLowerCase() ?? '';
    return url.contains('video') ||
        url.endsWith('.mp4') ||
        url.endsWith('.mov') ||
        url.endsWith('.avi');
  }

  Widget _buildActionButton({
    required IconData icon,
    IconData? activeIcon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: Colors.grey[700],
        size: 20,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 12,
        ),
      ),
      style: TextButton.styleFrom(
        minimumSize: const Size(60, 36),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildMediaItem(
      dynamic mediaItem, String postId, BuildContext context) {
    final url = mediaItem.originalUrl;
    final contentType = mediaItem.originalUrl?.toString().toLowerCase() ?? '';
    final isVideo = contentType.contains('video') ||
        url.toString().toLowerCase().endsWith('.mp4') ||
        url.toString().toLowerCase().endsWith('.mov');

    if (isVideo) {
      final videoKey = '${postId}_$url';

      if (!_videoControllers.containsKey(videoKey)) {
        final controller = VideoPlayerController.network(url);
        final chewieController = ChewieController(
          videoPlayerController: controller,
          autoPlay: false,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: Colors.blue,
            handleColor: Colors.blue,
            backgroundColor: Colors.grey,
            bufferedColor: Colors.grey[300]!,
          ),
        );

        _videoControllers[videoKey] = controller;
        _chewieControllers[videoKey] = chewieController;

        // controller.initialize().then((_) {
        //   if (mounted) setState(() {});
        // });
      }

      return Container(
        height: 240,
        child: Chewie(controller: _chewieControllers[videoKey]!),
      );
    } else {
      return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  backgroundColor: Colors.black,
                  appBar: AppBar(
                    backgroundColor: Colors.black,
                    iconTheme: const IconThemeData(color: Colors.white),
                  ),
                  body: Center(
                    child: PhotoView(
                      imageProvider: NetworkImage(url),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                      heroAttributes: PhotoViewHeroAttributes(tag: url),
                    ),
                  ),
                ),
              ),
            );
          },
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            placeholder: (context, url) => Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ));
    }
  }
}
