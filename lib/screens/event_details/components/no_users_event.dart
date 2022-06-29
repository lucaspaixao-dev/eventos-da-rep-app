import 'package:flutter/material.dart';

class NoUsersOnEvent extends StatelessWidget {
  const NoUsersOnEvent({
    Key? key,
    required this.isEmpty,
  }) : super(key: key);

  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isEmpty,
      child: const Text(
        "Nenhum usuário confirmou presença 🥲",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
