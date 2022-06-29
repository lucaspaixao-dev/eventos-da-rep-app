import 'package:flutter/material.dart';

import '../../../widgets/loader.dart';

class ConfirmButtonEventDetails extends StatelessWidget {
  const ConfirmButtonEventDetails({
    Key? key,
    required this.isGoing,
    required bool isLoading,
    required this.onPressed,
  })  : _isLoading = isLoading,
        super(key: key);

  final bool isGoing;
  final bool _isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        primary: !isGoing ? Colors.green : Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      child: (_isLoading)
          ? const Loader()
          : !isGoing
              ? const Text('Confirmar Presença')
              : const Text('Cancelar Presença'),
    );
  }
}
