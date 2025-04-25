import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/app_colors.dart';
import 'package:eswap/presentation/components/bottom_sheet.dart';
import 'package:eswap/presentation/components/post_item.dart';
import 'package:eswap/presentation/components/user_item.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/presentation/widgets/search.dart';
import 'package:eswap/model/page_response.dart';
import 'package:eswap/model/post_model.dart';
import 'package:eswap/model/user_model.dart';
import 'package:eswap/presentation/views/home/search_filter_sort_provider.dart';
import 'package:eswap/presentation/components/education_institution_dialog.dart';
import 'package:eswap/service/post_service.dart';
import 'package:eswap/service/user_service.dart';
import 'package:eswap/presentation/views/home/filter.dart';
import 'package:eswap/presentation/views/search/search_user_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExplorePage extends StatefulWidget {
  static const String route = '/explore';

  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

enum FetchPostType { EXPLORE, FOLLOWING, PROVINCE, EDUCATION_INSTITUTION }

enum SortPostType { RELATED, LATEST, PRICE_ASC, PRICE_DESC }

class _ExplorePageState extends State<ExplorePage>
    with AutomaticKeepAliveClientMixin {
  FetchPostType _fetchType = FetchPostType.EXPLORE;
  int? _educationInstitutionId;
  String? _provinceId;
  bool _isOnlyShop = false;

  String scope = "nationwide".tr();
  bool _isGridView = false;
  final ScrollController _scrollController = ScrollController();
  final PostService _postService = PostService();
  final UserService _userService = UserService();
  List<Post> _allPosts = [];
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  List<UserInfomation> _firstSearchUsers = [];
  TextEditingController searchController = TextEditingController();

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String? kw =
        Provider.of<SearchFilterSortProvider>(context, listen: false).keyword;

    searchController.text = kw ?? '';
    _loadInitialPosts();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _postService.dispose();
  }

  Future<void> _reloadPost(
      Future<PageResponse<Post>> Function() fetchPostFunc) async {
    if (_isLoading || !mounted) return;
    setState(() {
      _isLoading = true;
      _allPosts = [];
      _currentPage = 0;
      _hasMore = true;
    });
    try {
      final postpage = await fetchPostFunc();
      setState(() {
        _allPosts = postpage.content;
        _hasMore = !postpage.last;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showErrorSnackbar(context, 'Error loading posts: ${e.toString()}');
      }
    }
  }

  Future<void> _loadInitialPosts() async {
    String? kw =
        Provider.of<SearchFilterSortProvider>(context, listen: false).keyword;
    if (kw != null) {
      setState(() {
        _firstSearchUsers = [];
      });
      final pageUsers = await _userService.fetchSearchUser(kw, 0, 3, context);
      setState(() {
        _firstSearchUsers = pageUsers.content;
      });
    } else {
      setState(() {
        _firstSearchUsers = [];
      });
    }

    switch (_fetchType) {
      case FetchPostType.EXPLORE:
        _reloadPost(() => _postService.fetchExplorePosts(
              _currentPage,
              _pageSize,
              _isOnlyShop,
              context,
            ));
        break;
      case FetchPostType.FOLLOWING:
        _reloadPost(() => _postService.fetchPostsOfFollowing(
              _currentPage,
              _pageSize,
              context,
            ));
        break;
      case FetchPostType.PROVINCE:
        _reloadPost(() => _postService.fetchPostsByProvince(
              _provinceId!,
              _currentPage,
              _pageSize,
              _isOnlyShop,
              context,
            ));
        break;
      case FetchPostType.EDUCATION_INSTITUTION:
        _reloadPost(() => _postService.fetchPostByEducationInstitution(
              _educationInstitutionId!,
              _currentPage,
              _pageSize,
              _isOnlyShop,
              context,
            ));
        break;
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });
    try {
      PageResponse<Post> postPage;
      switch (_fetchType) {
        case FetchPostType.EXPLORE:
          postPage = await _postService.fetchExplorePosts(
            _currentPage + 1,
            _pageSize,
            _isOnlyShop,
            context,
          );
          break;
        case FetchPostType.FOLLOWING:
          postPage = await _postService.fetchPostsOfFollowing(
            _currentPage + 1,
            _pageSize,
            context,
          );
          break;
        case FetchPostType.PROVINCE:
          postPage = await _postService.fetchPostsByProvince(
            _provinceId!,
            _currentPage + 1,
            _pageSize,
            _isOnlyShop,
            context,
          );
          break;
        case FetchPostType.EDUCATION_INSTITUTION:
          postPage = await _postService.fetchPostByEducationInstitution(
            _educationInstitutionId!,
            _currentPage + 1,
            _pageSize,
            _isOnlyShop,
            context,
          );
          break;
      }
      setState(() {
        _currentPage++;
        _allPosts.addAll(postPage.content);
        _hasMore = !postPage.last;
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

  void _showFilter(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, Object>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.transparent,
        builder: (context) => EnhancedDraggableSheet(
                child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: FilterDialog(
                onClose: () {
                  Navigator.of(context).pop();
                  _loadInitialPosts();
                },
              ),
            )));
  }

  void _showInstitutionDialog(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, Object>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.transparent,
        builder: (context) =>
            EnhancedDraggableSheet(child: InstitutionSelectionDialog()));
    if (result != null) {
      final isNationwide = result['isNationwide'] as bool;
      bool isReset = false;
      if (isNationwide) {
        setState(() {
          if (_fetchType != FetchPostType.EXPLORE) {
            _fetchType = FetchPostType.EXPLORE;
            isReset = true;
          }
          _provinceId = null;
          _educationInstitutionId = null;
          scope = "nationwide".tr();
        });
        if (isReset) _loadInitialPosts();
      } else {
        final isProvince = result['isProvince'] as bool;
        if (isProvince) {
          final provinceId = result['provinceId'] as String;
          final provinceName = result['provinceName'] as String;
          setState(() {
            if (_fetchType != FetchPostType.PROVINCE) {
              _fetchType = FetchPostType.PROVINCE;
              isReset = true;
            }
            _provinceId = provinceId;
            scope = provinceName;
          });

          if (isReset) _loadInitialPosts();
        } else {
          final educationInstitutionId =
              result['educationInstitutionId'] as int;
          final educationInstitutionName =
              result['educationInstitutionName'] as String;
          setState(() {
            if (_fetchType != FetchPostType.EDUCATION_INSTITUTION) {
              _fetchType = FetchPostType.EDUCATION_INSTITUTION;
              isReset = true;
            }
            _educationInstitutionId = educationInstitutionId;
            scope = educationInstitutionName;
          });
          if (isReset) _loadInitialPosts();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: GestureDetector(
            onTap: () {
              _scrollToTop(true);
            },
            onLongPress: () {
              _showInstitutionDialog(context);
            },
            onDoubleTap: () {
              _showInstitutionDialog(context);
            },
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "scope".tr(),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.sync_alt,
                      size: 20,
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    scope,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            )),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Provider.of<SearchFilterSortProvider>(context, listen: false)
                .reset();
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
              SliverToBoxAdapter(
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                    child: searchFilterSort(textTheme)),
              ),
              if (_firstSearchUsers.isNotEmpty)
                SliverToBoxAdapter(child: _buildFirstSearchUsers(textTheme)),
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

  void _handleSearch(String kw) {
    setState(() {
      Provider.of<SearchFilterSortProvider>(context, listen: false)
          .updateKeyword(kw.isNotEmpty ? kw : null);
      _loadInitialPosts();
    });
  }

  Widget searchFilterSort(TextTheme textTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: AppSearch(
                controller: searchController,
                onSearch: _handleSearch,
              ),
            ),
            SizedBox(
              width: 40,
              child: GestureDetector(
                onTap: () {
                  _showFilter(context);
                },
                child: Stack(
                  children: [
                    (Provider.of<SearchFilterSortProvider>(context,
                                listen: false)
                            .isNoFilter())
                        ? Image.asset(
                            'assets/images/filter.png',
                            width: 24,
                            height: 24,
                            color: AppColors.lightPrimary,
                          )
                        : Image.asset(
                            'assets/images/filter_done.png',
                            width: 24,
                            height: 24,
                            color: AppColors.lightPrimary,
                          ),
                    Positioned(
                        left: 16,
                        bottom: -4,
                        child: Text("filter".tr(),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.lightPrimary,
                            ))),
                  ],
                ),
              ),
            )
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 5),
          color: AppColors.lightBackground,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    Provider.of<SearchFilterSortProvider>(context,
                            listen: false)
                        .updateSortBy(SortPostType.RELATED);
                    _loadInitialPosts();
                  });
                },
                child: (Provider.of<SearchFilterSortProvider>(context,
                                    listen: true)
                                .sortBy ==
                            SortPostType.RELATED ||
                        Provider.of<SearchFilterSortProvider>(context,
                                    listen: true)
                                .sortBy ==
                            null)
                    ? Text(
                        "sort_related".tr(),
                        style: textTheme.titleSmall!
                            .copyWith(color: AppColors.lightPrimary),
                      )
                    : Text("sort_related".tr(), style: textTheme.titleSmall),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    Provider.of<SearchFilterSortProvider>(context,
                            listen: false)
                        .updateSortBy(SortPostType.LATEST);
                    _loadInitialPosts();
                  });
                },
                child:
                    Provider.of<SearchFilterSortProvider>(context, listen: true)
                                .sortBy ==
                            SortPostType.LATEST
                        ? Text(
                            "sort_latest".tr(),
                            style: textTheme.titleSmall!
                                .copyWith(color: AppColors.lightPrimary),
                          )
                        : Text("sort_latest".tr(), style: textTheme.titleSmall),
              ),
              TextButton(
                  onPressed: () {
                    SortPostType? sortBy =
                        Provider.of<SearchFilterSortProvider>(context,
                                listen: false)
                            .sortBy;
                    setState(() {
                      Provider.of<SearchFilterSortProvider>(context,
                              listen: false)
                          .updateSortBy(sortBy == SortPostType.PRICE_ASC
                              ? SortPostType.PRICE_DESC
                              : SortPostType.PRICE_ASC);
                      _loadInitialPosts();
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        "sort_price".tr(),
                        style: Provider.of<SearchFilterSortProvider>(context,
                                            listen: true)
                                        .sortBy ==
                                    SortPostType.PRICE_ASC ||
                                Provider.of<SearchFilterSortProvider>(context,
                                            listen: true)
                                        .sortBy ==
                                    SortPostType.PRICE_DESC
                            ? textTheme.titleSmall!
                                .copyWith(color: AppColors.lightPrimary)
                            : textTheme.titleSmall,
                      ),
                      if (Provider.of<SearchFilterSortProvider>(context,
                                  listen: true)
                              .sortBy ==
                          SortPostType.PRICE_ASC)
                        Transform.rotate(
                          angle: 270 * 3.1416 / 180,
                          child: Icon(
                            Icons.arrow_right_alt_outlined,
                            color: AppColors.lightPrimary,
                          ),
                        )
                      else if (Provider.of<SearchFilterSortProvider>(context,
                                  listen: true)
                              .sortBy ==
                          SortPostType.PRICE_DESC)
                        Transform.rotate(
                          angle: 90 * 3.1416 / 180,
                          child: Icon(
                            Icons.arrow_right_alt_outlined,
                            color: AppColors.lightPrimary,
                          ),
                        )
                      else
                        Transform.rotate(
                          angle: 90 * 3.1416 / 180,
                          child: Icon(
                            Icons.compare_arrows,
                            color: AppColors.lightText,
                          ),
                        )
                    ],
                  )),
              InkWell(
                onTap: () {
                  setState(() {
                    _isOnlyShop = !_isOnlyShop;
                    _loadInitialPosts();
                  });
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: _isOnlyShop,
                      onChanged: (bool? value) {
                        setState(() {
                          _isOnlyShop = value ?? false;
                          _loadInitialPosts();
                        });
                      },
                      visualDensity:
                          VisualDensity(horizontal: -4.0, vertical: -4.0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Text(
                      "filter_shop".tr(),
                      style: textTheme.titleSmall!.copyWith(
                        color: _isOnlyShop ? AppColors.lightPrimary : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildFirstSearchUsers(TextTheme textTheme) {
    if (_firstSearchUsers.isEmpty) {
      return const SizedBox.shrink();
    } else {
      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _firstSearchUsers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: UserItemForList(user: _firstSearchUsers[index]),
              );
            },
          ),
          SizedBox(
            width: 300,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                backgroundColor: Colors.white10,
              ),
              onPressed: () {
                String? kw = Provider.of<SearchFilterSortProvider>(context,
                        listen: false)
                    .keyword;
                if (kw != null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SearchUserList(keyword: kw))).then((value) {
                    _loadInitialPosts();
                  });
                  ;
                }
              },
              child: Text(
                "show_more".tr(),
                style:
                    textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 5,
            width: double.infinity,
            color: Colors.black26,
          ),
        ],
      );
    }
  }
}
