import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AppPasswordTextFormField extends StatefulWidget {
  AppPasswordTextFormField({
    Key? key,
    required this.passwordController,
    required bool passwordVisible,
  })  : _passwordVisible = passwordVisible,
        super(key: key);

  final TextEditingController passwordController;
  bool _passwordVisible;

  @override
  State<AppPasswordTextFormField> createState() =>
      _AppPasswordTextFormFieldState();
}

class _AppPasswordTextFormFieldState extends State<AppPasswordTextFormField> {
  @override
  Widget build(BuildContext context) => TextFormField(
        controller: widget.passwordController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Insira sua senha.';
          }
          return null;
        },
        obscureText: !widget._passwordVisible,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          labelText: 'Senha',
          labelStyle: const TextStyle(color: Colors.white),
          hintStyle: const TextStyle(color: Colors.white),
          errorStyle: const TextStyle(color: Colors.redAccent),
          suffixIcon: IconButton(
            icon: Icon(widget._passwordVisible
                ? Icons.visibility
                : Icons.visibility_off),
            color: Colors.white,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () {
              setState(() {
                widget._passwordVisible = !widget._passwordVisible;
              });
            },
          ),
        ),
      );
}
