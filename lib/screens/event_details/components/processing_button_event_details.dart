import 'package:flutter/material.dart';

class ProcessingButtonEventDetails extends StatelessWidget {
  const ProcessingButtonEventDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        primary: const Color.fromARGB(255, 228, 172, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      child: const Text('Processando...'),
    );
  }
}
