import 'package:flutter/material.dart';

class AppCreateEmailTextFormField extends StatelessWidget {
  const AppCreateEmailTextFormField({
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

          if (value.length < 5 || value.length > 100) {
            return 'Seu e-mail deve ter entre 5 e até 100 caracteres.';
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
          labelText: 'Seu e-mail',
          labelStyle: TextStyle(color: Colors.white),
          hintStyle: TextStyle(color: Colors.white),
          errorStyle: TextStyle(color: Colors.redAccent),
        ),
      );
}
