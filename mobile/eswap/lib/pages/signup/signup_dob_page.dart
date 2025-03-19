import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/pages/signup/signup_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:eswap/pages/login/login_page.dart';
import 'package:eswap/pages/signup/signup_gender_page.dart';
import 'package:provider/provider.dart';

class SignUpBirthdayPage extends StatefulWidget {
  @override
  _SignUpBirthdayPageState createState() => _SignUpBirthdayPageState();
}

class _SignUpBirthdayPageState extends State<SignUpBirthdayPage> {
  final TextEditingController dobController = TextEditingController();
  String? _errorText;

  void _validateAndProceed() {
    setState(() {
      _errorText = null;
    });

    if (dobController.text.isEmpty) {
      setState(() {
        _errorText = 'alert_null_value'.tr(args: ["dob".tr()]);
      });
      return;
    }

    DateTime dob = DateFormat('yyyy-MM-dd').parse(dobController.text);
    DateTime today = DateTime.now();
    int age = today.year - dob.year;

    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--; // Trừ đi 1 nếu chưa đến sinh nhật năm nay
    }

    if (age < 13) {
      setState(() {
        _errorText = "registration_age_limit".tr(args: ["13"]);
      });
      return;
    }

    // Nếu hợp lệ, chuyển sang bước tiếp theo
    Provider.of<SignupProvider>(context, listen: false).updateDob(dobController.text);
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpGenderPage()));
  }

  @override
  Widget build(BuildContext context) {
    TextTheme _textTheme = Theme.of(context).textTheme;

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
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "signup_question_3".tr(),
                            style: _textTheme.headlineMedium,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "signup_question_3_desc".tr(),
                            style: _textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      TextFormField(
                        controller: dobController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "dob".tr(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 2.0),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF1F4FF),
                          suffixIcon: Icon(Icons.calendar_today, color: Colors.blue),
                          errorText: _errorText, // Hiển thị lỗi dưới ô nhập
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null) {
                            String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                            setState(() {
                              dobController.text = formattedDate;
                              _errorText = null; // Xóa lỗi nếu hợp lệ
                            });
                          }
                        },
                      ),
                      SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _validateAndProceed,
                          child: Text("next".tr()),
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
                  style: _textTheme.labelMedium,
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
