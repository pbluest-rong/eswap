class NotificationModel {
  final int id;
  final int? senderId;
  final String? senderFirstName;
  final String? senderLastName;
  final String senderRole;
  final String category;
  final String type;
  bool read;
  final int? postId;
  final String createdAt;
  String? avatarUrl;
  String? orderId;

  NotificationModel(
      {required this.id,
      this.senderId,
      this.senderFirstName,
      this.senderLastName,
      required this.senderRole,
      required this.category,
      required this.type,
      required this.read,
      this.postId,
      required this.createdAt,
      this.avatarUrl,
      this.orderId});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
        id: json['id'],
        senderId: json['senderId'],
        senderFirstName: json['senderFirstName'],
        senderLastName: json['senderLastName'],
        senderRole: json['senderRole'],
        category: json['category'],
        type: json['type'],
        postId: json['postId'],
        createdAt: json['createdAt'],
        read: json['read'],
        avatarUrl: json['avatarUrl'],
        orderId: json['orderId']);
  }
}
