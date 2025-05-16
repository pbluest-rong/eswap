import 'package:flutter/widgets.dart';

class OrderCounterProvider extends ChangeNotifier {
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

  OrderCounterProvider({
    this.buyerPendingOrderNumber = 0,
    this.buyerAcceptedOrderNumber = 0,
    this.buyerAwaitingDepositNumber = 0,
    this.buyerDepositedOrderNumber = 0,
    this.buyerCancelledOrderNumber = 0,
    this.buyerCompletedOrderNumber = 0,
    this.sellerPendingOrderNumber = 0,
    this.sellerAcceptedOrderNumber = 0,
    this.sellerDepositedOrderNumber = 0,
    this.sellerCancelledOrderNumber = 0,
    this.sellerCompletedOrderNumber = 0,
  });

  // Buyer methods
  void updateBuyerPendingOrderNumber(int value) {
    buyerPendingOrderNumber = value;
    notifyListeners();
  }

  void plusBuyerPendingOrderNumber() {
    buyerPendingOrderNumber += 1;
    notifyListeners();
  }

  void minusBuyerPendingOrderNumber() {
    buyerPendingOrderNumber -= 1;
    notifyListeners();
  }

  void updateBuyerAcceptedOrderNumber(int value) {
    buyerAcceptedOrderNumber = value;
    notifyListeners();
  }

  void plusBuyerAcceptedOrderNumber() {
    buyerAcceptedOrderNumber += 1;
    notifyListeners();
  }

  void minusBuyerAcceptedOrderNumber() {
    buyerAcceptedOrderNumber -= 1;
    notifyListeners();
  }

  void updateBuyerAwaitingDepositNumber(int value) {
    buyerAwaitingDepositNumber = value;
    notifyListeners();
  }

  void plusBuyerAwaitingDepositNumber() {
    buyerAwaitingDepositNumber += 1;
    notifyListeners();
  }

  void minusBuyerAwaitingDepositNumber() {
    buyerAwaitingDepositNumber -= 1;
    notifyListeners();
  }

  void updateBuyerDepositedOrderNumber(int value) {
    buyerDepositedOrderNumber = value;
    notifyListeners();
  }

  void plusBuyerDepositedOrderNumber() {
    buyerDepositedOrderNumber += 1;
    notifyListeners();
  }

  void minusBuyerDepositedOrderNumber() {
    buyerDepositedOrderNumber -= 1;
    notifyListeners();
  }

  void updateBuyerCancelledOrderNumber(int value) {
    buyerCancelledOrderNumber = value;
    notifyListeners();
  }

  void plusBuyerCancelledOrderNumber() {
    buyerCancelledOrderNumber += 1;
    notifyListeners();
  }

  void minusBuyerCancelledOrderNumber() {
    buyerCancelledOrderNumber -= 1;
    notifyListeners();
  }

  void updateBuyerCompletedOrderNumber(int value) {
    buyerCompletedOrderNumber = value;
    notifyListeners();
  }

  void plusBuyerCompletedOrderNumber() {
    buyerCompletedOrderNumber += 1;
    notifyListeners();
  }

  void minusBuyerCompletedOrderNumber() {
    buyerCompletedOrderNumber -= 1;
    notifyListeners();
  }

  // Seller methods
  void updateSellerPendingOrderNumber(int value) {
    sellerPendingOrderNumber = value;
    notifyListeners();
  }

  void plusSellerPendingOrderNumber() {
    sellerPendingOrderNumber += 1;
    notifyListeners();
  }

  void minusSellerPendingOrderNumber() {
    sellerPendingOrderNumber -= 1;
    notifyListeners();
  }

  void updateSellerAcceptedOrderNumber(int value) {
    sellerAcceptedOrderNumber = value;
    notifyListeners();
  }

  void plusSellerAcceptedOrderNumber() {
    sellerAcceptedOrderNumber += 1;
    notifyListeners();
  }

  void minusSellerAcceptedOrderNumber() {
    sellerAcceptedOrderNumber -= 1;
    notifyListeners();
  }

  void updateSellerDepositedOrderNumber(int value) {
    sellerDepositedOrderNumber = value;
    notifyListeners();
  }

  void plusSellerDepositedOrderNumber() {
    sellerDepositedOrderNumber += 1;
    notifyListeners();
  }

  void minusSellerDepositedOrderNumber() {
    sellerDepositedOrderNumber -= 1;
    notifyListeners();
  }

  void updateSellerCancelledOrderNumber(int value) {
    sellerCancelledOrderNumber = value;
    notifyListeners();
  }

  void plusSellerCancelledOrderNumber() {
    sellerCancelledOrderNumber += 1;
    notifyListeners();
  }

  void minusSellerCancelledOrderNumber() {
    sellerCancelledOrderNumber -= 1;
    notifyListeners();
  }

  void updateSellerCompletedOrderNumber(int value) {
    sellerCompletedOrderNumber = value;
    notifyListeners();
  }

  void plusSellerCompletedOrderNumber() {
    sellerCompletedOrderNumber += 1;
    notifyListeners();
  }

  void minusSellerCompletedOrderNumber() {
    sellerCompletedOrderNumber -= 1;
    notifyListeners();
  }

  // Reset all counters
  void resetAllCounters() {
    // Buyer counters
    buyerPendingOrderNumber = 0;
    buyerAcceptedOrderNumber = 0;
    buyerAwaitingDepositNumber = 0;
    buyerDepositedOrderNumber = 0;
    buyerCancelledOrderNumber = 0;
    buyerCompletedOrderNumber = 0;

    // Seller counters
    sellerPendingOrderNumber = 0;
    sellerAcceptedOrderNumber = 0;
    sellerDepositedOrderNumber = 0;
    sellerCancelledOrderNumber = 0;
    sellerCompletedOrderNumber = 0;

    notifyListeners();
  }
  void updateFromJson(Map<String, dynamic> json) {
    buyerPendingOrderNumber = json['buyerPendingOrderNumber'] ?? buyerPendingOrderNumber;
    buyerAcceptedOrderNumber = json['buyerAcceptedOrderNumber'] ?? buyerAcceptedOrderNumber;
    buyerAwaitingDepositNumber = json['buyerAwaitingDepositNumber'] ?? buyerAwaitingDepositNumber;
    buyerDepositedOrderNumber = json['buyerDepositedOrderNumber'] ?? buyerDepositedOrderNumber;
    buyerCancelledOrderNumber = json['buyerCancelledOrderNumber'] ?? buyerCancelledOrderNumber;
    buyerCompletedOrderNumber = json['buyerCompletedOrderNumber'] ?? buyerCompletedOrderNumber;

    sellerPendingOrderNumber = json['sellerPendingOrderNumber'] ?? sellerPendingOrderNumber;
    sellerAcceptedOrderNumber = json['sellerAcceptedOrderNumber'] ?? sellerAcceptedOrderNumber;
    sellerDepositedOrderNumber = json['sellerDepositedOrderNumber'] ?? sellerDepositedOrderNumber;
    sellerCancelledOrderNumber = json['sellerCancelledOrderNumber'] ?? sellerCancelledOrderNumber;
    sellerCompletedOrderNumber = json['sellerCompletedOrderNumber'] ?? sellerCompletedOrderNumber;

    notifyListeners();
  }
}