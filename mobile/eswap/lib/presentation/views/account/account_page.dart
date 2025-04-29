import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/model/user_model.dart';
import 'package:eswap/service/user_service.dart';
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
      body: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _user == null
                  ? Center(child: Text('no_result_found'.tr()))
                  : Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(_user.toString())
                          ],
                        ),
                      ),
                    )),
    );
  }
}
