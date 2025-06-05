import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/app_colors.dart';
import 'package:eswap/main.dart';
import 'package:eswap/model/order.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:eswap/presentation/views/account/account_page.dart';
import 'package:eswap/presentation/views/order/order_provider.dart';
import 'package:eswap/presentation/views/order/payment_momo_page.dart';
import 'package:eswap/presentation/views/post/standalone_post.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/service/order_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailOrderItem extends StatefulWidget {
  final String orderId;

  const DetailOrderItem({super.key, required this.orderId});

  @override
  State<DetailOrderItem> createState() => _DetailOrderItemState();
}

class _DetailOrderItemState extends State<DetailOrderItem> {
  bool _isLoading = true;
  Order? order;
  bool? isSellOrder;
  final orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> loadUserSession() async {
    final userSession = await UserSession.load();
    if (userSession!.userId == order!.sellerId) {
      setState(() {
        isSellOrder = true;
      });
    } else {
      setState(() {
        isSellOrder = false;
      });
    }
  }

  Future<void> _fetchOrder() async {
    try {
      final OrderService orderService = OrderService();
      final response = await orderService.fetchById(widget.orderId, context);
      setState(() {
        order = response;
        _isLoading = false;
      });
      loadUserSession();
    } catch (e) {
      setState(() {
        _isLoading = false;
        order = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (isSellOrder == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final otherPartyName = isSellOrder!
        ? '${order!.buyerFirstName} ${order!.buyerLastName}'
        : '${order!.sellerFirstName} ${order!.sellerLastName}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn hàng'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order status card
                  _buildStatusCard(context),

                  const SizedBox(height: 20),

                  // Product information
                  Text('Thông tin sản phẩm',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 8),
                  GestureDetector(
                      onTap: () {
                        navigatorKey.currentState?.push(
                          MaterialPageRoute(
                              builder: (_) => StandalonePost(
                                    postId: order!.postId,
                                  )),
                        );
                      },
                      child: _buildProductInfo(context)),

                  const SizedBox(height: 20),

                  // Order information
                  Text('Thông tin đơn hàng',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 8),
                  _buildOrderInfo(context, otherPartyName),

                  const SizedBox(height: 20),

                  // Payment information
                  if (order!.status == 'DEPOSITED' ||
                      order!.status == 'COMPLETED')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Thông tin đặt cọc',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 8),
                        _buildPaymentInfo(context),
                        const SizedBox(height: 20),
                      ],
                    ),

                  // Action buttons
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (order!.status) {
      case 'PENDING':
        statusColor = Colors.orange;
        statusText = 'Chờ xác nhận';
        break;
      case 'SELLER_ACCEPTS':
        statusColor = Colors.blue;
        statusText = 'Đã xác nhận';
        break;
      case 'AWAITING_DEPOSIT':
        statusColor = Colors.orange;
        statusText = 'Đợi đặt cọc';
        break;
      case 'DEPOSITED':
        statusColor = Colors.green;
        statusText = 'Đã đặt cọc';
        break;
      case 'COMPLETED':
        statusColor = Colors.green;
        statusText = 'Đã hoàn thành';
        break;
      case 'CANCELLED':
        statusColor = Colors.red;
        statusText = 'Đã hủy';
        break;
      case 'DELETED':
        statusColor = Colors.grey;
        statusText = 'Đã hủy';
        break;
      default:
        statusColor = Colors.grey;
        statusText = order!.status;
    }

    return Card(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: statusColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    if (order!.cancelReason != null &&
                        (order!.status == 'CANCELLED' ||
                            order!.status == 'DELETED'))
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          order!.cancelReasonContent ??
                              order!.cancelReason ??
                              '',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(order!.firstMediaUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order!.postName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Số lượng',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const Spacer(),
                          Text(
                            order!.quantity.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Giá bán',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const Spacer(),
                          Text(
                            NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                                .format(order!.totalAmount / order!.quantity),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Tổng'.tr(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                                .format(order!.totalAmount),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo(BuildContext context, String otherPartyName) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.receipt,
              title: 'Mã đơn hàng',
              value: order!.id,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                      builder: (_) => DetailUserPage(
                          userId:
                              isSellOrder! ? order!.sellerId : order!.buyerId)),
                );
              },
              child: _buildInfoRow(
                icon: Icons.person,
                title: isSellOrder! ? 'Người mua' : 'Người bán',
                value: otherPartyName,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.calendar_today,
              title: 'Ngày tạo',
              value: DateFormat('HH:mm dd/MM/yyyy').format(order!.createdAt),
            ),
            if (order!.updatedAt != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.update,
                title: 'updated_at'.tr(),
                value: DateFormat('HH:mm dd/MM/yyyy').format(order!.updatedAt!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.account_balance_wallet,
              title: 'Đã đặt cọc'.tr(),
              value: NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                  .format(order!.depositAmount),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.payment,
              title: 'Phải trả'.tr(),
              value: NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                  .format(order!.remainingAmount),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Wrap(
          spacing: 6,
          children: [
            if (isSellOrder! && order!.status == OrderStatus.PENDING.name)
              OutlinedButton.icon(
                label: Text('Xác nhận', style: TextStyle(color: Colors.blue)),
                style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.blue)),
                onPressed: () {
                  AppAlert.show(
                      context: context,
                      title: "Chấp nhận bán cho người dùng này?",
                      actions: [
                        AlertAction(text: "Hủy"),
                        AlertAction(
                            text: "Xác nhận",
                            handler: () {
                              orderService.acceptNoDepositBySeller(
                                  order!.id, context);
                              Provider.of<OrderProvider>(context, listen: false)
                                  .removeOrder(order!.id);
                            })
                      ]);
                },
              ),
            // Chỉ người mua mới đặt cọc
            if (!isSellOrder! &&
                order!.status == OrderStatus.AWAITING_DEPOSIT.name)
              OutlinedButton.icon(
                label: Text('Đặt cọc', style: TextStyle(color: Colors.orange)),
                style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.orange)),
                onPressed: () async {
                  try {
                    OrderCreation orderCreation = await orderService
                        .depositByBuyer(order!.id, "momo", context);
                    Provider.of<OrderProvider>(context, listen: false)
                        .removeOrder(order!.id);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PaymentScreen(orderCreation: orderCreation),
                      ),
                    );
                  } catch (e) {
                    AppAlert.show(
                        context: context,
                        title:
                        "Đơn hàng đã yêu cầu thanh toán đặt cọc nhiều lần, vui lòng hủy đơn hàng",
                        actions: [AlertAction(text: "OK")]);
                  }
                },
              ),
            //Chỉ người bán mới hoàn thành đơn đã xác nhận
            if (isSellOrder! && order!.status == OrderStatus.SELLER_ACCEPTS.name)
              OutlinedButton.icon(
                label:
                Text('Hoàn thành', style: TextStyle(color: Colors.green)),
                style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.green)),
                onPressed: () {
                  AppAlert.show(
                      context: context,
                      title: "Xác nhận đã bán đơn hàng",
                      actions: [
                        AlertAction(text: "Hủy"),
                        AlertAction(
                            text: "Xác nhận",
                            handler: () {
                              orderService.completeOrder(order!.id, context);
                            })
                      ]);
                },
              ),
            // Chỉ người mua mới hoàn thành đơn đặt cọc
            if (!isSellOrder! && order!.status == OrderStatus.DEPOSITED.name)
              OutlinedButton.icon(
                label:
                Text('Hoàn thành', style: TextStyle(color: Colors.green)),
                style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.green)),
                onPressed: () {
                  AppAlert.show(
                      context: context,
                      title: "Xác nhận đã mua đơn hàng",
                      actions: [
                        AlertAction(text: "Hủy"),
                        AlertAction(
                            text: "Xác nhận",
                            handler: () {
                              orderService.completeOrder(order!.id, context);
                              Provider.of<OrderProvider>(context, listen: false)
                                  .removeOrder(order!.id);
                            })
                      ]);
                },
              ),
            if (order!.status != OrderStatus.COMPLETED.name &&
                order!.status != OrderStatus.CANCELLED.name &&
                order!.status != OrderStatus.DELETED.name)
              OutlinedButton.icon(
                label: Text('Hủy bỏ', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.red)),
                onPressed: () {
                  TextEditingController _reasonController =
                  TextEditingController();
                  AppAlert.show(
                    context: context,
                    centerWidget: TextField(
                      controller: _reasonController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: "Vui lòng nhập lý do hủy",
                      ),
                    ),
                    title: "Bạn có chắc muốn hủy bỏ đơn hàng?",
                    actions: [
                      AlertAction(text: "Hủy"),
                      AlertAction(
                          text: "Xác nhận",
                          handler: () {
                            final reason = _reasonController.text.trim();
                            if (reason.isEmpty) {
                              AppAlert.show(
                                  context: context,
                                  title: "Vui lòng nhập lý do hủy đơn hàng",
                                  actions: [AlertAction(text: "OK")]);
                              return;
                            }
                            orderService.cancelOrder(order!.id, reason, context);
                            Provider.of<OrderProvider>(context, listen: false)
                                .removeOrder(order!.id);
                          },
                          isDestructive: true),
                    ],
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}
