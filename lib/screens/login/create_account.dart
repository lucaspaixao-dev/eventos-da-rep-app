import 'package:eventos_da_rep/widgets/app_back_button.dart';
import 'package:eventos_da_rep/widgets/app_button.dart';
import 'package:eventos_da_rep/widgets/app_logo.dart';
import 'package:eventos_da_rep/widgets/app_subtitle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../exceptions/exceptions.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_create_email_text_form_field.dart';
import '../../widgets/app_create_password_text_form_field.dart';
import '../../widgets/app_name_text_form_field.dart';
import '../../widgets/app_snack_bar.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final bool _passwordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 18,
                ),
                const AppLogo(
                  fontSize: 25,
                ),
                const SizedBox(
                  height: 14,
                ),
                const AppSubtitle(),
                const SizedBox(
                  height: 14,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppNameTextFormField(
                        nameController: nameController,
                      ),
                      AppCreateEmailTextFormField(
                        emailController: emailController,
                      ),
                      AppCreatePasswordTextFormField(
                        passwordController: passwordController,
                        passwordVisible: _passwordVisible,
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      AppButton(
                        isLoading: _isLoading,
                        onPressed: () => _validateAndCreateAccount(),
                        text: "Criar conta",
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 14,
                ),
                AppBackButton(
                  isLoading: _isLoading,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _validateAndCreateAccount() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthProvider>(
        context,
        listen: false,
      );
      setState(() {
        _isLoading = true;
      });

      String email = emailController.text;
      String password = passwordController.text;
      String name = nameController.text;

      SnackBar snackBar;
      await authService
          .emailAndPasswordCreate(name, email, password)
          .then((value) => Navigator.pop(context))
          .catchError(
              (e) => {
                    if (e.code == 'invalid-email')
                      {
                        snackBar = buildErrorSnackBar(
                          "E-mail inválido.",
                        )
                      }
                    else if (e.code == 'weak-password')
                      {
                        snackBar = buildErrorSnackBar(
                          "Senha muito fraca.",
                        )
                      }
                    else if (e.code == 'email-already-in-use')
                      {
                        snackBar = buildErrorSnackBar(
                          "E-mail já cadastrado.",
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
                      e.cause,
                    ),
                    ScaffoldMessenger.of(context).showSnackBar(snackBar),
                  },
              test: (e) => e is ApiException)
          .catchError(
              (e) => {
                    snackBar = buildErrorSnackBar(
                      "Ocorreu um erro ao tentar criar sua conta. Tente novamente mais tarde.",
                    ),
                    ScaffoldMessenger.of(context).showSnackBar(snackBar),
                  },
              test: (e) => e is Exception)
          .whenComplete(
            () => setState(() {
              _isLoading = false;
            }),
          );
    }
  }
}
