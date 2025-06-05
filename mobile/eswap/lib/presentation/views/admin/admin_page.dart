import 'package:eswap/main.dart';
import 'package:eswap/presentation/views/admin/admin_dashboard_page.dart';
import 'package:eswap/presentation/views/admin/admin_sidebar.dart';
import 'package:eswap/presentation/views/admin/admin_users_page.dart';
import 'package:eswap/presentation/views/admin/balances_page.dart';
import 'package:eswap/presentation/views/admin/category_brand_page.dart';
import 'package:eswap/presentation/views/setting/account_setting.dart';
import 'package:eswap/presentation/views/setting/settings_page.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;
  bool _showSidebar = false;

  final List<Widget> _pages = [
    AdminDashboardPage(),
    AdminUsersPage(),
    AdminCategoryBrandPage(),
    AdminBalancePage(),
    SettingsPage(
      isAppBar: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Nội dung chính
          _pages[_selectedIndex],

          // Overlay để đóng sidebar khi click ra ngoài
          if (_showSidebar)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _showSidebar = false;
                });
              },
            ),

          // Sidebar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: _showSidebar ? 0 : -250,
            top: 0,
            bottom: 0,
            child: Material(
              elevation: 16,
              child: Container(
                width: 250,
                color: Theme
                    .of(context)
                    .scaffoldBackgroundColor,
                child: AdminSidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                      _showSidebar = false;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          setState(() {
            _showSidebar = !_showSidebar;
          });
        },
      ),
      title: _buildAppBarTitle(),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return const Text('Dashboard');
      case 1:
        return const Text('Quản lý người dùng');
      case 2:
        return const Text('Quản lý danh mục và thương hiệu');
      case 3:
        return const Text('Giải ngân');
      case 4:
        return const Text('Cài đặt');
      default:
        return const Text('Admin Panel');
    }
  }
}
