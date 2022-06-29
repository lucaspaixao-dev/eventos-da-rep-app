import 'package:flutter/material.dart';

class AppLink extends StatelessWidget {
  const AppLink({
    Key? key,
    required this.firstText,
    required this.secondText,
    required this.to,
  }) : super(key: key);

  final String firstText;
  final String secondText;
  final Widget to;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => to,
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              // "Não possuí uma conta? ",
              firstText,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            Text(
              secondText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      );
}
