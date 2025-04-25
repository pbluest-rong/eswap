import 'dart:convert';

import 'package:eswap/main.dart';
import 'package:eswap/presentation/components/bottom_sheet.dart';
import 'package:eswap/presentation/views/chat/Chat.dart';
import 'package:eswap/presentation/views/post/add_post.dart';
import 'package:eswap/presentation/views/post/add_post_provider.dart';
import 'package:eswap/presentation/views/post/select_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:eswap/presentation/views/home/home_page.dart';
import 'package:eswap/presentation/views/search/search_page.dart';
import 'package:eswap/presentation/views/account/other_page.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentPageIndex = 0;
  final int _notificationCount = 12;
  final HomePageController _homePageController = HomePageController();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(controller: _homePageController),
      const SearchPage(),
      const SizedBox(),
      const ChatPage(),
      const OtherPage(),
    ];
  }

  Future<void> showCategorySelectionSheet(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.transparent,
        builder: (context) => EnhancedDraggableSheet(
                child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: CategorySelectionWidget(),
            )));

    if (result != null) {
      if (result != null && result['childCategory'] != null) {
        final parentCategory = result['parentCategory'] ?? '';
        final childCategory = result['childCategory'];

        int categoryId = childCategory['id'];
        String categoryName =
            "${childCategory['name']} - ${parentCategory['name']}";

        Provider.of<AddPostProvider>(context, listen: false)
            .updateCategory(categoryId, categoryName);

        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AddPostPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _currentPageIndex,
        children: _pages,
      ),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {
            showCategorySelectionSheet(context);
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
                _buildNavItem(Icons.message_outlined, 3,
                    hasBadge: true, notificationCount: _notificationCount),
                _buildNavItem(Icons.menu_sharp, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index,
      {bool hasBadge = false, int notificationCount = 0}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (index == _currentPageIndex && index == 0) {
            _homePageController.scrollToTop();
          } else {
            setState(() {
              _currentPageIndex = index;
            });
          }
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
                      child: _buildNotificationBadge(notificationCount > 9
                          ? "9+"
                          : notificationCount.toString()),
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
