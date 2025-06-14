import 'package:eswap/model/dashboard.dart';
import 'package:eswap/service/user_service.dart';
import 'package:flutter/material.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Dashboard? dashboard;
  bool isLoading = true;

  Future<void> _onRefresh() async {
    await _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      setState(() => isLoading = true);
      final newDashboard = await UserService().dashboard(context);
      setState(() {
        dashboard = newDashboard;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      // Handle error appropriately
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load dashboard: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildStatCard(
                          'Người dùng',
                          dashboard?.totalUsers.toString() ?? '0',
                          Icons.person,
                          Colors.blue),
                      _buildStatCard(
                          'Bài đăng',
                          dashboard?.totalPosts.toString() ?? '0',
                          Icons.post_add,
                          Colors.yellow),
                      _buildStatCard(
                          'Đơn hàng',
                          dashboard?.totalOrders.toString() ?? '0',
                          Icons.shopping_cart,
                          Colors.green),
                      _buildStatCard(
                          'Giao dịch',
                          dashboard?.totalTransactions.toString() ?? '0',
                          Icons.currency_exchange,
                          Colors.green),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    double itemWidth = (MediaQuery.of(context).size.width - 16 * 2 - 10) / 2;

    return SizedBox(
      width: itemWidth,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}