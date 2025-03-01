import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ecoswap/components/dropdown.dart';
import 'package:ecoswap/login/login_page.dart';
import 'package:ecoswap/signup/signup_dob_page.dart';

class SignUpEducationPage extends StatelessWidget {
  final TextEditingController educationController = TextEditingController();

  SignUpEducationPage({super.key});

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
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "signup_question_2".tr(),
                              style: TextStyle(
                                fontFamily: "Lato",
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "signup_question_2_desc".tr(),
                              style: TextStyle(
                                fontFamily: "Lato",
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Dropdown(
                        label: "province".tr(),
                        list: List.generate(63, (index) => 'Item ${index + 1}'),
                        menuMaxHeightValue: 200,
                      ),
                      Dropdown(
                        label: "education_institution".tr(),
                        list: List.generate(40, (index) => 'Item ${index + 1}'),
                        menuMaxHeightValue: 400,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 32),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SignUpBirthdayPage()));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F41BB),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4))),
                          child: Text(
                            "next".tr(),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Lato",
                                color: Colors.white),
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
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                ),
              ),
            ),
          ]),
        ));
  }
}
