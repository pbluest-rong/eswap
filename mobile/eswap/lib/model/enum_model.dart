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

enum NotificationCategory {
  NEW_POST_FOLLOWER,
  NEW_MESSAGE,
  NEW_LIKE,
  NEW_FOLLOW,
  NEW_REQUEST_FOLLOW,
  NEW_NOTICE,
  ORDER,
}

enum NotificationType { INFORM, ALERT, SUCCESS, ERROR, WARNING, SYSTEM }

enum DealAgreementStatus { WAITING, COMPLETED, CANCELLED }

enum PostStatus {
  PUBLISHED,
  HIDDEN,
  PENDING,
  DELETED,
  REJECTED,
}
