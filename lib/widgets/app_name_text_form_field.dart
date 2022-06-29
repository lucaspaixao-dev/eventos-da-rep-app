import 'package:flutter/material.dart';

class AppNameTextFormField extends StatelessWidget {
  const AppNameTextFormField({
    Key? key,
    required this.nameController,
  }) : super(key: key);

  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: nameController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Insira seu nome.';
        }

        if (value.length < 5 || value.length > 50) {
          return 'Seu nome deve ter entre 5 e até 50 caracteres.';
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
        labelText: 'Seu nome',
        labelStyle: TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Colors.white),
        errorStyle: TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
