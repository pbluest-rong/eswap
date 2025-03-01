import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ecoswap/components/dropdown.dart';
import 'package:ecoswap/login/login_page.dart';
import 'package:ecoswap/signup/signup_email_page.dart';

class SignUpGenderPage extends StatelessWidget {
  final TextEditingController dobController = TextEditingController();

  SignUpGenderPage({super.key});

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
            children:[
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
                              "signup_question_4".tr(),
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
                              "signup_question_4_desc".tr(),
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
                      RadioListTileExample(),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 32),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpEmailPage()));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F41BB),
                              padding:
                                  EdgeInsets.symmetric(horizontal: 40, vertical: 16),
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                  ),
                ),
              ),
    ]
          ),
        ));
  }
}

enum GenderOption { male, female, another }

class RadioListTileExample extends StatefulWidget {
  const RadioListTileExample({super.key});

  @override
  State<RadioListTileExample> createState() => _RadioListTileExampleState();
}

class _RadioListTileExampleState extends State<RadioListTileExample> {
  GenderOption? _gender = GenderOption.female;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildRadioTile(GenderOption.female, "female".tr()),
        SizedBox(height: 12),
        _buildRadioTile(GenderOption.male, "male".tr()),
        SizedBox(height: 12),
        _buildRadioTile(GenderOption.another, "another".tr()),
      ],
    );
  }

  Widget _buildRadioTile(GenderOption value, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF1F4FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _gender == value ? Colors.blue : Colors.transparent,
          // Border khi chọn
          width: _gender == value ? 2.0 : 0,
        ),
      ),
      child: RadioListTile<GenderOption>(
        title: Text(title),
        value: value,
        groupValue: _gender,
        onChanged: (GenderOption? newValue) {
          setState(() {
            _gender = newValue;
          });
        },
        activeColor: Colors.blue,
        tileColor: Colors.transparent,
      ),
    );
  }
}
