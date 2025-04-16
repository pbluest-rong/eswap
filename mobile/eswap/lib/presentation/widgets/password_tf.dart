import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppBody extends StatelessWidget {
  final Widget child;

  const AppBody({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.01,
          vertical: MediaQuery.of(context).size.height * 0.005,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.02,
          vertical: MediaQuery.of(context).size.height * 0.003,
        ),
        child: child,
      ),
    );
  }
}

class AppPasswordTextField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final TextEditingController? matchController;
  final bool validatePassword;

  const AppPasswordTextField({
    super.key,
    required this.labelText,
    required this.controller,
    this.matchController,
    this.validatePassword = true,
  });

  @override
  _AppPasswordTextFieldState createState() => _AppPasswordTextFieldState();
}

class _AppPasswordTextFieldState extends State<AppPasswordTextField> {
  bool _isObscure = true;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "alert_null_value".tr(args: ["pw".tr()]);
    }

    if (!widget.validatePassword) {
      return null;
    }

    if (value.length < 8) {
      return "password_length".tr();
    }
    if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[\W_])(?!.*\s)[A-Za-z\d\W_]{8,}$')
        .hasMatch(value)) {
      return "password_requirements".tr();
    }

    if (widget.matchController != null &&
        value != widget.matchController!.text) {
      return "password_mismatch".tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscure,
      validator: _validatePassword,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: widget.labelText,
        errorMaxLines: 2,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
        filled: true,
        fillColor: const Color(0xFFF1F4FF),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscure ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        ),
      ),
    );
  }
}
