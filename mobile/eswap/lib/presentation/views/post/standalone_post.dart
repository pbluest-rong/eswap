import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/model/chat_model.dart';
import 'package:eswap/model/enum_model.dart';
import 'package:eswap/model/post_model.dart';
import 'package:eswap/presentation/components/post_item.dart';
import 'package:eswap/presentation/components/user_item.dart';
import 'package:eswap/presentation/views/chat/chat_page.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/service/post_service.dart';
import 'package:flutter/material.dart';

class StandalonePost extends StatefulWidget {
  final int postId;
  bool editEnable;
  int? customerId;
  String? customerFirstname;
  String? customerLastname;
  String? customerAvtUrl;

  StandalonePost(
      {super.key,
      required this.postId,
      this.editEnable = false,
      this.customerId,
      this.customerFirstname,
      this.customerLastname,
      this.customerAvtUrl});

  @override
  State<StandalonePost> createState() => _StandalonePostState();
}

class _StandalonePostState extends State<StandalonePost> {
  Post? _post;
  bool _isLoading = true;
  bool _editEnable = false;

  @override
  void initState() {
    super.initState();
    _editEnable = widget.editEnable;
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
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildActionButtons() {
    print(_editEnable);
    print(widget.customerId != null);
    return (_editEnable && widget.customerId != null)
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    Chat chat = new Chat(
                        id: -1,
                        chatPartnerId: widget.customerId!,
                        chatPartnerAvatarUrl: widget.customerAvtUrl,
                        chatPartnerFirstName: widget.customerFirstname!,
                        chatPartnerLastName: widget.customerLastname!,
                        educationInstitutionId: _post!.educationInstitutionId,
                        educationInstitutionName:
                            _post!.educationInstitutionName,
                        currentPostId: _post!.id,
                        currentPostName: _post!.name,
                        currentPostSalePrice: _post!.salePrice,
                        quantity: _post!.quantity,
                        sold: _post!.sold,
                        currentPostFirstMediaUrl:
                            _post!.media.first.originalUrl,
                        unReadMessageNumber: 0,
                        currentPostUserId: _post!.userId);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatPage(
                                  chat: chat,
                                )));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: _editEnable
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: [
                        Icon(Icons.chat_bubble_outline),
                        Text("Liên hệ ngay")
                      ],
                    ),
                  ),
                ),
              ),
              Wrap(
                spacing: 6,
                children: [
                  if (_post!.status == PostStatus.PENDING.name)
                    OutlinedButton.icon(
                      label:
                          Text('Từ chối', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: Colors.red)),
                      onPressed: () {
                        AppAlert.show(
                          context: context,
                          title: "Bạn có chắc muốn từ chối?",
                          actions: [
                            AlertAction(text: "Hủy"),
                            AlertAction(
                                text: "Xác nhận",
                                handler: () async {
                                  await PostService().rejectPostByStore(
                                      widget.postId, context);
                                  setState(() {
                                    _editEnable = false;
                                  });
                                },
                                isDestructive: true),
                          ],
                        );
                      },
                    ),
                  if (_post!.status == PostStatus.PENDING.name)
                    OutlinedButton.icon(
                      label: Text('Chấp nhận',
                          style: TextStyle(color: Colors.green)),
                      style: OutlinedButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: Colors.green)),
                      onPressed: () {
                        AppAlert.show(
                          context: context,
                          title: "Xác nhận chấp nhận?",
                          actions: [
                            AlertAction(text: "Hủy"),
                            AlertAction(
                                text: "Xác nhận",
                                handler: () async {
                                  await PostService().acceptPostByStore(
                                      widget.postId, context);
                                  setState(() {
                                    _editEnable = false;
                                  });
                                },
                                isDestructive: true),
                          ],
                        );
                      },
                    ),
                ],
              )
            ],
          )
        : SizedBox.shrink();
  }
}
