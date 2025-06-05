import 'package:eswap/core/theme/theme.dart';
import 'package:eswap/model/user_model.dart';
import 'package:eswap/presentation/components/bottom_sheet.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:eswap/presentation/views/setting/account_setting.dart';
import 'package:eswap/presentation/views/welcome/welcome_page.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsPage extends StatefulWidget {
  bool isAppBar;

  SettingsPage({super.key, this.isAppBar = true});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = 'Tiếng Việt';
  UserSession? userSession;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    final session = await UserSession.load();
    if (mounted) {
      setState(() {
        userSession = session;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _themeManager = ThemeManager();
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: (widget.isAppBar ?? false)
          ? AppBar(
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
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('TÀI KHOẢN'),
          _buildListTileSetting(
            title: 'Thông tin tài khoản',
            icon: Icons.person_outline,
            onTap: () {
              _navigateToAccountInfo();
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('GIAO DIỆN'),
          PopupMenuButton<ThemeMode>(
            offset: const Offset(150, 0),
            itemBuilder: (context) => [
              _buildPopupItem(
                  ThemeMode.system, "Theo thiết bị", Icons.phone_android),
              _buildPopupItem(ThemeMode.light, "Sáng", Icons.wb_sunny),
              _buildPopupItem(ThemeMode.dark, "Tối", Icons.nights_stay),
            ],
            onSelected: (ThemeMode mode) {
              _themeManager.setThemeMode(mode);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Theme.of(context).cardColor,
            elevation: 5,
            child: ListTile(
              leading: isDark ? Icon(Icons.nights_stay) : Icon(Icons.wb_sunny),
              title: Text("Giao diện"),
              trailing: const Icon(Icons.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            ),
          ),
          const SizedBox(height: 24),
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

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return "Sáng";
      case ThemeMode.dark:
        return "Tối";
      case ThemeMode.system:
      default:
        return "Theo thiết bị";
    }
  }

  PopupMenuItem<ThemeMode> _buildPopupItem(
      ThemeMode mode, String text, IconData icon) {
    return PopupMenuItem(
      value: mode,
      child: Row(
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 10),
          Text(text),
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

  void _navigateToAccountInfo() async {
    UserInfomation user =
        await UserService().fetchUserById(userSession!.userId, context);
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
              child: AccountSetting(
                user: user,
              ),
            )));
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
          AlertAction(
              text: "Đăng xuất",
              isDestructive: true,
              handler: () async {
                UserSession.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          WelcomePage(isFirstTimeInstallApp: false)),
                  (Route<dynamic> route) => false,
                );
              })
        ]);
  }
}
