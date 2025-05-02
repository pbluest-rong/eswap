import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/model/post_model.dart';
import 'package:eswap/presentation/components/post_item.dart';
import 'package:eswap/presentation/components/user_item.dart';
import 'package:eswap/service/post_service.dart';
import 'package:flutter/material.dart';

class StandalonePost extends StatefulWidget {
  final int postId;

  const StandalonePost({super.key, required this.postId});

  @override
  State<StandalonePost> createState() => _StandalonePostState();
}

class _StandalonePostState extends State<StandalonePost> {
  Post? _post;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPost();
  }

  Future<void> _fetchPost() async {
    try {
      final PostService postService = PostService();
      final fetchedPost = await postService.fetchById(widget.postId, context);
      setState(() {
        _post = fetchedPost;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _post = null;
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
        leading: IconButton(
          padding: EdgeInsets.only(left: 10),
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: _isLoading
            ? Text('...')
            : _post != null
            ? UserItemForPost(post: _post!)
            : Text('no_result_found'.tr()),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _post == null
            ? Center(child: Text('no_result_found'.tr()))
            : Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                PostItem(
                  post: _post!,
                  isStandalone: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
