import 'package:easy_localization/easy_localization.dart';
import 'package:ecoswap/common/textfields.dart';
import 'package:flutter/material.dart';
import 'package:ecoswap/pages/login/login_page.dart';


class ResetPasswordPage extends StatelessWidget {
  final TextEditingController dobController = TextEditingController();

  ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("reset_pw".tr(),
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
                  child: Column(
                    children: [
                      AppPasswordTextField(labelText: "new_pw".tr(),),
                      SizedBox(
                        height: 24,
                      ),
                      AppPasswordTextField(labelText: "confirm_new_pw".tr(),),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 32),
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()));
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1F41BB),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4))),
                            child: Text(
                              "submit".tr(),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Lato",
                                  color: Colors.white),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ));
  }
}
