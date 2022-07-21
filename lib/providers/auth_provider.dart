import 'package:eventos_da_rep/http/user_client.dart';
import 'package:eventos_da_rep/models/user.dart' as project;
import 'package:eventos_da_rep/providers/device_provider.dart';
import 'package:eventos_da_rep/providers/shared_preferences_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gravatar/flutter_gravatar.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/device.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseService firebaseService = FirebaseService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserClient _userClient = UserClient();
  final SharedPreferencesProvider _sharedPreferencesProvider =
      SharedPreferencesProvider();

  final DeviceProvider deviceProvider = DeviceProvider();
  final FirebaseMessaging messaging = FirebaseService().getMessaging();

  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  Future<void> googleSignIn() async {
    try {
      final GoogleSignInAccount? user = await _googleSignIn.signIn();

      if (user == null) {
        return;
      }

      final GoogleSignInAuthentication auth = await user.authentication;
      await _createUserOnService(
        user.displayName!,
        user.email,
        user.photoUrl!,
      );

      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      await firebaseService
          .getFirebaseAuthInstance()
          .signInWithCredential(credential);

      await FirebaseMessaging.instance.subscribeToTopic("users-topic");

      notifyListeners();
    } catch (e) {
      await _googleSignIn.disconnect();
      firebaseService.getFirebaseAuthInstance().signOut();

      rethrow;
    }
  }

  Future<void> emailAndPasswordCreate(
    String name,
    String email,
    String password,
  ) async {
    try {
      final gravatar = Gravatar(email);
      String photoUrl = gravatar.imageUrl();

      await _createUserOnService(
        name,
        email,
        photoUrl,
      );

      await _sharedPreferencesProvider.putStringValue(
        prefUserName,
        name,
      );

      await _sharedPreferencesProvider.putStringValue(
        prefUserEmail,
        email,
      );

      await _sharedPreferencesProvider.putStringValue(
        prefUserPhotoUrl,
        photoUrl,
      );

      await firebaseService
          .getFirebaseAuthInstance()
          .createUserWithEmailAndPassword(email: email, password: password);

      String apiToken = await firebaseService.getAuthUser()!.getIdToken();
      await _sharedPreferencesProvider.putStringValue(
        prefApiToken,
        apiToken,
      );

      await firebaseService.getAuthUser()?.sendEmailVerification();

      await FirebaseMessaging.instance.subscribeToTopic("users-topic");
      notifyListeners();
    } catch (e) {
      firebaseService.getFirebaseAuthInstance().signOut();
      rethrow;
    }
  }

  Future<void> emailAndPasswordSignIn(String email, String password) async {
    try {
      await firebaseService
          .getFirebaseAuthInstance()
          .signInWithEmailAndPassword(
            email: email,
            password: password,
          );

      project.User user = await _userClient.findByEmail(email);
      await _sharedPreferencesProvider.putStringValue(
        prefUserId,
        user.id!,
      );
      await _sharedPreferencesProvider.putStringValue(
        prefCloudToken,
        user.device?.token ?? "",
      );

      User? firebaseUser = firebaseService.getAuthUser();
      if (firebaseUser != null) {
        String apiToken = await firebaseUser.getIdToken();
        await _sharedPreferencesProvider.putStringValue(prefApiToken, apiToken);
      }

      await FirebaseMessaging.instance.subscribeToTopic("users-topic");
      notifyListeners();
    } catch (e) {
      firebaseService.getFirebaseAuthInstance().signOut();
      rethrow;
    }
  }

  Future<void> sendForgotPasswordEmail(String email) async {
    await firebaseService
        .getFirebaseAuthInstance()
        .sendPasswordResetEmail(email: email);
  }

  Future<void> logout() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic("users-topic");
    firebaseService.getFirebaseAuthInstance().signOut();

    await _googleSignIn.isSignedIn().then((isSignedIn) {
      if (isSignedIn) {
        _googleSignIn.disconnect();
      }
    });

    notifyListeners();
  }

  Future<void> _createUserOnService(
    String name,
    String email,
    String photo,
  ) async {
    try {
      String? token = await messaging.getToken();
      final Device device = await deviceProvider.getDeviceInfos(token!);

      final newUser = project.User(
        name: name,
        email: email,
        photo: photo,
        device: device,
      );

      final userId = await _userClient.createUser(newUser);
      await _sharedPreferencesProvider.putStringValue(
        prefUserId,
        userId,
      );
      await _sharedPreferencesProvider.putStringValue(
        prefCloudToken,
        token,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    String email = firebaseService.getAuthUser()?.email ?? "";

    if (email.isEmpty) {
      throw Exception("Usuário não está logado");
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await firebaseService
        .getAuthUser()
        ?.reauthenticateWithCredential(credential);

    await firebaseService.getAuthUser()?.updatePassword(newPassword);
  }

  Future<bool> isGoogleAuth() async {
    return await _googleSignIn.isSignedIn();
  }
}
