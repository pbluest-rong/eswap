import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/utils/validation.dart';
import 'package:eswap/pages/signup/signup_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:eswap/pages/login/login_page.dart';
import 'package:eswap/pages/signup/signup_education_page.dart';
import 'package:provider/provider.dart';

class SignUpNamePage extends StatelessWidget {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  SignUpNamePage({super.key});

  /// Add firstname and lastname to SignupProvider
  /// Routing to SignupEducationPage
  void next(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      Provider.of<SignupProvider>(context, listen: false)
          .updateFirstName(firstNameController.text);
      Provider.of<SignupProvider>(context, listen: false)
          .updateLastName(lastNameController.text);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignUpEducationPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
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
        child: Form( // Bọc Form vào đây
          key: _formKey,
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
                          style: textTheme.headlineMedium,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "signup_question_1_desc".tr(),
                          style: textTheme.bodyLarge,
                        ),
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: "last_name".tr(),
                                ),
                                controller: lastNameController,
                                validator: ValidationUtils.validateName,
                                autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: "first_name".tr(),
                                ),
                                controller: firstNameController,
                                validator: ValidationUtils.validateName,
                                autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => next(context), // Gọi next()
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
                    style: textTheme.labelMedium,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
