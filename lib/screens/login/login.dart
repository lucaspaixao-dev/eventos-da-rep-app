import 'package:eventos_da_rep/exceptions/exceptions.dart';
import 'package:eventos_da_rep/screens/login/create_account.dart';
import 'package:eventos_da_rep/screens/login/forget_password.dart';
import 'package:eventos_da_rep/widgets/app_subtitle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';

import '../../helpers/internet_helper.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_email_text_form_field.dart';
import '../../widgets/app_link.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_password_text_form_field.dart';
import '../../widgets/app_snack_bar.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final bool _passwordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    FlutterNativeSplash.remove();
    checkInternetConnection().then(
      (value) {
        if (!value) {
          SnackBar snackBar = buildErrorSnackBar(
              "Sem conexão com a internet, por favor, verifique sua conexão e tente novamente.");

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
    );
    super.initState();
  }

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
                      AppEmailTextFormField(
                        emailController: emailController,
                      ),
                      AppPasswordTextFormField(
                        passwordController: passwordController,
                        passwordVisible: _passwordVisible,
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      AppButton(
                        text: "Entrar",
                        isLoading: _isLoading,
                        onPressed: () => _validateAndLogin(),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 14,
                ),
                const AppLink(
                  to: CreateAccount(),
                  firstText: "Não possuí uma conta? ",
                  secondText: "Clique aqui",
                ),
                const SizedBox(
                  height: 12,
                ),
                const AppLink(
                  to: ForgetPassword(),
                  firstText: "Esqueceu sua senha? ",
                  secondText: "Clique aqui",
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: const [
                      Expanded(
                        child: Divider(
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 8, left: 8),
                        child: Text(
                          "OU",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 10),
                  child: SignInButton(
                    text: "Entrar com Google",
                    mini: false,
                    Buttons.GoogleDark,
                    onPressed: () async {
                      try {
                        final authService =
                            Provider.of<AuthProvider>(context, listen: false);
                        await authService.googleSignIn();
                      } on ApiException catch (e) {
                        SnackBar snackBar = buildErrorSnackBar(e.cause);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } on Exception catch (_) {
                        SnackBar snackBar = buildErrorSnackBar(
                          "Ocorreu um erro ao conectar ao Google, tente novamente mais tarde.",
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _validateAndLogin() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthProvider>(
        context,
        listen: false,
      );
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      String email = emailController.text;
      String password = passwordController.text;

      SnackBar snackBar;
      await authService
          .emailAndPasswordSignIn(
            email,
            password,
          )
          .then((value) => Navigator.pop(context))
          .catchError(
              (e) => {
                    if (e.code == 'invalid-email')
                      {
                        snackBar = buildErrorSnackBar(
                          "E-mail inválido.",
                        )
                      }
                    else if (e.code == 'user-disabled')
                      {
                        snackBar = buildErrorSnackBar(
                          "Usuário desativado.",
                        )
                      }
                    else if (e.code == 'user-not-found')
                      {
                        snackBar = buildErrorSnackBar(
                          "Usuário não encontrado.",
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
            () => {
              if (mounted)
                {
                  setState(() {
                    _isLoading = false;
                  })
                }
            },
          );
    }
  }
}
