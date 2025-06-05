import 'package:flutter/material.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Future<void> _onRefresh() async {
    // Giả lập delay, bạn có thể thêm API refresh tại đây
    await Future.delayed(const Duration(seconds: 1));
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
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildStatCard(
                        'Người dùng', '10', Icons.person, Colors.blue),
                    _buildStatCard(
                        'Bài đăng', '30', Icons.post_add, Colors.yellow),
                    _buildStatCard(
                        'Đơn hàng', '9', Icons.shopping_cart, Colors.green),
                    _buildStatCard(
                        'Giao dịch', '4', Icons.currency_exchange, Colors.green),
                    // _buildStatCard('Báo cáo', '10', Icons.report, Colors.red),
                  ],
                ),
                // const SizedBox(height: 24),
                // const Text('Hoạt động gần đây',
                //     style:
                //         TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                // const SizedBox(height: 8),
                // ListView.builder(
                //   shrinkWrap: true,
                //   physics: const NeverScrollableScrollPhysics(),
                //   itemCount: 5,
                //   itemBuilder: (context, index) {
                //     return ListTile(
                //       leading: const Icon(Icons.notifications),
                //       title: Text('Thông báo #${index + 1}'),
                //       subtitle: const Text(
                //           'Chi tiết thông báo hoặc hoạt động gần đây.'),
                //     );
                //   },
                // )
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
