import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/app_colors.dart';
import 'package:eswap/main.dart';
import 'package:eswap/model/order.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:eswap/presentation/views/order/detail_order_item.dart';
import 'package:eswap/presentation/views/order/order_provider.dart';
import 'package:eswap/presentation/views/order/payment_momo_page.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/service/order_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderItem extends StatefulWidget {
  final Order order;

  const OrderItem({super.key, required this.order});

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool? isSellOrder;
  final orderService = OrderService();

  @override
  void initState() {
    super.initState();
    loadUserSession();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (isSellOrder != null) return _buildOrderItem(textTheme);
    return SizedBox.shrink();
  }

  Future<void> loadUserSession() async {
    final userSession = await UserSession.load();
    if (userSession!.userId == widget.order.sellerId) {
      setState(() {
        isSellOrder = true;
      });
    } else {
      setState(() {
        isSellOrder = false;
      });
    }
  }

  Widget _buildOrderItem(TextTheme textTheme) {
    final otherPartyName = isSellOrder!
        ? '${widget.order.buyerFirstName} ${widget.order.buyerLastName}'
        : '${widget.order.sellerFirstName} ${widget.order.sellerLastName}';

    return Card(
      margin: EdgeInsets.all(8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
                builder: (_) => DetailOrderItem(orderId: widget.order.id)),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image with shadow
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            )
                          ],
                          image: DecorationImage(
                            image: NetworkImage(widget.order.firstMediaUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(width: 12),

                  // Product info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.order.postName,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 8),

                        // Price and quantity row
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.lightPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${widget.order.quantity} × ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(widget.order.totalAmount / widget.order.quantity)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.lightPrimary,
                                ),
                              ),
                            ),
                            Spacer(),
                            Text(
                              NumberFormat.currency(
                                      locale: 'vi_VN', symbol: '₫')
                                  .format(widget.order.totalAmount),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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

              SizedBox(height: 16),

              // Divider with subtle style
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[200],
              ),

              SizedBox(height: 12),

              // Compact details
              _buildCompactDetailRow(
                icon: Icons.receipt,
                title: 'Mã đơn hàng',
                value: widget.order.id,
              ),

              _buildCompactDetailRow(
                icon: Icons.person,
                title: isSellOrder! ? 'Người mua' : 'Người bán',
                value: otherPartyName,
              ),

              _buildCompactDetailRow(
                icon: Icons.calendar_today,
                title: 'Ngày tạo',
                value: DateFormat('dd/MM/yyyy').format(widget.order.createdAt),
              ),
              if (widget.order.status == 'DEPOSITED')
                _buildCompactDetailRow(
                  icon: Icons.account_balance_wallet,
                  title: 'Đã đặt cọc',
                  value: NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                      .format(widget.order.depositAmount),
                ),
              _buildActionButtons(widget.order),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Order order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Wrap(
          spacing: 6,
          children: [
            if (isSellOrder! && order.status == OrderStatus.PENDING.name)
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
                                  order.id, context);
                              Provider.of<OrderProvider>(context, listen: false)
                                  .removeOrder(order.id);
                            })
                      ]);
                },
              ),
            // Chỉ người mua mới đặt cọc
            if (!isSellOrder! &&
                order.status == OrderStatus.AWAITING_DEPOSIT.name)
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
                        .depositByBuyer(order.id, "momo", context);
                    Provider.of<OrderProvider>(context, listen: false)
                        .removeOrder(order.id);
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
            if (isSellOrder! && order.status == OrderStatus.SELLER_ACCEPTS.name)
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
                              orderService.completeOrder(order.id, context);
                            })
                      ]);
                },
              ),
            // Chỉ người mua mới hoàn thành đơn đặt cọc
            if (!isSellOrder! && order.status == OrderStatus.DEPOSITED.name)
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
                              orderService.completeOrder(order.id, context);
                              Provider.of<OrderProvider>(context, listen: false)
                                  .removeOrder(order.id);
                            })
                      ]);
                },
              ),
            if (order.status != OrderStatus.COMPLETED.name &&
                order.status != OrderStatus.CANCELLED.name &&
                order.status != OrderStatus.DELETED.name)
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
                            orderService.cancelOrder(order.id, reason, context);
                            Provider.of<OrderProvider>(context, listen: false)
                                .removeOrder(order.id);
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

  Widget _buildCompactDetailRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          SizedBox(width: 8),
          Text(
            '$title: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: valueColor ?? Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
