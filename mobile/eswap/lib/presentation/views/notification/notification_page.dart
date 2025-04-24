import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/model/enum_model.dart';
import 'package:eswap/model/notification_model.dart';
import 'package:eswap/presentation/components/notification_item.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/service/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  static const String route = '/notification';

  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _allNotifications = [];
  int _currentPage = 0;
  final int _pageSize = 6;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadInitialNotifications();
  }

  Future<void> _loadInitialNotifications() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _allNotifications = [];
      _currentPage = 0;
      _hasMore = true;
    });
    try {
      final notificationsPage = await _notificationService.fetchNotifications(
          _currentPage, _pageSize, context);
      setState(() {
        _allNotifications = notificationsPage.content;
        _hasMore = !notificationsPage.last;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showErrorSnackbar(
          context, 'Error loading notifications: ${e.toString()}');
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final notificationPage = await _notificationService.fetchNotifications(
          _currentPage + 1, _pageSize, context);

      setState(() {
        _currentPage++;
        _allNotifications.addAll(notificationPage.content);
        _hasMore = !notificationPage.last;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      showErrorSnackbar(
          context, 'Error loading more notifications: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("notification".tr(),
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadInitialNotifications,
          child: _isLoading && _allNotifications.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _allNotifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.supervised_user_circle_outlined,
                              size: 50, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            "no_result_found".tr(),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          TextButton(
                            onPressed: _loadInitialNotifications,
                            child: Text("retry".tr()),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _allNotifications.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _allNotifications.length) {
                          return Column(
                            key: PageStorageKey(
                                'notification_${_allNotifications[index].id}'),
                            children: [
                              NotificationItem(
                                  notification: _allNotifications[index]),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    backgroundColor: Colors.white10,
                                  ),
                                  onPressed: () {
                                    _isLoadingMore
                                        ? null
                                        : _loadMoreNotifications();
                                  },
                                  child: _isLoadingMore
                                      ? const CircularProgressIndicator()
                                      : Text(
                                          "show_more".tr(),
                                          style: textTheme.titleSmall!.copyWith(
                                              fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              )
                            ],
                          );
                        }
                      },
                    ),
        ),
      ),
    );
  }
}
