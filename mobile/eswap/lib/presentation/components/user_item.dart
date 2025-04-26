import 'package:eswap/model/enum_model.dart';
import 'package:eswap/model/post_model.dart';
import 'package:eswap/model/user_model.dart';
import 'package:eswap/presentation/components/follow_button.dart';
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

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
                    _post.createdAt,
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
                    followStatus: FollowStatus.fromString(_post.followStatus!),
                    otherUserId: _post.userId,
                  )
                : SizedBox.shrink(),
            Container(
              margin: EdgeInsets.only(left: 5),
              padding: EdgeInsets.symmetric(vertical: 2),
              child: GestureDetector(
                onTap: () {},
                child: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
              ),
            ),
          ],
        )
      ],
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
    return Row(
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
              Text(
                _user.username,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                _user.educationInstitutionName,
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
                    followStatus: FollowStatus.fromString(_user.followStatus!),
                    otherUserId: _user.id,
                  )
                : SizedBox.shrink(),
          ],
        )
      ],
    );
  }
}
