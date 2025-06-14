import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/main.dart';
import 'package:eswap/model/order.dart';
import 'package:eswap/presentation/views/order/detail_order_item.dart';
import 'package:eswap/presentation/views/order/order_provider.dart';
import 'package:eswap/presentation/views/order/payment_momo_page.dart';
import 'package:eswap/presentation/views/post/standalone_post.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/presentation/widgets/password_tf.dart';
import 'package:eswap/presentation/widgets/switch_button.dart';
import 'package:eswap/service/order_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateOrder extends StatefulWidget {
  final int userId;
  final int postId;
  final String postName;
  final String firstMediaUrl;
  final double salePrice;
  final int purchaseQuantity;

  const CreateOrder({
    super.key,
    required this.userId,
    required this.postId,
    required this.postName,
    required this.firstMediaUrl,
    required this.salePrice,
    required this.purchaseQuantity,
  });

  @override
  State<CreateOrder> createState() => _CreateOrderState();
}

class _CreateOrderState extends State<CreateOrder> {
  final orderService = OrderService();
  double depositAmount = 0;
  bool isDeposit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    calDepositAmount();
  }

  Future<void> calDepositAmount() async {
    double calDepositAmount = await orderService
        .calDepositAmount(widget.salePrice * widget.purchaseQuantity);
    setState(() {
      depositAmount = calDepositAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool? _isMomo = true;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Gửi yêu cầu mua",
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: AppBody(
          child: Column(
        children: [
          _buildCurrentPostWidget(widget.postId, widget.firstMediaUrl,
              widget.postName, widget.salePrice, widget.purchaseQuantity),
          if (widget.salePrice > 0)
            isDeposit
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Yêu cầu đặt cọc",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange),
                      ),
                      SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 15, color: Colors.black),
                          children: [
                            TextSpan(
                                text:
                                    "Để đảm bảo giao dịch an toàn khi mua, bạn cần đặt cọc một khoản là "),
                            TextSpan(
                              text: "${depositAmount.toStringAsFixed(0)} VND",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                                text:
                                    ". Khoản đặt cọc này sẽ được hoàn lại trong trường hợp đơn hàng bị huỷ do người bán."),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      RichText(
                          text: TextSpan(
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black),
                              children: [
                            TextSpan(
                              text:
                                  "Sau khi đặt cọc, bạn sẽ tiến hành giao dịch với người bán với số tiền phải trả là ",
                            ),
                            TextSpan(
                              text:
                                  "${((widget.salePrice * widget.purchaseQuantity) - depositAmount).toStringAsFixed(0)} VND",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ])),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Chờ người bán xác nhận",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 15, color: Colors.black),
                          children: [
                            TextSpan(
                              text: "Nếu không đặt cọc, ",
                            ),
                            TextSpan(
                              text:
                                  "bạn sẽ phải chờ người bán xác nhận có bán cho bạn hay không! ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red, // Làm nổi bật cảnh báo
                              ),
                            ),
                            TextSpan(
                              text:
                                  "Trong thời gian này, sản phẩm có thể được bán cho người khác.",
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Đặt cọc giúp giao dịch của bạn được xử lý nhanh chóng và đảm bảo an toàn. Bạn nên cân nhắc sử dụng hình thức đặt cọc nhé.",
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
          Spacer(),
          if (widget.salePrice > 0)
            SwitchButton(
                onLabel: "Đặt cọc",
                offLabel: "Không đặt cọc",
                onChanged: (value) {
                  setState(() {
                    isDeposit = value;
                  });
                }),
          SizedBox(
            height: 8,
          ),
          if (isDeposit && widget.salePrice > 0)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  AppAlert.show(
                      context: context,
                      title: "Chọn phương thức thanh toán",
                      centerWidget: RadioListTile<bool>(
                        title: Text('Ví điện tử MOMO'),
                        value: true,
                        groupValue: _isMomo,
                        onChanged: (bool? value) {
                          setState(() {
                            _isMomo = value;
                          });
                        },
                      ),
                      actions: [
                        AlertAction(text: "cancel".tr()),
                        AlertAction(
                            text: "confirm".tr(),
                            handler: () async {
                              OrderCreation orderCreation =
                                  await orderService.createOrderByBuyer(
                                      postId: widget.postId,
                                      quantity: widget.purchaseQuantity,
                                      paymentType: "momo",
                                      context: context);

                              Provider.of<OrderProvider>(context, listen: false)
                                  .addOrder(orderCreation.order);

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentScreen(
                                      orderCreation: orderCreation),
                                ),
                              );
                            })
                      ]);
                },
                icon: Icon(Icons.qr_code),
                label: Text("Tiến hành thanh toán đặt cọc"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  OrderCreation orderCreation =
                      await orderService.createOrderByBuyer(
                          postId: widget.postId,
                          quantity: widget.purchaseQuantity,
                          context: context);

                  Provider.of<OrderProvider>(context, listen: false)
                      .addOrder(orderCreation.order);

                  AppAlert.show(
                    context: context,
                    title: 'Tạo đơn hàng thành công',
                    buttonLayout: AlertButtonLayout.dual,
                    actions: [
                      AlertAction(
                          text: 'Quay lại',
                          handler: () {
                            Navigator.pop(context);
                          }),
                      AlertAction(
                          text: 'Xem chi tiết',
                          handler: () {
                            navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                  builder: (_) => DetailOrderItem(
                                        orderId: orderCreation.order.id,
                                      )),
                            );
                          }),
                    ],
                  );
                },
                icon: Icon(Icons.done),
                label: Text("Hoàn tất"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ),
          SizedBox(
            height: 20,
          )
        ],
      )),
    );
  }

  Widget _buildCurrentPostWidget(int postId, String firstMediaUrl,
      String postName, double salePrice, int purchaseQuantity) {
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
                          "$salePrice VND",
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
                          "Số lượng: ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "$purchaseQuantity",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tổng: ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "${salePrice * purchaseQuantity} VND",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.only(top: 8, bottom: 8, right: 4),
              child: GestureDetector(
                  onTap: () {
                    navigatorKey.currentState?.push(
                      MaterialPageRoute(
                          builder: (_) => StandalonePost(postId: postId)),
                    );
                  },
                  child: Icon(Icons.arrow_forward_ios)),
            )
          ],
        ),
      ),
    );
  }
}
