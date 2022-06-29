import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    Key? key,
    required this.isLoading,
  }) : super(key: key);

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        minimumSize: const Size.fromHeight(50), // NEW
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      onPressed: () => isLoading ? null : Navigator.pop(context),
      child: const Text(
        "Voltar",
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
