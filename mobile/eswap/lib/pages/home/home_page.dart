import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:eswap/pages/home/post_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:eswap/pages/notification/notification_page.dart';
import 'package:eswap/provider/info_provider.dart';
import 'package:eswap/websocket/websocket.dart';


final GlobalKey<HomePageState> homePageKey = GlobalKey();

class HomePageController {
  late VoidCallback scrollToTop;
}

class HomePage extends StatefulWidget {
  final HomePageController? controller;

  const HomePage({super.key, this.controller});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final PostService _postService = PostService();

  List<dynamic> _allPosts = [];
  final Map<String, VideoPlayerController> _videoControllers = {};
  final Map<String, ChewieController> _chewieControllers = {};

  int _currentPage = 0;
  final int _pageSize = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ).then((_) {
        _loadInitialPosts();
      });
    } else {
      _loadInitialPosts();
    }
  }
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _setupWebSocket();
    widget.controller?.scrollToTop = _scrollToTop;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadInitialPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    for (final controller in _chewieControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadInitialPosts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _allPosts = [];
      _currentPage = 0;
      _hasMore = true;
    });

    try {
      final response = await _postService.getPostsByEducationInstitution(
        context,
        _currentPage,
        _pageSize,
      );

      setState(() {
        _allPosts = response['data']['content'];
        _hasMore = !response['data']['last'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Error loading posts: ${e.toString()}');
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await _postService.getPostsByEducationInstitution(
        context,
        _currentPage + 1,
        _pageSize,
      );

      setState(() {
        _currentPage++;
        _allPosts.addAll(response['data']['content']);
        _hasMore = !response['data']['last'];
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      _showErrorSnackbar('Error loading more posts: ${e.toString()}');
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMorePosts();
      }
    });
  }

  void _setupWebSocket() {
    WebSocketService().listenForNewPosts((newPost) {
      setState(() {
        Map<String, dynamic> post = json.decode(newPost);
        if (post['media'] is List<String>) {
          post['media'] = post['media'].map((e) => {'originalUrl': e}).toList();
        }
        // _newPostsFromWS.insert(0, post);
        _allPosts.add(post);
        if (_allPosts.length > 100) {
          _allPosts.removeAt(0);
        }
      });
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadInitialPosts,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            cacheExtent: 1000, // Cache more items offscreen
            slivers: [
              SliverPersistentHeader(
                floating: true,
                delegate: _HeaderDelegate(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    child: _buildHomeHeader(),
                  ),
                  maxExtent: 60,
                  minExtent: 60,
                ),
              ),
              if (_isLoading && _allPosts.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!_isLoading && _allPosts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.post_add,
                            size: 50, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No posts available',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: _loadInitialPosts,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < _allPosts.length) {
                      return Column(
                        key: PageStorageKey('post_${_allPosts[index]['id']}'),
                        children: [
                          _buildPostItem(_allPosts[index]),
                          Container(
                            height: 5,
                            width: double.infinity,
                            color: Colors.black26,
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    } else if (_hasMore) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                  childCount: _allPosts.length + (_hasMore ? 1 : 0),
                  addAutomaticKeepAlives: true,
                  addRepaintBoundaries: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostItem(dynamic post) {
    final userFirstname = post['firstname'] ?? 'Unknown';
    final userLastname = post['lastname'] ?? '';
    final institutionName =
        post['educationInstitution']['name'] ?? 'Unknown institution';
    final media = post['media'] ?? [];
    final price = post['salePrice']?.toStringAsFixed(0) ?? '0';
    final quantity = post['quantity']?.toString() ?? '0';
    final likes = post['likesNumber']?.toString() ?? '0';

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
                  backgroundImage: post['avtUrl'] != null
                      ? NetworkImage(post['avtUrl'])
                      : null,
                  child: post['avtUrl'] == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$userFirstname $userLastname',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        institutionName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Text(
                    "Đang theo dõi",
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
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
                  post['name'] ?? 'Không có tiêu đề',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post['description'] ?? 'Không có mô tả',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          if (media.isNotEmpty)
            Container(
              height: 240,
              width: double.infinity,
              child: media.length > 1
                  ? Swiper(
                      itemBuilder: (BuildContext context, int index) {
                        return _buildMediaItem(
                            media[index], post['id'].toString());
                      },
                      itemCount: media.length,
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
                      control: SwiperControl(
                        color: Colors.black54,
                        padding: const EdgeInsets.all(8),
                      ),
                    )
                  : _buildMediaItem(media[0], post['id'].toString()),
            ),

          // Price and quantity info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Giá: ",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "$price VND",
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
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
                      quantity,
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
                  label: likes,
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

  Widget _buildHomeHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          offset: const Offset(0, 30),
          constraints: const BoxConstraints(minWidth: 100),
          onSelected: (value) {
            if (value == 'explore') {
              // Handle explore
            } else if (value == 'following') {
              // Handle following
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'explore',
              height: 30,
              child: const Row(
                children: [
                  Text('Khám phá',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Spacer(),
                  Icon(Icons.location_on_outlined)
                ],
              ),
            ),
            PopupMenuItem(
              value: 'following',
              height: 30,
              child: const Row(
                children: [
                  Text('Đang theo dõi',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Spacer(),
                  Icon(Icons.account_box_outlined)
                ],
              ),
            ),
          ],
          child: Image.asset(
            "assets/images/menu.png",
            width: 40,
            height: 40,
          ),
        ),
        Expanded(
          child: Text(
            "🌏 ${Provider.of<InfoProvider>(context, listen: true).educationInstitutionName}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, NotificationPage.route);
          },
          child: Stack(
            children: [
              const Icon(Icons.notifications),
              Positioned(
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaItem(dynamic mediaItem, String postId) {
    final url = mediaItem['originalUrl'];
    final contentType =
        mediaItem['contentType']?.toString()?.toLowerCase() ?? '';
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

        controller.initialize().then((_) {
          if (mounted) setState(() {});
        });
      }

      return Container(
        height: 240,
        child: Chewie(controller: _chewieControllers[videoKey]!),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        memCacheWidth: MediaQuery.of(context).size.width.toInt(),
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double maxExtent;
  final double minExtent;

  const _HeaderDelegate({
    required this.child,
    required this.maxExtent,
    required this.minExtent,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.maxExtent != maxExtent ||
        oldDelegate.minExtent != minExtent;
  }
}
