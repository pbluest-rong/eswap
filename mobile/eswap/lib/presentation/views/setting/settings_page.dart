import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false;
  bool _darkModeEnabled = true;
  String _selectedLanguage = 'Tiếng Việt';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Cài đặt'),
        centerTitle: true,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('TÀI KHOẢN'),
          _buildSwitchSetting(
            title: 'Thông báo',
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
          ),
          _buildListTileSetting(
            title: 'Thông tin tài khoản',
            icon: Icons.person_outline,
            onTap: () => _navigateToAccountInfo(),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('GIAO DIỆN'),
          _buildSwitchSetting(
            title: 'Chế độ tối',
            value: _darkModeEnabled,
            onChanged: (value) => setState(() => _darkModeEnabled = value),
          ),
          _buildDropdownSetting(
            title: 'Ngôn ngữ',
            value: _selectedLanguage,
            items: ['Tiếng Việt', 'English'],
            onChanged: (value) => setState(() => _selectedLanguage = value!),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('ỨNG DỤNG'),
          _buildListTileSetting(
            title: 'Đánh giá ứng dụng',
            icon: Icons.star_border,
            onTap: () => _rateApp(),
          ),
          _buildListTileSetting(
            title: 'Chia sẻ ứng dụng',
            icon: Icons.share,
            onTap: () => _shareApp(),
          ),
          _buildListTileSetting(
            title: 'Chính sách bảo mật',
            icon: Icons.privacy_tip_outlined,
            onTap: () => _openPrivacyPolicy(),
          ),
          _buildListTileSetting(
            title: 'Điều khoản và điều kiện',
            icon: Icons.description_outlined,
            onTap: () => _openTermsAndConditions(),
          ),
          _buildListTileSetting(
            title: 'Đóng góp ý kiến',
            icon: Icons.feedback_outlined,
            onTap: () => _sendFeedback(),
          ),
          const SizedBox(height: 24),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSwitchSetting({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }

  Widget _buildListTileSetting({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      onTap: onTap,
    );
  }

  Widget _buildDropdownSetting({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: title,
        labelStyle: TextStyle(
          color: Colors.grey[700],
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.blue.shade300,
            width: 1.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      isExpanded: true,
      value: value,
      style: TextStyle(
        color: Colors.grey[800],
        fontSize: 15,
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[50],
        foregroundColor: Colors.red,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text('Đăng xuất'),
      onPressed: () => _confirmLogout(),
    );
  }

  // Các hàm xử lý sự kiện
  void _navigateToAccountInfo() {
    // TODO: Điều hướng đến trang thông tin tài khoản
  }

  void _rateApp() {
    // TODO: Mở cửa sổ đánh giá ứng dụng
  }

  void _shareApp() {
    // TODO: Chia sẻ ứng dụng
  }

  void _openPrivacyPolicy() {
    // TODO: Mở chính sách bảo mật
  }

  void _openTermsAndConditions() {
    // TODO: Mở điều khoản và điều kiện
  }

  void _sendFeedback() {
    // TODO: Gửi phản hồi
  }

  void _confirmLogout() {
    AppAlert.show(
        context: context,
        title: "Bạn có chắc chắn muốn đăng xuất?",
        actions: [
          AlertAction(text: "Hủy"),
          AlertAction(text: "Đăng xuất", isDestructive: true, handler: () {})
        ]);
  }
}
