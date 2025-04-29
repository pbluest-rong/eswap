import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/presentation/components/post_item.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/model/post_model.dart';
import 'package:eswap/service/post_service.dart';
import 'package:eswap/service/websocket.dart';
import 'package:flutter/material.dart';

class FollowingPage extends StatefulWidget {
  static const String route = '/following';

  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage>
    with AutomaticKeepAliveClientMixin {
  bool _isGridView = false;
  final ScrollController _scrollController = ScrollController();
  final PostService _postService = PostService();
  List<Post> _allPosts = [];
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  void _scrollToTop(isReLoad) {
    if (_scrollController.hasClients) {
      _scrollController
          .animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      )
          .then((_) {
        if (isReLoad) _loadInitialPosts();
      });
    } else {
      if (isReLoad) _loadInitialPosts();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _setupWebSocket();
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
      final postpage = await _postService.fetchPostsOfFollowing(
        _currentPage,
        _pageSize,
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
      final postpage = await _postService.fetchPostsOfFollowing(
          _currentPage + 1, _pageSize, context);

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

  void _setupWebSocket() async {
    final WebSocketService _webSocketService =
        await WebSocketService.getInstance();
    _webSocketService.listenForNewPosts((newPost) {
      if (!mounted) return;
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
      appBar: AppBar(
        centerTitle: true,
        title: GestureDetector(
          onTap: () {
            _scrollToTop(true);
          },
          child: Text(
            "following".tr(),
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
              icon: _isGridView
                  ? Icon(Icons.format_list_bulleted)
                  : Icon(Icons.grid_view_rounded)),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadInitialPosts,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            cacheExtent: 1000,
            slivers: [
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
              if (_isGridView)
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < _allPosts.length) {
                        return PostItem(
                          post: _allPosts[index],
                          isGridView: _isGridView,
                        );
                      } else if (_hasMore) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                    childCount: _allPosts.length + (_hasMore ? 1 : 0),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < _allPosts.length) {
                        return Column(
                          key: PageStorageKey('post_${_allPosts[index].id}'),
                          children: [
                            PostItem(
                                post: _allPosts[index],
                                isGridView: _isGridView),
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
