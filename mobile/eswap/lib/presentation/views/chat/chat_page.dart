import 'dart:async';
import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/app_colors.dart';
import 'package:eswap/main.dart';
import 'package:eswap/model/chat_model.dart';
import 'package:eswap/model/message_model.dart';
import 'package:eswap/model/user_model.dart';
import 'package:eswap/presentation/components/quantity_selector.dart';
import 'package:eswap/presentation/components/user_item.dart';
import 'package:eswap/presentation/provider/user_provider.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:eswap/presentation/views/chat/chat_provider.dart';
import 'package:eswap/presentation/views/order/create_order_page.dart';
import 'package:eswap/presentation/views/post/standalone_post.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/presentation/widgets/send_message.dart';
import 'package:eswap/service/chat_service.dart';
import 'package:eswap/service/websocket.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class ChatPage extends StatefulWidget {
  static const String route = '/chats';
  final Chat chat;

  const ChatPage({super.key, required this.chat});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  UserSession? userSession;
  late final StreamSubscription<String> messagesSubscription;
  final _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  int _currentPage = 0;
  final int _pageSize = 15;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _initialScrollDone = false;
  DateTime _lastLoadTime = DateTime.now();
  final _loadThreshold = Duration(seconds: 1);
  bool _showScrollDownButton = false;
  List<String> mediaFiles = [];

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _loadUserSession();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadInitialChat();
      _setupWebSocket();
      _setIsChatNotify(true);
    });
  }

  Future<void> _loadUserSession() async {
    final session = await UserSession.load();
    if (mounted) {
      setState(() {
        userSession = session;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.chat.unReadMessageNumber > 0) {
        Provider.of<UserSessionProvider>(context, listen: false)
            .minusUnreadMessageNumber(widget.chat.unReadMessageNumber);
      }
    });
  }

  Future<void> _setIsChatNotify(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isChatNotify", value);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    messagesSubscription.cancel();
    _setIsChatNotify(false);
    super.dispose();
  }

  Future<void> _loadInitialChat() async {
    if (!mounted || _isLoading) return;
    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _hasMore = true;
      _initialScrollDone = false;
    });

    try {
      final messagesPage = await _chatService.fetchMessages(
          widget.chat.chatPartnerId, _currentPage, _pageSize, context);

      Provider.of<ChatProvider>(context, listen: false)
          .updateMessages(messagesPage.content.reversed.toList());
      setState(() {
        _hasMore = !messagesPage.last;
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController
              .jumpTo(_scrollController.position.maxScrollExtent + 200);
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreOldMessage() async {
    if (_isLoadingMore || !_hasMore) return;

    if (mounted) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final messagePage = await _chatService.fetchMessages(
          widget.chat.chatPartnerId, _currentPage + 1, _pageSize, context);

      if (messagePage.content.isEmpty) {
        setState(() {
          _hasMore = false;
          _isLoadingMore = false;
        });
        return;
      }
      final previousMaxExtent = _scrollController.position.maxScrollExtent;
      final previousPixels = _scrollController.position.pixels;

      if (mounted) {
        Provider.of<ChatProvider>(context, listen: false)
            .addMessages(messagePage.content.reversed.toList());
        setState(() {
          _currentPage++;
          _hasMore = !messagePage.last;
          _isLoadingMore = false;
        });
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final newMaxExtent = _scrollController.position.maxScrollExtent;
          final scrollTo = previousPixels + (newMaxExtent - previousMaxExtent);
          _scrollController.jumpTo(scrollTo);
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  bool isLink(String text) {
    final urlPattern = r'^(https?:\/\/)?([\w-]+\.)+[\w-]+(\/[\w-./?%&=]*)?$';
    final regex = RegExp(urlPattern);
    return regex.hasMatch(text.trim());
  }

  void _handleSend() {
    Provider.of<ChatProvider>(context, listen: false).setSendingMessage(true);
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      SendMessageRequest messageRequest = SendMessageRequest(
          chatPartnerId: widget.chat.chatPartnerId,
          contentType: isLink(text) ? ContentType.LINK : ContentType.TEXT,
          content: text,
          postId: widget.chat.currentPostId);

      _chatService.sendMessage(
          sendMessageRequest: messageRequest, context: context);

      _messageController.clear();
      FocusScope.of(context).unfocus();
    }
    if (mediaFiles.isNotEmpty) {
      SendMessageRequest messageRequest = SendMessageRequest(
          chatPartnerId: widget.chat.chatPartnerId,
          contentType: ContentType.MEDIA,
          postId: widget.chat.currentPostId);
      _chatService.sendMessage(
          sendMessageRequest: messageRequest,
          context: context,
          mediaFiles: mediaFiles);
    }
  }

  int? newMessageId;

  void _setupWebSocket() async {
    await _loadUserSession();
    WebSocketService.getInstance().then((ws) {
      messagesSubscription = ws.messageStream.listen((data) {
        if (!mounted) return;
        final chat = Chat.fromJson(json.decode(data));

        // current Post
        if (newMessageId == null ||
            newMessageId != chat.mostRecentMessage!.id) {
          newMessageId = chat.mostRecentMessage!.id;
          Provider.of<ChatProvider>(context, listen: false).addChat(chat);
          // Notify
          if (_scrollController.offset <
              _scrollController.position.maxScrollExtent - 300) {
            if (userSession!.userId != chat.chatPartnerId) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Có tin nhắn mới"),
                  duration: const Duration(seconds: 3),
                  backgroundColor: Colors.grey,
                ),
              );
            }
          }
        }
        _scrollDown();
      });
    });
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Load more when scrolled near the top
      if (_scrollController.position.pixels <= 200 &&
          !_isLoadingMore &&
          _hasMore &&
          DateTime.now().difference(_lastLoadTime) > _loadThreshold) {
        _lastLoadTime = DateTime.now();
        _loadMoreOldMessage();
      }

      // Phần show/ẩn nút scroll down cũng nên nằm trong listener này luôn
      if (_scrollController.offset <
          _scrollController.position.maxScrollExtent - 700) {
        if (!_showScrollDownButton) {
          setState(() {
            _showScrollDownButton = true;
          });
        }
      } else {
        if (_showScrollDownButton) {
          setState(() {
            _showScrollDownButton = false;
          });
        }
      }
    });

    // Ban đầu (sau khi build) mới kiểm tra một lần
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (_scrollController.offset <
            _scrollController.position.maxScrollExtent - 200) {
          setState(() {
            _showScrollDownButton = true;
          });
        } else {
          setState(() {
            _showScrollDownButton = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: GestureDetector(
              onTap: () async {
                _setIsChatNotify(false);
                Navigator.pop(context);
                _chatService.markAsRead(widget.chat.chatPartnerId);
              },
              child: Icon(Icons.arrow_back_ios)),
          title: UserItemForList(
            user: UserInfomation(
                id: widget.chat.chatPartnerId,
                waitingAcceptFollow: false,
                username: null,
                firstname: widget.chat.chatPartnerFirstName,
                lastname: widget.chat.chatPartnerLastName,
                educationInstitutionName: widget.chat.educationInstitutionName,
                avatarUrl: widget.chat.chatPartnerAvatarUrl),
          ),
          actions: [
            IconButton(
              onPressed: () => setState(() {}),
              icon: Icon(Icons.more_vert),
            )
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                _isLoading
                    ? SizedBox.shrink()
                    : _buildCurrentPostWidget(
                        widget.chat.currentPostId,
                        widget.chat.currentPostFirstMediaUrl,
                        widget.chat.currentPostName,
                        widget.chat.currentPostSalePrice,
                        widget.chat.quantity,
                        widget.chat.sold),
                Expanded(child: _buildMessagesWidget()),
                _buildSendMessageWidget(),
              ],
            ),
            if (_showScrollDownButton)
              Positioned(
                right: 16,
                bottom: 90,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: _scrollDown,
                  child: Icon(Icons.arrow_circle_down),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesWidget() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (Provider.of<ChatProvider>(context, listen: true).messages.isEmpty) {
      return Center(child: Text('no_messages_yet'.tr()));
    }

    return Scrollbar(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        itemCount:
            Provider.of<ChatProvider>(context, listen: true).messages.length +
                (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index ==
              Provider.of<ChatProvider>(context, listen: true)
                  .messages
                  .length) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final message =
              Provider.of<ChatProvider>(context, listen: true).messages[index];
          return MessageBubble(
            key: ValueKey(message.id),
            message: message,
            isMe: !(message.fromUserId == widget.chat.chatPartnerId),
          );
        },
      ),
    );
  }

  Widget _buildSendMessageWidget() {
    return Container(
      margin: EdgeInsets.only(left: 14, right: 14, top: 14, bottom: 24),
      child: SendMessageWidget(
        controller: _messageController,
        onSend: _handleSend,
        mediaFiles: mediaFiles,
      ),
    );
  }

  Widget _buildCurrentPostWidget(int postId, String firstMediaUrl,
      String postName, double salePrice, int quantity, int sold) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    firstMediaUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        postName ?? 'Không có tiêu đề',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Số lượng: ",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "$quantity",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Đã bán: ",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "$sold",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Giá bán: ",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "${salePrice} VND",
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              margin: EdgeInsets.only(top: 8, bottom: 8, right: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap: () {
                        navigatorKey.currentState?.push(
                          MaterialPageRoute(
                              builder: (_) => StandalonePost(postId: postId)),
                        );
                      },
                      child: Icon(Icons.arrow_forward_ios)),
                  if (userSession != null &&
                      userSession!.userId != widget.chat.currentPostUserId &&
                      userSession!.userId != widget.chat.chatPartnerId &&
                      widget.chat.quantity > widget.chat.sold)
                    GestureDetector(
                        onTap: () {
                          int purchaseQuantity = 1;
                          AppAlert.show(
                            centerWidget: (quantity > sold)
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      QuantitySelector(
                                        initialValue: 1,
                                        maxValue: quantity - sold,
                                        onChanged: (q) {
                                          purchaseQuantity = q;
                                        },
                                      ),
                                    ],
                                  )
                                : null,
                            context: context,
                            title: 'Bạn muốn mua bao nhiêu?',
                            buttonLayout: AlertButtonLayout.dual,
                            actions: [
                              AlertAction(text: 'Hủy', handler: () {}),
                              AlertAction(
                                  text: 'Xác nhận',
                                  handler: () {
                                    navigatorKey.currentState?.push(
                                      MaterialPageRoute(
                                          builder: (_) => CreateOrder(
                                              userId: userSession!.userId,
                                              postId: postId,
                                              postName: postName,
                                              firstMediaUrl: firstMediaUrl,
                                              salePrice: salePrice,
                                              purchaseQuantity:
                                                  purchaseQuantity)),
                                    );
                                  }),
                            ],
                          );
                        },
                        child: Icon(
                          Icons.add_shopping_cart,
                          color: AppColors.lightPrimary,
                          size: 28,
                        )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bubbleAlignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isMe ? Colors.blue[200] : Colors.grey[300];
    final textColor = isMe ? Colors.black : Colors.black;
    final margin = isMe
        ? const EdgeInsets.only(left: 50, top: 8, bottom: 8, right: 8)
        : const EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 50);

    return Align(
      alignment: bubbleAlignment,
      child: Container(
        margin: margin,
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: (message.contentType != ContentType.MEDIA &&
                      message.contentType != ContentType.POST)
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                  : EdgeInsets.zero,
              decoration: BoxDecoration(
                color: (message.contentType != ContentType.MEDIA &&
                        message.contentType != ContentType.POST)
                    ? bubbleColor
                    : null,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(message, context),
                ],
              ),
            ),
            Container(
              margin:
                  isMe ? EdgeInsets.only(right: 8) : EdgeInsets.only(left: 8),
              child: (message.contentType == ContentType.POST)
                  ? SizedBox.shrink()
                  : Text(
                      isToday(message.createdAt)
                          ? DateFormat('HH:mm').format(message.createdAt)
                          : DateFormat('dd/MM/yyyy  HH:mm')
                              .format(message.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(Message message, BuildContext context) {
    switch (message.contentType) {
      case ContentType.TEXT:
        return Text(
          message.content,
          style: const TextStyle(fontSize: 16),
        );
      case ContentType.LINK:
        return InkWell(
          onTap: () {},
          child: Text(
            message.content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
        );
      case ContentType.LOCATION:
        return Column(
          children: [
            const Icon(Icons.location_on, size: 40, color: Colors.red),
            Text(
              message.content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        );
      case ContentType.MEDIA:
        List<String> urlList = List<String>.from(jsonDecode(message.content));
        return Column(children: [
          for (int i = 0; i < urlList.length; i++)
            _isVideoMedia(urlList[i])
                ? Container(
                    margin: (i != urlList.length - 1)
                        ? EdgeInsets.only(bottom: 10)
                        : null,
                    child: Chewie(
                      controller: ChewieController(
                        videoPlayerController:
                            VideoPlayerController.network(urlList[i]),
                        autoPlay: false,
                        looping: false,
                        allowFullScreen: true,
                      ),
                    ))
                : Container(
                    margin: (i != urlList.length - 1)
                        ? EdgeInsets.only(bottom: 10)
                        : null,
                    child: GestureDetector(
                      onTap: () {
                        // Mở ảnh fullscreen
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                  backgroundColor: Colors.black,
                                  iconTheme:
                                      const IconThemeData(color: Colors.white),
                                  leading: IconButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      icon: const Icon(Icons.arrow_back_ios)),
                                ),
                                body: Center(
                                  child: PhotoView(
                                    imageProvider: NetworkImage(urlList[i]),
                                    minScale: PhotoViewComputedScale.contained,
                                    maxScale:
                                        PhotoViewComputedScale.covered * 2,
                                    heroAttributes: PhotoViewHeroAttributes(
                                        tag: urlList[i]),
                                  ),
                                ),
                              ),
                            ));
                      },
                      child: _buildImage(urlList[i], context),
                    ))
        ]);
      case ContentType.POST:
        Map<String, dynamic> postData = json.decode(message.content);
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: _buildNewPostForMessage(
            postData['firstMediaUrl'],
            postData['postName'],
            postData['salePrice'],
          ),
        );
      default:
        return Text(
          message.content,
          style: const TextStyle(fontSize: 16),
        );
    }
  }

  Widget _buildNewPostForMessage(
      String firstMediaUrl, String postName, double salePrice) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    firstMediaUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        postName ?? 'Không có tiêu đề',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Giá bán: ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "${salePrice} VND",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isVideoMedia(String url) {
    return url.contains('video') ||
        url.endsWith('.mp4') ||
        url.endsWith('.mov') ||
        url.endsWith('.avi');
  }

  Widget _buildImage(String url, BuildContext context) {
    return FutureBuilder(
      future: precacheImage(NetworkImage(url), context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              width: MediaQuery.of(context).size.width * 0.4,
              url,
              fit: BoxFit.cover,
            ),
          );
        }
        return Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: 200, // Set a fixed height while loading
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildVideoPlayer(String url, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.play_circle_fill, size: 50, color: Colors.white),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'VIDEO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
