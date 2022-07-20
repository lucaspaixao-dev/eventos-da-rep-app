import 'package:flutter/material.dart';

class NoItemsFoundIndicator extends StatelessWidget {
  const NoItemsFoundIndicator({Key? key, required this.message})
      : super(key: key);
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Image.asset(
              "assets/not_found.png",
              width: 110,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              message,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      );
}
