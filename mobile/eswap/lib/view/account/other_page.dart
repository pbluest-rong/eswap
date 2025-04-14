import 'package:flutter/material.dart';

class OtherPage extends StatelessWidget {
  const OtherPage({super.key});

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
        
      ],
    );
  }

  Widget _buildContentList() {
    return Row();
  }
}
