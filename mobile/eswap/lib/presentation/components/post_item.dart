import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:eswap/model/post_model.dart';
import 'package:eswap/presentation/components/user_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class PostItem extends StatefulWidget {
  final Post post;
  final bool isGridView;

  PostItem({super.key, required this.post, this.isGridView = false});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  late Post _post;
  final Map<String, VideoPlayerController> _videoControllers = {};
  final Map<String, ChewieController> _chewieControllers = {};

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  void dispose() {
    super.dispose();
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();

    for (final controller in _chewieControllers.values) {
      controller.dispose();
    }
    _chewieControllers.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGridView) {
      return _buildPostItemHorizontal(_post, context);
    } else {
      return _buildPostItemVertical(_post, context);
    }
  }

  Widget _buildPostItemVertical(Post post, BuildContext context) {
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
            child: UserItemForPost(post: post),
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

  Widget _buildPostItemHorizontal(Post post, BuildContext context) {
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

  bool _isVideoMedia(dynamic mediaItem) {
    final url = mediaItem.originalUrl?.toString().toLowerCase() ?? '';
    return url.contains('video') ||
        url.endsWith('.mp4') ||
        url.endsWith('.mov') ||
        url.endsWith('.avi');
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
      dynamic mediaItem, String postId, BuildContext context)
  {
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
}
