import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;

  const AdminSidebar({
    Key? key,
    required this.onItemSelected,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        const SizedBox(height: 10),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildMenuItem(
                  context,
                  index: 0,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                ),
                _buildMenuItem(
                  context,
                  index: 1,
                  icon: Icons.people,
                  title: 'Người dùng',
                ),
                _buildMenuItem(
                  context,
                  index: 2,
                  icon: Icons.shopping_cart,
                  title: 'Danh mục và thương hiệu',
                ),
                _buildMenuItem(
                  context,
                  index: 3,
                  icon: Icons.report,
                  title: 'Báo cáo',
                ),
                _buildMenuItem(
                  context,
                  index: 4,
                  icon: Icons.manage_history,
                  title: 'Lịch sử hệ thống',
                ),
                _buildMenuItem(
                  context,
                  index: 5,
                  icon: Icons.settings,
                  title: 'Cài đặt',
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Text(
              'A',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ba Phung Le',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'admin@example.com',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
  }) {
    final isSelected = selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).primaryColor
            : Theme.of(context).iconTheme.color,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
      ),
      onTap: () => onItemSelected(index),
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }

  Widget _buildExpansionMenuItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final isSelected = selectedIndex == index ||
        (selectedIndex > index * 10 && selectedIndex < (index + 1) * 10);

    return ExpansionTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).primaryColor
            : Theme.of(context).iconTheme.color,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
      ),
      initiallyExpanded: isSelected,
      children: children,
    );
  }

  Widget _buildSubMenuItem(
    BuildContext context, {
    required String title,
    required int index,
  }) {
    final isSelected = selectedIndex == index;

    return ListTile(
      title: Row(
        children: [
          Icon(Icons.circle, size: 8),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      onTap: () => onItemSelected(index),
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      contentPadding: const EdgeInsets.only(left: 40),
    );
  }
}
