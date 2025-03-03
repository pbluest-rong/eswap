import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ecoswap/pages/home/home_page.dart';
import 'package:ecoswap/pages/search/search_page.dart';
import 'package:ecoswap/pages/notification/notification_page.dart';
import 'package:ecoswap/pages/account/account_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: switch (_currentPageIndex) {
          0 => HomePage(),
          1 => SearchPage(),
          3 => NotificationPage(),
          4 => AccountPage(),
          _ => Text(
              "Page $_currentPageIndex",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
        },
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
        height: 70, // Giảm chiều cao để vừa vặn hơn
        child: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 6,
          color: Colors.grey[300],
          child: SizedBox(
            height: 50, // Điều chỉnh chiều cao hợp lý hơn
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 0),
                _buildNavItem(Icons.search, 1),
                SizedBox(width: 40), // Khoảng trống cho FloatingActionButton
                _buildNavItem(Icons.notifications, 3, hasBadge: true),
                _buildNavItem(Icons.person, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, {bool hasBadge = false}) {
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
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
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
}
