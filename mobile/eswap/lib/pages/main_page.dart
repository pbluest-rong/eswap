import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:eswap/pages/home/home_page.dart';
import 'package:eswap/pages/search/search_page.dart';
import 'package:eswap/pages/notification/notification_page.dart';
import 'package:eswap/pages/account/other_page.dart';

class MainPage extends StatefulWidget {

  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentPageIndex = 0;
  final int _notificationCount = 12;

  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(),
    SizedBox(),
    NotificationPage(),
    OtherPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentPageIndex,
        children: _pages,
      ),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {
            // TODO: Xử lý khi ấn nút trung tâm
          },
          backgroundColor: Color(0xFF1F41BB),
          shape: CircleBorder(),
          child: Icon(Icons.add, size: 50, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SizedBox(
        height: 70,
        child: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 6,
          color: Colors.grey[300],
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 0),
                _buildNavItem(Icons.search, 1),
                SizedBox(width: 40),
                _buildNavItem(Icons.message_outlined, 3, hasBadge: true, notificationCount: _notificationCount),
                _buildNavItem(Icons.menu_sharp, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, {bool hasBadge = false, int notificationCount = 0}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            _currentPageIndex = index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon,
                      size: 28,
                      color: _currentPageIndex == index
                          ? Color(0xFF1F41BB)
                          : null),
                  if (hasBadge)
                    Positioned(
                      right: -10,
                      top: -10,
                      child: _buildNotificationBadge(notificationCount > 9 ? "9+" : notificationCount.toString()),
                    ),
                ],
              ),
              SizedBox(height: 2),
              if (_currentPageIndex == index)
                Container(
                  height: 3,
                  width: 22,
                  decoration: BoxDecoration(
                    color: Color(0xFF1F41BB),
                    borderRadius: BorderRadius.circular(56),
                  ),
                ),
            ],
          ),
        ),
      ),
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
