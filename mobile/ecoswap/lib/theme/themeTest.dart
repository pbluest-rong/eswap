import 'package:ecoswap/common/textfields.dart';
import 'package:ecoswap/theme/theme_manager.dart';
import 'package:flutter/material.dart';

final _themeManager = ThemeManager();

class ThemeTest extends StatelessWidget {
  const ThemeTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Theme app"),
        actions: [
          Switch(
              value: _themeManager.themeMode == ThemeMode.dark,
              onChanged: (newValue) {
                _themeManager.toggleThem(newValue);
              })
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("What's your name?"),
            SizedBox(
              height: 10,
            ),
            AppTextField(label: "Full name")
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
