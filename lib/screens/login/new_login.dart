import 'package:eventos_da_rep/exceptions/exceptions.dart';
import 'package:eventos_da_rep/screens/login/create_account.dart';
import 'package:eventos_da_rep/screens/login/forget_password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';

import '../../helpers/internet_helper.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/loader.dart';

class NewLogin extends StatefulWidget {
  const NewLogin({Key? key}) : super(key: key);

  @override
  State<NewLogin> createState() => _NewLoginState();
}

class _NewLoginState extends State<NewLogin> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool _isLoading = false;

  String emailRegex =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

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
                  "Fique por dentro dos eventos da REP mais badalada de Araraquara e região!",
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
                          labelText: 'E-mail',
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white),
                          errorStyle: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                      TextFormField(
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira sua senha.';
                          }
                          return null;
                        },
                        obscureText: !_passwordVisible,
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
                            icon: Icon(_passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            color: Colors.white,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          minimumSize: const Size.fromHeight(50), // NEW
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        onPressed: () =>
                            _isLoading ? null : _validateAndLogin(),
                        child: !_isLoading
                            ? const Text(
                                "Entrar",
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateAccount(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Text(
                        "Não possuí uma conta? ",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Clique aqui",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgetPassword(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Text(
                        "Esqueceu sua senha? ",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "Clique aqui",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
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
                            "Ocorreu um erro ao conectar ao Google, tente novamente mais tarde.");
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
      setState(() {
        _isLoading = true;
      });

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
            () => setState(() {
              _isLoading = false;
            }),
          );
    }
  }
}
