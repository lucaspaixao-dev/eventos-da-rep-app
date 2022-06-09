import 'package:eventos_da_rep/http/user_client.dart';
import 'package:eventos_da_rep/models/user.dart' as project;
import 'package:eventos_da_rep/providers/shared_preferences_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserClient _userClient = UserClient();
  final SharedPreferencesProvider _sharedPreferencesProvider =
      SharedPreferencesProvider();

  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  Future signIn() async {
    try {
      final GoogleSignInAccount? user = await _googleSignIn.signIn();
      if (user == null) {
        return;
      }

      final GoogleSignInAuthentication auth = await user.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      await firebaseAuth.signInWithCredential(credential);

      final newUser = project.User(
        name: FirebaseAuth.instance.currentUser!.displayName!,
        authenticationId: FirebaseAuth.instance.currentUser!.uid,
        email: FirebaseAuth.instance.currentUser!.email!,
        photo: FirebaseAuth.instance.currentUser!.photoURL!,
      );
      final userId = await _userClient.createUser(newUser);
      await _sharedPreferencesProvider.putStringValue(
        'userId',
        userId,
      );
    } catch (e) {
      print(e.toString());
    }

    notifyListeners();
  }

  Future logout() async {
    await _googleSignIn.disconnect();
    firebaseAuth.signOut();

    notifyListeners();
  }

  Future<String>? getUserToken() {
    if (firebaseAuth.currentUser != null) {
      return firebaseAuth.currentUser!.getIdToken();
    }

    return null;
  }
}
