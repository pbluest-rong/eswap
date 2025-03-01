import 'package:flutter/material.dart';
import 'package:ecoswap/components/text_1.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHomeHeader(),
              _buildContentList(),
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildHomeHeader() {
    return Row(
      children: [
        Text1(textKey: "Notification")
      ],
    );
  }

  Widget _buildContentList() {
    return Row();
  }
}
