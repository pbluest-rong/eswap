class UserBalance {
  final int userId;
  double balance;
  final String? bankName;
  final String? bankAccountNumber;
  final String? accountHolder;
  bool withdrawRequested;
  DateTime? withdrawDateTime;

  UserBalance({
    required this.userId,
    required this.balance,
    this.bankName,
    this.bankAccountNumber,
    this.accountHolder,
    required this.withdrawRequested,
    this.withdrawDateTime,
  });

  factory UserBalance.fromJson(Map<String, dynamic> json) {
    return UserBalance(
      userId: json['userId'],
      balance: json['balance']?.toDouble() ?? 0.0,
      bankName: json['bankName'],
      bankAccountNumber: json['bankAccountNumber'],
      accountHolder: json['accountHolder'],
      withdrawRequested: json['withdrawRequested'] ?? false,
      withdrawDateTime: json['withdrawDateTime'] != null
          ? DateTime.parse(json['withdrawDateTime']).toLocal()
          : null,
    );
  }
}
