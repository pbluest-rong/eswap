import 'package:eswap/main.dart';
import 'package:eswap/model/enum_model.dart';
import 'package:eswap/model/notification_model.dart';
import 'package:eswap/model/post_model.dart';
import 'package:eswap/presentation/provider/user_provider.dart';
import 'package:eswap/presentation/views/account/account_page.dart';
import 'package:eswap/presentation/views/post/standalone_post.dart';
import 'package:eswap/service/notification_service.dart';
import 'package:eswap/service/post_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationItem extends StatefulWidget {
  final NotificationModel notification;

  const NotificationItem({super.key, required this.notification});

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  late NotificationModel _notification;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notification = widget.notification;
  }

  @override
  Widget build(BuildContext context) {
    return _buildNotificationItem(_notification);
  }

  NotificationCategory? notificationCategoryFromString(String value) {
    try {
      return NotificationCategory.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return null;
    }
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    NotificationCategory? category =
    notificationCategoryFromString(notification.category);

    if (category != null) {
      switch (category) {
        case NotificationCategory.NEW_FOLLOW:
          return _isReadForNotification(
              notification, _buildFollowNotification(notification));
        case NotificationCategory.NEW_LIKE:
          return _isReadForNotification(
              notification, _buildLikeNotification(notification));
        case NotificationCategory.NEW_POST_FOLLOWER:
          return _isReadForNotification(
              notification, _buildNewPostNotification(notification));
        case NotificationCategory.NEW_NOTICE:
          return _isReadForNotification(
              notification, _buildSystemNotification(notification));
        case NotificationCategory.NEW_MESSAGE:
          return _isReadForNotification(
              notification, Text(notification.category));
        default:
          return Container();
      }
    }
    return Container();
  }

  Widget _isReadForNotification(NotificationModel notification,
      Widget notificationWidget) {
    if (notification.read) {
      return notificationWidget;
    } else {
      return Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          color: Colors.blue.shade50,
          child: notificationWidget);
    }
  }

  Widget _wrapNotification({
    required NotificationModel notification,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onTap();
          if (!notification.read) {
            _notificationService.markAsRead(notification.id);
            int unreadNotificationNumber =
                Provider
                    .of<UserSessionProvider>(context, listen: false)
                    .unreadNotificationNumber;
            if (unreadNotificationNumber > 0) {
              Provider.of<UserSessionProvider>(context, listen: false)
                  .updateUnreadNotificationNumber(
                  unreadNotificationNumber - 1);
            }
          }
          setState(() {
            notification.read = true;
          });
        },
        child: Container(
          color: notification.read ? null : Colors.blue.shade50,
          padding: const EdgeInsets.all(8),
          child: child,
        ),
      ),
    );
  }

  Widget _buildFollowNotification(NotificationModel notification) {
    return _wrapNotification(
      notification: notification,
      onTap: () {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
              builder: (_) => DetailUserPage(userId: notification.senderId!)),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvt(notification),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                    '${notification.senderFirstName} ${notification
                        .senderLastName}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        if (notification.senderId != null) {
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    DetailUserPage(
                                        userId: notification.senderId!)),
                          );
                        }
                      },
                  ),
                  const TextSpan(
                    text: ' đã follow bạn',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeNotification(NotificationModel notification) {
    return _wrapNotification(
      notification: notification,
      onTap: () {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
              builder: (_) => StandalonePost(postId: notification.postId!)),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvt(notification),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                    '${notification.senderFirstName} ${notification
                        .senderLastName}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        if (notification.senderId != null) {
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    DetailUserPage(
                                        userId: notification.senderId!)),
                          );
                        }
                      },
                  ),
                  const TextSpan(
                    text: ' đã thích bài viết của bạn',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewPostNotification(NotificationModel notification) {
    return _wrapNotification(
      notification: notification,
      onTap: () {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
              builder: (_) => StandalonePost(postId: notification.postId!)),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvt(notification),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                    '${notification.senderFirstName} ${notification
                        .senderLastName}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        if (notification.senderId != null) {
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    DetailUserPage(
                                        userId: notification.senderId!)),
                          );
                        }
                      },
                  ),
                  const TextSpan(
                    text: ' đã đăng một bài viết mới',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemNotification(NotificationModel notification) {
    return _wrapNotification(
      notification: notification,
      onTap: () {
        // Có thể xử lý khác nếu cần
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvt(notification),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                    '${notification.senderFirstName} ${notification
                        .senderLastName}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        if (notification.senderId != null) {
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    DetailUserPage(
                                        userId: notification.senderId!)),
                          );
                        }
                      },
                  ),
                  TextSpan(
                    text: notification.category,
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvt(NotificationModel notification) {
    return GestureDetector(
      onTap: () {
        if (notification.senderId != null) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
                builder: (_) => DetailUserPage(userId: notification.senderId!)),
          );
        }
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[200],
        backgroundImage: notification.avatarUrl != null
            ? NetworkImage("${notification.avatarUrl}")
            : null,
        child: notification.avatarUrl == null
            ? const Icon(Icons.person, color: Colors.grey)
            : null,
      ),
    );
  }
}
