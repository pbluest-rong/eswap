import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/app_colors.dart';
import 'package:eswap/model/enum_model.dart';
import 'package:eswap/model/page_response.dart';
import 'package:eswap/model/post_model.dart';
import 'package:eswap/model/user_model.dart';
import 'package:eswap/presentation/components/follow_button.dart';
import 'package:eswap/presentation/components/pick_media.dart';
import 'package:eswap/presentation/components/post_item.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/service/post_service.dart';
import 'package:eswap/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DetailUserPage extends StatefulWidget {
  final int userId;

  const DetailUserPage({super.key, required this.userId});

  @override
  State<DetailUserPage> createState() => _DetailUserPageState();
}

class _DetailUserPageState extends State<DetailUserPage> {
  UserInfomation? _user;
  bool _isLoadingUser = true;
  bool _isMe = false;
  String? _error;

  final PostService _postService = PostService();
  List<Post> _allPosts = [];
  int _currentPage = 0;
  final int _pageSize = 6;
  bool _hasMore = true;
  bool _isLoadingPosts = false;
  bool _isLoadingMorePosts = false;
  PostFilterType _postFilter = PostFilterType.available;

  bool isUpdateAvt = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _postService.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _fetchUser();
    await _loadInitialPosts();
  }

  Future<void> _refreshData() async {
    setState(() {
      _currentPage = 0;
      _hasMore = true;
      _allPosts.clear();
    });
    await _loadInitialData();
  }

  Future<void> _fetchUser() async {
    setState(() {
      _isLoadingUser = true;
      _error = null;
    });

    try {
      final userService = UserService();
      final fetchedUser =
          await userService.fetchUserById(widget.userId, context);

      final userSession = await UserSession.load();
      int? userId = userSession!.userId;

      setState(() {
        _user = fetchedUser;
        _isMe = userId == fetchedUser.id;
        _isLoadingUser = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingUser = false;
        _user = null;
      });
    }
  }

  Future<void> _loadInitialPosts() async {
    if (_isLoadingPosts) return;

    setState(() {
      _isLoadingPosts = true;
    });

    try {
      PageResponse<Post> postPage;
      if (_postFilter == PostFilterType.sold) {
        postPage = await _postService.fetchSoldUserPosts(
          widget.userId,
          _currentPage,
          _pageSize,
          context,
        );
      } else {
        postPage = await _postService.fetchShowingUserPosts(
          widget.userId,
          _currentPage,
          _pageSize,
          context,
        );
      }

      setState(() {
        _allPosts = postPage.content;
        _hasMore = !postPage.last;
        _isLoadingPosts = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingPosts = false;
      });
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMorePosts || !_hasMore) return;

    setState(() {
      _isLoadingMorePosts = true;
    });

    try {
      PageResponse<Post> postPage;
      if (_postFilter == PostFilterType.sold) {
        postPage = await _postService.fetchSoldUserPosts(
          widget.userId,
          _currentPage + 1,
          _pageSize,
          context,
        );
      } else {
        postPage = await _postService.fetchShowingUserPosts(
          widget.userId,
          _currentPage + 1,
          _pageSize,
          context,
        );
      }

      print(postPage.size);
      setState(() {
        _currentPage++;
        _allPosts.addAll(postPage.content);
        _hasMore = !postPage.last;
        _isLoadingMorePosts = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingMorePosts = false;
      });
    }
  }

  Future<void> _handleFollowAction() async {
    if (_user == null) return;
  }

  void _changePostFilter(PostFilterType filter) {
    if (_postFilter != filter) {
      setState(() {
        _postFilter = filter;
        _currentPage = 0;
        _hasMore = true;
        _allPosts.clear();
      });
      _loadInitialPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actionsPadding: EdgeInsets.only(right: 8),
        leading: IconButton(
          padding: const EdgeInsets.only(left: 10),
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isLoadingUser
            ? Text('...')
            : _user != null
                ? Text(
                    _user!.username!,
                    overflow: TextOverflow.ellipsis,
                  )
                : Text('no_result_found'.tr()),
        actions: [
          if (_user != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.yellow,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${_user!.reputationScore}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final textTheme = Theme.of(context).textTheme;

    if (_isLoadingUser && _user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_user == null) {
      return Center(child: Text('no_result_found'.tr()));
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: _buildUserInfo(_user!),
            ),
          ),
          _buildPostsSection(),
          _buildPostGrid(),
          if (_hasMore && _allPosts.isNotEmpty) _buildShowMoreButtonSliver(),
        ],
      ),
    );
  }

  Widget _buildShowMoreButtonSliver() {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 16),
      sliver: SliverToBoxAdapter(
        child: Center(
          child: _isLoadingMorePosts
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    backgroundColor: Colors.white10,
                  ),
                  onPressed: _loadMorePosts,
                  child: Text(
                    "show_more".tr(),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(UserInfomation user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserHeader(user),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: _buildActionButtons(user)),
        const SizedBox(height: 16),
        _buildUserDetails(user),
      ],
    );
  }

  Widget _buildUserHeader(UserInfomation user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserAvatar(user),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${user.firstname} ${user.lastname}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              _buildUserStats(user),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar(UserInfomation user) {
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        isUpdateAvt
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                      : null,
                ),
              )
            : CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
        if (_isMe)
          Positioned(
            bottom: -4,
            right: -4,
            child: PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                offset: const Offset(0, 30),
                constraints: const BoxConstraints(minWidth: 100),
                onSelected: (value) async {
                  if (value == 'newAvt') {
                    final userService = UserService();
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MediaLibraryScreen(
                          maxSelection: 1,
                          isSelectImage: true,
                          isSelectVideo: false,
                          enableCamera: true,
                        ),
                      ),
                    );
                    if (result != null && result.isNotEmpty) {
                      for (var asset in result) {
                        final file = await asset.file;
                        setState(() {
                          isUpdateAvt = true;
                        });
                        String newAvt =
                            await userService.uploadAvatar(file, context);
                        setState(() {
                          user.avatarUrl = newAvt;
                          isUpdateAvt = false;
                        });
                        break;
                      }
                    }
                  } else if (value == 'deleteAvt') {
                    AppAlert.show(
                      context: context,
                      title: 'Xóa ảnh đại diện?',
                      description:
                          'Khi xóa ảnh đại diện, thao tác sẽ không thể hoàn tác!',
                      actions: [
                        AlertAction(text: "cancel".tr(), handler: () {}),
                        AlertAction(
                            text: "confirm".tr(),
                            isDestructive: true,
                            handler: () {
                              final userService = UserService();
                              userService.deleteAvatar(context);
                              setState(() {
                                user.avatarUrl = null;
                              });
                            }),
                      ],
                    );
                  }
                },
                itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'newAvt',
                        height: 30,
                        child: const Row(
                          children: [
                            Text('Thay đổi ảnh đại diện',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            Spacer(),
                            Icon(Icons.add_a_photo)
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'deleteAvt',
                        height: 30,
                        child: const Row(
                          children: [
                            Text('Xóa ảnh đại diện',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            Spacer(),
                            Icon(Icons.delete)
                          ],
                        ),
                      ),
                    ],
                child: Icon(Icons.edit)),
          ),
      ],
    );
  }

  Widget _buildUserStats(UserInfomation user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(user.postCount.toString(), 'posts'.tr()),
        _buildStatItem(user.followerCount.toString(), 'followers'.tr()),
        _buildStatItem(user.followingCount.toString(), 'following'.tr()),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(UserInfomation user) {
    if (_isMe) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _navigateToEditProfile(),
              child: Text('edit_profile'.tr()),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => _shareProfile(),
            child: Text('share'.tr()),
          ),
        ],
      );
    }

    return FollowButton(
      followStatus: FollowStatus.fromString(user.followStatus!),
      otherUserId: user.id,
      bigSize: true,
    );
  }

  Widget _buildUserDetails(UserInfomation user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user.educationInstitutionName != null)
          _buildDetailRow(
            Icons.location_on_outlined,
            'location'.tr(),
            user.educationInstitutionName!,
          ),
        _buildDetailRow(
          Icons.calendar_month,
          'joined'.tr(),
          DateFormat('dd/MM/yyyy')
              .format(DateTime.parse(user.createdAt!).toLocal()),
        ),
        if (user.gender != null)
          _buildDetailRow(
            user.gender! ? Icons.male : Icons.female,
            'gender'.tr(),
            user.gender! ? 'male'.tr() : 'female'.tr(),
          ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: '),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsSection() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildPostFilterTabs(),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _buildPostFilterTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => _changePostFilter(PostFilterType.available),
              child: Text(
                'available'.tr(),
                style: TextStyle(
                  color: _postFilter == PostFilterType.available
                      ? AppColors.lightPrimary
                      : AppColors.lightText,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () => _changePostFilter(PostFilterType.sold),
              child: Text(
                'sold'.tr(),
                style: TextStyle(
                  color: _postFilter == PostFilterType.sold
                      ? AppColors.lightPrimary
                      : AppColors.lightText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < _allPosts.length) {
            return PostItem(
              key: ValueKey('post_${_allPosts[index].id}_$index'),
              post: _allPosts[index],
              isGridView: true,
            );
          }
          return null;
        },
        childCount: _allPosts.length + (_hasMore ? 1 : 0),
      ),
    );
  }

  void _navigateToEditProfile() {}

  void _shareProfile() {}
}

enum PostFilterType {
  available,
  sold,
}
