import 'package:flutter/material.dart';

class AppSubtitle extends StatelessWidget {
  const AppSubtitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const Text(
        "Fique por dentro dos eventos da REP mais badalada de Araraquara e região!",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
}
