import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/pages/signup/signup_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:eswap/pages/login/login_page.dart';
import 'package:eswap/pages/signup/signup_email_page.dart';
import 'package:provider/provider.dart';

class SignUpGenderPage extends StatefulWidget {
  SignUpGenderPage({super.key});

  @override
  _SignUpGenderPageState createState() => _SignUpGenderPageState();
}

class _SignUpGenderPageState extends State<SignUpGenderPage> {
  GenderOption? selectedGender = GenderOption.female; // Giá trị mặc định

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
                              "signup_question_4".tr(),
                              style: _textTheme.headlineMedium,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "signup_question_4_desc".tr(),
                              style: _textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        RadioListGender(
                          selectedGender: selectedGender,
                          onGenderChanged: (GenderOption? gender) {
                            setState(() {
                              selectedGender = gender;
                            });
                          },
                        ),
                        SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Provider.of<SignupProvider>(context,
                                  listen: false)
                                  .updateGender(
                                  _convertGenderToBool(selectedGender));
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpEmailPage(),
                                ),
                              );
                            },
                            child: Text(
                              "next".tr(),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

bool? _convertGenderToBool(GenderOption? gender) {
  if (gender == GenderOption.male) return true;
  if (gender == GenderOption.female) return false;
  return null;
}

enum GenderOption { male, female, another }

class RadioListGender extends StatefulWidget {
  final GenderOption? selectedGender;
  final Function(GenderOption?) onGenderChanged;

  const RadioListGender(
      {super.key, required this.selectedGender, required this.onGenderChanged});

  @override
  State<RadioListGender> createState() => _RadioListGenderState();
}

class _RadioListGenderState extends State<RadioListGender> {
  GenderOption? _gender;

  @override
  void initState() {
    super.initState();
    _gender = widget.selectedGender;
  }

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
          widget.onGenderChanged(newValue);
        },
        activeColor: Colors.blue,
        tileColor: Colors.transparent,
      ),
    );
  }
}
