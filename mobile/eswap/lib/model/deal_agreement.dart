class DealAgreement {
  int id;
  int postId;
  String firstMediaUrl;
  String postName;
  double? originalPrice;
  double salePrice;
  int quantity;
  String sellerFirstName;
  String sellerLastName;
  String buyerFirstName;
  String buyerLastName;
  DateTime requestAt;
  DateTime? completedAt;
  String status;

  DealAgreement(
      {required this.id,
      required this.postId,
      required this.firstMediaUrl,
      required this.postName,
      this.originalPrice,
      required this.salePrice,
      required this.quantity,
      required this.sellerFirstName,
      required this.sellerLastName,
      required this.buyerFirstName,
      required this.buyerLastName,
      required this.requestAt,
      this.completedAt,
      required this.status});

  factory DealAgreement.fromJson(Map<String, dynamic> json) {
    return DealAgreement(
        id: json['id'],
        postId: json['postId'],
        firstMediaUrl: json['firstMediaUrl'],
        postName: json['postName'],
        originalPrice: json['originalPrice'] != null
            ? (json['originalPrice'] as num).toDouble()
            : null,
        salePrice: (json['salePrice'] as num).toDouble(),
        quantity: json['quantity'],
        sellerFirstName: json['sellerFirstName'],
        sellerLastName: json['sellerLastName'],
        buyerFirstName: json['buyerFirstName'],
        buyerLastName: json['buyerLastName'],
        requestAt: DateTime.parse(json['requestAt']).toLocal(),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt']).toLocal()
            : null,
        status: json['status']);
  }
}
