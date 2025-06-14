import 'package:eswap/model/enum_model.dart';

class UserInfomation {
  final int id;
  bool waitingAcceptFollow;
  String? username;
  String firstname;
  String lastname;
  String? avatarUrl;
  String? educationInstitutionName;
  String? followStatus;
  int? postCount;
  int? followerCount;
  int? followingCount;
  bool? gender;
  String? createdAt;
  int reputationScore = 0;
  String? address;
  String? role;
  bool isLocked;
  bool? requireFollowApproval;

  UserInfomation(
      {required this.id,
      required this.waitingAcceptFollow,
      this.username,
      required this.firstname,
      required this.lastname,
      this.avatarUrl,
      required this.educationInstitutionName,
      this.followStatus,
      this.postCount,
      this.followerCount,
      this.followingCount,
      this.gender,
      this.createdAt,
      this.reputationScore = 0,
      this.address,
      this.role,
      this.isLocked = false,
      this.requireFollowApproval});

  factory UserInfomation.fromJson(Map<String, dynamic> json) {
    return UserInfomation(
        id: json['id'],
        waitingAcceptFollow: json['waitingAcceptFollow'],
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
        createdAt: json['createdAt'],
        reputationScore: json['reputationScore'] ?? 0,
        address: json['address'],
        role: json['role'],
        isLocked: json['locked'],
        requireFollowApproval: json['requireFollowApproval']);
  }
}
