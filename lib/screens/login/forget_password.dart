// ignore_for_file: use_build_context_synchronously

import 'package:eventos_da_rep/widgets/app_button.dart';
import 'package:eventos_da_rep/widgets/app_logo.dart';
import 'package:eventos_da_rep/widgets/app_subtitle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/internet_helper.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_email_text_form_field.dart';
import '../../widgets/app_snack_bar.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      AppEmailTextFormField(
                        emailController: emailController,
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      AppButton(
                        isLoading: isLoading,
                        text: "Redifinir minha senha",
                        color: Colors.blue,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            SnackBar snackBar;
                            await _sendEmail()
                                .then((_) => {
                                      snackBar = const AppSnackBar(
                                        duration: Duration(
                                          milliseconds: 2000,
                                        ),
                                        title: "Deu certo!",
                                        message:
                                            "Enviamos um e-mail para você contendo as instruções para redifinir sua senha",
                                        isSuccess: true,
                                        elevation: 10.0,
                                      ).buildSnackBar(),
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar),
                                    })
                                .onError(
                                  (e, stackTrace) => {
                                    if (e is FirebaseAuthException)
                                      {
                                        if (e.code == 'invalid-email')
                                          {
                                            snackBar = buildErrorSnackBar(
                                              "E-mail inválido.",
                                            ),
                                          }
                                        else if (e.code == 'user-not-found')
                                          {
                                            snackBar = buildErrorSnackBar(
                                              "E-mail não encontrado, você possuí uma conta?",
                                            ),
                                          }
                                        else
                                          {
                                            snackBar = buildErrorSnackBar(
                                                "Ocorreu um erro ao enviar o e-mail, tente novamente mais tarde."),
                                          }
                                      }
                                    else
                                      {
                                        snackBar = buildErrorSnackBar(
                                            "Ocorreu um erro ao enviar o e-mail, tente novamente mais tarde."),
                                      },
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar)
                                  },
                                )
                                .whenComplete(
                                  () => setState(
                                    () {
                                      isLoading = false;
                                    },
                                  ),
                                );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 14,
                ),
                AppBackButton(isLoading: isLoading),
                const SizedBox(
                  height: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmail() async {
    final hasInternet = await checkInternetConnection();

    if (hasInternet) {
      final authService = Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      await authService.sendForgotPasswordEmail(emailController.text);
    } else {
      SnackBar snackBar = buildErrorSnackBar(
          "Sem conexão com a internet, por favor, verifique sua conexão e tente novamente.");

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
