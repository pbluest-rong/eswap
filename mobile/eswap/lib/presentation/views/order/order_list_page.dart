import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/app_colors.dart';
import 'package:eswap/main.dart';
import 'package:eswap/model/order.dart';
import 'package:eswap/presentation/components/order_item.dart';
import 'package:eswap/presentation/views/order/order_provider.dart';
import 'package:eswap/presentation/views/order/order_search_page.dart';
import 'package:eswap/service/order_service.dart';
import 'package:eswap/service/websocket.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderListPage extends StatefulWidget {
  bool isSellOrders;
  int orderStatus;

  OrderListPage(
      {super.key, required this.isSellOrders, required this.orderStatus});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final _orderService = OrderService();
  late int orderStatusChoice;
  final ScrollController _statusScrollController = ScrollController();
  List<String> buyChoice = [
    "Chờ xác nhận",
    "Đã xác nhận",
    "Đợi đặt cọc",
    "Đã đặt cọc",
    "Đã hủy",
    "Đã hoàn thành"
  ];

  List<String> sellChoice = [
    "Cần xác nhận",
    "Đã xác nhận",
    "Đã đặt cọc",
    "Đã hủy",
    "Đã hoàn thành"
  ];
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    orderStatusChoice = widget.orderStatus;
    _setupWebSocket();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadInitialOrders();
  }

  @override
  void dispose() {
    _statusScrollController.dispose();
    super.dispose();
  }

  bool _initialized = false;

  Future<void> _loadInitialOrders() async {
    if (_isLoading || _initialized) return;

    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _hasMore = true;
      _initialized = true;
    });
    try {
      final ordersPage = await _orderService.fetchOrders(widget.isSellOrders,
          orderStatusChoice, _currentPage, _pageSize, context);

      if (widget.isSellOrders) {
        if (orderStatusChoice == 0) {
          Provider.of<OrderProvider>(context, listen: false)
              .initOrders(true, OrderStatus.PENDING, ordersPage.content);
        } else if (orderStatusChoice == 1) {
          Provider.of<OrderProvider>(context, listen: false)
              .initOrders(true, OrderStatus.SELLER_ACCEPTS, ordersPage.content);
        } else if (orderStatusChoice == 2) {
          Provider.of<OrderProvider>(context, listen: false)
              .initOrders(true, OrderStatus.DEPOSITED, ordersPage.content);
        } else if (orderStatusChoice == 3) {
          Provider.of<OrderProvider>(context, listen: false)
              .initOrders(true, OrderStatus.CANCELLED, ordersPage.content);
        } else if (orderStatusChoice == 4) {
          Provider.of<OrderProvider>(context, listen: false)
              .initOrders(true, OrderStatus.COMPLETED, ordersPage.content);
        }
      } else {
        if (orderStatusChoice == 0) {
          Provider.of<OrderProvider>(context, listen: false)
              .initOrders(false, OrderStatus.PENDING, ordersPage.content);
        } else if (orderStatusChoice == 1) {
          Provider.of<OrderProvider>(context, listen: false).initOrders(
              false, OrderStatus.SELLER_ACCEPTS, ordersPage.content);
        } else if (orderStatusChoice == 2) {
          Provider.of<OrderProvider>(context, listen: false).initOrders(
              false, OrderStatus.AWAITING_DEPOSIT, ordersPage.content);
        } else if (orderStatusChoice == 3) {
          Provider.of<OrderProvider>(context, listen: false)
              .initOrders(false, OrderStatus.DEPOSITED, ordersPage.content);
        } else if (orderStatusChoice == 4) {
          Provider.of<OrderProvider>(context, listen: false)
              .initOrders(false, OrderStatus.CANCELLED, ordersPage.content);
        } else if (orderStatusChoice == 5) {
          Provider.of<OrderProvider>(context, listen: false)
              .initOrders(false, OrderStatus.COMPLETED, ordersPage.content);
        }
      }

      setState(() {
        _hasMore = !ordersPage.last;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreOrders() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final ordersPage = await _orderService.fetchOrders(widget.isSellOrders,
          orderStatusChoice, _currentPage + 1, _pageSize, context);

      Provider.of<OrderProvider>(context, listen: false)
          .addMoreOrders(ordersPage.content);

      setState(() {
        _currentPage++;
        _hasMore = !ordersPage.last;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _setupWebSocket() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await WebSocketService.getInstance()
        .then((ws) => ws.initializeWithProvider(orderProvider));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    List<Order> allOrders =
        Provider.of<OrderProvider>(context, listen: true).orders;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.isSellOrders ? "Lịch sử bán hàng" : "Lịch sử mua hàng",
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              navigatorKey.currentState?.push(
                MaterialPageRoute(builder: (_) => OrderSearchPage()),
              );
            }),
            icon: Icon(Icons.search, color: Colors.black, size: 24),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 5),
            color: AppColors.lightBackground,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _statusScrollController,
              child: Row(
                children: List.generate(
                  widget.isSellOrders ? sellChoice.length : buyChoice.length,
                  (index) => _buildOrderStatusButton(
                    widget.isSellOrders,
                    index,
                    textTheme,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
              child: _isLoading && allOrders.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : allOrders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_bag_outlined,
                                  size: 50, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                "Chưa có đơn hàng nào",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: allOrders.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < allOrders.length) {
                              return Column(
                                key: PageStorageKey(
                                    'order_${allOrders[index].id}'),
                                children: [
                                  OrderItem(
                                      key: ValueKey(allOrders[index].id),
                                      order: allOrders[index])
                                ],
                              );
                            } else {
                              if (!_initialized) {
                                return Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          backgroundColor: Colors.white10,
                                        ),
                                        onPressed: () {
                                          _isLoadingMore
                                              ? null
                                              : _loadMoreOrders();
                                        },
                                        child: _isLoadingMore
                                            ? const CircularProgressIndicator()
                                            : Text(
                                                "show_more".tr(),
                                                style: textTheme.titleSmall!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    )
                                  ],
                                );
                              }
                            }
                          },
                        ))
        ],
      ),
    );
  }

  Widget _buildOrderStatusButton(
      bool isSellOrders, int orderStatus, TextTheme textTheme) {
    final statusList = isSellOrders ? sellChoice : buyChoice;
    int number = 0;

    final provider = Provider.of<OrderProvider>(context, listen: true);

    if (isSellOrders) {
      switch (orderStatus) {
        case 0:
          number = provider.sellerPendingOrderNumber;
          break;
        case 1:
          number = provider.sellerAcceptedOrderNumber;
          break;
        case 2:
          number = provider.sellerDepositedOrderNumber;
          break;
        case 3:
          number = provider.sellerCancelledOrderNumber;
          break;
        case 4:
          number = provider.sellerCompletedOrderNumber;
          break;
      }
    } else {
      switch (orderStatus) {
        case 0:
          number = provider.buyerPendingOrderNumber;
          break;
        case 1:
          number = provider.buyerAcceptedOrderNumber;
          break;
        case 2:
          number = provider.buyerAwaitingDepositNumber;
          break;
        case 3:
          number = provider.buyerDepositedOrderNumber;
          break;
        case 4:
          number = provider.buyerCancelledOrderNumber;
          break;
        case 5:
          number = provider.buyerCompletedOrderNumber;
          break;
      }
    }

    return Builder(
      builder: (contextButton) => TextButton(
        onPressed: () {
          _initialized = false;
          orderStatusChoice = orderStatus;
          _loadInitialOrders();

          Scrollable.ensureVisible(
            contextButton,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            alignment: 0.5,
          );
        },
        child: Row(
          children: [
            Text(
              statusList[orderStatus],
              style: textTheme.titleSmall!.copyWith(
                color: orderStatusChoice == orderStatus
                    ? AppColors.lightPrimary
                    : Colors.black,
              ),
            ),
            if (number > 0)
              Text(
                " ($number)",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              )
          ],
        ),
      ),
    );
  }
}
