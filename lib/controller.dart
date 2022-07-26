import 'package:eventos_da_rep/screens/home/home.dart';
import 'package:eventos_da_rep/screens/login/login.dart';
import 'package:eventos_da_rep/services/firebase_service.dart';
import 'package:flutter/material.dart';

class Controller extends StatelessWidget {
  const Controller({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseService firebaseService = FirebaseService();

    return StreamBuilder(
      stream: firebaseService.getFirebaseAuthInstance().authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          return const Home();
        } else {
          return const Login();
        }
      },
    );
  }
}
