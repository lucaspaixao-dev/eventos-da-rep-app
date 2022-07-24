import 'package:eventos_da_rep/widgets/app_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/app_create_password_text_form_field.dart';
import '../../widgets/app_snack_bar.dart';

class UpdatePassword extends StatefulWidget {
  const UpdatePassword({Key? key}) : super(key: key);

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  final _formKey = GlobalKey<FormState>();
  final bool _passwordVisible = false;
  final bool _repeatPasswordVisible = false;
  final bool _currentPasswordVisible = false;

  bool _isLoading = false;

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alterar senha'),
        backgroundColor: const Color(0xff102733),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: Color(0xff102733)),
          ),
          //const TopCloseButton(),
          SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 16,
                      ),
                      AppCreatePasswordTextFormField(
                        passwordController: currentPasswordController,
                        passwordVisible: _currentPasswordVisible,
                        text: "Sua senha atual",
                      ),
                      const SizedBox(height: 14),
                      AppCreatePasswordTextFormField(
                        passwordController: passwordController,
                        passwordVisible: _passwordVisible,
                        text: "Sua nova senha",
                        showPasswordStrength: true,
                      ),
                      const SizedBox(height: 14),
                      AppCreatePasswordTextFormField(
                        passwordController: repeatPasswordController,
                        passwordVisible: _repeatPasswordVisible,
                        text: "Confirme sua nova senha",
                        showPasswordStrength: true,
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        isLoading: _isLoading,
                        text: "Alterar senha",
                        color: Colors.blue,
                        onPressed: () async {
                          _updatePassword();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePassword() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String currentPassword = currentPasswordController.text;
      String password = passwordController.text;
      String repeatPassword = repeatPasswordController.text;

      if (password != repeatPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          buildErrorSnackBar("As senhas não são iguais"),
        );
        setState(() {
          _isLoading = false;
        });
        return Future.error("As senhas não são iguais");
      }

      final authService = Provider.of<AuthProvider>(context, listen: false);
      SnackBar snackBar;
      authService
          .updatePassword(currentPassword, password)
          .then(
            (value) => {
              snackBar = const AppSnackBar(
                duration: Duration(
                  milliseconds: 2000,
                ),
                title: "Deu certo!",
                message: "Sua senha foi alterada!",
                isSuccess: true,
                elevation: 10.0,
              ).buildSnackBar(),
              ScaffoldMessenger.of(context).showSnackBar(snackBar),
              currentPasswordController.clear(),
              passwordController.clear(),
              repeatPasswordController.clear(),
            },
          )
          .catchError(
              (e) => {
                    if (e.code == 'wrong-password')
                      {
                        snackBar = buildErrorSnackBar(
                          "Senha inválida.",
                        )
                      }
                    else
                      {
                        snackBar = buildErrorSnackBar(
                          "Ocorreu um erro, tente novamente.",
                        )
                      },
                    ScaffoldMessenger.of(context).showSnackBar(snackBar),
                  },
              test: (e) => e is FirebaseAuthException)
          .catchError(
              (e) => {
                    snackBar = buildErrorSnackBar(
                        "Ocorreu um erro atualizar sua senha, tente novamente mais tarde."),
                    ScaffoldMessenger.of(context).showSnackBar(snackBar),
                  },
              test: (e) => e is Exception)
          .whenComplete(() => setState(
                () {
                  _isLoading = false;
                },
              ));

      return Future.value();
    }

    return Future.error("Campos inválidos");
  }
}
