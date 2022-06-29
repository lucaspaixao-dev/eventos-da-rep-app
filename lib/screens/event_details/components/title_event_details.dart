import 'package:flutter/material.dart';

class TitleEventDetails extends StatelessWidget {
  const TitleEventDetails({
    Key? key,
    required this.mediaQuery,
    required this.title,
  }) : super(key: key);

  final MediaQueryData mediaQuery;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: mediaQuery.size.width * 0.90,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
