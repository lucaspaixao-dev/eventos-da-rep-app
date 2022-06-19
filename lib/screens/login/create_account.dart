import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../exceptions/exceptions.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/loader.dart';

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
  bool _passwordVisible = false;
  bool _isLoading = false;
  String emailRegex =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

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
                      ),
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
                      ),
                      TextFormField(
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira sua senha.';
                          }

                          if (value.length < 5 || value.length > 30) {
                            return 'Seu e-mail deve ter entre 5 e até 30 caracteres.';
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
                          labelText: 'Sua senha',
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
                            _isLoading ? null : _validateAndCreateAccount(),
                        child: !_isLoading
                            ? const Text(
                                "Criar conta",
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onPressed: () => _isLoading ? null : Navigator.pop(context),
                  child: const Text(
                    "Voltar",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
