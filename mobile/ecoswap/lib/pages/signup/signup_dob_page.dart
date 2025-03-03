import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ecoswap/pages/login/login_page.dart';
import 'package:ecoswap/pages/signup/signup_gender_page.dart';

class SignUpBirthdayPage extends StatelessWidget {
  final TextEditingController dobController = TextEditingController();

  SignUpBirthdayPage({super.key});

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
                              "signup_question_3".tr(),
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
                              "signup_question_3_desc".tr(),
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
                      TextFormField(
                        controller: dobController,
                        readOnly: true,
                        // Không cho phép nhập tay, chỉ chọn từ DatePicker
                        decoration: InputDecoration(
                          labelText: "dob".tr(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2.0),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF1F4FF),
                          suffixIcon: Icon(Icons.calendar_today,
                              color: Colors.blue), // Icon lịch
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  primaryColor: Colors.blue,
                                  // Màu chính của DatePicker
                                  canvasColor: Colors.blue,
                                  colorScheme:
                                      ColorScheme.light(primary: Colors.blue),
                                  buttonTheme: ButtonThemeData(
                                      textTheme: ButtonTextTheme.primary),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (pickedDate != null) {
                            String formattedDate =
                                "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                            dobController.text = formattedDate;
                          }
                        },
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 32),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpGenderPage()));
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
