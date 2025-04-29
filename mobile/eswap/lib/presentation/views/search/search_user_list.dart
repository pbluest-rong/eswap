import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/presentation/components/user_item.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/presentation/widgets/search.dart';
import 'package:eswap/model/user_model.dart';
import 'package:eswap/service/user_service.dart';
import 'package:flutter/material.dart';

class SearchUserList extends StatefulWidget {
  static const String route = '/search-user';
  String keyword;

  SearchUserList({super.key, required this.keyword});

  @override
  State<SearchUserList> createState() => _SearchUserListState();
}

class _SearchUserListState extends State<SearchUserList>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final UserService _userService = UserService();
  List<UserInfomation> _allUsers = [];
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  late String _keyword;
  late final TextEditingController _searchController = TextEditingController();

  void _scrollToTop(isReLoad) {
    if (_scrollController.hasClients) {
      _scrollController
          .animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      )
          .then((_) {
        if (isReLoad) _loadInitialUsers();
      });
    } else {
      if (isReLoad) _loadInitialUsers();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _keyword = widget.keyword;
    _searchController.text = _keyword;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadInitialUsers();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialUsers() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _allUsers = [];
      _currentPage = 0;
      _hasMore = true;
    });

    try {
      final userspage = await _userService.fetchSearchUser(
        _keyword,
        _currentPage,
        _pageSize,
        context,
      );

      setState(() {
        _allUsers = userspage.content;
        _hasMore = !userspage.last;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showErrorSnackbar(context, 'Error loading users: ${e.toString()}');
    }
  }

  Future<void> _loadMoreUser() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final postpage = await _userService.fetchSearchUser(
          _keyword, _currentPage + 1, _pageSize, context);

      setState(() {
        _currentPage++;
        _allUsers.addAll(postpage.content);
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
        _loadMoreUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          child: AppSearch(
            controller: _searchController,
            onSearch: (keyword) {
              setState(() {
                _keyword = keyword;
                _loadInitialUsers();
              });
            },
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
          child: RefreshIndicator(
              onRefresh: _loadInitialUsers,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                cacheExtent: 1000,
                slivers: [
                  if (_isLoading && _allUsers.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (!_isLoading && _allUsers.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.supervised_user_circle_outlined,
                                size: 50, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              "no_result_found".tr(),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            TextButton(
                              onPressed: _loadInitialUsers,
                              child: Text("retry".tr()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < _allUsers.length) {
                        return Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            key: PageStorageKey('user_${_allUsers[index].id}'),
                            children: [
                              UserItemForList(user: _allUsers[index]),
                            ],
                          ),
                        );
                      } else if (_hasMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    },
                    childCount: _allUsers.length + (_hasMore ? 1 : 0),
                    addAutomaticKeepAlives: true,
                    addRepaintBoundaries: true,
                  ))
                ],
              ))),
    );
  }
}
