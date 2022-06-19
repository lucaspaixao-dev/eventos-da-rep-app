import 'package:eventos_da_rep/exceptions/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:provider/provider.dart';

import '../../helpers/internet_helper.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_snack_bar.dart';
import 'credentials_login.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                SignInButton(
                  Buttons.GoogleDark,
                  text: "Faça login no Google",
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
                SignInButton(
                  Buttons.Email,
                  text: "Use seu e-mail",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CredentialsLogin(),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 14,
                ),
                const Text(
                  "Para continuar, você precisa ter um convite. Entre em contato com a administração para receber seu convite.",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
