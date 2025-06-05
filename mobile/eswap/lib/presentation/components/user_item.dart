import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/main.dart';
import 'package:eswap/model/enum_model.dart';
import 'package:eswap/model/post_model.dart';
import 'package:eswap/model/user_model.dart';
import 'package:eswap/presentation/components/follow_button.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:eswap/presentation/views/account/account_page.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/service/post_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserItemForPost extends StatefulWidget {
  final Post post;

  UserItemForPost({super.key, required this.post});

  @override
  State<UserItemForPost> createState() => _UserItemForPostState();
}

class _UserItemForPostState extends State<UserItemForPost> {
  late Post _post;
  UserSession? _userSession;

  Future<void> loadSessionUser() async {
    if (!mounted) return;
    final userSession = await UserSession.load();
    if (userSession != null) {
      setState(() {
        _userSession = userSession;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    loadSessionUser();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
              builder: (_) => DetailUserPage(userId: _post.userId)),
        );
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            backgroundImage:
                _post.avtUrl != null ? NetworkImage("${_post.avtUrl}") : null,
            child: _post.avtUrl == null
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_post.firstname} ${_post.lastname}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (_post.role! == 'USER')
                  Text(
                    _post.educationInstitutionName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _post.privacy == Privacy.FOLLOWERS
                          ? Icons.person_sharp
                          : Icons.public,
                      size: 15,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 5),
                    Text(
                      DateFormat('dd/MM/yyyy  HH:mm')
                          .format(DateTime.parse(_post.createdAt).toLocal()),
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
              _post.followStatus != null
                  ? FollowButton(
                      followStatus:
                          FollowStatus.fromString(_post.followStatus!),
                      waitingAcceptFollow: _post.waitingAcceptFollow,
                      otherUserId: _post.userId,
                    )
                  : SizedBox.shrink(),
              PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  offset: const Offset(0, 30),
                  constraints: const BoxConstraints(minWidth: 100),
                  onSelected: (value) {
                    final postService = PostService();
                    if (value == 'remove') {
                      AppAlert.show(
                          context: context,
                          title: "Thao tác sẽ không thể hoàn tác!",
                          description:
                              "Bài đăng sẽ không còn hiển thị trên hồ sơ của bạn!",
                          actions: [
                            AlertAction(text: "cancel".tr()),
                            AlertAction(
                                text: "confirm".tr(),
                                isDestructive: true,
                                handler: () {
                                  try {
                                    postService.removePost(_post.id, context);
                                    showNotificationDialog(
                                        context, "Xóa bài đăng thành công");
                                  } catch (e) {
                                    print(e);
                                  }
                                })
                          ]);
                    } else if (value == 'report') {}
                  },
                  itemBuilder: (context) => [
                        // if (_userSession != null &&
                        //     _post.userId == _userSession!.userId)
                        //   PopupMenuItem(
                        //     value: 'edit',
                        //     height: 30,
                        //     child: const Row(
                        //       children: [
                        //         Text('Chỉnh sửa',
                        //             style: TextStyle(
                        //                 fontSize: 14,
                        //                 fontWeight: FontWeight.bold)),
                        //         Spacer(),
                        //         Icon(Icons.edit)
                        //       ],
                        //     ),
                        //   ),
                        if (_userSession != null &&
                            _post.userId == _userSession!.userId &&
                            _post.status != PostStatus.DELETED.name)
                          PopupMenuItem(
                            value: 'remove',
                            height: 30,
                            child: const Row(
                              children: [
                                Text('Xóa bài đăng',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                Spacer(),
                                Icon(Icons.delete_forever)
                              ],
                            ),
                          ),
                        // if (_userSession != null &&
                        //     _post.userId != _userSession!.userId)
                        //   PopupMenuItem(
                        //     value: 'report',
                        //     height: 30,
                        //     child: const Row(
                        //       children: [
                        //         Text('Báo cáo bài đăng',
                        //             style: TextStyle(
                        //                 fontSize: 14,
                        //                 fontWeight: FontWeight.bold)),
                        //         Spacer(),
                        //         Icon(Icons.report)
                        //       ],
                        //     ),
                        //   ),
                      ],
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(Icons.more_vert,
                        color: Colors.grey[600], size: 20),
                  )),
            ],
          )
        ],
      ),
    );
  }
}

class UserItemForList extends StatefulWidget {
  final UserInfomation user;

  const UserItemForList({super.key, required this.user});

  @override
  State<UserItemForList> createState() => _UserItemForListState();
}

class _UserItemForListState extends State<UserItemForList> {
  late UserInfomation _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => DetailUserPage(userId: _user.id)),
        );
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            backgroundImage: _user.avatarUrl != null
                ? NetworkImage("${_user.avatarUrl}")
                : null,
            child: _user.avatarUrl == null
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_user.firstname} ${_user.lastname}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _user.username != null
                    ? Text(
                        _user.username!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      )
                    : SizedBox.shrink(),
                if (_user.role != null && _user.role! == 'USER')
                  Text(
                    _user.educationInstitutionName!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              (_user.followStatus != null)
                  ? FollowButton(
                      followStatus:
                          FollowStatus.fromString(_user.followStatus!),
                      waitingAcceptFollow: _user.waitingAcceptFollow,
                      otherUserId: _user.id,
                    )
                  : SizedBox.shrink(),
            ],
          )
        ],
      ),
    );
  }
}
