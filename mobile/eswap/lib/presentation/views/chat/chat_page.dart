import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/model/message_model.dart';
import 'package:eswap/model/user_model.dart';
import 'package:eswap/presentation/components/user_item.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/presentation/widgets/send_message.dart';
import 'package:eswap/service/chat_service.dart';
import 'package:eswap/service/websocket.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final int chatPartnerId;
  final String chatPartnerFirstName;
  final String chatPartnerLastName;
  final String? chatPartnerAvatarUrl;
  final int chatPartnerEducationInstitutionId;
  final String chatPartnerEducationInstitutionName;
  final int postId;
  final String postName;
  final double salePrice;
  final String firstMediaUrl;

  const ChatPage(
      {super.key,
      required this.chatPartnerId,
      required this.chatPartnerFirstName,
      required this.chatPartnerLastName,
      this.chatPartnerAvatarUrl,
      required this.chatPartnerEducationInstitutionId,
      required this.chatPartnerEducationInstitutionName,
      required this.postId,
      required this.postName,
      required this.salePrice,
      required this.firstMediaUrl});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  late List<Message> _messages;
  int _currentPage = 0;
  final int _pageSize = 10;
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
    _messages = [];
    _setupScrollListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialChat();
      _setupWebSocket();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialChat() async {
    if (!mounted || _isLoading) return;
    setState(() {
      _isLoading = true;
      _messages = [];
      _currentPage = 0;
      _hasMore = true;
      _initialScrollDone = false;
    });

    try {
      final messagesPage = await _chatService.fetchMessages(
          widget.chatPartnerId, _currentPage, _pageSize, context);

      setState(() {
        _messages = messagesPage.content.reversed.toList();
        _hasMore = !messagesPage.last;
        _isLoading = false;
      });

      if (_messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && !_initialScrollDone) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
            _initialScrollDone = true;
          }
        });
      }
    } catch (e, a) {
      print(a.toString());
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showErrorSnackbar(context, 'Error loading chat: ${e.toString()}');
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
          widget.chatPartnerId, _currentPage + 1, _pageSize, context);

      final previousMaxExtent = _scrollController.position.maxScrollExtent;
      final previousPixels = _scrollController.position.pixels;

      if (mounted) {
        setState(() {
          _currentPage++;
          _messages = List<Message>.from(messagePage.content.reversed.toList())
            ..addAll(_messages);
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
        showErrorSnackbar(
            context, 'Error loading more messages: ${e.toString()}');
      }
    }
  }

  bool isLink(String text) {
    final urlPattern = r'^(https?:\/\/)?([\w-]+\.)+[\w-]+(\/[\w-./?%&=]*)?$';
    final regex = RegExp(urlPattern);
    return regex.hasMatch(text.trim());
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      SendMessageRequest messageRequest = SendMessageRequest(
          chatPartnerId: widget.chatPartnerId,
          contentType: isLink(text) ? ContentType.LINK : ContentType.TEXT,
          content: text,
          postId: widget.postId);

      _chatService.sendMessage(
          sendMessageRequest: messageRequest, context: context);

      _messageController.clear();
      FocusScope.of(context).unfocus();
    }
    if (mediaFiles.isNotEmpty) {
      SendMessageRequest messageRequest = SendMessageRequest(
          chatPartnerId: widget.chatPartnerId,
          contentType: ContentType.MEDIA,
          postId: widget.postId);
      _chatService.sendMessage(
          sendMessageRequest: messageRequest,
          context: context,
          mediaFiles: mediaFiles);
    }
  }

  void _setupWebSocket() async {
    final WebSocketService webSocketService =
        await WebSocketService.getInstance();
    webSocketService.listenForNewMessage((message) {
      if (!mounted) return;

      Map<String, dynamic> messageJson = json.decode(message);
      Message newMessage = Message.fromJson(messageJson);
      setState(() {
        _messages = List<Message>.from(_messages)..add(newMessage);
      });

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
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
          leadingWidth: 32,
          leading: IconButton(
            padding: EdgeInsets.only(left: 10),
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          title: UserItemForList(
            user: UserInfomation(
                id: widget.chatPartnerId,
                username: null,
                firstname: widget.chatPartnerFirstName,
                lastname: widget.chatPartnerLastName,
                educationInstitutionName:
                    widget.chatPartnerEducationInstitutionName,
                avatarUrl: widget.chatPartnerAvatarUrl),
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
                        widget.firstMediaUrl,
                        widget.postName,
                        widget.salePrice,
                      ),
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

    if (_messages.isEmpty) {
      return Center(child: Text('no_messages_yet'.tr()));
    }

    return Scrollbar(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final message = _messages[index];
          return MessageBubble(
            key: ValueKey(message.id),
            message: message,
            isMe: !(message.fromUserId == widget.chatPartnerId),
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
}

Widget _buildCurrentPostWidget(
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
                    child: _buildVideoPlayer(urlList[i], context))
                : Container(
                    margin: (i != urlList.length - 1)
                        ? EdgeInsets.only(bottom: 10)
                        : null,
                    child: _buildImage(urlList[i], context))
        ]);
      case ContentType.POST:
        Map<String, dynamic> postData = json.decode(message.content);
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: _buildCurrentPostWidget(
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

  bool _isVideoMedia(String url) {
    return url.contains('video') ||
        url.endsWith('.mp4') ||
        url.endsWith('.mov') ||
        url.endsWith('.avi');
  }

  Widget _buildImage(String url, BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        width: MediaQuery.of(context).size.width * 0.4,
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error);
        },
      ),
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
