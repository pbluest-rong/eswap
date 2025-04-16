import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/presentation/components/post_item.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/model/post_model.dart';
import 'package:eswap/presentation/views/home/search_filter_sort_provider.dart';
import 'package:eswap/service/post_service.dart';
import 'package:eswap/presentation/views/home/explore.dart';
import 'package:eswap/presentation/views/home/following.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:eswap/presentation/views/notification/notification_page.dart';
import 'package:eswap/providers/info_provider.dart';
import 'package:eswap/service/websocket.dart';

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

class HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final PostService _postService = PostService();
  List<Post> _allPosts = [];
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController
          .animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      )
          .then((_) {
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
    super.dispose();
    _scrollController.dispose();
    _postService.dispose();
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
      final institutionId = Provider.of<InfoProvider>(context, listen: false)
          .educationInstitutionId;
      final postpage = await _postService.fetchPostByEducationInstitution(
        institutionId,
        _currentPage,
        _pageSize,
        false,
        context,
      );

      setState(() {
        _allPosts = postpage.content;
        _hasMore = !postpage.last;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showErrorSnackbar(context, 'Error loading posts: ${e.toString()}');
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final institutionId = Provider.of<InfoProvider>(context, listen: false)
          .educationInstitutionId;
      final postpage = await _postService.fetchPostByEducationInstitution(
          institutionId, _currentPage + 1, _pageSize, false, context);

      setState(() {
        _currentPage++;
        _allPosts.addAll(postpage.content);
        _hasMore = !postpage.last;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      showErrorSnackbar(context, 'Error loading more posts: ${e.toString()}');
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
        Map<String, dynamic> postJson = json.decode(newPost);
        Post post = Post.fromJson(postJson);

        _allPosts.add(post);
        if (_allPosts.length > 100) {
          _allPosts.removeAt(0);
        }
      });
    });
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
                          "no_posts_available".tr(),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: _loadInitialPosts,
                          child: Text("retry".tr()),
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
                        key: PageStorageKey('post_${_allPosts[index].id}'),
                        children: [
                          PostItem(post: _allPosts[index]),
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
              Provider.of<SearchFilterSortProvider>(context, listen: false)
                  .reset();
              Navigator.pushNamed(context, ExplorePage.route);
            } else if (value == 'following') {
              Navigator.pushNamed(context, FollowingPage.route);
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset(
            //   "assets/images/vietnam.png",
            //   width: 25,
            //   height: 25,
            //   fit: BoxFit.fill,
            // ),
            Text(
              Provider.of<InfoProvider>(context, listen: true)
                  .educationInstitutionName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )),
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
