enum Privacy {
  PUBLIC,
  FOLLOWERS,
}

enum Condition { NEW, USED }

enum FollowStatus {
  FOLLOWED,
  UNFOLLOWED,
  WAITING;

  static FollowStatus fromString(String status) {
    return FollowStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => FollowStatus.UNFOLLOWED,
    );
  }
}
