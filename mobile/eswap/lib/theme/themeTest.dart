import 'package:eswap/widgets/password_tf.dart';
import 'package:eswap/theme/theme_manager.dart';
import 'package:flutter/material.dart';

final _themeManager = ThemeManager();

class ThemeTest extends StatelessWidget {
  const ThemeTest({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme _textTheme = Theme.of(context).textTheme;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Theme app"),
        actions: [
          PopupMenuButton<ThemeMode>(
            icon: Icon(Icons.color_lens),
            onSelected: (ThemeMode mode) {
              _themeManager.setThemeMode(mode);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ThemeMode.system,
                child: Text("Theo thiết bị"),
              ),
              PopupMenuItem(
                value: ThemeMode.light,
                child: Text("Sáng"),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Text("Tối"),
              ),
            ],
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "About you!",
              style: _textTheme.headlineLarge
                  ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            Text(
              "What's your name?",
              style: _textTheme.bodyMedium,
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
