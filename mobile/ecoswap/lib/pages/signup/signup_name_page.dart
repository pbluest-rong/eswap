import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ecoswap/pages/login/login_page.dart';
import 'package:ecoswap/pages/signup/signup_education_page.dart';

class SignUpNamePage extends StatelessWidget {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  SignUpNamePage({super.key});

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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "signup_question_1".tr(),
                        style: TextStyle(
                          fontFamily: "Lato",
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "signup_question_1_desc".tr(),
                        style: TextStyle(
                          fontFamily: "Lato",
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: firstNameController,
                              decoration: InputDecoration(
                                labelText: "first_name".tr(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF1F4FF),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: lastNameController,
                              decoration: InputDecoration(
                                labelText: "last_name".tr(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF1F4FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpEducationPage()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1F41BB),
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            "next".tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Lato",
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: RichText(
                text: TextSpan(
                  text: "signup_bottom".tr(),
                  style: TextStyle(
                    color: const Color(0xFF1F41BB),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}