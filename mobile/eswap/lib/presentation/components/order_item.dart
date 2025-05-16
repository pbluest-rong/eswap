import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/app_colors.dart';
import 'package:eswap/model/order.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:flutter/material.dart';

class OrderItem extends StatefulWidget {
  Order order;

  OrderItem({super.key, required this.order});

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool isSellOrder = false;

  @override
  void initState() {
    super.initState();
    loadUserSession();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return _buildOrderItem(widget.order, textTheme);
  }

  Future<void> loadUserSession() async {
    final userSession = await UserSession.load();
    if (userSession!.userId == widget.order.sellerId) {
      setState(() {
        isSellOrder = true;
      });
    }
  }

  Widget _buildOrderItem(Order order, TextTheme textTheme) {
    final otherPartyName = isSellOrder
        ? '${order.buyerFirstName} ${order.buyerLastName}'
        : '${order.sellerFirstName} ${order.sellerLastName}';

    return Card(
      margin: EdgeInsets.all(8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle tap on entire card
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
                            image: NetworkImage(order.firstMediaUrl),
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
                          order.postName,
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
                                '${order.quantity} × ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(order.totalAmount / order.quantity)}',
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
                                  .format(order.totalAmount),
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
                value: order.id,
              ),

              _buildCompactDetailRow(
                icon: Icons.person,
                title: isSellOrder ? 'Người mua' : 'Người bán',
                value: otherPartyName,
              ),

              _buildCompactDetailRow(
                icon: Icons.calendar_today,
                title: 'Ngày tạo',
                value: DateFormat('dd/MM/yyyy').format(order.createdAt),
              ),
              if (order.status == 'DEPOSITED')
                _buildCompactDetailRow(
                  icon: Icons.account_balance_wallet,
                  title: 'Đã đặt cọc',
                  value: NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                      .format(order.depositAmount),
                ),

              if (order.status == 'CANCELLED' && order.cancelReason != null)
                _buildCompactDetailRow(
                  icon: Icons.cancel,
                  title: 'Lý do hủy',
                  value:
                      '${order.cancelReason}${order.cancelReasonContent != null ? ': ${order.cancelReasonContent}' : ''}',
                  valueColor: Colors.red,
                ),

              SizedBox(height: 12),

              // Action buttons with better styling
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.remove_red_eye, size: 18),
                      label: Text('Chi tiết'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Handle view details
                      },
                    ),
                  ),
                  if (_shouldShowActionButton(order.status)) ...[
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon:
                            Icon(_getActionButtonIcon(order.status), size: 18),
                        label: Text(_getActionButtonText(order.status)),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: _getActionButtonColor(order.status),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          // Handle action
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
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

  IconData _getActionButtonIcon(String status) {
    switch (status) {
      case 'PENDING':
        return isSellOrder ? Icons.thumb_up : Icons.cancel;
      case 'ACCEPTED':
        return Icons.account_balance_wallet;
      default:
        return Icons.remove_red_eye;
    }
  }

  Color _getActionButtonColor(String status) {
    switch (status) {
      case 'PENDING':
        return isSellOrder ? Colors.green : Colors.red;
      case 'ACCEPTED':
        return AppColors.lightPrimary;
      default:
        return Colors.blue;
    }
  }

  bool _shouldShowActionButton(String status) {
    return status == 'PENDING' || status == 'ACCEPTED';
  }

  String _getActionButtonText(String status) {
    switch (status) {
      case 'PENDING':
        return isSellOrder ? 'Xác nhận' : 'Hủy đơn';
      case 'ACCEPTED':
        return 'Đặt cọc';
      default:
        return 'Chi tiết';
    }
  }
}
