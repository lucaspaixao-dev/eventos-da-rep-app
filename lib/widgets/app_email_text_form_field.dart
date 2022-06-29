import 'package:flutter/material.dart';

class AppEmailTextFormField extends StatelessWidget {
  const AppEmailTextFormField({
    Key? key,
    required this.emailController,
  }) : super(key: key);

  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: emailController,
        validator: (value) {
          String emailRegex =
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
          if (value == null || value.isEmpty) {
            return 'Insira seu e-mail.';
          }

          bool emailValid = RegExp(emailRegex).hasMatch(value);

          if (!emailValid) {
            return 'Insira um e-mail válido.';
          }
          return null;
        },
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          labelText: 'E-mail',
          labelStyle: TextStyle(color: Colors.white),
          hintStyle: TextStyle(color: Colors.white),
          errorStyle: TextStyle(color: Colors.redAccent),
        ),
      );
}
