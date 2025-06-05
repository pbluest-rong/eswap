import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/main.dart';
import 'package:eswap/model/user_model.dart';
import 'package:eswap/presentation/views/account/account_page.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/presentation/widgets/search.dart';
import 'package:eswap/service/user_service.dart';
import 'package:flutter/material.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final UserService userService = UserService();
  List<UserInfomation> _allUsers = [];
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _keyword;
  late final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadInitialUsers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
      final userspage = await userService.fetchUsersByAdmin(
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
    }
  }

  Future<void> _loadMoreUser() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final postpage = await userService.fetchUsersByAdmin(
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
                              Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: _buildUserWidget(_allUsers[index]),
                                  ),
                                ],
                              )
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

  Widget _buildUserWidget(UserInfomation user) {
    return GestureDetector(
      onTap: () {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
              builder: (_) => DetailUserPage(
                    userId: user.id,
                    isAdmin: true,
                  )),
        );
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            backgroundImage: user.avatarUrl != null
                ? NetworkImage("${user.avatarUrl}")
                : null,
            child: user.avatarUrl == null
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstname} ${user.lastname}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                user.username != null
                    ? Text(
                        user.username!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      )
                    : SizedBox.shrink(),
                if (user.role != null && user.role! == 'USER')
                  Text(
                    user.educationInstitutionName!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          user.isLocked
              ? GestureDetector(
                  onTap: () {
                    AppAlert.show(
                        context: context,
                        title: "Mở khóa tài khoản này",
                        actions: [
                          AlertAction(text: "Hủy"),
                          AlertAction(
                              text: "Xác nhận",
                              handler: () {
                                userService.unlockUserByAdmin(user.id, context);
                                setState(() {
                                  user.isLocked = false;
                                });
                              })
                        ]);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(Icons.lock),
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    AppAlert.show(
                        context: context,
                        title: "Khóa tài khoản này",
                        actions: [
                          AlertAction(text: "Hủy"),
                          AlertAction(
                              text: "Xác nhận",
                              handler: () {
                                userService.lockUserByAdmin(user.id, context);
                                setState(() {
                                  user.isLocked = true;
                                });
                              })
                        ]);
                  },
                  child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(Icons.lock_open)),
                )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
