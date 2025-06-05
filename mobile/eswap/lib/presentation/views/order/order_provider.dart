import 'package:flutter/cupertino.dart';
import 'package:eswap/model/order.dart';

class OrderProvider extends ChangeNotifier {
  bool isSellOrders = false;
  OrderStatus status = OrderStatus.PENDING;
  Map<String, Order> _orders = {};

  List<Order> get orders => _orders.values.toList();

  void initOrders(bool isSellOrders, OrderStatus status, List<Order> orders) {
    this.isSellOrders = isSellOrders;
    this.status = status;
    _orders = {};
    for (Order o in orders) {
      _orders[o.id] = o;
    }
    notifyListeners();
  }

  void addMoreOrders(List<Order> orders) {
    for (Order o in orders) {
      _orders[o.id] = o;
    }
    notifyListeners();
  }

  void addOrder(Order order) {
    print("add order: ${order.status}");
    if (order.status == status.name) {
      _orders[order.id] = order;
      notifyListeners();
    }
  }

  void removeOrder(String orderId) {
    _orders.remove(orderId);
    notifyListeners();
  }

  // Buyer counters
  int buyerPendingOrderNumber = 0;
  int buyerAcceptedOrderNumber = 0;
  int buyerAwaitingDepositNumber = 0;
  int buyerDepositedOrderNumber = 0;
  int buyerCancelledOrderNumber = 0;
  int buyerCompletedOrderNumber = 0;

  // Seller counters
  int sellerPendingOrderNumber = 0;
  int sellerAcceptedOrderNumber = 0;
  int sellerDepositedOrderNumber = 0;
  int sellerCancelledOrderNumber = 0;
  int sellerCompletedOrderNumber = 0;

  void updateFromJson(Map<String, dynamic> json) {
    buyerPendingOrderNumber =
        json['buyerPendingOrderNumber'] ?? buyerPendingOrderNumber;
    buyerAcceptedOrderNumber =
        json['buyerAcceptedOrderNumber'] ?? buyerAcceptedOrderNumber;
    buyerAwaitingDepositNumber =
        json['buyerAwaitingDepositNumber'] ?? buyerAwaitingDepositNumber;
    buyerDepositedOrderNumber =
        json['buyerDepositedOrderNumber'] ?? buyerDepositedOrderNumber;
    buyerCancelledOrderNumber =
        json['buyerCancelledOrderNumber'] ?? buyerCancelledOrderNumber;
    buyerCompletedOrderNumber =
        json['buyerCompletedOrderNumber'] ?? buyerCompletedOrderNumber;

    sellerPendingOrderNumber =
        json['sellerPendingOrderNumber'] ?? sellerPendingOrderNumber;
    sellerAcceptedOrderNumber =
        json['sellerAcceptedOrderNumber'] ?? sellerAcceptedOrderNumber;
    sellerDepositedOrderNumber =
        json['sellerDepositedOrderNumber'] ?? sellerDepositedOrderNumber;
    sellerCancelledOrderNumber =
        json['sellerCancelledOrderNumber'] ?? sellerCancelledOrderNumber;
    sellerCompletedOrderNumber =
        json['sellerCompletedOrderNumber'] ?? sellerCompletedOrderNumber;

    notifyListeners();
  }
}
