import 'package:flutter/material.dart';

class LoginPrompt extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const LoginPrompt({super.key, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
              text: title,
              style: TextStyle(color: Color(0xFFA8ABA6)),
              children: [
                TextSpan(
                    text: subtitle,
                    style: TextStyle(color: Color(0xFFFFA7A7))
                )
              ]
          ),
        ),
      ),
    );
  }
}
