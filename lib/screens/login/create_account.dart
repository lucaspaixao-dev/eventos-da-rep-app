import 'package:eventos_da_rep/screens/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../exceptions/exceptions.dart';
import '../../providers/auth_provider.dart';
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
                        ),
                        onPressed: () async {
                          _validateAndCreateAccount().then(
                            (value) => Navigator.pop(context),
                          );
                        },
                        child: !_isLoading
                            ? const Text(
                                "Criar conta",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : _getLoader(),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Login(),
                      ),
                    ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _validateAndCreateAccount() async {
    SnackBar? snackBar;

    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      try {
        setState(() {
          _isLoading = true;
        });

        String email = emailController.text;
        String password = passwordController.text;
        String name = nameController.text;

        await authService.emailAndPasswordCreate(
          name,
          email,
          password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-email') {
          snackBar = buildErrorSnackBar(
            "E-mail inválido.",
          );
        } else if (e.code == 'weak-password') {
          snackBar = buildErrorSnackBar(
            "Senha muito fraca.",
          );
        } else if (e.code == 'email-already-in-use') {
          snackBar = buildErrorSnackBar(
            "E-mail já cadastrado.",
          );
        }

        if (snackBar != null) {
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } on ApiException catch (e) {
        snackBar = buildErrorSnackBar(
          e.cause,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } catch (_) {
        snackBar = buildErrorSnackBar(
          "Ocorreu um erro ao tentar criar sua conta. Tente novamente mais tarde.",
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _getLoader() => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 1.5,
        ),
      );
}
