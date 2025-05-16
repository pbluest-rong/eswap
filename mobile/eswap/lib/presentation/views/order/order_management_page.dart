import 'package:eswap/core/constants/app_colors.dart';
import 'package:eswap/main.dart';
import 'package:eswap/model/page_response.dart';
import 'package:eswap/model/post_model.dart';
import 'package:eswap/model/user_model.dart';
import 'package:eswap/presentation/components/post_item.dart';
import 'package:eswap/presentation/components/user_item.dart';
import 'package:eswap/presentation/provider/order_counter_provider.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:eswap/presentation/views/account/account_page.dart';
import 'package:eswap/presentation/views/order/order_list_page.dart';
import 'package:eswap/presentation/views/setting/settings_page.dart';
import 'package:eswap/presentation/widgets/password_tf.dart';
import 'package:eswap/service/order_service.dart';
import 'package:eswap/service/post_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage>
    with AutomaticKeepAliveClientMixin {
  UserSession? _userSession;
  final PostService _postService = PostService();
  List<Post> _allPosts = [];
  int _currentPage = 0;
  final int _pageSize = 6;
  bool _hasMore = true;
  bool _isLoadingPosts = false;
  bool _isLoadingMorePosts = false;
  final ScrollController _scrollController = ScrollController();
  final OrderService _orderService = OrderService();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _postService.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _loadMorePosts();
    }
  }

  Future<void> _loadInitialData() async {
    await loadSessionUser();
    await _loadInitialPosts();
    await _loadOrderCounter();
  }

  Future<void> loadSessionUser() async {
    final userSession = await UserSession.load();
    if (userSession != null) {
      setState(() {
        _userSession = userSession;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _currentPage = 0;
      _hasMore = true;
      _allPosts.clear();
    });
    await _loadInitialData();
  }

  Future<void> _loadOrderCounter() async {
    try {
      final jsonData = await _orderService.getOrderCounters();

      Provider.of<OrderCounterProvider>(context, listen: false)
          .updateFromJson(jsonData);
    } catch (e) {
      e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (_userSession != null)
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.lightPrimary,
                  child: AppBody(
                    child: _buildInfo(
                        _userSession!.userId,
                        _userSession!.firstName,
                        _userSession!.lastName,
                        _userSession!.avatarUrl,
                        _userSession!.educationInstitutionName),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  children: [
                    _buildBuyOrderListWidget(),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: const Divider(),
                    ),
                    _buildSaleOrderListWidget(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 40, height: 2, color: Colors.black45),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          "Có thể bạn cũng thích",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black45),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Container(width: 40, height: 2, color: Colors.black45),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _buildPostGrid(),
            if (_isLoadingMorePosts)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(int userId, String firstName, String lastName,
      String? avatarUrl, String educationInstitutionName) {
    return GestureDetector(
      onTap: () {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => DetailUserPage(userId: userId)),
        );
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[200],
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$firstName $lastName',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white),
                ),
                Text(
                  educationInstitutionName,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
          GestureDetector(
              onTap: () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(builder: (_) => SettingsPage()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(2.0),
                child: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
              ))
        ],
      ),
    );
  }

  Widget _buildBuyOrderListWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Đơn mua",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                      builder: (_) => OrderListPage(
                            isSellOrders: false,
                            orderStatus: 0,
                          )),
                );
              },
              child: const Row(
                children: [
                  Text(
                    "Xem lịch sử mua hàng",
                    style: TextStyle(fontSize: 12),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                  )
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOrderChoiceIcon(
                  Icons.hourglass_top_outlined,
                  "Chờ xác nhận",
                  Provider.of<OrderCounterProvider>(context, listen: true)
                      .buyerPendingOrderNumber, () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                      builder: (_) => OrderListPage(
                            isSellOrders: false,
                            orderStatus: 0,
                          )),
                );
              }),
              _buildOrderChoiceIcon(
                  Icons.check_circle_outline,
                  "Đã xác nhận",
                  Provider.of<OrderCounterProvider>(context, listen: true)
                      .buyerAcceptedOrderNumber, () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                      builder: (_) => OrderListPage(
                            isSellOrders: false,
                            orderStatus: 1,
                          )),
                );
              }),
              _buildOrderChoiceIcon(
                  Icons.payments_outlined,
                  "Đợi đặt cọc",
                  Provider.of<OrderCounterProvider>(context, listen: true)
                      .buyerAwaitingDepositNumber, () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                      builder: (_) => OrderListPage(
                            isSellOrders: false,
                            orderStatus: 2,
                          )),
                );
              }),
              _buildOrderChoiceIcon(
                  Icons.account_balance_wallet_outlined,
                  "Đã đặt cọc",
                  Provider.of<OrderCounterProvider>(context, listen: true)
                      .buyerDepositedOrderNumber, () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                      builder: (_) => OrderListPage(
                            isSellOrders: false,
                            orderStatus: 3,
                          )),
                );
              }),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSaleOrderListWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Đơn bán",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                      builder: (_) => OrderListPage(
                            isSellOrders: true,
                            orderStatus: 0,
                          )),
                );
              },
              child: const Row(
                children: [
                  Text(
                    "Xem lịch sử bán hàng",
                    style: TextStyle(fontSize: 12),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                  )
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOrderChoiceIcon(
                  Icons.mark_email_unread_outlined,
                  "Cần xác nhận",
                  Provider.of<OrderCounterProvider>(context, listen: true)
                      .sellerPendingOrderNumber, () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                      builder: (_) => OrderListPage(
                            isSellOrders: true,
                            orderStatus: 0,
                          )),
                );
              }),
              _buildOrderChoiceIcon(
                  Icons.verified_outlined,
                  "Đã xác nhận",
                  Provider.of<OrderCounterProvider>(context, listen: true)
                      .sellerAcceptedOrderNumber, () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                      builder: (_) => OrderListPage(
                            isSellOrders: true,
                            orderStatus: 1,
                          )),
                );
              }),
              _buildOrderChoiceIcon(
                  Icons.account_balance_wallet_outlined,
                  "Đã đặt cọc",
                  Provider.of<OrderCounterProvider>(context, listen: true)
                      .sellerDepositedOrderNumber, () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                      builder: (_) => OrderListPage(
                            isSellOrders: true,
                            orderStatus: 2,
                          )),
                );
              }),
              _buildOrderChoiceIcon(
                  Icons.done_all_sharp,
                  "Đã hoàn thành",
                  Provider.of<OrderCounterProvider>(context, listen: true)
                      .sellerCompletedOrderNumber, () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                      builder: (_) => OrderListPage(
                            isSellOrders: true,
                            orderStatus: 4,
                          )),
                );
              }),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildOrderChoiceIcon(
      IconData icon, String label, int number, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 30),
              if (number > 0)
                Positioned(
                  top: -9,
                  right: -9,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      number > 9 ? "9+" : "$number",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPostGrid() {
    if (_isLoadingPosts) {
      return const SliverToBoxAdapter(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_allPosts.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: const Text(
            "Chưa có bài đăng nào",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < _allPosts.length) {
            return PostItem(
              key: ValueKey('post_${_allPosts[index].id}_$index'),
              post: _allPosts[index],
              isGridView: true,
            );
          }
          return null;
        },
        childCount: _allPosts.length,
      ),
    );
  }

  Future<void> _loadInitialPosts() async {
    if (_isLoadingPosts || _userSession == null) return;

    setState(() {
      _isLoadingPosts = true;
      _currentPage = 0;
      _hasMore = true;
    });

    try {
      final postPage = await _postService.fetchRecommendPosts(
        _currentPage,
        _pageSize,
        context,
      );

      setState(() {
        _allPosts = postPage.content;
        _hasMore = !postPage.last;
        _isLoadingPosts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPosts = false;
      });
      // TODO: Handle error
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMorePosts || !_hasMore || _userSession == null) return;

    setState(() {
      _isLoadingMorePosts = true;
    });

    try {
      final postPage = await _postService.fetchRecommendPosts(
        _currentPage + 1,
        _pageSize,
        context,
      );

      setState(() {
        _currentPage++;
        _allPosts.addAll(postPage.content);
        _hasMore = !postPage.last;
        _isLoadingMorePosts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMorePosts = false;
      });
      // TODO: Handle error
    }
  }
}
