import 'package:eswap/model/enum_model.dart';

/*
1. me
+ id
+ first name, lastname
+ avt_url
+ post_count
+ follower_count
+ following_count
+ educationInstitutionName
+ participation time
+ gender
 */
class UserInfomation {
  final int id;
  String username;
  String firstname;
  String lastname;
  String? avatarUrl;
  String educationInstitutionName;
  String? followStatus;
  int? postCount;
  int? followerCount;
  int? followingCount;
  bool? gender;
  String? createdAt;

  UserInfomation(
      {required this.id,
      required this.username,
      required this.firstname,
      required this.lastname,
      this.avatarUrl,
      required this.educationInstitutionName,
      this.followStatus,
      this.postCount,
      this.followerCount,
      this.followingCount,
      this.gender,
      this.createdAt});

  factory UserInfomation.fromJson(Map<String, dynamic> json) {
    return UserInfomation(
        id: json['id'],
        username: json['username'],
        firstname: json['firstname'],
        lastname: json['lastname'],
        avatarUrl: json['avatarUrl'],
        educationInstitutionName: json['educationInstitutionName'],
        followStatus: json['followStatus'],
        postCount: json['postCount'],
        followerCount: json['followerCount'],
        followingCount: json['followingCount'],
        gender: json['gender'],
        createdAt: json['createdAt']);
  }
}
