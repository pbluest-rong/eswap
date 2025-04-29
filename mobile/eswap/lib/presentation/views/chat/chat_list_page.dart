import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/app_colors.dart';
import 'package:eswap/model/chat_model.dart';
import 'package:eswap/model/message_model.dart';
import 'package:eswap/presentation/views/chat/chat_page.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/presentation/widgets/search.dart';
import 'package:eswap/service/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatList extends StatefulWidget {
  static const String route = '/chats';

  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final ScrollController _scrollController = ScrollController();
  final _chatService = ChatService();
  List<Chat> _allChats = [];
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadInitial();
    _setupScrollListener();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt("userId");
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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

  Future<void> _loadInitial() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _allChats = [];
      _currentPage = 0;
      _hasMore = true;
    });

    try {
      final chatsPage = await _chatService.fetchChats(
        _currentPage,
        _pageSize,
        context,
      );

      setState(() {
        _allChats = chatsPage.content;
        _hasMore = !chatsPage.last;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showErrorSnackbar(context, 'Error loading chats: ${e.toString()}');
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

      setState(() {
        _currentPage++;
        _allChats.addAll(chatsPage.content);
        _hasMore = !chatsPage.last;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      showErrorSnackbar(context, 'Error loading more chats: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              if (_isLoading && _allChats.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!_isLoading && _allChats.isEmpty)
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
              SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                if (index < _allChats.length) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      key: PageStorageKey('chat_${_allChats[index].id}'),
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                          chatPartnerId:
                                              _allChats[index].chatPartnerId,
                                          chatPartnerAvatarUrl: _allChats[index]
                                              .chatPartnerAvatarUrl,
                                          chatPartnerFirstName: _allChats[index]
                                              .chatPartnerFirstName,
                                          chatPartnerLastName: _allChats[index]
                                              .chatPartnerLastName,
                                          chatPartnerEducationInstitutionId:
                                              _allChats[index]
                                                  .educationInstitutionId,
                                          chatPartnerEducationInstitutionName:
                                              _allChats[index]
                                                  .educationInstitutionName,
                                          postId:
                                              _allChats[index].currentPostId,
                                          postName:
                                              _allChats[index].currentPostName,
                                          salePrice: _allChats[index]
                                              .currentPostSalePrice,
                                          firstMediaUrl: _allChats[index]
                                              .currentPostFirstMediaUrl)));
                            },
                            child: _buildMessageItem(_allChats[index])),
                      ],
                    ),
                  );
                } else if (_hasMore) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              }))
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
      default:
        return "$senderName ${chat.mostRecentMessage!.content}";
    }
  }
}
