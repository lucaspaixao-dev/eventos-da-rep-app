import 'package:flutter/material.dart';
import 'package:flutter_password_strength/flutter_password_strength.dart';

// ignore: must_be_immutable
class AppCreatePasswordTextFormField extends StatefulWidget {
  AppCreatePasswordTextFormField({
    Key? key,
    required this.passwordController,
    required bool passwordVisible,
    this.text,
    this.showPasswordStrength,
  })  : _passwordVisible = passwordVisible,
        super(key: key);

  final TextEditingController passwordController;
  bool _passwordVisible;
  String? text;
  bool? showPasswordStrength = false;

  @override
  State<AppCreatePasswordTextFormField> createState() =>
      _AppCreatePasswordTextFormFieldState();
}

class _AppCreatePasswordTextFormFieldState
    extends State<AppCreatePasswordTextFormField> {
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          onChanged: (text) => {
            setState(() {
              password = text;
            })
          },
          controller: widget.passwordController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Insira sua senha.';
            }

            if (value.length < 5 || value.length > 30) {
              return 'Seu e-mail deve ter entre 5 e até 30 caracteres.';
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
            labelText: widget.text ?? 'Sua senha',
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
        ),
        Visibility(
          visible: widget.showPasswordStrength ?? false,
          child: Column(
            children: [
              const SizedBox(
                height: 16,
              ),
              FlutterPasswordStrength(
                password: password,
              )
            ],
          ),
        ),
      ],
    );
  }
}
