import 'package:flutter/material.dart';
import 'package:ecoswap/components/text_1.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHomeHeader(),
              _buildContentList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Menu
          GestureDetector(
            onTap: () {
              print("Menu clicked");
            },
            child: Container(
              padding: EdgeInsets.only(top: 3, right: 3),
              child: Image.asset(
                "assets/images/menu.png",
                width: 40,
                height: 40,
              ),
            ),
          ),
          Expanded(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Center(
                  child: Text(
                    "🌏 Đại học Nông Lâm TPHCM",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )),

          // Icon Message
          GestureDetector(
            onTap: () {
              print("Message clicked");
            },
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 3, right: 3),
                  child: Image.asset(
                    "assets/images/message.png",
                    width: 40,
                    height: 40,
                  ),
                ),
                Positioned(
                  right: 0,
                  child: "9+".length < 2
                      ? Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.5),
                          decoration: BoxDecoration(
                              color: Colors.red.shade500,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  width: 2,
                                  color: Colors.white,
                                  style: BorderStyle.solid)),
                          child: Text(
                            "1",
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                              color: Colors.red.shade500,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  width: 2,
                                  color: Colors.white,
                                  style: BorderStyle.solid)),
                          child: Text(
                            "9+",
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    return Row();
  }
}
