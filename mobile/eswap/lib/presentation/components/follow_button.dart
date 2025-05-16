import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/model/enum_model.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/service/user_service.dart';
import 'package:flutter/material.dart';

class FollowButton extends StatefulWidget {
  final FollowStatus followStatus;
  final int otherUserId;
  final bool bigSize;

  FollowButton(
      {super.key,
      required this.followStatus,
      required this.otherUserId,
      this.bigSize = false});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late FollowStatus _status;
  late int _otherUserId;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _status = widget.followStatus;
    _otherUserId = widget.otherUserId;
  }

  void _handleTap() async {
    if (_status == FollowStatus.FOLLOWED || _status == FollowStatus.WAITING) {
      String title = _status == FollowStatus.FOLLOWED
          ? "Bỏ theo dõi?"
          : "Hủy yêu cầu theo dõi?";
      String description = _status == FollowStatus.FOLLOWED
          ? "Bạn có chắc chắn muốn bỏ theo dõi người này?"
          : "Bạn có chắc chắn muốn hủy yêu cầu theo dõi đã gửi?";
      AppAlert.show(
        context: context,
        title: title,
        description: description,
        buttonLayout: AlertButtonLayout.dual,
        actions: [
          AlertAction(text: "cancel".tr(), handler: () {}),
          AlertAction(text: "confirm".tr(), handler: () async {
            // unfollow
            await _userService.unfollow(_otherUserId, context);
            setState(() {
              _status = FollowStatus.UNFOLLOWED;
            });
          }),
        ],
      );
    } else {
      // follow
      FollowStatus? newStatus =
          await _userService.follow(_otherUserId, context);
      if (newStatus != null) {
        setState(() {
          _status = newStatus;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String text;
    switch (_status) {
      case FollowStatus.FOLLOWED:
        text = "Đang theo dõi";
        break;
      case FollowStatus.WAITING:
        text = "Đã gửi yêu cầu";
        break;
      default:
        text = "Theo dõi";
    }

    if (widget.bigSize) {
      return OutlinedButton(
        onPressed: _handleTap,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.blue[800],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: _handleTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[100]!),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 12,
            ),
          ),
        ),
      );
    }
  }
}
