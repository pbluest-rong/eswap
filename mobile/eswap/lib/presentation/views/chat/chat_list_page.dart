import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/app_colors.dart';
import 'package:eswap/model/chat_model.dart';
import 'package:eswap/model/message_model.dart';
import 'package:eswap/presentation/views/chat/chat_provider.dart';
import 'package:eswap/presentation/views/chat/chat_page.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/presentation/widgets/search.dart';
import 'package:eswap/service/chat_service.dart';
import 'package:eswap/service/websocket.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatList extends StatefulWidget {
  static const String route = '/chats';

  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  late final StreamSubscription<String> messagesSubscription;
  final ScrollController _scrollController = ScrollController();
  final _chatService = ChatService();
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  late String _keyword;
  late final TextEditingController _searchController = TextEditingController();
  late int? userId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _loadUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitial();
      _setupWebSocket();
    });
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt("userId");
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    messagesSubscription.cancel();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  int? newMessageId;

  void _setupWebSocket() async {
    WebSocketService.getInstance().then((ws) {
      messagesSubscription = ws.messageStream.listen((data) {
        if (!mounted) return;
        final chat = Chat.fromJson(json.decode(data));
        if (newMessageId == null ||
            newMessageId != chat.mostRecentMessage!.id) {
          newMessageId = chat.mostRecentMessage!.id;
          Provider.of<ChatProvider>(context, listen: false).addChat(chat);
        }
      });
    });
  }

  Future<void> _loadInitial() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _hasMore = true;
    });

    try {
      final chatsPage = await _chatService.fetchChats(
        _currentPage,
        _pageSize,
        context,
      );
      Provider.of<ChatProvider>(context, listen: false)
          .updateChats(chatsPage.content);
      setState(() {
        _hasMore = !chatsPage.last;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showErrorSnackBar(context, 'Error loading chats: ${e.toString()}');
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final chatsPage =
          await _chatService.fetchChats(_currentPage + 1, _pageSize, context);

      Provider.of<ChatProvider>(context, listen: false)
          .addChats(chatsPage.content);
      setState(() {
        _currentPage++;
        _hasMore = !chatsPage.last;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      showErrorSnackBar(context, 'Error loading more chats: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          child: AppSearch(
            hintText: "search".tr(),
            controller: _searchController,
            onSearch: (keyword) {
              setState(() {
                _keyword = keyword;
                _loadInitial();
              });
            },
          ),
        ),
      ),
      body: SafeArea(
          child: RefreshIndicator(
        onRefresh: _loadInitial,
        child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            cacheExtent: 1000,
            slivers: [
              if (_isLoading && chatProvider.chats.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!_isLoading && chatProvider.chats.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat, size: 50, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          "no_result_found".tr(),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: _loadInitial,
                          child: Text("retry".tr()),
                        ),
                      ],
                    ),
                  ),
                ),
              SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                if (index < chatProvider.chats.length) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      key: PageStorageKey(
                          'chat_${chatProvider.chats[index].id}'),
                      children: [
                        GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                            chat: chatProvider.chats[index],
                                          )));
                              chatProvider.markAsReadUI(index);
                              _chatService.markAsRead(
                                  chatProvider.chats[index].chatPartnerId);
                              chatProvider.markAsReadUI(index);
                            },
                            child:
                                _buildMessageItem(chatProvider.chats[index])),
                      ],
                    ),
                  );
                } else if (_hasMore) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return const SizedBox.shrink();
                }
              }, childCount: chatProvider.chats.length + (_hasMore ? 1 : 0)))
            ]),
      )),
    );
  }

  Widget _buildMessageItem(Chat chat) {
    return Container(
      color: Colors.transparent,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[200],
            backgroundImage: chat.chatPartnerAvatarUrl != null
                ? NetworkImage("${chat.chatPartnerAvatarUrl}")
                : null,
            child: chat.chatPartnerAvatarUrl == null
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${chat.chatPartnerFirstName} ${chat.chatPartnerLastName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                chat.mostRecentMessage != null
                    ? Text(
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        showShortMessage(chat, userId),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (chat.mostRecentMessage != null)
                Text(
                  isToday(chat.mostRecentMessage!.createdAt)
                      ? DateFormat('HH:mm')
                          .format(chat.mostRecentMessage!.createdAt)
                      : DateFormat('dd/MM/yyyy  HH:mm')
                          .format(chat.mostRecentMessage!.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              if (chat.unReadMessageNumber > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  constraints: BoxConstraints(minWidth: 20),
                  child: Text(
                    chat.unReadMessageNumber > 99
                        ? '99+'
                        : '${chat.unReadMessageNumber}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  String showShortMessage(Chat chat, int? currentUserId) {
    String senderName = currentUserId == null
        ? ""
        : chat.mostRecentMessage!.fromUserId == currentUserId
            ? "Bạn:"
            : "";
    switch (chat.mostRecentMessage!.contentType) {
      case ContentType.MEDIA:
        return "$senderName Đã gửi tệp đa phương tiện";
      case ContentType.POST:
        return "$senderName Đã trao đổi bài viết mới";
      case ContentType.LOCATION:
        return "$senderName Đã chia sẻ vị trí";
      case ContentType.DEAL:
        return "$senderName Đã gửi xác nhận trao đổi";
      default:
        return "$senderName ${chat.mostRecentMessage!.content}";
    }
  }
}
