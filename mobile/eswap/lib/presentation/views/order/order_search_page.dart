import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/model/order.dart';
import 'package:eswap/presentation/components/order_item.dart';
import 'package:eswap/presentation/widgets/search.dart';
import 'package:eswap/service/order_service.dart';
import 'package:flutter/material.dart';

class OrderSearchPage extends StatefulWidget {
  OrderSearchPage({super.key});

  @override
  State<OrderSearchPage> createState() => _OrderSearchPageState();
}

class _OrderSearchPageState extends State<OrderSearchPage> {
  bool isBeforeTakingActionFind = true;
  final ScrollController _scrollController = ScrollController();
  final _orderService = OrderService();
  List<Order> _allOrders = [];
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  late String _keyword;
  late final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupScrollListener();
  }

  Future<void> _loadInitialOrders() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _allOrders = [];
      _currentPage = 0;
      _hasMore = true;
    });

    try {
      final ordersPage = await _orderService.findOrders(
        _keyword,
        _currentPage,
        _pageSize,
        context,
      );

      setState(() {
        _allOrders = ordersPage.content;
        _hasMore = !ordersPage.last;
        _isLoading = false;
        if (isBeforeTakingActionFind) {
          isBeforeTakingActionFind = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreUser() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final ordersPage = await _orderService.findOrders(
          _keyword, _currentPage + 1, _pageSize, context);

      setState(() {
        _currentPage++;
        _allOrders.addAll(ordersPage.content);
        _hasMore = !ordersPage.last;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: SizedBox(
          child: AppSearch(
            controller: _searchController,
            onSearch: (keyword) {
              setState(() {
                _keyword = keyword;
                _loadInitialOrders();
              });
            },
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
          child: RefreshIndicator(
              onRefresh: _loadInitialOrders,
              child: isBeforeTakingActionFind
                  ? Center(
                      child: Text(
                        "Tìm kiếm theo tên người bán, người mua, ID đơn hàng, tên sản phẩm",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      cacheExtent: 1000,
                      slivers: [
                        if (_isLoading && _allOrders.isEmpty)
                          const SliverFillRemaining(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        if (!_isLoading && _allOrders.isEmpty)
                          SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.shopping_bag_outlined,
                                      size: 50, color: Colors.grey),
                                  const SizedBox(height: 16),
                                  Text(
                                    "no_result_found".tr(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _loadInitialOrders,
                                    child: Text("retry".tr()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SliverList(
                            delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index < _allOrders.length) {
                              return Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  key: PageStorageKey(
                                      'order_${_allOrders[index].id}'),
                                  children: [
                                    OrderItem(order: _allOrders[index])
                                  ],
                                ),
                              );
                            } else if (_hasMore) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                          },
                          childCount: _allOrders.length + (_hasMore ? 1 : 0),
                          addAutomaticKeepAlives: true,
                          addRepaintBoundaries: true,
                        ))
                      ],
                    ))),
    );
  }
}
