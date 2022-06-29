import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    Key? key,
    required this.fontSize,
  }) : super(key: key);

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          "EVENTOS ",
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          "DA REP",
          style: TextStyle(
            color: const Color(0xffFFA700),
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
          ),
        )
      ],
    );
  }
}
