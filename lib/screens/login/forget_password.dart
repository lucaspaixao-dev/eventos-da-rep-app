import 'package:eventos_da_rep/widgets/loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/app_snack_bar.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  String emailRegex =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

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
                Row(
                  children: const <Widget>[
                    Text(
                      "EVENTOS ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "DA REP",
                      style: TextStyle(
                        color: Color(0xffFFA700),
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 14,
                ),
                const Text(
                  "Fique por dentro dos eventos da REP mais badalada da região!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 14,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        validator: (value) {
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
                          labelText: 'Seu e-mail',
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white),
                          errorStyle: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          minimumSize: const Size.fromHeight(50), // NEW
                        ),
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          if (_formKey.currentState!.validate()) {
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
                                );
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                        child: !isLoading
                            ? const Text(
                                "Redifinir minha senha",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : const Loader(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 14,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    minimumSize: const Size.fromHeight(50), // NEW
                  ),
                  onPressed: () => {
                    Navigator.pop(context),
                  },
                  child: const Text(
                    "Voltar",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
    final authService = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    await authService.sendForgotPasswordEmail(emailController.text);
  }
}
