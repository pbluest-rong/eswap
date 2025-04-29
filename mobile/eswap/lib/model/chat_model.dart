import 'package:eswap/model/message_model.dart';

class Chat {
  final int id;
  final int chatPartnerId;
  final String? chatPartnerAvatarUrl;
  final String chatPartnerFirstName;
  final String chatPartnerLastName;
  final int educationInstitutionId;
  final String educationInstitutionName;
  final int currentPostId;
  final String currentPostName;
  final double currentPostSalePrice;
  final String currentPostFirstMediaUrl;
  Message? mostRecentMessage;
  int unReadMessageNumber;

  Chat({
    required this.id,
    required this.chatPartnerId,
    this.chatPartnerAvatarUrl,
    required this.chatPartnerFirstName,
    required this.chatPartnerLastName,
    required this.educationInstitutionId,
    required this.educationInstitutionName,
    required this.currentPostId,
    required this.currentPostName,
    required this.currentPostSalePrice,
    required this.currentPostFirstMediaUrl,
    this.mostRecentMessage,
    required this.unReadMessageNumber,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      chatPartnerId: json['chatPartnerId'],
      chatPartnerAvatarUrl: json['chatPartnerAvatarUrl'],
      chatPartnerFirstName: json['chatPartnerFirstName'],
      chatPartnerLastName: json['chatPartnerLastName'],
      educationInstitutionId: json['educationInstitutionId'],
      educationInstitutionName: json['educationInstitutionName'],
      currentPostId: json['currentPostId'],
      currentPostName: json['currentPostName'],
      currentPostSalePrice: json['currentPostSalePrice'],
      currentPostFirstMediaUrl: json['currentPostFirstMediaUrl'],
      mostRecentMessage: json['mostRecentMessage'] != null
          ? Message.fromJson(json['mostRecentMessage'])
          : null,
      unReadMessageNumber: json['unReadMessageNumber'] ?? 0,
    );
  }
}
