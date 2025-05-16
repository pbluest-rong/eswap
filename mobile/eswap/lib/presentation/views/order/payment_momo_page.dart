import 'dart:async';
import 'dart:convert';

import 'package:eswap/model/order.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/service/websocket.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends StatefulWidget {
  final OrderCreation orderCreation;

  const PaymentScreen({Key? key, required this.orderCreation})
      : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  String? _errorMessage;
  StreamSubscription<String>? depositOrderStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setupWebSocket();
  }

  @override
  void dispose() {
    depositOrderStream?.cancel();
    super.dispose();
  }

  void _setupWebSocket() async {
    WebSocketService.getInstance().then((ws) {
      depositOrderStream = ws.depositOrderStream.listen((data) {
        if (!mounted) return;
        final order = Order.fromJson(json.decode(data));
        if (order.id == widget.orderCreation.order.id) {
          AppAlert.show(
              context: context,
              title: "Đặt cọc thành công",
              buttonLayout: AlertButtonLayout.single,
              actions: [
                AlertAction(
                    text: "OK",
                    handler: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    })
              ]);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.orderCreation.order;
    final payment = widget.orderCreation.payment;

    if (payment == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Thanh toán đơn hàng'),
        ),
        body: const Center(
          child: Text('Không tìm thấy thông tin thanh toán'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán đơn hàng'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin đơn hàng
            _buildOrderInfo(order),

            const SizedBox(height: 24),

            // Phương thức thanh toán
            _buildPaymentOptions(payment),

            const SizedBox(height: 24),

            // Thông tin số tiền
            _buildAmountInfo(order),

            const SizedBox(height: 32),

            // Nút thanh toán
            _buildPaymentButtons(context, payment),

            // Hiển thị lỗi nếu có
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin đơn hàng',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: order.firstMediaUrl.isNotEmpty
                ? Image.network(
                    order.firstMediaUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, size: 60);
                    },
                  )
                : const Icon(Icons.image, size: 60),
            title: Text(order.postName),
            subtitle: Text('Số lượng: ${order.quantity}'),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOptions(CreatePayment payment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phương thức thanh toán',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFA50064),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'MoMo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            title: const Text('Ví điện tử MoMo'),
            subtitle: const Text('Thanh toán nhanh chóng và an toàn'),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInfo(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin thanh toán',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildAmountRow('Đặt cọc:', order.depositAmount),
        const Divider(),
        _buildAmountRow(
          'Thanh toán đặt cọc:',
          order.depositAmount,
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildAmountRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(0).replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]}.',
                )}đ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButtons(BuildContext context, CreatePayment payment) {
    return Column(
      children: [
        // Nút thanh toán bằng ứng dụng MoMo
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA50064),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _isProcessing
                ? null
                : () =>
                    _handlePayment(context, payment.deeplink, payment.payUrl),
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Thanh toán bằng MoMo',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),
        ),

        const SizedBox(height: 12),

        // Nút thanh toán bằng trình duyệt
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: const BorderSide(color: Color(0xFFA50064)),
            ),
            onPressed:
                _isProcessing ? null : () => _launchPaymentUrl(payment.payUrl),
            child: const Text(
              'Thanh toán bằng trình duyệt',
              style: TextStyle(fontSize: 16, color: Color(0xFFA50064)),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // QR Code nếu có
        if (payment.qrCodeUrl.isNotEmpty) ...[
          const Text(
            'Hoặc quét mã QR',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: QrImageView(
              data: payment.qrCodeUrl,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _handlePayment(
      BuildContext context, String deeplink, String payUrl) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      if (await canLaunchUrl(Uri.parse(deeplink))) {
        await launchUrl(Uri.parse(deeplink));
      } else {
        await _launchPaymentUrl(payUrl);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi mở ứng dụng thanh toán: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _launchPaymentUrl(String payUrl) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      if (await canLaunchUrl(Uri.parse(payUrl))) {
        await launchUrl(
          Uri.parse(payUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        setState(() {
          _errorMessage = 'Không thể mở trình duyệt';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi mở trình duyệt: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  String _getQrCodeImageUrl(String qrCodeUrl) {
    // Xử lý URL QR code từ MoMo
    if (qrCodeUrl.startsWith('momo://qr')) {
      return 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${Uri.encodeComponent(qrCodeUrl)}';
    }
    return qrCodeUrl;
  }
}
