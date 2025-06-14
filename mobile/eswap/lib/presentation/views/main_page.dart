import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/main.dart';
import 'package:eswap/model/user_model.dart';
import 'package:eswap/presentation/components/bottom_sheet.dart';
import 'package:eswap/presentation/provider/user_provider.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:eswap/presentation/views/chat/chat_list_page.dart';
import 'package:eswap/presentation/views/post/add_post.dart';
import 'package:eswap/presentation/views/post/add_post_provider.dart';
import 'package:eswap/presentation/views/post/select_category.dart';
import 'package:eswap/presentation/widgets/password_tf.dart';
import 'package:eswap/service/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:eswap/presentation/views/home/home_page.dart';
import 'package:eswap/presentation/views/search/search_page.dart';
import 'package:eswap/presentation/views/order/order_management_page.dart';
import 'package:provider/provider.dart';
import 'package:searchfield/searchfield.dart';
import 'package:shimmer/shimmer.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentPageIndex = 0;
  final HomePageController _homePageController = HomePageController();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(controller: _homePageController),
      const SearchPage(),
      const SizedBox(),
      ChatList(),
      OrderManagementPage(),
    ];
  }

  Future<void> showCategorySelectionSheet(BuildContext context) async {
    final sessionUser = await UserSession.load();
    final chooseAddPostOrStore =
        await showModalBottomSheet<Map<String, dynamic>>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            barrierColor: Colors.transparent,
            builder: (context) => EnhancedDraggableSheet(
                    child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: AppBody(
                    child: Column(
                      children: [
                        if (sessionUser!.role == 'USER')
                          Container(
                            margin: EdgeInsets.only(bottom: 14),
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () {
                                  final result = {
                                    'isAddPost': false,
                                  };
                                  Navigator.pop(context, result);
                                },
                                child: Text("Sử dụng dịch vụ Eswap Store")),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                              onPressed: () {
                                final result = {
                                  'isAddPost': true,
                                };
                                Navigator.pop(context, result);
                              },
                              child: Text("Đăng trên hồ sơ của bạn")),
                        )
                      ],
                    ),
                  ),
                )));

    if (chooseAddPostOrStore != null) {
      bool isAddPost = chooseAddPostOrStore['isAddPost'];
      if (isAddPost) {
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
              MaterialPageRoute(
                  builder: (_) => AddPostPage(
                        isStore: false,
                      )),
            );
          }
        }
      } else {
        await _loadStores();
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
                  child: _buildStoreChoiceWidget(),
                )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int unreadCount = Provider.of<UserSessionProvider>(context, listen: true)
        .unreadMessageNumber;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _currentPageIndex,
        children: _pages,
      ),
      floatingActionButton:
          Provider.of<UserSessionProvider>(context, listen: true).addPostName !=
                  null
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: SizedBox(
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
                )
              : SizedBox(
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
                (unreadCount > 0)
                    ? _buildNavItem(Icons.message_outlined, 3,
                        hasBadge: true, notificationCount: unreadCount)
                    : _buildNavItem(Icons.message_outlined, 3),
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

  List<SearchFieldListItem<UserInfomation>> _stores = [];
  final TextEditingController storesController = TextEditingController();

  Future<void> _loadStores() async {
    try {
      final userService = UserService();
      final stores = await userService.fetchStores(context);
      setState(() {
        _stores = stores.map((store) {
          return SearchFieldListItem<UserInfomation>(
            "${store.firstname} ${store.lastname}",
            item: store,
            child: Text("${store.firstname} ${store.lastname}"),
          );
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load institutions: $e')),
      );
    }
  }

  Widget _buildStoreChoiceWidget() {
    return AppBody(
      child: Column(
        children: [
          SearchField<UserInfomation>(
            controller: storesController,
            suggestions: _stores,
            hint: "Chọn Store",
            searchInputDecoration: SearchInputDecoration(
              labelText: "Chọn Store",
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
              ),
            ),
            onSuggestionTap: (value) {
              if (value.item != null) {
                setState(() {
                  storesController.text =
                      "${value.item!.firstname} ${value.item!.lastname}";
                  int storeId = value.item!.id;
                  Provider.of<AddPostProvider>(context, listen: false).updateStore(
                      storeId,
                      "${value.item!.firstname} ${value.item!.lastname} - ${value.item!.address}");
                });
              }
            },
          ),
          SizedBox(
            height: 14,
          ),
          ElevatedButton(
              onPressed: () async {
                if (Provider.of<AddPostProvider>(context, listen: false)
                        .storeId !=
                    null) {
                  Navigator.pop(context);
                  final result =
                      await showModalBottomSheet<Map<String, dynamic>>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          barrierColor: Colors.transparent,
                          builder: (context) => EnhancedDraggableSheet(
                                  child: Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom,
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
                        MaterialPageRoute(
                            builder: (_) => AddPostPage(
                                  isStore: true,
                                )),
                      );
                    }
                  }
                }
              },
              child: Text("next".tr()))
        ],
      ),
    );
  }
}
