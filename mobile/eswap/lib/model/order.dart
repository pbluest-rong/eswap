class OrderCreation {
  final Order order;
  final CreatePayment? payment;

  OrderCreation({required this.order, required this.payment});

  factory OrderCreation.fromJson(Map<String, dynamic> json) {
    return OrderCreation(
      order: Order.fromJson(json['order']),
      payment: json['payment'] != null
          ? CreatePayment.fromJson(json['payment'])
          : null,
    );
  }
}

class Order {
  final String id;
  final int postId;
  final String postName;
  final String firstMediaUrl;
  final int sellerId;
  final String sellerFirstName;
  final String sellerLastName;
  final int buyerId;
  final String buyerFirstName;
  final String buyerLastName;
  final int quantity;
  final double totalAmount;
  final double depositAmount;
  final double remainingAmount;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? cancelReason;
  final String? cancelReasonContent;

  Order(
      {required this.id,
      required this.postId,
      required this.postName,
      required this.firstMediaUrl,
      required this.sellerId,
      required this.sellerFirstName,
      required this.sellerLastName,
      required this.buyerId,
      required this.buyerFirstName,
      required this.buyerLastName,
      required this.quantity,
      required this.totalAmount,
      required this.depositAmount,
      required this.remainingAmount,
      required this.status,
      required this.createdAt,
      this.updatedAt,
      this.cancelReason,
      this.cancelReasonContent});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
        id: json['id'],
        postId: json['postId'],
        postName: json['postName'],
        firstMediaUrl: json['firstMediaUrl'],
        sellerId: json['sellerId'],
        sellerFirstName: json['sellerFirstName'],
        sellerLastName: json['sellerLastName'],
        buyerId: json['buyerId'],
        buyerFirstName: json['buyerFirstName'],
        buyerLastName: json['buyerLastName'],
        quantity: json['quantity'],
        totalAmount: (json['totalAmount'] as num).toDouble(),
        depositAmount: (json['depositAmount'] as num).toDouble(),
        remainingAmount: (json['remainingAmount'] as num).toDouble(),
        status: json['status'],
        createdAt: DateTime.parse(json['createdAt']).toLocal());
  }
}

enum CancelReason { BUYER_CANCELLED, SELLER_REJECTED, TIMEOUT, OTHER }

enum OrderStatus {
  PENDING, // Đơn được tạo nhưng chưa đặt cọc
  SELLER_ACCEPTS, // Người bán cho phép không đặt cọc
  AWAITING_DEPOSIT,
  DEPOSITED, // Đã đặt cọc
  COMPLETED, // Đã thanh toán đủ
  CANCELLED, // Đã hủy
  DELETED
}

class CreatePayment {
  final String partnerCode;
  final int responseTime;
  final int resultCode;
  final String payUrl;
  final String deeplink;
  final String qrCodeUrl;
  final String orderId;
  final String requestId;
  final int amount;
  final String message;

  CreatePayment({
    required this.partnerCode,
    required this.responseTime,
    required this.resultCode,
    required this.payUrl,
    required this.deeplink,
    required this.qrCodeUrl,
    required this.orderId,
    required this.requestId,
    required this.amount,
    required this.message,
  });

  factory CreatePayment.fromJson(Map<String, dynamic> json) {
    return CreatePayment(
        partnerCode: json['partnerCode'],
        responseTime: json['responseTime'],
        resultCode: json['resultCode'],
        payUrl: json['payUrl'],
        deeplink: json['deeplink'],
        qrCodeUrl: json['qrCodeUrl'],
        orderId: json['orderId'],
        requestId: json['requestId'],
        amount: json['amount'],
        message: json['message']);
  }
}
