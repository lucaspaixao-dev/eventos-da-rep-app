import 'package:eventos_da_rep/widgets/loader.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    Key? key,
    required bool isLoading,
    required this.onPressed,
    required this.text,
    required this.color,
  })  : _isLoading = isLoading,
        super(key: key);

  final bool _isLoading;
  final VoidCallback onPressed;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: color,
          minimumSize: const Size.fromHeight(50), // NEW
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        onPressed: _isLoading ? null : onPressed,
        child: !_isLoading
            ? Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              )
            : const Loader(),
      );
}
