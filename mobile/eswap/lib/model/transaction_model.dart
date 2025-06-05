class Transaction {
  final String id;
  final String? orderId;
  final TransactionType type;
  final double amount;
  final TransactionStatus status;
  final DateTime createdAt;
  final String? note;

  Transaction({
    required this.id,
    this.orderId,
    required this.type,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.note,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      orderId: json['orderId'],
      type: _parseTransactionType(json['type']),
      amount: (json['amount'] as num).toDouble(),
      status: _parseTransactionStatus(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      note: json['note'],
    );
  }

  static TransactionType _parseTransactionType(String type) {
    switch (type) {
      case 'DEPOSIT':
        return TransactionType.DEPOSIT;
      case 'DEPOSIT_REFUND':
        return TransactionType.DEPOSIT_REFUND;
      case 'DEPOSIT_RELEASE_TO_SELLER':
        return TransactionType.DEPOSIT_RELEASE_TO_SELLER;
      case 'WITHDRAWAL':
        return TransactionType.WITHDRAWAL;
      default:
        throw ArgumentError('Unknown transaction type: $type');
    }
  }

  static TransactionStatus _parseTransactionStatus(String status) {
    switch (status) {
      case 'SUCCESS':
        return TransactionStatus.SUCCESS;
      case 'FAILED':
        return TransactionStatus.FAILED;
      default:
        throw ArgumentError('Unknown transaction status: $status');
    }
  }
}

enum TransactionType {
  DEPOSIT,
  DEPOSIT_REFUND,
  DEPOSIT_RELEASE_TO_SELLER,
  WITHDRAWAL,
}

enum TransactionStatus {
  SUCCESS,
  FAILED,
}

extension TransactionTypeExtension on TransactionType {
  String get name {
    switch (this) {
      case TransactionType.DEPOSIT:
        return 'DEPOSIT';
      case TransactionType.DEPOSIT_REFUND:
        return 'DEPOSIT_REFUND';
      case TransactionType.DEPOSIT_RELEASE_TO_SELLER:
        return 'DEPOSIT_RELEASE_TO_SELLER';
      case TransactionType.WITHDRAWAL:
        return 'WITHDRAWAL';
    }
  }
}

extension TransactionStatusExtension on TransactionStatus {
  String get name {
    switch (this) {
      case TransactionStatus.SUCCESS:
        return 'SUCCESS';
      case TransactionStatus.FAILED:
        return 'FAILED';
    }
  }
}