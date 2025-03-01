import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecoswap/forgotpw/forgotpw_reset_page.dart';
import 'package:ecoswap/login/login_page.dart';

class VerifyEmailPage extends StatelessWidget {
  final bool redirectToReset;

  const VerifyEmailPage({super.key, this.redirectToReset = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("signup_verify_title".tr(),
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              overflow: TextOverflow.fade),
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
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 32,
                      ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 24),
                          children: [
                            TextSpan(text: "signup_verify_desc_head".tr()),
                            TextSpan(
                              text: " (pbluest.rong@gmail.com) ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: "signup_verify_desc_tail".tr()),
                          ],
                        ),
                      ),
                      //Code Input

                      _buildCodeInputAll(context),

                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 18),
                          children: [
                            TextSpan(text: "resend_question".tr()),
                            TextSpan(
                              text: " ${"resend".tr()}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 18),
                          children: [
                            TextSpan(text: "expires_in".tr()),
                            TextSpan(
                              text: " 1:00".tr(),
                              style: TextStyle(
                                  color: const Color(0xFF1F41BB),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 32),
                        child: ElevatedButton(
                          onPressed: () {
                            if (redirectToReset) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ResetPasswordPage()));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()));
                            }
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
        ])));
  }

  Widget _buildCodeInputAll(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      child: Form(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCodeInput(context),
          _buildCodeInput(context),
          _buildCodeInput(context),
          _buildCodeInput(context),
        ],
      )),
    );
  }

  Widget _buildCodeInput(BuildContext context) {
    return SizedBox(
      height: 68,
      width: 64,
      child: TextFormField(
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
        onSaved: (pin) {},
        style: Theme.of(context).textTheme.headlineLarge,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          border: OutlineInputBorder(), // Thêm border
        ),
      ),
    );
  }
}
