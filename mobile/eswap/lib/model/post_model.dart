import 'package:eswap/model/education_institution_model.dart';
import 'package:eswap/model/enum_model.dart';
import 'package:eswap/model/post_media_model.dart';

class Post {
  final int userId;
  final String firstname;
  final String lastname;
  final String? avtUrl;
  String followStatus;

  final int id;
  final int educationInstitutionId;
  final String educationInstitutionName;
  final String name;
  final String description;
  final String? brand;
  final double? originalPrice;
  final double salePrice;
  final int quantity;
  final int sold;
  final String status;
  final String privacy;
  final String availableTime;
  final String condition;
  final String createdAt;
  final List<PostMedia> media;
  int likesCount;
  bool liked;

  Post(
      {required this.userId,
      required this.firstname,
      required this.lastname,
      required this.avtUrl,
      required this.followStatus,
      required this.id,
      required this.educationInstitutionId,
      required this.educationInstitutionName,
      required this.name,
      required this.description,
      required this.brand,
      required this.originalPrice,
      required this.salePrice,
      required this.quantity,
      required this.sold,
      required this.status,
      required this.privacy,
      required this.availableTime,
      required this.condition,
      required this.createdAt,
      required this.media,
      required this.likesCount,
      required this.liked
      });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      avtUrl: json['avtUrl'],
      followStatus: json['followStatus'],
      id: json['id'],
      educationInstitutionId: json['educationInstitutionId'],
      educationInstitutionName: json['educationInstitutionName'],
      name: json['name'],
      description: json['description'],
      brand: json['brand'],
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
      salePrice: (json['salePrice'] as num).toDouble(),
      quantity: json['quantity'],
      sold: json['sold'],
      status: json['status'],
      privacy: json['privacy'],
      availableTime: json['availableTime'],
      condition: json['condition'],
      createdAt: json['createdAt'],
      media: (json['media'] as List<dynamic>)
          .map((e) => PostMedia.fromJson(e))
          .toList(),
      likesCount: json['likesCount'],
      liked: json['liked'],
    );
  }
}
