import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/model/enum_model.dart';
import 'package:eswap/model/user_model.dart';
import 'package:eswap/presentation/widgets/password_tf.dart';
import 'package:eswap/service/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DetailUserPage extends StatefulWidget {
  final int userId;

  const DetailUserPage({super.key, required this.userId});

  @override
  State<DetailUserPage> createState() => _DetailUserPageState();
}

class _DetailUserPageState extends State<DetailUserPage> {
  UserInfomation? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final UserService userService = UserService();
      final fetchedUser =
          await userService.fetchUserById(widget.userId, context);
      setState(() {
        _user = fetchedUser;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _user = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: 32,
        leading: IconButton(
          padding: EdgeInsets.only(left: 10),
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: _isLoading
            ? Text('...')
            : _user != null
                ? Text(_user!.username!)
                : Text('no_result_found'.tr()),
      ),
      body: AppBody(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _user == null
                  ? Center(child: Text('no_result_found'.tr()))
                  : Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [Text(_user.toString())],
                        ),
                      ),
                    )),
    );
  }

  Widget _buildUserInfo(UserInfomation user) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            backgroundImage:
                user != null ? NetworkImage("${user.avatarUrl}") : null,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [Text("${user.postCount}"), Text("Bài đăng")],
                    ),
                    Column(
                      children: [
                        Text("${user.followerCount}"),
                        Text("Người theo dõi")
                      ],
                    ),
                    Column(
                      children: [
                        Text("${user.followingCount}"),
                        Text("Đang theo dõi")
                      ],
                    )
                  ],
                ),
                if (user.followStatus == FollowStatus.UNFOLLOWED)
                  OutlinedButton(onPressed: () {}, child: Text("Theo dõi"))
                else if (user.followStatus == FollowStatus.WAITING)
                  OutlinedButton(
                      onPressed: () {}, child: Text("Đã gửi yêu cầu"))
                else if (user.followStatus == FollowStatus.FOLLOWED)
                  OutlinedButton(onPressed: () {}, child: Text("Đang theo dõi"))
              ],
            ),
          ),
        ]),
        Row(
          children: [
            Icon(Icons.location_on_outlined),
            Text("Khu vực:"),
            Text("${user.educationInstitutionName}")
          ],
        ),
        Row(
          children: [
            Icon(Icons.location_on_outlined),
            Text("Đã tham gia:"),
            Text("${user.createdAt}")
          ],
        ),
        if (user.gender != null)
          Row(
            children: [
              Icon(Icons.location_on_outlined),
              Text("Giới tính:"),
              Text(user.gender! ? "Nam" : "Nữ")
            ],
          )
      ],
    );
  }
}
