import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

class AppSnackBar {
  final String title;
  final String message;
  final bool isSuccess;
  final double elevation;
  final Duration duration;

  const AppSnackBar({
    required this.title,
    required this.message,
    required this.isSuccess,
    required this.elevation,
    required this.duration,
  });

  SnackBar buildSnackBar() {
    return SnackBar(
      duration: duration,
      elevation: elevation,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: isSuccess ? ContentType.success : ContentType.failure,
      ),
    );
  }
}

SnackBar buildErrorSnackBar(String message) {
  return AppSnackBar(
    title: "Ops! Ocorreu um erro!",
    message: message,
    isSuccess: false,
    elevation: 10.0,
    duration: const Duration(milliseconds: 3000),
  ).buildSnackBar();
}
