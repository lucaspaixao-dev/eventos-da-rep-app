import 'package:flutter/material.dart';

class DecriptionBoxEventDetails extends StatelessWidget {
  const DecriptionBoxEventDetails({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'Descrição',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
