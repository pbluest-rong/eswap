import 'package:flutter/material.dart';

class AppTextField  extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;

  const AppTextField ({
    Key? key,
    required this.label,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
        filled: true,
        fillColor: const Color(0xFFF1F4FF),
      ),
    );
  }
}


class AppPasswordTextField extends StatefulWidget {
  final String labelText;

  const AppPasswordTextField({super.key, required this.labelText});


  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<AppPasswordTextField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: _isObscure,
      decoration: InputDecoration(
        labelText: widget.labelText,
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
