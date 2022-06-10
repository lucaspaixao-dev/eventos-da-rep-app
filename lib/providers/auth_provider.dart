import 'package:eventos_da_rep/http/user_client.dart';
import 'package:eventos_da_rep/models/user.dart' as project;
import 'package:eventos_da_rep/providers/device_provider.dart';
import 'package:eventos_da_rep/providers/shared_preferences_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/device.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserClient _userClient = UserClient();
  final SharedPreferencesProvider _sharedPreferencesProvider =
      SharedPreferencesProvider();

  final DeviceProvider deviceProvider = DeviceProvider();

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

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      final Device device = await deviceProvider.getDeviceInfos(token!);

      final newUser = project.User(
        name: FirebaseAuth.instance.currentUser!.displayName!,
        authenticationId: FirebaseAuth.instance.currentUser!.uid,
        email: FirebaseAuth.instance.currentUser!.email!,
        photo: FirebaseAuth.instance.currentUser!.photoURL!,
        device: device,
      );

      final userId = await _userClient.createUser(newUser);
      await _sharedPreferencesProvider.putStringValue(
        'userId',
        userId,
      );
      await _sharedPreferencesProvider.putStringValue(
        'cloudToken',
        token,
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
