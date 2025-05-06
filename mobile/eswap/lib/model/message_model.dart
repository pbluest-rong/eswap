import 'package:easy_localization/easy_localization.dart';

enum ContentType { TEXT, LINK, LOCATION, MEDIA, POST, DEAL }

bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

class Message {
  final int id;
  final DateTime createdAt;
  final int fromUserId;
  final int toUserId;
  final ContentType contentType;
  final String content;
  final bool read;

  Message(
      {required this.id,
      required this.createdAt,
      required this.fromUserId,
      required this.toUserId,
      required this.contentType,
      required this.content,
      required this.read});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        id: json['id'],
        createdAt: DateTime.parse(json['createdAt']).toLocal(),
        fromUserId: json['fromUserId'],
        toUserId: json['toUserId'],
        contentType: ContentType.values.firstWhere(
          (e) => e.name == json['contentType'],
          orElse: () => ContentType.TEXT,
        ),
        content: json['content'],
        read: json['read']);
  }
}

class SendMessageRequest {
  int chatPartnerId;
  ContentType contentType;
  String? content;
  int? postId;

  SendMessageRequest(
      {required this.chatPartnerId,
      required this.contentType,
      this.content,
      this.postId});

  Map<String, dynamic> toJsonForSendMessage() {
    return {
      "chatPartnerId": chatPartnerId,
      "contentType": contentType.name,
      "content": content,
      "postId": postId
    };
  }
}
