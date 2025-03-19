import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            // Có thể xử lý thêm nếu muốn biết đang scroll lên/xuống
            return false;
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPersistentHeader(
                floating: true,
                delegate: _HeaderDelegate(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    child: _buildHomeHeader(),
                  ),
                  maxExtent: 60,
                  minExtent: 60,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => ListTile(
                    title: Text('Item $index'),
                  ),
                  childCount: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(16),
                  height: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.swap_vert),
                        title: Text('Thay đổi địa điểm'),
                        onTap: () {
                          Navigator.pop(context);
                          // Xử lý điều hướng
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.brightness_6),
                        title: Text('Giao diện'),
                        onTap: () {
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.brightness_4),
                                    title: Text('Dark Mode'),
                                    onTap: () {
                                      // Cài đặt Dark Mode tại đây
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.brightness_high),
                                    title: Text('Light Mode'),
                                    onTap: () {
                                      // Cài đặt Light Mode tại đây
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.settings_suggest),
                                    title: Text('Theo hệ thống'),
                                    onTap: () {
                                      // Cài đặt chế độ theo hệ thống tại đây
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.settings),
                        title: Text('Cài đặt'),
                        onTap: () {
                          Navigator.pop(context);
                          // Xử lý điều hướng
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Image.asset(
            "assets/images/menu.png",
            width: 40,
            height: 40,
          ),
        ),

        Expanded(
          child: Text(
            "🌏 Đại học Nông Lâm TPHCM",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            print("Message clicked");
          },
          child: Stack(
            children: [
              Image.asset(
                "assets/images/message.png",
                width: 40,
                height: 40,
              ),
              Positioned(
                right: 0,
                child: _buildNotificationBadge("9+"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationBadge(String count) {
    bool isSingleDigit = count.length < 2;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSingleDigit ? 6.5 : 3),
      decoration: BoxDecoration(
        color: Colors.red.shade500,
        borderRadius: BorderRadius.circular(isSingleDigit ? 100 : 10),
        border: Border.all(width: 2, color: Colors.white),
      ),
      child: Text(
        count,
        style: TextStyle(fontSize: 12, color: Colors.white),
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double maxExtent;
  final double minExtent;

  _HeaderDelegate({
    required this.child,
    required this.maxExtent,
    required this.minExtent,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.maxExtent != maxExtent ||
        oldDelegate.minExtent != minExtent;
  }
}
