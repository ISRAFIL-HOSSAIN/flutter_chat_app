import 'package:flutter/material.dart';

import '../constant/constant.dart';
import 'input_container.dart';

class Rounded_password extends StatelessWidget {
  const Rounded_password({
    Key? key,
    required this.size,
    required this.icon,
    required this.hint, controller, required String? Function(String? value) validator,
  }) : super(key: key);

  final Size size;
  final IconData icon;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return InputContainer(
      child: TextField(
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
            icon: Icon(icon, color: kPrimaryColor),
            hintText: hint,
            border: InputBorder.none),
      ),
    );
  }
}
